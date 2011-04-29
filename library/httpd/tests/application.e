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
		local
			res: INTEGER
			nb: INTEGER
		do
			initialize
			launch
			from
				res := fcgi.fcgi_listen
			until
				res < 0
			loop
				nb := nb + 1
				fcgi.put_string (header ("FCGI Eiffel Application"))

				fcgi.put_string ("<h1>Hello FCGI Eiffel Application</h1>%N")
				fcgi.put_string ("Request number " + nb.out + "<br/>%N")

				fcgi.put_string ("<ul>Environment variables%N")
				print_environment_variables (fcgi.updated_environ_variables)
				fcgi.put_string ("</ul>")
				fcgi.put_string (footer)

				res := fcgi.fcgi_listen
			end
		end

feature -- Execution

	execute (a_variables: HASH_TABLE [STRING, STRING])
		do
			http_put_string (header ("FCGI Eiffel Application"))

			http_put_string ("<h1>Hello FCGI Eiffel Application</h1>%N")
			http_put_string ("Request number " + request_count.out + "<br/>%N")

			http_put_string ("<ul>Environment variables%N")
			print_environment_variables (a_variables)
			http_put_string ("</ul>")
			http_put_string (footer)
			http_flush
		end

feature -- Access

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

end
