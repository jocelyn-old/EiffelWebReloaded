note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	REST_APPLICATION

inherit
	HTTPD_APPLICATION
		redefine
			new_request_context
		end

feature {NONE} -- Handlers

	handler_manager: REST_REQUEST_HANDLER_MANAGER
		deferred
		end

feature {NONE} -- Environment

	new_request_context (a_vars: HASH_TABLE [STRING, STRING]; a_input: HTTPD_SERVER_INPUT; a_output: HTTPD_SERVER_OUTPUT): REST_REQUEST_CONTEXT
		do
			create Result.make (a_vars, a_input, a_output)
			Result.environment_variables.add_variable (request_count.out, "REQUEST_COUNT")
		end

feature -- Execution

	execute (ctx: like new_request_context)
		local
			rescued: INTEGER
			rq: detachable REST_REQUEST_HANDLER
		do
			if rescued = 0 then
				rq := handler_manager.handler (ctx)
				if rq = Void then
					rq := handler_manager.smart_handler (ctx)
				end
				if rq /= Void then
					rq.execute (ctx)
				else
					execute_default (ctx)
				end
			elseif rescued = 1 then
				execute_rescue (ctx)
			else
				-- Bye Bye
				exit_with_code (-1)
			end
		rescue
			rescued := rescued + 1
			retry
		end

	execute_default (ctx: like new_request_context)
			-- Execute the default behavior
		deferred
		end

	execute_rescue (ctx: like new_request_context)
			-- Execute the default rescue behavior
		deferred
		end

feature -- Execution

	exit_with_code (a_code: INTEGER)
		do
			(create {EXCEPTIONS}).die (a_code)
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
