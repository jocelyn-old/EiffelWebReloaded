note
	description: "Summary description for {HTTPD_NINO_APPLICATION}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_NINO_APPLICATION

inherit
	HTTPD_APPLICATION

feature {NONE} -- Initialization

	initialize
		do
			initialize_server

			create {HTTPD_NINO_SERVER_INPUT} input.make_empty
			create {HTTPD_NINO_SERVER_OUTPUT} output.make_empty
		end

	initialize_server
		local
			cfg: HTTP_SERVER_CONFIGURATION
		do
			create cfg.make
			create server.make (cfg)
		end

	server: HTTP_SERVER

feature -- Access

	request_count: INTEGER

	base: detachable STRING
		deferred
		end

feature -- Basic operation

	launch
		local
			l_http_handler : HTTP_HANDLER
		do
			create {HTTPD_NINO_HANDLER} l_http_handler.make_with_callback (server, "HTTPD_NINO_HANDLER", Current)
			server.setup (l_http_handler)
		end

	process_request (env: HASH_TABLE [STRING, STRING]; a_headers_text: STRING; a_input: HTTP_INPUT_STREAM; a_output: HTTP_OUTPUT_STREAM)
			-- Process request ...
		local
			l_path_info: STRING
		do
			input.set_nino_input (a_input)
			output.set_nino_output (a_output)

			request_count := request_count + 1

			if attached base as l_base and then attached env.item ("REQUEST_URI") as uri then
				if uri.starts_with (l_base) then
					l_path_info := uri.substring (l_base.count + 1, uri.count)
					env.force (l_path_info, "PATH_INFO")
					env.force (l_base, "SCRIPT_NAME")
				end
			end

			call_execute (env)

			input.set_nino_input (Void)
			output.set_nino_output (Void)
		end

feature -- Input/Output

	input: HTTPD_NINO_SERVER_INPUT
			-- Input from client

	output: HTTPD_NINO_SERVER_OUTPUT
			-- Output to client

feature -- Output

	http_put_string (s: STRING)
		do
			output.put_string (s)
		end

	http_flush
		do
		end

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
