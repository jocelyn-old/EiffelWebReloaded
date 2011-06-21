note
	description: "Summary description for {REST_SERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_SERVER

inherit
	REST_APPLICATION
		redefine
			new_request_context,
			execute,
			exit_with_code
		end

	REST_APPLICATION_GATEWAY
		redefine
			new_request_context,
			execute
		end

	SHARED_LOGGER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			logger_cell.replace (create {FILE_LOGGER}.make_with_filename (gateway_name + "-rest.log"))
			initialize
			create handler_manager.make (10)
			initialize_handlers (handler_manager)
			launch
			logger.close
		end

feature {NONE} -- Environment

	new_request_context (a_vars: HASH_TABLE [STRING, STRING]; a_input: HTTPD_SERVER_INPUT; a_output: HTTPD_SERVER_OUTPUT): REST_SERVER_REQUEST_CONTEXT
		do
			create Result.make (a_vars, a_input, a_output)
			Result.environment_variables.add_variable (request_count.out, "REQUEST_COUNT")
		end

feature {NONE} -- Handlers		

	handler_manager: REST_REQUEST_HANDLER_MANAGER

	initialize_handlers (m: like handler_manager)
		local
			h: REST_REQUEST_HANDLER
		do
			m.register (create {APP_API_DOCUMENTATION}.make ("/doc", handler_manager))
			m.register (create {APP_ACCOUNT_VERIFY_CREDENTIAL}.make ("/account/verify_credentials"))
			m.register (create {APP_TEST}.make ("test"))
			m.register (create {APP_DEBUG_LOG}.make ("/debug/log"))

			create {REST_REQUEST_AGENT_HANDLER} h.make (agent execute_exit_application, "/debug/exit")
			h.set_description ("tell the REST server to exit (in FCGI context, this is used to reload the FCGI server)")
			h.enable_request_method_get
			h.enable_format_text
			m.register (h)
		end

feature -- Execution

	execute (ctx: like new_request_context)
		do
			logger.logf (1, "[$3] execute: path_info=$1 (request_count=$2)", <<ctx.path_info, request_count, ctx.environment_variables.remote_addr>>)
			Precursor (ctx)
		end

	execute_default (ctx: like new_request_context)
			-- Execute the default behavior
		local
			rqst_uri: detachable STRING
			l_path_info: detachable STRING
			h: HTTPD_HEADER
			s: STRING
		do
			create h.make
			h.put_refresh (ctx.script_url ("/doc"), 2, {HTTP_STATUS_CODE}.temp_redirect)
			h.put_content_type_text_html
			create s.make_empty
			s := "Request [" + ctx.path_info + "] is not available. <br/>%N";
			s.append ("You are being redirected to <a href=%"" + ctx.script_url ("/doc") + "%">/doc</a> in 2 seconds ...%N")
			h.put_content_length (s.count)
			ctx.output.put_string (h.string)
			ctx.output.put_string (s)
		end

	execute_rescue (ctx: like new_request_context)
			-- Execute the default rescue behavior
		do
			execute_exception_trace (ctx)
		end

feature -- Implementation

	execute_exception_trace (ctx: like new_request_context)
		local
			h: HTTPD_HEADER
			s: STRING
		do
			create h.make
			h.put_content_type_text_plain
			ctx.output.put_string (h.string)
			ctx.output.put_string ("Error occurred .. rq="+ request_count.out +"%N")

			if attached (create {EXCEPTIONS}).exception_trace as l_trace then
				ctx.output.put_string ("<pre>" + l_trace + "</pre>")
			end
			h.recycle
			exit_with_code (-1)
		end

	execute_exit_application (ctx: REST_REQUEST_CONTEXT; a_format_name: detachable STRING; a_args: detachable STRING)
		local
			rep: REST_RESPONSE
			s: STRING
		do
			create rep.make ("exit")
			rep.headers.put_content_type_text_html
			create s.make_empty
			s.append_string ("Exited")
			s.append_string (" <a href=%"" + ctx.script_url ("/") + "%">start again</a>%N")
			rep.set_message (s)
			ctx.output.put_string (rep.string)
			rep.recycle
			exit_with_code (0)
		end

	exit_with_code (a_code: INTEGER)
		do
			logger.close;
			Precursor (a_code)
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
