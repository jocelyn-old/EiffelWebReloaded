note
	description: "Summary description for {HTTPD_ENVIRONMENT}."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make (a_vars: like execution_variables; a_input: HTTPD_SERVER_INPUT)
			-- Initialize Current with variable `a_vars' and `a_input'
		do
			input := a_input
			create request_uri.make_empty
			create request_method.make_empty
			content_type := default_content_type
			execution_variables := a_vars
			create error_handler.make
			analyze
		end

feature -- Recycle

	recycle
			-- Clean structure
		do
			if attached uploaded_files as l_files then
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
			if not has_error then
				validate_http_cookie
			end
		end

feature -- Error handling

	has_error: BOOLEAN
		do
			Result := error_handler.has_error
		end

	error_handler: ERROR_HANDLER
			-- Error handler
			-- By default initialized to new handler

feature -- Element change: Error handling

	set_error_handler (ehdl: like error_handler)
			-- Set `error_handler' to `ehdl'
		do
			error_handler := ehdl
		end

feature -- Access: variable

	execution_variables: HASH_TABLE [STRING, STRING]
			-- Execution environment

	execution_variable (a_name: STRING): detachable STRING
			-- Execution environment variable related to `a_name'
		require
			a_name_valid: a_name /= Void and then not a_name.is_empty
		do
			Result := execution_variables.item (a_name)
		end

feature -- Access

	request_uri: STRING

	request_method: STRING
			-- request method used to access the page
			-- i.e. 'GET', 'HEAD', 'POST', 'PUT', 'DELETE'.

	query_string: detachable STRING
			-- query string, if any, via which the page was accessed.

	path_info: detachable STRING
			-- Contains any client-provided pathname information
			-- trailing the actual script filename but preceding the query string, if available.
			--| For instance, if the current script was accessed via the URL
			--| http://www.example.com/eiffel/path_info.exe/some/stuff?foo=bar, then $_SERVER['PATH_INFO'] would contain /some/stuff.

	orig_path_info: detachable STRING
    		-- Original version of `path_info' before processed by Current environment

	path_translated: detachable STRING
			-- Filesystem- (not document root-) based path to the current script,
			-- after the server has done any virtual-to-real mapping.

	content_length: INTEGER
	content_type: STRING
	default_content_type: STRING = "text/plain"

	http_user_agent: detachable STRING
			-- Contents of the User-Agent: header from the current request, if there is one.
			-- This is a string denoting the user agent being which is accessing the page.
			-- A typical example is: Mozilla/4.5 [en] (X11; U; Linux 2.2.9 i586).

	http_host: detachable STRING
			-- Contents of the Host: header from the current request, if there is one.

	http_authorization: detachable STRING

	http_cookie: detachable STRING
			-- Raw value of the 'Cookie' header sent by the user agent.

feature -- Not request-specific environment variables

	gateway_interface: detachable STRING
			-- Revision of the CGI specification to which this server complies.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.gateway_interface)
		end

	server_name: detachable STRING
			-- Server's hostname, DNS alias, or IP address.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.server_name)
		end

	server_software: detachable STRING
			-- Name and version of information server answering the request.
		once
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.server_software)
		end

feature -- Request specific environment variables

	auth_type: detachable STRING
			-- Protocol-specific authentication method used to validate user.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.auth_type)
		end

	remote_host: detachable STRING
			-- Hostname making the request.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.remote_host)
		end

	remote_addr: detachable STRING
			-- IP address of the remote host making the request.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.remote_addr)
		end

	remote_ident: detachable STRING
			-- User name retrieved from server if RFC 931 supported.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.remote_ident)
		end

	remote_user: detachable STRING
			-- Username, if applicable.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.remote_user)
		end

	script_name: detachable STRING
			-- Virtual path to the script being executed.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.script_name)
		end

	server_port: detachable STRING
			-- Port number to which request was sent.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.server_port)
		end

	server_protocol: detachable STRING
			-- Name and revision of information protocol of this request.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.server_protocol)
		end

feature -- Headerline based environment variables

	http_accept: detachable STRING
			-- MIME types which the client will accept.
		do
			Result := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.http_accept)
		end

feature -- Queries

	variables_GET: like explode_to_variables
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
						create vars.make (3)
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
					vars := explode_to_variables (s, True)
				else
					create vars.make (0)
				end
				internal_variables_GET := vars
			end
			Result := vars
		end

	variables_POST: like explode_to_variables
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
						create vars.make (1)
						--| FIXME: optimization ... fetch the input data progressively, otherwise we might run out of memory ...
						s := form_input_data (n)

						analyze_multipart_form (l_type, s, vars)
					else
						s := form_input_data (n)
						vars := explode_to_variables (s, True)
					end
--					vars.force ("<pre>"+s+"</pre>", "_")
				else
					create vars.make (0)
				end
				internal_variables_POST := vars
			end
			Result := vars
		end

	uploaded_files: detachable HASH_TABLE [TUPLE [name: STRING; type: STRING; tmp_name: STRING; error: INTEGER; size: INTEGER], STRING]

	cookies: HASH_TABLE [STRING, STRING]
			-- Cookie Information relative to data.
		local
			i,j,p,n: INTEGER
			s: STRING
		do
			if attached http_cookie as l_cookies then
				create Result.make (10)
				s := l_cookies
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
							Result.put (s.substring (i + 1, n), s.substring (p, i - 1))
							p := 0 -- force termination
						else
							Result.put (s.substring (i + 1, j - 1), s.substring (p, i - 1))
							p := j + 1
						end
					end
				end
			else
				create Result.make (0)
			end
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
		do
			if attached uploaded_files as l_files then
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

	save_uploaded_file (a_content: STRING; a_filename: STRING): detachable STRING
			-- Save uploaded file content to `a_filename'
		local
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
					from
						create fn.make_from_string (dn)
						fn.set_file_name ("tmp-" + a_filename)
						create f.make (fn.string)
						n := 0
					until
						not f.exists
						or else n > 1_000
					loop
						n := n + 1
						fn.make_from_string (dn)
						fn.set_file_name ("tmp-" + n.out + "-" + a_filename)
						f.make (fn.string)
					end

					if not f.exists or else f.is_writable then
						f.open_write
						f.put_string (a_content)
						f.close
						Result := f.name
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

				from
					i := 1 + l_boundary_len + 2
					next_b := i
				until
					i = 0
				loop
					next_b := s.substring_index (l_boundary, i)
					if next_b > 0 then
						m := s.substring (i, next_b - 1 - 2) --| 2 = CR LF = %R %N
						analyze_multipart_form_input (m, vars)
						i := next_b + l_boundary_len + 2
					else
						if not l_boundary_prefix.same_string (s.substring (i, s.count)) then
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
			l_files: like uploaded_files
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
								if l_line[p+1] = '%"' then
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
								if l_line[p+1] = '%"' then
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
						l_files := uploaded_files
						if l_files = Void then
							create l_files.make (1)
							uploaded_files := l_files
						end
						if attached save_uploaded_file (l_content, l_filename) as l_saved_fn then
							vars_post.force (l_saved_fn, "_TMP_FILENAME_" + vars_post.count.out)
							l_files.force ([l_filename, l_content_type, l_saved_fn, 0, l_content.count], l_name)
						else
							l_files.force ([l_filename, l_content_type, "", -1, l_content.count], l_name)
						end
					else
						vars_post.force (l_content, l_name)
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
				n = 0
			loop
				read_input (n)
				t := last_input_string
				Result.append_string (t)
				n := t.count
			end
		end

	internal_variables_GET: detachable like variables_GET
			-- cached value for `variables_GET'

	internal_variables_POST: detachable like variables_post
			-- cached value for `variables_POST'

feature -- I/O

	input: HTTPD_SERVER_INPUT
			-- Server input channel

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
		do
			path_info := s
			--| Warning
			--| on IIS: we might have   PATH_INFO = /sample.exe/foo/bar
			--| on apache:				PATH_INFO = /foo/bar
			--| So, we might need to check with SCRIPT_NAME and remove it on IIS
			--| store original PATH_INFO in ORIG_PATH_INFO
		end

	set_path_translated (s: detachable STRING)
		do
			path_translated := s
			-- analyze_path_translated
		end

feature {NONE} -- Implementation: Validation

	validate_http_cookie
		do
			if attached http_cookie as l_cookie and then not l_cookie.is_empty then

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

	explode_to_variables (a_content: STRING; decoding: BOOLEAN): HASH_TABLE [STRING_32, STRING_32]
		local
			n, p, i, j: INTEGER
			s: STRING
			l_name,l_value: STRING_32
		do
			n := a_content.count
			if n > 0 then
				create Result.make (10)
				from
					p := 1
				until
					p = 0
				loop
					i := a_content.index_of ('&', p)
					if i = 0 then
						s := a_content.substring (p, n)
						p := 0
					else
						s := a_content.substring (p, i - 1)
						p := i + 1
					end
					if not s.is_empty then
						j := s.index_of ('=', 1)
						if j > 0 then
							l_name := s.substring (1, j - 1)
							l_value := s.substring (j + 1, s.count)
							if decoding then
								l_name := string_routines.string_url_decoded (l_name)
								l_value := string_routines.string_url_decoded (l_value)
							end
							Result.force (l_value, l_name)
						end
					end
				end
			else
				create Result.make (0)
			end
		end

	extract_variables
			-- Extract relevant environment variables
		local
			s: detachable STRING
		do
			s := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.request_uri)
			if s /= Void and then not s.is_empty then
				request_uri := s
			else
				report_bad_request_error ("Missing URI")
			end
			if not has_error then
				s := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.request_method)
				if s /= Void and then not s.is_empty then
					request_method := s
				else
					report_bad_request_error ("Missing request method")
				end
			end
			if not has_error then
				http_user_agent := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.http_user_agent)
				http_authorization := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.http_authorization)
--				analyze_authorization
			end
			if not has_error then
				if attached execution_variable ({HTTPD_ENVIRONMENT_NAMES}.http_host) as l_host and then not l_host.is_empty then
					set_http_host (l_host)
				else
					report_bad_request_error ("Missing host header")
				end
			end
			if not has_error then
				set_query_string (execution_variable ({HTTPD_ENVIRONMENT_NAMES}.query_string))
				s := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.content_type)
				if s /= Void and then not s.is_empty then
					set_content_type (s)
				end
				s := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.content_length)
				if s /= Void and then s.is_integer then
					set_content_length (s.to_integer)
				end
				set_path_info (execution_variable ({HTTPD_ENVIRONMENT_NAMES}.path_info))
				set_path_translated (execution_variable ({HTTPD_ENVIRONMENT_NAMES}.path_translated))
				http_cookie := execution_variable ({HTTPD_ENVIRONMENT_NAMES}.http_cookie)
			end
		end

	string_routines: HTTP_STRING_ROUTINES
		once
			create Result
		end

end
