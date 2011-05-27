note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	HTTPD_NINO_HANDLER

inherit
	HTTP_CONNECTION_HANDLER

create
	make_with_callback

feature {NONE} -- Initialization

	make_with_callback (a_main_server: like main_server; a_name: STRING; a_callback: HTTPD_NINO_APPLICATION)
			-- Initialize `Current'.
		do
			make (a_main_server, a_name)
			callback := a_callback
		end

	callback: HTTPD_NINO_APPLICATION

feature -- Request processing

	process_request (a_handler: HTTP_CONNECTION_HANDLER; a_input: HTTP_INPUT_STREAM; a_output: HTTP_OUTPUT_STREAM)
			-- Process request ...
		local
			env, vars: HASH_TABLE [STRING, STRING]
			p: INTEGER
			l_request_uri, l_script_name, l_query_string: STRING
			l_server_name, l_server_port: detachable STRING
			a_headers_map: HASH_TABLE [STRING, STRING]

			e: EXECUTION_ENVIRONMENT
		do
			l_request_uri := a_handler.uri
			a_headers_map := a_handler.request_header_map
			create e
			vars := e.starting_environment_variables
			env := vars.twin

			p := l_request_uri.index_of ('?', 1)
			if p > 0 then
				l_script_name := l_request_uri.substring (1, p - 1)
				l_query_string := l_request_uri.substring (p + 1, l_request_uri.count)
			else
				l_script_name := l_request_uri.string
				l_query_string := ""
			end
			if attached a_headers_map.item ("Host") as l_host then
				add_environment_variable (l_host, "HTTP_HOST", env)

				p := l_host.index_of (':', 1)
				if p > 0 then
					l_server_name := l_host.substring (1, p - 1)
					l_server_port := l_host.substring (p+1, l_host.count)
				else
					l_server_name := l_host
					l_server_port := "80" -- Default
				end
			end

			add_environment_variable (a_headers_map.item ("User-Agent"), "HTTP_USER_AGENT", env)
			add_environment_variable (a_headers_map.item ("Accept"), "HTTP_ACCEPT", env)
			add_environment_variable (a_headers_map.item ("Accept-Language"), "HTTP_ACCEPT_LANGUAGE", env)
			add_environment_variable (a_headers_map.item ("Accept-Encoding"), "HTTP_ACCEPT_ENCODING", env)
			add_environment_variable (a_headers_map.item ("Accept-Charset"), "HTTP_ACCEPT_CHARSET", env)
			add_environment_variable (a_headers_map.item ("Connection"), "HTTP_CONNECTION", env)
			add_environment_variable (a_headers_map.item ("Referer"), "HTTP_REFERER", env)

			if attached a_headers_map.item ("Authorization") as l_authorization then
				add_environment_variable (l_authorization, "HTTP_AUTHORIZATION", env)
				p := l_authorization.index_of (' ', 1)
				if p > 0 then
					add_environment_variable (l_authorization.substring (1, p - 1), "AUTH_TYPE", env)
				end
			end

			add_environment_variable (a_headers_map.item ("Content-Length"), "CONTENT_LENGTH", env)
			add_environment_variable (a_headers_map.item ("Content-Type"), "CONTENT_TYPE", env)

			add_environment_variable ("CGI/1.1", "GATEWAY_INTERFACE", env)
--			add_environment_variable (Void, "PATH_INFO", env)
--			add_environment_variable (Void, "PATH_TRANSLATED", env)

			add_environment_variable (l_query_string, "QUERY_STRING", env)

			if attached a_handler.remote_info as l_remote_info then
				add_environment_variable (l_remote_info.addr, "REMOTE_ADDR", env)
				add_environment_variable (l_remote_info.hostname, "REMOTE_HOST", env)
				add_environment_variable (l_remote_info.port.out, "REMOTE_PORT", env)
--				add_environment_variable (Void, "REMOTE_IDENT", env)
--				add_environment_variable (Void, "REMOTE_USER", env)			
			end

			add_environment_variable (l_request_uri, "REQUEST_URI", env)
			add_environment_variable (a_handler.method, "REQUEST_METHOD", env)

			add_environment_variable (l_script_name, "SCRIPT_NAME", env)
			add_environment_variable (l_server_name, "SERVER_NAME", env)
			add_environment_variable (l_server_name, "SERVER_PORT", env)
			add_environment_variable (a_handler.version, "SERVER_PROTOCOL", env)
			add_environment_variable ({HTTP_SERVER_CONFIGURATION}.Server_details, "SERVER_SOFTWARE", env)

			callback.process_request (env, a_handler.request_header, a_input, a_output)
		end

	add_environment_variable (a_value: detachable STRING; a_var_name: STRING; env: HASH_TABLE [STRING, STRING])
		do
			if a_value /= Void then
				env.force (a_value, a_var_name)
			end
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
