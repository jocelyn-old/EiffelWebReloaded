note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	HTTPD_FCGI_APPLICATION
		redefine
			pre_execute,
			post_execute
		end

	SHARED_LOGGER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			logger_cell.replace (create {FILE_LOGGER}.make_with_filename ("sample.log"))
			initialize
			launch
			logger.close
		end

feature -- Execution

	html_menu (henv: HTTPD_ENVIRONMENT): STRING
		local
			s: detachable STRING
		do
			s := henv.execution_variables.script_name
			if s = Void then
				s := ""
			end
			Result := "<div> "
					+ "<a href=%"" + s + "/home%">Home</a> "
					+ "<a href=%"" + s + "/help%">Help</a> "
					+ "<a href=%"" + s + "/env%">Env</a> "
					+ "<a href=%"" + s + "/quit%">Quit</a> "
					+ "</div>"
		end

	execute (henv: HTTPD_ENVIRONMENT)
		local
			rqst_uri: detachable STRING
			l_path_info: detachable STRING
		do
			logger.log (1, "execute: " + request_count.out)
--			if attached henv.all_variables as vars then
--				from
--					vars.start
--				until
--					vars.after
--				loop
--					logger.log (1, "%T" + vars.key_for_iteration.as_string_8 + "=" + vars.item_for_iteration.as_string_8)
--					vars.forth
--				end
--			end
			l_path_info := henv.path_info
			if l_path_info.is_empty then
				l_path_info := "/home" --| Default application
			end
			if l_path_info.starts_with ("/help") then
				execute_help_application (henv)
			elseif l_path_info.starts_with ("/home") then
				execute_home_application (henv)
			elseif l_path_info.starts_with ("/env") then
				execute_default_application (henv)
			elseif l_path_info.starts_with ("/file") or l_path_info.starts_with ("/download") then
				execute_file_application (henv)
			elseif l_path_info.starts_with ("/quit") then
				execute_exit_application (henv)
			else
				execute_default_application (henv)
			end
		end

	execute_home_application (henv: HTTPD_ENVIRONMENT)
		do
			http_put_string (header ("FCGI Eiffel Application - Home"))
			http_put_string (html_menu (henv))
			http_put_string ("<h1> Welcome to the Eiffel Web Application (request count="+request_count.out+")</h1>")
			http_put_string ("PATH_INFO=" + henv.path_info + "<br/>")
			http_put_string (footer)
		end

	execute_file_application (henv: HTTPD_ENVIRONMENT)
		local
			l_path_info: STRING
			p: INTEGER
			l_file: STRING
		do
			l_path_info := henv.path_info
			p := l_path_info.substring_index ("download/", 1)
			if p > 0 then
				l_file := l_path_info.substring (p + 9, l_path_info.count)
				http_put_header_line ("Content-Type: application/force-download; name=%""+ basename (l_file) +"%"")
				http_put_header_line ("Content-Type: image/png; name=%""+ basename (l_file) +"%"")
				http_put_header_line ("Content-Transfer-Encoding: binary")
				http_put_header_line ("Content-Length: " + filesize (l_file).out)
				http_put_header_line ("Content-Disposition: attachment; filename=%""+ basename (l_file) +"%"")
				http_put_header_line ("Expires: 0")
				http_put_header_line ("Cache-Control: no-cache, must-revalidate")
				http_put_header_line ("Pragma: no-cache")
				http_put_header_line ("")

				http_put_file_content (l_file);
			else
				p := l_path_info.substring_index ("file/", 1)
				if p > 0 then
					l_file := l_path_info.substring (p + 5, l_path_info.count)
					http_put_header_line ("Content-Type: " + content_type_by_extension (file_extension (l_file)) + "; name=%""+ basename (l_file) +"%"")
					http_put_header_line ("Content-Transfer-Encoding: binary")
					http_put_header_line ("Content-Length: " + filesize (l_file).out)
					http_put_header_line ("Content-Disposition: attachment; filename=%""+ basename (l_file) +"%"")
					http_put_header_line ("Expires: 0")
					http_put_header_line ("Cache-Control: no-cache, must-revalidate")
					http_put_header_line ("Pragma: no-cache")
					http_put_header_line ("")

					http_put_file_content (l_file);
				else
					http_put_string (header ("FCGI Eiffel Application - File"))
					http_put_string (footer)
				end
			end
		end

	filesize (fn: STRING): INTEGER
		local
			f: RAW_FILE
		do
			create f.make (fn)
			if f.exists then
				Result := f.count
			end
		end

	content_type_by_extension (ext: STRING): STRING
		local
			e: STRING
		do
			e := ext.as_lower
			if e.same_string ("pdf") then
      			Result := "application/pdf"
      		elseif e.same_string ("exe") then
      			Result := "application/octet-stream"
      		elseif e.same_string ("exe") then
				Result := "application/octet-stream"
      		elseif e.same_string ("zip") then
				Result := "application/zip"
      		elseif e.same_string ("doc") then
				Result := "application/msword"
      		elseif e.same_string ("xls") then
				Result := "application/vnd.ms-excel"
      		elseif e.same_string ("ppt") then
				Result := "application/vnd.ms-powerpoint"
      		elseif e.same_string ("gif") then
				Result := "image/gif"
      		elseif e.same_string ("png") then
				Result := "image/png"
      		elseif e.same_string ("jpg") or e.same_string ("jpeg") then
				Result := "image/jpg"
      		else
				Result := "application/force-download"
			end
		end

	file_extension (fn: STRING): STRING
		local
			p: INTEGER
		do
			p := fn.last_index_of ('.', fn.count)
			if p > 0 then
				Result := fn.substring (p + 1, fn.count)
			else
				Result := ""
			end
		end

	basename (fn: STRING): STRING
		local
			p: INTEGER
		do
			p := fn.last_index_of ((create {OPERATING_ENVIRONMENT}).Directory_separator, fn.count)
			if p > 0 then
				Result := fn.substring (p + 1, fn.count)
			else
				Result := fn
			end
		end

	dirname (fn: STRING): STRING
		local
			p: INTEGER
		do
			p := fn.last_index_of ((create {OPERATING_ENVIRONMENT}).Directory_separator, fn.count)
			if p > 0 then
				Result := fn.substring (1, p - 1)
			else
				Result := ""
			end
		end

	execute_exit_application (henv: HTTPD_ENVIRONMENT)
		do
			http_put_string (header ("FCGI Eiffel Application - Bye bye"))
			http_put_string (html_menu (henv))
			http_put_string ("<h1>Eiffel Web Application - bye bye (request count="+request_count.out+")</h1>")
			http_put_string (footer)
			http_flush;
			(create {EXCEPTIONS}).die (0)
		end

	execute_help_application (henv: HTTPD_ENVIRONMENT)
		do
			http_put_string (header ("FCGI Eiffel Application - Help"))
			http_put_string (html_menu (henv))
			http_put_string ("<h1>Help ...</h1>")
			http_put_string (footer)
		end

	execute_default_application (henv: HTTPD_ENVIRONMENT)
		local
			rqst_uri: detachable STRING
			n: INTEGER
		do
			http_put_string (header ("FCGI Eiffel Application"))
			http_put_string (html_menu (henv))
			if henv.has_error then
				http_put_string ("<div>ERROR occurred%N")
				print_errors (henv.error_handler)
				http_put_string ("</div>")
			end
			rqst_uri := henv.request_uri
			if rqst_uri /= Void then
				if attached henv.request_method as l_rqst_method then
					if l_rqst_method.is_case_insensitive_equal ("GET") then
						http_put_string ("<div>Method: GET")
						http_put_string ("<form id=%"sample_form_1%" name=%"sample_form_1%" action=%"" + rqst_uri + "%" method=%"POST%">%N")
						http_put_string ("<input type=%"text%" name=%"fd_text%" value=%"TEXT%">%N")
						http_put_string ("<input type=%"text%" name=%"fd_text2%" value=%"TEXT2%">%N")
						http_put_string ("<input type=%"text%" name=%"fd_text3%" value=%"TEXT3%">%N")
						http_put_string ("<input type=%"text%" name=%"fd_text4%" value=%"TEXT4%">%N")
						http_put_string ("<input type=%"text%" name=%"a.b1%" value=%"A.B1%">%N")
						http_put_string ("<input type=%"text%" name=%"a.b2%" value=%"A.B2%">%N")
						http_put_string ("<input type=%"text%" name=%"a.b3%" value=%"A.B3%">%N")
						http_put_string ("<input type=%"text%" name=%"z[a]%" value=%"Z[A]%">%N")
						http_put_string ("<input type=%"text%" name=%"z[b]%" value=%"Z[B]%">%N")
						http_put_string ("<input type=%"text%" name=%"z[c]%" value=%"Z[C]%">%N")

						http_put_string ("<input type=%"reset%" name=%"fd_cancel%" value=%"Cancel%">%N")
						http_put_string ("<input type=%"submit%" name=%"fd_submit%" value=%"Validate%">%N")
						http_put_string ("</form>%N")
						http_put_string ("</div>%N")
					elseif l_rqst_method.is_case_insensitive_equal ("POST") then
						http_put_string ("<div>Method: POST")
						http_put_string ("<li>type=" + variable ("CONTENT_TYPE", henv.content_type) + "</li>%N")
						http_put_string ("<li>length=" + henv.content_length.out + "</li>%N")
						if
							henv.content_length > 0
						then
							print_hash_table_string_string (henv.variables_post)
--							http_put_string ("content=[")
--							fcgi.read_from_stdin (henv.content_length)
--							http_put_string (fcgi.buffer_contents)
--							http_put_string ("]")
						end
						http_put_string ("</div>%N")
					elseif l_rqst_method.is_case_insensitive_equal ("PUT") then
						http_put_string ("<h1>Method: " + l_rqst_method + "</h1>%N")
					elseif l_rqst_method.is_case_insensitive_equal ("DELETE") then
						http_put_string ("<h1>Method: " + l_rqst_method + "</h1>%N")
					end

					http_put_string ("<div>%N")
					http_put_string ("<form id=%"sample_form_2%" name=%"sample_form_2%" action=%"" + rqst_uri + "%" method=%"POST%">%N")
					http_put_string ("<input type=%"text%" name=%"fd_text%">%N")
					http_put_string ("<input type=%"reset%" name=%"fd_cancel%" value=%"Cancel%">%N")
					http_put_string ("<input type=%"submit%" name=%"fd_submit%" value=%"GO%">%N")
					http_put_string ("</form>%N")

					http_put_string ("</div>%N")

					http_put_string("<div><form action=%"" + rqst_uri + "%" enctype=%"multipart/form-data%" method=%"POST%">%N")
					http_put_string("[
										<p>
											Type some text (if you like):<br>
											<input type="text" name="textline" size="30" value="FooBar">FOOBAR</input>
										</p>
										<p>
										Please specify a file, or a set of files:<br>
										<input type="file" name="datafile" size="40">
										</p>
										<div><input type="submit" value="Send"></div></form>
							]")
				end
			end

			http_put_string ("<h1>Hello FCGI Eiffel Application</h1>%N")
			http_put_string ("Request number " + request_count.out + "<br/>%N")


			http_put_string ("<ul>GET variables%N")
			print_hash_table_string_string (henv.variables_get)
			http_put_string ("</ul>")

			http_put_string ("<ul>POST variables%N")
			print_hash_table_string_string (henv.variables_post)
			http_put_string ("</ul>")

			if attached henv.uploaded_files as l_files and then not l_files.is_empty then
				http_put_string ("<ul>FILES variables%N")
				from
					l_files.start
				until
					l_files.after
				loop
					http_put_string ("<li><strong>" + l_files.key_for_iteration + "</strong>")
					http_put_string (" filename=" + l_files.item_for_iteration.name)
					http_put_string (" type=" + l_files.item_for_iteration.type)
					http_put_string (" size=" + l_files.item_for_iteration.size.out)
					http_put_string (" tmp_basename=" + l_files.item_for_iteration.tmp_basename)
					http_put_string (" tmp_name=" + l_files.item_for_iteration.tmp_name)
					if attached henv.path_info as l_path_info then
						http_put_string ("<img src=%"")
						from
							n := l_path_info.occurrences ('/')
						until
							n = 0
						loop
						 	http_put_string ("../")
						 	n := n - 1
						end
						http_put_string (l_files.item_for_iteration.tmp_basename + "%" />")
					else
						http_put_string ("<img src=%"" + l_files.item_for_iteration.tmp_basename + "%" />")
					end
					if attached henv.execution_variables.script_name as l_script_name then
						http_put_string ("<a href=%"" + l_script_name + "/download/" + l_files.item_for_iteration.tmp_basename + "%">")
						http_put_string ("<img src=%"" + l_script_name + "/file/" + l_files.item_for_iteration.tmp_basename + "%" />")
						http_put_string ("</a>")
					end

					http_put_string ("</li>%N")
					l_files.forth
				end
				http_put_string ("</ul>")
			end



			http_put_string ("<ul>COOKIE variables%N")
			print_hash_table_string_string (henv.cookies)
			http_put_string ("</ul>")

			http_put_string ("<ul>Environment variables%N")
			print_environment_variables (henv.execution_variables)
			http_put_string ("</ul>")
			http_put_string (footer)
			http_flush

			post_execute_ignored := True
		end

	pre_execute
		do
			post_execute_ignored := False
		end

	post_execute (henv: detachable HTTPD_ENVIRONMENT; e: detachable EXCEPTION)
		do
			if e /= Void then
				http_put_string ("Exception occurred%N")
				http_put_string ("<p>" + e.meaning + "</p")
				if attached e.exception_trace as l_trace then
					http_put_string ("<pre>" + l_trace + "</pre>")
				end
				http_flush
			end
			if not post_execute_ignored then
				Precursor (henv, e)
			end
		end

	post_execute_ignored: BOOLEAN

feature -- Access

	variable (k: STRING; v: detachable STRING): STRING
		do
			if v /= Void then
				Result := v
			else
				Result := "$" + k
			end
		end

--	variable (vars: HASH_TABLE [STRING, STRING]; n: STRING): STRING
--		do
--			if attached vars.item (n) as v then
--				Result := v
--			else
--				Result := "$" + n
--			end
--		end

	cookie (key, value: STRING; expiration, path, domain, secure: detachable STRING): STRING
			-- Set a cookie on the client's machine
			-- with key 'key' and value 'value'.
		require
--			not_yet_sent: not is_sent
			make_sense: (key /= Void and value /= Void) and then
						(not key.is_empty and not value.is_empty)
--			header_is_complete: is_complete_header
		do
			Result := "Set-Cookie:" + key + "=" + value
			if expiration /= Void then
				Result.append (";expires=" + expiration)
			end
			if path /= Void then
				Result.append (";path=" + path)
			end
			if domain /= Void then
				Result.append (";domain=" + domain)
			end
			if secure /= Void then
				Result.append (";secure=" + secure)
			end
			Result.append_character ('%R')
			Result.append_character ('%N')
		end

	header_auth: STRING
		do
			Result := ""
			Result.append ("Status: 401 Unauthorized%R%N")
			Result.append ("WWW-Authenticate: Basic realm=%"Eiffel Auth%"%R%N%R%N")
		end

	header (a_title: STRING): STRING
		do
			Result := ""
			Result.append ("Content-type: text/html%R%N")
--			Result.append (cookie ("foo", "bar#" + request_count.out, Void, Void, Void, Void))
			Result.append ("%R%N")
			Result.append ("<html>%N")
			Result.append ("<head><title>" + a_title + "</title></head>")
			Result.append ("<body>%N")
		end

	footer: STRING
		do
			Result := "</body>%N</html>%N"
		end

	print_environment_variables (vars: HASH_TABLE [STRING, STRING])
		do
			print_hash_table_string_string (vars)
		end

	print_hash_table_string_string (ht: HASH_TABLE [STRING_GENERAL, STRING_GENERAL])
		do
			from
				ht.start
			until
				ht.after
			loop
				http_put_string ("<li><strong>" + ht.key_for_iteration.as_string_8 + "</strong> = " + ht.item_for_iteration.as_string_8 + "</li>%N")
				ht.forth
			end
		end

	print_errors (hdl: ERROR_HANDLER)
		local
			v: APPLICATION_ERROR_HTML_PRINTER
			s: STRING
		do
			if attached hdl.as_single_error as e then
				create s.make (50)
				create v.make (s)
				e.process (v)
				http_put_string (s)
			end
		end

feature -- Constants

	request_method_varname: STRING = "REQUEST_METHOD"

	request_uri_varname: STRING = "REQUEST_URI"

	request_content_type_varname: STRING = "CONTENT_TYPE"

	request_content_length_varname: STRING = "CONTENT_LENGTH"

end
