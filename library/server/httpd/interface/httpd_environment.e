note
	description: "[
			Server environment of the httpd request
			
			You can create your own descendant of this class to
			add/remove specific value or processing
			
			This object is created by {HTTPD_APPLICATION}.new_environment
		]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_ENVIRONMENT

create {HTTPD_APPLICATION}
	make

feature {NONE} -- Initialization

	make (a_vars: HASH_TABLE [STRING, STRING]; a_input: HTTPD_SERVER_INPUT; a_output: HTTPD_SERVER_OUTPUT)
			-- Initialize Current with variable `a_vars' and `a_input'
		do
			input := a_input
			output := a_output
			create request_uri.make_empty
			create request_method.make_empty
			create path_info.make_empty

			content_type := default_content_type
			create execution_variables.make (10)
			create environment_variables.make_with_variables (a_vars)
			create uploaded_files.make (0)
			create error_handler.make

			initialize
			analyze
		end

	initialize
			-- Specific initialization
		local
			dtu: HTTP_DATE_TIME_UTILITIES
			p: INTEGER
		do
			create dtu
				--| do not use `force', to avoid overwriting existing variable
			if attached environment_variables.request_uri as rq_uri then
				p := rq_uri.index_of ('?', 1)
				if p > 0 then
					environment_variables.add_variable (rq_uri.substring (1, p-1), "CURRENT_SELF")
				else
					environment_variables.add_variable (rq_uri, "CURRENT_SELF")
				end
			end
			environment_variables.add_variable (dtu.unix_time_stamp (Void).out, "REQUEST_TIME")
		end

feature -- Access: Input/Output

	output: HTTPD_SERVER_OUTPUT
			-- Server output channel

	input: HTTPD_SERVER_INPUT
			-- Server input channel

feature -- Error handling

	has_error: BOOLEAN
		do
			Result := error_handler.has_error
		end

	error_handler: ERROR_HANDLER
			-- Error handler
			-- By default initialized to new handler			

feature -- Recycle

	recycle
			-- Clean structure
		local
			l_files: like uploaded_files
		do
			l_files := uploaded_files
			if not l_files.is_empty then
				from
					l_files.start
				until
					l_files.after
				loop
					if
						attached l_files.item_for_iteration.tmp_name as l_tmp_name and then
						not l_tmp_name.is_empty
					then
						delete_uploaded_file (l_tmp_name)
					end
					l_files.forth
				end
			end
		end

feature -- Basic operation

	analyze
			-- Analyze environment, and set various attributes
		do
			extract_variables
		end

feature -- Element change: Error handling

	set_error_handler (ehdl: like error_handler)
			-- Set `error_handler' to `ehdl'
		do
			error_handler := ehdl
		end

feature -- Access: global variable

	variables: HASH_TABLE [STRING_GENERAL, STRING_GENERAL]
		local
			vars: HASH_TABLE [STRING_GENERAL, STRING_GENERAL]
		do
			create Result.make (100)

			vars := execution_variables
			from
				vars.start
			until
				vars.after
			loop
				Result.put (vars.item_for_iteration, vars.key_for_iteration)
				vars.forth
			end

			vars := environment_variables
			from
				vars.start
			until
				vars.after
			loop
				Result.put (vars.item_for_iteration, vars.key_for_iteration)
				vars.forth
			end

			vars := variables_get.variables
			from
				vars.start
			until
				vars.after
			loop
				Result.put (vars.item_for_iteration, vars.key_for_iteration)
				vars.forth
			end

			vars := variables_post.variables
			from
				vars.start
			until
				vars.after
			loop
				Result.put (vars.item_for_iteration, vars.key_for_iteration)
				vars.forth
			end

			vars := cookies_variables
			from
				vars.start
			until
				vars.after
			loop
				Result.put (vars.item_for_iteration, vars.key_for_iteration)
				vars.forth
			end
		end

	variable (n: STRING_GENERAL): detachable STRING_GENERAL
		local
			n8: STRING_8
		do
			n8 := n.as_string_8
			Result := execution_variable (n8)
			if Result = Void then
				Result := environment_variable (n8)
				if Result = Void then
					Result := variables_get.variable (n8)
					if Result = Void then
						Result := variables_post.variable (n8)
						if Result = Void then
							Result := cookies_variables.item (n8)
						end
					end
				end
			end
		end

	request_variable (n: STRING_GENERAL): detachable STRING_32
			-- Variable from GET or POST
		local
			n8: STRING_8
		do
			n8 := n.as_string_8
			Result := variables_get.variable (n8)
			if Result = Void then
				Result := variables_post.variable (n8)
			end
		end

feature -- Access: variable		

	environment_variables: HTTPD_ENVIRONMENT_VARIABLES
			-- Environment variables

	environment_variable (a_name: STRING): detachable STRING
			-- Environment variable related to `a_name'
		require
			a_name_valid: a_name /= Void and then not a_name.is_empty
		do
			Result := environment_variables.item (a_name)
		end

	execution_variables: HASH_TABLE [STRING, STRING]
			-- Execution variables set by the application

	execution_variable (a_name: STRING): detachable STRING
			-- Execution variable related to `a_name'
		require
			a_name_valid: a_name /= Void and then not a_name.is_empty
		do
			Result := execution_variables.item (a_name)
		end

feature -- Query

	script_absolute_url (a_path: STRING): STRING
			-- Absolute Url
		do
			Result := script_url (a_path)
			if attached http_host as h then
				Result.prepend (h)
			else
				--| Issue ??
			end
		end

	script_url (a_path: STRING): STRING
			-- Url relative to script name if any
		local
			l_base_url: like script_url_base
			i,m,n: INTEGER
			l_rq_uri: like request_uri
		do
			l_base_url := script_url_base
			if l_base_url = Void then
				if attached environment_variables.script_name as l_script_name then
					l_rq_uri := request_uri
					if l_rq_uri.starts_with (l_script_name) then
						l_base_url := l_script_name
					else
						--| Handle Rewrite url engine, to have clean path
						from
							i := 1
							m := l_rq_uri.count
							n := l_script_name.count
						until
							i > m or i > n or l_rq_uri[i] /= l_script_name[i]
						loop
							i := i + 1
						end
						if i > 1 then
							if l_rq_uri[i-1] = '/' then
								i := i -1
							end
							l_base_url := l_rq_uri.substring (1, i - 1)
						end
					end
				end
				if l_base_url = Void then
					create l_base_url.make_empty
				end
				script_url_base := l_base_url
			end
			Result := l_base_url + a_path
		end

	script_url_base: detachable STRING

feature -- Access

	request_uri: STRING
			-- URI given in order to access this page; for instance, '/index.html'.

	request_method: STRING
			-- request method used to access the page
			-- i.e. 'GET', 'HEAD', 'POST', 'PUT', 'DELETE'.

	query_string: detachable STRING
			-- query string, if any, via which the page was accessed.

	path_info: STRING
			-- Contains any client-provided pathname information
			-- trailing the actual script filename but preceding the query string, if available.
			--| For instance, if the current script was accessed via the URL
			--| http://www.example.com/eiffel/path_info.exe/some/stuff?foo=bar, then $_SERVER['PATH_INFO'] would contain /some/stuff.
			--|
			--| Note that is the PATH_INFO variable does not exists, the `path_info' value will be empty

	orig_path_info: detachable STRING
    		-- Original version of `path_info' before processed by Current environment
    	do
    		Result := environment_variables.orig_path_info
    	end

	content_length: INTEGER
	content_type: STRING
	default_content_type: STRING = "text/plain"

	http_user_agent: detachable STRING
			-- Contents of the User-Agent: header from the current request, if there is one.
			-- This is a string denoting the user agent being which is accessing the page.
			-- A typical example is: Mozilla/4.5 [en] (X11; U; Linux 2.2.9 i586).

	http_host: detachable STRING
			-- Contents of the Host: header from the current request, if there is one.

feature -- Authorization

	http_authorization: detachable STRING
			-- Base64-encoded authorization info

	http_authorization_login_password: detachable TUPLE [login: STRING; password: STRING]
			-- Login/password extracted from http_authorization
		local
			p: INTEGER
			s: detachable STRING
		do
			s := http_authorization
			if s /= Void and then not s.is_empty then
				p := 1
				if s[p] = ' ' then
					p := p + 1
				end
				p := s.index_of (' ', p)
				if p > 0 then
					s := (create {BASE64}).decoded_string (s.substring (p + 1, s.count))
					p := s.index_of (':', 1) --| Let's assume ':' is forbidden in login ...
					if p > 0 then
						Result := [s.substring (1, p - 1), s.substring (p + 1, s.count)]
					end
				end
			end
		end

feature -- Queries

	variables_GET: HTTPD_REQUEST_VARIABLES
			-- Variables from url
		local
			vars: like internal_variables_GET
			p,e: INTEGER
			rq_uri: like request_uri
			s: detachable STRING
		do
			vars := internal_variables_GET
			if vars = Void then
				s := query_string
				if s = Void then
					rq_uri := request_uri
					p := rq_uri.index_of ('?', 1)
					if p > 0 then
						e := rq_uri.index_of ('#', p + 1)
						if e = 0 then
							e := rq_uri.count
						else
							e := e - 1
						end
						s := rq_uri.substring (p+1, e)
					end
				end
				if s /= Void and then not s.is_empty then
					create vars.make_from_urlencoded (s, True)
				else
					create vars.make (0)
				end
				internal_variables_GET := vars
			end
			Result := vars
		end

	variables_POST: HTTPD_REQUEST_VARIABLES
			-- Variables sent by POST request
		local
			vars: like internal_variables_POST
			s: STRING
			n: INTEGER
			l_type: detachable STRING
		do
			vars := internal_variables_POST
			if vars = Void then
				n := content_length
				if n > 0 then
					l_type := content_type
					if
						l_type.starts_with ({HTTP_CONSTANTS}.multipart_form)
					then
						create vars.make (5)
						--| FIXME: optimization ... fetch the input data progressively, otherwise we might run out of memory ...
						s := form_input_data (n)
						analyze_multipart_form (l_type, s, vars)
					else
						s := form_input_data (n)
						create vars.make_from_urlencoded (s, True)
					end
--					vars.force ("<pre>"+s+"</pre>", "_")
				else
					create vars.make (0)
				end
				internal_variables_POST := vars
			end
			Result := vars
		end

	uploaded_files: HASH_TABLE [TUPLE [name: STRING; type: STRING; tmp_name: STRING; tmp_basename: STRING; error: INTEGER; size: INTEGER], STRING]
			-- Table of uploaded files information
			--| name: original path from the user
			--| type: content type
			--| tmp_name: path to temp file that resides on server
			--| tmp_base_name: basename of `tmp_name'
			--| error: if /= 0 , there was an error : TODO ...
			--| size: size of the file given by the http request

	cookies_variables: HASH_TABLE [STRING, STRING]
			-- Expanded cookies variable
		local
			l_cookies: like cookies
		do
			l_cookies := cookies
			create Result.make (l_cookies.count)
			from
				l_cookies.start
			until
				l_cookies.after
			loop
				if attached l_cookies.item_for_iteration.variables as vars then
					from
						vars.start
					until
						vars.after
					loop
						Result.force (vars.item_for_iteration, vars.key_for_iteration)
						vars.forth
					end
				else
					check same_name: l_cookies.key_for_iteration.same_string (l_cookies.item_for_iteration.name) end
					Result.force (l_cookies.item_for_iteration.value, l_cookies.key_for_iteration)
				end
				l_cookies.forth
			end
		end

	cookies: HASH_TABLE [HTTPD_COOKIE, STRING]
			-- Cookies Information
		local
			i,j,p,n: INTEGER
			l_cookies: like internal_cookies
			k,v: STRING
		do
			l_cookies := internal_cookies
			if l_cookies = Void then
				if attached environment_variable ({HTTPD_ENVIRONMENT_NAMES}.http_cookie) as s then
					create l_cookies.make (5)
					from
						n := s.count
						p := 1
						i := 1
					until
						p < 1
					loop
						i := s.index_of ('=', p)
						if i > 0 then
							j := s.index_of (';', i)
							if j = 0 then
								j := n + 1
								k := s.substring (p, i - 1)
								v := s.substring (i + 1, n)

								p := 0 -- force termination
							else
								k := s.substring (p, i - 1)
								v := s.substring (i + 1, j - 1)
								p := j + 1
							end
							l_cookies.put (create {HTTPD_COOKIE}.make (k,v), k)
						end
					end
				else
					create l_cookies.make (0)
				end
				internal_cookies := l_cookies
			end
			Result := l_cookies
		end

feature -- Uploaded File Handling

	move_uploaded_file (a_filename: STRING; a_destination: STRING): BOOLEAN
			-- Move uploaded file `a_filename' to `a_destination'
			--| if this is not an uploaded file, do not move it.
		require
			a_filename_valid: a_filename /= Void and then not a_filename.is_empty
			a_destination_valid: a_destination /= Void and then not a_destination.is_empty
		local
			f: RAW_FILE
		do
			if is_uploaded_file (a_filename) then
				create f.make (a_filename)
				if f.exists then
					f.change_name (a_destination)
					Result := True
				end
			end
		end

	is_uploaded_file (a_filename: STRING): BOOLEAN
			-- Is `a_filename' a file uploaded via HTTP POST
		local
			l_files: like uploaded_files
		do
			l_files := uploaded_files
			if not l_files.is_empty then
				from
					l_files.start
				until
					l_files.after or Result
				loop
					if l_files.item_for_iteration.tmp_name.same_string (a_filename) then
						Result := True
					end
					l_files.forth
				end
			end
		end

feature {NONE} -- Temporary File handling		

	delete_uploaded_file (a_filename: STRING)
			-- Delete file `a_filename'
		require
			a_filename_valid: a_filename /= Void and then not a_filename.is_empty
		local
			f: RAW_FILE
		do
			if is_uploaded_file (a_filename) then
				create f.make (a_filename)
				if f.exists and then f.is_writable then
					f.delete
				else
					error_handler.add_custom_error (0, "Can not delete file", "Can not delete file %""+ a_filename +"%"")
				end
			else
				error_handler.add_custom_error (0, "Not uploaded file", "This file %""+ a_filename +"%" is not an uploaded file.")
			end
		end

	save_uploaded_file (a_content: STRING; a_filename: STRING): detachable TUPLE [name: STRING; basename: STRING]
			-- Save uploaded file content to `a_filename'
		local
			bn: STRING
			l_safe_name: STRING
			f: RAW_FILE
			dn: STRING
			fn: FILE_NAME
			d: DIRECTORY
			n: INTEGER
			rescued: BOOLEAN
		do
			if not rescued then
				dn := (create {EXECUTION_ENVIRONMENT}).current_working_directory
				create d.make (dn)
				if d.exists and then d.is_writable then
					l_safe_name := safe_filename (a_filename)
					from
						create fn.make_from_string (dn)
						bn := "tmp-" + l_safe_name
						fn.set_file_name (bn)
						create f.make (fn.string)
						n := 0
					until
						not f.exists
						or else n > 1_000
					loop
						n := n + 1
						fn.make_from_string (dn)
						bn := "tmp-" + n.out + "-" + l_safe_name
						fn.set_file_name (bn)
						f.make (fn.string)
					end

					if not f.exists or else f.is_writable then
						f.open_write
						f.put_string (a_content)
						f.close
						Result := [f.name, bn]
					else
						Result := Void
					end
				else
					error_handler.add_custom_error (0, "Directory not writable", "Can not create file in directory %""+ dn +"%"")
				end
			else
				Result := Void
			end
		rescue
			rescued := True
			retry
		end

	safe_filename (fn: STRING): STRING
		local
			c: CHARACTER
			i, n, p: INTEGER
			l_accentued, l_non_accentued: STRING
		do
			l_accentued := "ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðòóôõöùúûüýÿ"
			l_non_accentued := "AAAAAACEEEEIIIIOOOOOUUUUYaaaaaaceeeeiiiioooooouuuuyy"

				--| Compute safe filename, to avoid creating impossible filename, or dangerous one
			from
				i := 1
				n := fn.count
				create Result.make (n)
			until
				i > n
			loop
				c := fn[i]
				inspect c
				when '.', '-', '_' then
					Result.extend (c)
				when 'A' .. 'Z', 'a' .. 'z', '0' .. '9' then
					Result.extend (c)
				else
					p := l_accentued.index_of (c, 1)
					if p > 0 then
						Result.extend (l_non_accentued[p])
					else
						Result.extend ('-')
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation: Form analyzer

	analyze_multipart_form (t: STRING; s: STRING; vars: like variables_post)
		require
			t_attached: t /= Void
			s_attached: s /= Void
			vars_attached: vars /= Void
		local
			p,i,next_b: INTEGER
			l_boundary_prefix: STRING
			l_boundary: STRING
			l_boundary_len: INTEGER
			m: STRING
			is_crlf: BOOLEAN
		do
			p := t.substring_index ("boundary=", 1)
			if p > 0 then
				l_boundary := t.substring (p + 9, t.count)
				p := s.substring_index (l_boundary, 1)
				if p > 1 then
					l_boundary_prefix := s.substring (1, p - 1)
					l_boundary := l_boundary_prefix + l_boundary
				else
					create l_boundary_prefix.make_empty
				end
				l_boundary_len := l_boundary.count
					--| Let's support either %R%N and %N ... 
					--| Since both cases might occurs (for instance, our implementation of CGI does not have %R%N)
					--| then let's be as flexible as possible on this.
				is_crlf := s[l_boundary_len + 1] = '%R'
				from
					i := 1 + l_boundary_len + 1
					if is_crlf then
						i := i + 1 --| +1 = CR = %R
					end
					next_b := i
				until
					i = 0
				loop
					next_b := s.substring_index (l_boundary, i)
					if next_b > 0 then
						if is_crlf then
							m := s.substring (i, next_b - 1 - 2) --| 2 = CR LF = %R %N							
						else
							m := s.substring (i, next_b - 1 - 1) --| 1 = LF = %N														
						end
						analyze_multipart_form_input (m, vars)
						i := next_b + l_boundary_len + 1
						if is_crlf then
							i := i + 1 --| +1 = CR = %R
						end
					else
						if is_crlf then
							i := i + 1
						end
						m := s.substring (i - 1, s.count)
						m.right_adjust
						if not l_boundary_prefix.same_string (m) then
							error_handler.add_custom_error (0, "Invalid form data", "Invalid ending for form data from input")
						end
						i := next_b
					end
				end
			end
		end

	analyze_multipart_form_input (s: STRING; vars_post: like variables_post)
			-- Analyze multipart entry
		require
			s_not_empty: s /= Void and then not s.is_empty
		local
			n, i,p, b,e: INTEGER
			l_name, l_filename, l_content_type: detachable STRING
			l_header: detachable STRING
			l_content: detachable STRING
			l_line: detachable STRING
		do
			from
				p := 1
				n := s.count
			until
				p > n or l_header /= Void
			loop
				inspect s[p]
				when '%R' then -- CR
					if
						n >= p + 3 and then
						s[p+1] = '%N' and then -- LF
						s[p+2] = '%R' and then -- CR
						s[p+3] = '%N'		   -- LF
					then
						l_header := s.substring (1, p + 1)
						l_content := s.substring (p + 4, n)
					end
				when '%N' then
					if
						n >= p + 1 and then
						s[p+1] = '%N'
					then
						l_header := s.substring (1, p)
						l_content := s.substring (p + 2, n)
					end
				else
				end
				p := p + 1
			end
			if l_header /= Void and l_content /= Void then
				from
					i := 1
					n := l_header.count
				until
					i = 0 or i > n
				loop
					l_line := Void
					b := i
					p := l_header.index_of ('%N', b)
					if p > 0 then
						if l_header[p - 1] = '%R' then
							p := p - 1
							i := p + 2
						else
							i := p + 1
						end
					end
					if p > 0 then
						l_line := l_header.substring (b, p - 1)
						if l_line.starts_with ("Content-Disposition: form-data") then
							p := l_line.substring_index ("name=", 1)
							if p > 0 then
								p := p + 4 --| 4 = ("name=").count - 1
								if l_line.valid_index (p+1) and then l_line[p+1] = '%"' then
									p := p + 1
									e := l_line.index_of ('"', p + 1)
								else
									e := l_line.index_of (';', p + 1)
									if e = 0 then
										e := l_line.count
									end
								end
								l_name := l_header.substring (p + 1, e - 1)
							end

							p := l_line.substring_index ("filename=", 1)
							if p > 0 then
								p := p + 8 --| 8 = ("filename=").count - 1
								if l_line.valid_index (p+1) and then l_line[p+1] = '%"' then
									p := p + 1
									e := l_line.index_of ('"', p + 1)
								else
									e := l_line.index_of (';', p + 1)
									if e = 0 then
										e := l_line.count
									end
								end
								l_filename := l_header.substring (p + 1, e - 1)
							end
						elseif l_line.starts_with ("Content-Type: ") then
							l_content_type := l_line.substring (15, l_line.count)
						end
					else
						i := 0
					end
				end
				if l_name /= Void then
					if l_filename /= Void then
						if l_content_type = Void then
							l_content_type := default_content_type
						end
						if attached save_uploaded_file (l_content, l_filename) as l_saved_fn_info then
							uploaded_files.force ([l_filename, l_content_type, l_saved_fn_info.name, l_saved_fn_info.basename, 0, l_content.count], l_name)
						else
							uploaded_files.force ([l_filename, l_content_type, "", "", -1, l_content.count], l_name)
						end
					else
						vars_post.add_variable (l_content, l_name)
					end
				else
					error_handler.add_custom_error (0, "unamed multipart entry", Void)
				end
			else
				error_handler.add_custom_error (0, "missformed multipart entry", Void)
			end
		end

feature {NONE} -- Internal value

	form_input_data (nb: INTEGER): STRING
			-- data from input form
		local
			n: INTEGER
			t: STRING
		do
			from
				n := nb
				create Result.make (n)
				if n > 1_024 then
					n := 1_024
				end
			until
				n <= 0
			loop
				read_input (n)
				t := last_input_string
				Result.append_string (t)
				if t.count < n then
					n := 0
				end
				n := nb - t.count
			end
		end

	internal_variables_GET: detachable like variables_GET
			-- cached value for `variables_GET'

	internal_variables_POST: detachable like variables_POST
			-- cached value for `variables_POST'

	internal_cookies: detachable like cookies
			-- cached value for `cookies'

feature {NONE} -- I/O: implementation

	read_input (nb: INTEGER)
			-- Read `nb' bytes from `input'
		do
			input.read_stream (nb)
		end

	last_input_string: STRING
			-- Last string read from `input'
		do
			Result := input.last_string
		end

feature -- Element change

	set_http_host (s: detachable STRING)
		do
			http_host := s
			-- analyze_http_host
		end

	set_content_type (t: STRING)
		do
			content_type := t
		end

	set_content_length (n: INTEGER)
		do
			content_length := n
		end

	set_query_string (s: detachable STRING)
		do
			query_string := s
		end

	set_path_info (s: detachable STRING)
		local
			l_path_info: STRING
		do
			--| Warning
			--| on IIS: we might have   PATH_INFO = /sample.exe/foo/bar
			--| on apache:				PATH_INFO = /foo/bar
			--| So, we might need to check with SCRIPT_NAME and remove it on IIS
			--| store original PATH_INFO in ORIG_PATH_INFO
			if s /= Void and then not s.is_empty then
				environment_variables.replace_variable (s, {HTTPD_ENVIRONMENT_NAMES}.orig_path_info)
				path_info := s
				if attached environment_variables.script_name as l_script_name then
					if s.starts_with (l_script_name) then
						l_path_info := s.substring (l_script_name.count + 1 , s.count)
						environment_variables.replace_variable (l_path_info, {HTTPD_ENVIRONMENT_NAMES}.path_info)
						path_info := l_path_info
					end
				end
			else
				environment_variables.delete_variable ({HTTPD_ENVIRONMENT_NAMES}.orig_path_info)
				path_info := ""
			end
		end

feature {NONE} -- Implementation

	report_bad_request_error (a_message: detachable STRING)
			-- Report error
		local
			e: HTTPD_ERROR
		do
			create e.make ({HTTP_STATUS_CODE}.bad_request)
			if a_message /= Void then
				e.set_message (a_message)
			end
			error_handler.add_error (e)
		end

	extract_variables
			-- Extract relevant environment variables
		local
			s: detachable STRING
		do
			s := environment_variables.request_uri
			if s /= Void and then not s.is_empty then
				request_uri := s
			else
				report_bad_request_error ("Missing URI")
			end
			if not has_error then
				s := environment_variables.request_method
				if s /= Void and then not s.is_empty then
					request_method := s
				else
					report_bad_request_error ("Missing request method")
				end
			end
			if not has_error then
				http_user_agent := environment_variables.http_user_agent
				http_authorization := environment_variables.http_authorization
--				analyze_authorization
			end
			if not has_error then
				if attached environment_variables.http_host as l_host and then not l_host.is_empty then
					set_http_host (l_host)
				else
					report_bad_request_error ("Missing host header")
				end
			end
			if not has_error then
				set_query_string (environment_variables.query_string)
				s := environment_variables.content_type
				if s /= Void and then not s.is_empty then
					set_content_type (s)
				end
				s := environment_variable ({HTTPD_ENVIRONMENT_NAMES}.content_length)
				if s /= Void and then s.is_integer then
					set_content_length (s.to_integer)
				end
				set_path_info (environment_variable ({HTTPD_ENVIRONMENT_NAMES}.path_info))
			end
		end

invariant

	request_uri_attached: request_uri /= Void
	request_method_attached: request_method /= Void
	path_info_attached: path_info /= Void
	content_type_attached: content_type /= Void

note
	copyright: "Copyright (c) 1984-2011, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
