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
			debug ("nino")
				if attached base as l_base then
					print ("Base=" + l_base + "%N")
				end
			end
			server.setup (l_http_handler)
		end

	process_request (env: HASH_TABLE [STRING, STRING]; a_headers_text: STRING; a_input: HTTP_INPUT_STREAM; a_output: HTTP_OUTPUT_STREAM)
			-- Process request ...
		local
			l_path_info: STRING
			p: INTEGER
		do
			request_count := request_count + 1

			if attached base as l_base and then attached env.item ("REQUEST_URI") as uri then
				if uri.starts_with (l_base) then
					l_path_info := uri.substring (l_base.count + 1, uri.count)
					p := l_path_info.index_of ('?', 1)
					if p > 0 then
						l_path_info.keep_head (p - 1)
					end
					env.force (l_path_info, "PATH_INFO")
					env.force (l_base, "SCRIPT_NAME")
				end
			end

			call_execute (env, create {HTTPD_NINO_SERVER_INPUT}.make (a_input), create {HTTPD_NINO_SERVER_OUTPUT}.make (a_output))
		end

invariant

	server_attached: server /= Void

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
