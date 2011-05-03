note
	description: "Summary description for {HTTPD_FCGI_APPLICATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_FCGI_APPLICATION

inherit
	HTTPD_APPLICATION

feature {NONE} -- Initialization

	initialize
		do
			create fcgi.make
			create {HTTPD_FCGI_SERVER_INPUT} input.make (fcgi)
		end

feature -- Access

	request_count: INTEGER

feature -- Basic operation

	launch
		local
			res: INTEGER
		do
			from
				res := fcgi.fcgi_listen
			until
				res < 0
			loop
				request_count := request_count + 1
				call_execute (fcgi.updated_environ_variables)
				res := fcgi.fcgi_listen
			end
		end

feature -- Execution

	execute (henv: HTTPD_ENVIRONMENT)
		deferred
		end

feature -- Input

	input: HTTPD_SERVER_INPUT
			-- Input from httpd server

feature -- Output

	http_put_string (s: STRING)
		do
			fcgi.put_string (s)
		end

	http_flush
		do
		end

feature {NONE} -- Implementation

	fcgi: FCGI

end
