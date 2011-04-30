note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	HTTPD_FCGI_APPLICATION

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			initialize
			launch
		end

feature -- Execution

	execute (a_variables: HASH_TABLE [STRING, STRING])
		local
			rqst_uri: detachable STRING
			henv: HTTPD_ENVIRONMENT
		do
			http_put_string (header ("FCGI Eiffel Application"))
			create henv.make (a_variables)
			if henv.has_error then
				http_put_string ("<div>ERROR occurred%N")
				print_errors (henv.error_handler)
				http_put_string ("</div>")
			end
			rqst_uri := a_variables.item (request_uri_varname)
			if rqst_uri /= Void then
				if attached a_variables.item (request_method_varname) as l_rqst_method then
					if l_rqst_method.is_case_insensitive_equal ("GET") then
						http_put_string ("<div>Method: GET")
						http_put_string ("<form id=%"sample_form%" action=%"" + rqst_uri + "%" method=%"POST%">%N")
						http_put_string ("<input type=%"text%" name=%"fd_text%">%N")
						http_put_string ("<input type=%"reset%" name=%"fd_cancel%" value=%"Cancel%">%N")
						http_put_string ("<input type=%"submit%" name=%"fd_submit%" value=%"Validate%">%N")
						http_put_string ("</form>%N")
						http_put_string ("</div>%N")
					elseif l_rqst_method.is_case_insensitive_equal ("POST") then
						http_put_string ("<div>Method: POST")
						http_put_string ("<li>type=" + variable (a_variables, request_content_type_varname) + "</li>%N")
						http_put_string ("<li>length=" + variable (a_variables, request_content_length_varname) + "</li>%N")
						if
							attached a_variables.item (request_content_length_varname) as l_content_length and then
							l_content_length.is_integer
						then
							http_put_string ("content=[")
							fcgi.read_from_stdin (l_content_length.to_integer)
							http_put_string (fcgi.buffer_contents)
							http_put_string ("]")
						end
						http_put_string ("</div>%N")
					elseif l_rqst_method.is_case_insensitive_equal ("PUT") then
						http_put_string ("<h1>Method: " + l_rqst_method + "</h1>%N")
					elseif l_rqst_method.is_case_insensitive_equal ("DELETE") then
						http_put_string ("<h1>Method: " + l_rqst_method + "</h1>%N")
					end
				end
			end

			http_put_string ("<h1>Hello FCGI Eiffel Application</h1>%N")
			http_put_string ("Request number " + request_count.out + "<br/>%N")

			http_put_string ("<ul>Environment variables%N")
			print_environment_variables (a_variables)
			http_put_string ("</ul>")
			http_put_string (footer)
			http_flush
		end

feature -- Access

	variable (vars: HASH_TABLE [STRING, STRING]; n: STRING): STRING
		do
			if attached vars.item (n) as v then
				Result := v
			else
				Result := "$" + n
			end
		end

	header (a_title: STRING): STRING
		do
			Result := "Content-type: text/html%R%N"
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
		local
		do
			from
				vars.start
			until
				vars.after
			loop
				http_put_string ("<li><strong>" + vars.key_for_iteration + "</strong> = " + vars.item_for_iteration + "</li>%N")
				vars.forth
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
