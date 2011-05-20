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
			new_environment
		end

feature {NONE} -- Handlers

	handler_manager: REST_REQUEST_HANDLER_MANAGER
		deferred
		end

feature {NONE} -- Environment

	new_environment (a_vars: HASH_TABLE [STRING, STRING]): REST_ENVIRONMENT
		do
			create Result.make (a_vars, input)
			Result.environment_variables.add_variable (request_count.out, "REQUEST_COUNT")
		end

feature -- Execution

	execute (henv: like new_environment)
		local
			l_path_info: detachable STRING
			rescued: INTEGER
			rq: detachable REST_REQUEST_HANDLER
		do
			if rescued = 0 then
				l_path_info := henv.path_info
				rq := handler_manager.handler (l_path_info)
				if rq = Void then
					rq := handler_manager.smart_handler (l_path_info)
				end
				if rq /= Void then
					rq.execute (henv)
				else
					execute_default (henv)
				end
			elseif rescued = 1 then
				execute_rescue (henv)
			else
				-- Bye Bye
				exit_with_code (-1)
			end
		rescue
			rescued := rescued + 1
			retry
		end

	execute_default (henv: like new_environment)
			-- Execute the default behavior
		deferred
		end

	execute_rescue (henv: like new_environment)
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
