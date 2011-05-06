note
	description: "Summary description for {HTTPD_FCGI_APPLICATION}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
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
			create {HTTPD_FCGI_SERVER_OUTPUT} output.make (fcgi)
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
--				fcgi.fcgi_finish
				res := fcgi.fcgi_listen
			end
		end

feature -- Execution

	execute (henv: HTTPD_ENVIRONMENT)
		deferred
		end

feature -- Input/Output

	input: HTTPD_SERVER_INPUT
			-- Input from client (from httpd server via FCGI)

	output: HTTPD_SERVER_OUTPUT
			-- Output to client (via httpd server/fcgi)

feature -- Output

	http_put_string (s: STRING)
		do
			fcgi.put_string (s)
		end

	http_flush
		do
		end

feature {NONE} -- Implementation

	fcgi: FCGI;

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
