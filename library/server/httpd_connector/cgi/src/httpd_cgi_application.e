note
	description: "Summary description for {HTTPD_CGI_APPLICATION}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_CGI_APPLICATION

inherit
	HTTPD_APPLICATION

feature {NONE} -- Initialization

	initialize
		do
			create {HTTPD_CGI_SERVER_INPUT} input.make
			create {HTTPD_CGI_SERVER_OUTPUT} output.make
		end

feature -- Access

	request_count: INTEGER

feature -- Basic operation

	launch
		do
			request_count := request_count + 1
			call_execute ((create {EXECUTION_ENVIRONMENT}).starting_environment_variables, input, output)
		end

feature -- Input/Output

	input: HTTPD_SERVER_INPUT
			-- Input from client

	output: HTTPD_SERVER_OUTPUT
			-- Output to client

;note
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
