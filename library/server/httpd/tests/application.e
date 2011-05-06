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
			post_execute,
			new_environment
		end

	SHARED_LOGGER

	HTTP_FILE_SYSTEM_UTILITIES

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

feature -- Access

	new_environment (a_vars: HASH_TABLE [STRING, STRING]): APPLICATION_ENVIRONMENT
		do
			create Result.make (a_vars, input)
		end

feature -- Execution

	http_header: detachable HTTPD_HEADER

	html: detachable HTML_PAGE

	html_menu (henv: like new_environment): STRING
		do
			Result := "<div> "
					+ "<a href=%"" + henv.script_url ("/home") + "%">Home</a> "
					+ "<a href=%"" + henv.script_url ("/help") + "%">Help</a> "
					+ "<a href=%"" + henv.script_url ("/test")  + "%">Test</a> "
			if henv.authenticated then
				Result.append ("<a href=%"" + henv.script_url ("/private") + "%">"+ henv.authenticated_login + "</a> ")

				Result.append ("<a href=%"" + henv.script_url ("/logout") + "%">Logout</a> ")
			else
				Result.append ("<a href=%"" + henv.script_url ("/login") + "%">Login</a> ")
			end
			Result.append (
					  "<a href=%"" + henv.script_url ("/quit") + "%">Exit</a> "
					+ "</div>"
				)
		end

	execute (henv: like new_environment)
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
			elseif l_path_info.starts_with ("/login") then
				execute_login_application (henv)
			elseif l_path_info.starts_with ("/logout") then
				execute_logout_application (henv)
			elseif l_path_info.starts_with ("/private") then
				execute_private_application (henv)
			elseif l_path_info.starts_with ("/test") then
				execute_test_application (henv)
			elseif l_path_info.starts_with ("/file") or l_path_info.starts_with ("/download") then
				execute_file_application (henv)
			elseif l_path_info.starts_with ("/api/") then
				execute_api_application (henv)
			elseif l_path_info.starts_with ("/quit") then
				execute_exit_application (henv)
			else
				execute_test_application (henv)
			end
		end

	execute_home_application (henv: like new_environment)
		local
			h: APPLICATION_HTML_PAGE
			s: STRING
		do
			create h.make ("FCGI Eiffel Application - Home")
			h.headers.put_refresh (henv.script_url ("/home"), 1, 200)
			h.headers.put_content_type_text_html
			h.body_menu := html_menu (henv)
			create s.make_empty
			s.append_string ("<h1> Welcome to the Eiffel Web Application (request count="+request_count.out+")</h1>%N")
			s.append_string ("PATH_INFO=" + henv.path_info + "<br/>%N")
			h.body_main := s
			h.compute
			http_put_string (h.string)
			h.recycle
		end

	execute_login_application (henv: like new_environment)
		local
			hd: HTTPD_HEADER
			h: APPLICATION_HTML_PAGE
			s: STRING
		do
			if not henv.authenticated then
				create hd.make
				hd.put_status (401)
				hd.put_header ("WWW-Authenticate: Basic realm=%"Eiffel Auth%"")
				http_put_string (hd.string)
				hd.recycle
			else
				create h.make ("Login ...")
				h.headers.put_content_type_text_html
				h.headers.put_redirection (henv.script_url ("/home"), 0)
				h.headers.put_cookie ("uuid", "uuid_" + henv.authenticated_login, Void, Void, Void, Void)
				h.headers.put_cookie ("auth", "yes", Void, Void, Void, Void)
				h.headers.put_cookie ("user", henv.authenticated_login, Void, Void, Void, Void)
				h.body_menu := html_menu (henv)
				h.body_main.append ("Hello " + henv.authenticated_login + "%N")
				h.body_main.append ("Cookies:%N" + string_hash_table_string_string (henv.cookies_variables.new_cursor))
				http_put_string (h.string)
				h.recycle
			end
		end

	execute_logout_application (henv: like new_environment)
		local
			hd: HTTPD_HEADER
			h: APPLICATION_HTML_PAGE
		do
			if henv.authenticated then
				create hd.make
				hd.put_status (401)
				hd.put_header ("WWW-Authenticate: Basic realm=%"Eiffel Auth%"")
				hd.put_cookie ("uuid", "", Void, Void, Void, Void)
				hd.put_cookie ("auth", "logout", Void, Void, Void, Void)
				hd.put_cookie ("user", "", Void, Void, Void, Void)
				http_put_string (hd.string)
				hd.recycle
			else
				create h.make ("Logout ...")
				h.headers.put_content_type_text_html
				h.headers.put_cookie ("uuid", "", Void, Void, Void, Void)
				h.headers.put_cookie ("auth", "lno", Void, Void, Void, Void)
				h.headers.put_cookie ("user", "", Void, Void, Void, Void)
				h.body_menu := html_menu (henv)
				h.body_main.append ("Bye " + henv.authenticated_login + "%N")
				h.body_main.append ("Cookies:%N" + string_hash_table_string_string (henv.cookies_variables.new_cursor))
				http_put_string (h.string)
				h.recycle
			end
		end

	execute_api_application (henv: like new_environment)
		local
			l_path_info: STRING
			l_query: STRING
			h: HTTPD_HEADER
			r: HTML_PAGE
			s: STRING
--			j: JSON_
		do
--			execute_home_application (henv)
			l_path_info := henv.path_info
			check l_path_info.starts_with ("/api/") end
			l_query := l_path_info.substring (("/api").count + 1, l_path_info.count)
			if l_query.starts_with ("/test.plain") then
				s := "This is a test for api %"" + l_query + "%".%NBye bye.%N"

				create h.make
				h.put_content_type_text_plain
				h.put_content_length (s.count)
				output.put_string (h.string)
				output.put_string (s)
				output.flush
			elseif l_query.starts_with ("/test.xml") then
				s := "<doc><text>This is a test for api %"" + l_query + "%".%NBye bye.%N</text></doc>"

				create h.make
				h.put_content_type_text_xml
				h.put_content_length (s.count)
				output.put_string (h.string)
				output.put_string (s)
				output.flush
			elseif l_query.starts_with ("/test.json") then
				s := "{ %"title%": %"Eiffel Web Sample%", %"text%": %"This is a test for api [" + l_query + "].%NBye bye.%N%" }"

				create h.make
				h.put_content_type_application_json
				h.put_content_length (s.count)
				output.put_string (h.string)
				output.put_string (s)
				output.flush

			else
				create r.make (l_query)
				r.send (output)
			end
		end

	execute_private_application (henv: like new_environment)
		local
			hd: HTTPD_HEADER
			h: APPLICATION_HTML_PAGE
			s: STRING
		do
			if not henv.authenticated then
				create hd.make
				hd.put_status (401)
				hd.put_header ("WWW-Authenticate: Basic realm=%"Eiffel Auth%"")
				hd.put_redirection (henv.script_url ("/login"), 0)
				http_put_string (hd.string)
				hd.recycle
			else
				create h.make ("FCGI Eiffel Application - Private")
				h.headers.put_content_type_text_html
				h.body_menu := html_menu (henv)
				s := "<h1> Welcome to the private side of Eiffel Web Application (request count="+request_count.out+")</h1>"
				s.append_string ("PATH_INFO=" + henv.path_info + "<br/>")
				if attached henv.http_authorization as l_auth then
					s.append_string ("Auth=" + l_auth + "<br/>")
				else
					s.append_string ("Auth= ...<br/>")
				end
				s.append ("All var:%N" + string_hash_table_string_string (henv.variables.new_cursor))
				s.append ("Cookies:%N" + string_hash_table_string_string (henv.cookies_variables.new_cursor))
				h.body_main.append (s)
				http_put_string (h.string)
				h.recycle
			end
		end

	execute_file_application (henv: like new_environment)
		local
			l_path_info: STRING
			p: INTEGER
			l_file: STRING
			r: HTTPD_FILE_RESPONSE
		do
			l_path_info := henv.path_info
			p := l_path_info.substring_index ("download/", 1)
			if p > 0 then
				l_file := l_path_info.substring (p + 9, l_path_info.count)
				create {HTTPD_DOWNLOAD_RESPONSE} r.make (l_file)
				r.send (output)
			else
				p := l_path_info.substring_index ("file/", 1)
				if p > 0 then
					l_file := l_path_info.substring (p + 5, l_path_info.count)
					create {HTTPD_FILE_RESPONSE} r.make (l_file)
					r.send (output)
				else
					http_put_string (header ("FCGI Eiffel Application - File"))
					http_put_string (footer)
				end
			end
		end

	execute_exit_application (henv: like new_environment)
		do
			http_put_string (header ("FCGI Eiffel Application - Bye bye"))
			http_put_string (html_menu (henv))
			http_put_string ("<h1>Eiffel Web Application - bye bye (request count="+request_count.out+")</h1>")
			http_put_string (footer)
			http_flush;
			(create {EXCEPTIONS}).die (0)
		end

	execute_help_application (henv: like new_environment)
		do
			http_put_string (header ("FCGI Eiffel Application - Help"))
			http_put_string (html_menu (henv))
			http_put_string ("<h1>Help ...</h1>")
			http_put_string (footer)
		end

	execute_test_application (henv: like new_environment)
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
							print_hash_table_string_string (henv.variables_post.new_cursor)
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
			print_hash_table_string_string (henv.variables_get.new_cursor)
			http_put_string ("</ul>")

			http_put_string ("<ul>POST variables%N")
			print_hash_table_string_string (henv.variables_post.new_cursor)
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
					http_put_string ("<a href=%"" + henv.script_url ("/download/" + l_files.item_for_iteration.tmp_basename) + "%">")
					http_put_string ("<img src=%"" + henv.script_url ("/file/" + l_files.item_for_iteration.tmp_basename) + "%" />")
					http_put_string ("</a>")

					http_put_string ("</li>%N")
					l_files.forth
				end
				http_put_string ("</ul>")
			end

			http_put_string ("<ul>COOKIE variables%N")
			print_hash_table_string_string (henv.cookies_variables.new_cursor)
			http_put_string ("</ul>")

			http_put_string ("<ul>Environment variables%N")
			print_environment_variables (henv.environment_variables)
			http_put_string ("</ul>")
			http_put_string (footer)
			http_flush

			post_execute_ignored := True
		end

	pre_execute
		do
			post_execute_ignored := False
		end

	post_execute (henv: detachable like new_environment; e: detachable EXCEPTION)
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
			print_hash_table_string_string (vars.new_cursor)
		end

	print_hash_table_string_string (ht: HASH_TABLE_ITERATION_CURSOR [STRING_GENERAL, STRING_GENERAL])
		do
			from
				ht.start
			until
				ht.after
			loop
				http_put_string ("<li><strong>" + ht.key.as_string_8 + "</strong> = " + ht.item.as_string_8 + "</li>%N")
				ht.forth
			end
		end

	string_hash_table_string_string (ht: HASH_TABLE_ITERATION_CURSOR [STRING_GENERAL, STRING_GENERAL]): STRING_8
		do
			from
				create Result.make (100)
				ht.start
			until
				ht.after
			loop
				Result.append_string ("<li><strong>" + ht.key.as_string_8 + "</strong> = " + ht.item.as_string_8 + "</li>%N")
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
