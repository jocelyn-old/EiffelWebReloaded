note
	description: "Summary description for {REST_REQUEST_GROUP_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_REQUEST_GROUP_HANDLER

inherit
	REST_REQUEST_HANDLER

create
	make

feature {NONE} -- Initialization

	make (a_path: like path; a_count: INTEGER; a_output: like output)
		do
			path := a_path
			output := a_output
			description := "Request Group Handler"
			create handlers.make (a_count)
			initialize
		end

feature -- Access

	handlers: REST_REQUEST_HANDLER_MANAGER
			-- Associated handlers

	output: HTTPD_SERVER_OUTPUT
			-- Httpd server output

	authentication_required: BOOLEAN
		do
			Result := False
		end

feature -- Addition

	add_handler (r: REST_REQUEST_HANDLER)
			-- Register handler `r'
		require
			valid_path: r.path.starts_with (path)
		do
			handlers.register (r)
		end

feature -- Execution

	execute_application (henv: REST_ENVIRONMENT; a_format: detachable STRING_8; a_args: detachable STRING_8)
			-- Execute request handler with `a_format' ad `a_args'
		local
			l_path_info: detachable STRING
			rq: detachable REST_REQUEST_HANDLER
		do
			l_path_info := henv.path_info
			rq := handlers.handler (l_path_info)
			if rq = Void then
				rq := handlers.smart_handler (l_path_info)
			end
			if rq /= Void then
				rq.execute (henv)
			else
				execute_missing_application (henv, a_format, a_args)
			end
		end

	execute_missing_application (henv: REST_ENVIRONMENT; a_format: detachable STRING_8; a_args: detachable STRING_8)
		local
			h: HTTPD_HEADER
		do
			create h.make
			h.put_status ({HTTP_STATUS_CODE}.not_acceptable)
			output.put_string (h.string)
			h.recycle
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
