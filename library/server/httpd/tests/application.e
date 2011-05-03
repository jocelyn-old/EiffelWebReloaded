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
			logger_cell.replace (create {FILE_LOGGER}.make_with_filename ("c:\temp\sample.log"))
			initialize
			launch
			logger.close
		end

feature -- Execution

	execute (henv: HTTPD_ENVIRONMENT)
		local
			rqst_uri: detachable STRING
		do
			logger.log (1, "execute: " + request_count.out)
			http_put_string (header ("FCGI Eiffel Application"))
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

			if attached henv.uploaded_files as l_files then
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
					http_put_string (" tmp_name=" + l_files.item_for_iteration.tmp_name)
					http_put_string ("<img src=%"tmp-" + l_files.item_for_iteration.name + "%" />")

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

	post_execute (henv: detachable HTTPD_ENVIRONMENT)
		do
			if not post_execute_ignored then
				Precursor (henv)
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

	header (a_title: STRING): STRING
		do
			Result := "Content-type: text/html%R%N"
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
