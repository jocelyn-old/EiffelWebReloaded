note
	description: "[
				A simple example to demonstrate how to build a RESTful server
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	REST_SERVER

inherit

	REST_APPLICATION --| Use the provided RESTful implementation
		redefine
			new_environment,
			execute,
			exit_with_code
		end

		--| Precise which httpd support you want to use, here we use EiffelWebNino
		--| you could also use FCGI or CGI
	HTTPD_NINO_APPLICATION
		redefine
			initialize_server,
			new_environment,
			execute
		end

		--| Simple facility to trace your execution		
	SHARED_LOGGER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			initialize
			initialize_handlers
			initialize_logger
			launch
			logger.close
		end

	initialize_logger
		do
			logger_cell.replace (create {FILE_LOGGER}.make_with_filename ("server.log"))
		end

	initialize_server
		do
			Precursor
			base := "/service"  --| See `base' for details

				--| Let's use 8080 for the port number
				--| You can change it
			server.configuration.http_server_port := 8080

				--| If your application is not design to be run in multithread
				--| you can choose to force single_thread request handling
			server.configuration.force_single_threaded := True
		end

	base: detachable STRING
			-- Base url used to tell EiffelWebNino what is the "root" for the application
			--| basically if your service is  http://domain.tld/service
			--| and your request such http://domain.tld/service/test?foo=bar
			--| the base_url is /service
			--| and then, your PATH_INFO will be  /test  and the QUERY_STRING will be foo=bar

feature {NONE} -- Environment

	new_environment (a_vars: HASH_TABLE [STRING, STRING]; a_input: HTTPD_SERVER_INPUT; a_output: HTTPD_SERVER_OUTPUT): REST_SERVER_ENVIRONMENT
		do
			create Result.make (a_vars, a_input, a_output)
				--| At this point, you can decided to add your own environment variable
				--| this is a convenient way to share a value
			Result.environment_variables.add_variable (request_count.out, "REQUEST_COUNT")
		end

feature {NONE} -- Handlers		

	handler_manager: REST_REQUEST_HANDLER_MANAGER
			-- This is the main handler manager
			-- you can use your own implementation

	initialize_handlers
		local
			h: REST_REQUEST_HANDLER
			m: like handler_manager
		do
			create handler_manager.make (10)
			m := handler_manager

				--| This /doc is to show a quick documentation of your services,
				--| based on the declaration in the various APP_... classes
			m.register (create {APP_API_DOCUMENTATION}.make ("/doc", m))

				--| An example to handle login/password
			m.register (create {APP_ACCOUNT_VERIFY_CREDENTIAL}.make ("/account/verify_credentials"))

				--| Various tests ..
			m.register (create {APP_TEST}.make ("/test"))
			m.register (create {APP_DEBUG_LOG}.make ("/log"))

				--| One app to tell the server to exit
			create {REST_REQUEST_AGENT_HANDLER} h.make (agent execute_exit_application, "/exit")
			h.set_description ("tell the REST server to exit (in FCGI context, this could be used to reload the FCGI server)")
			h.enable_request_method_get
			h.enable_format_text
			m.register (h)
		end

feature -- Execution

	execute (henv: like new_environment)
		do
			logger.logf (1, "[$3] execute: path_info=$1 (request_count=$2)", <<henv.path_info, request_count, henv.environment_variables.remote_addr>>)
			Precursor (henv)
		end

	execute_default (henv: like new_environment)
			-- Execute the default behavior
		local
			rqst_uri: detachable STRING
			l_path_info: detachable STRING
			h: HTTPD_HEADER
			s: STRING
		do
			create h.make
			h.put_refresh (henv.script_url ("/doc"), 2, {HTTP_STATUS_CODE}.temp_redirect)
			h.put_content_type_text_html
			create s.make_empty
			s := "Request [" + henv.path_info + "] is not available. <br/>%N";
			s.append ("You are being redirected to <a href=%"" + henv.script_url ("/doc") + "%">/doc</a> in 2 seconds ...%N")
			h.put_content_length (s.count)
			henv.output.put_string (h.string)
			henv.output.put_string (s)
		end

	execute_rescue (henv: like new_environment)
			-- Execute the default rescue behavior
		do
			execute_exception_trace (henv)
		end

feature -- Implementation

	execute_exception_trace (henv: like new_environment)
		local
			h: HTTPD_HEADER
			s: STRING
		do
			create h.make
			h.put_content_type_text_plain
			henv.output.put_string (h.string)
			henv.output.put_string ("Error occurred .. rq="+ request_count.out +"%N")

			if attached (create {EXCEPTIONS}).exception_trace as l_trace then
				henv.output.put_string ("<pre>" + l_trace + "</pre>")
			end
			h.recycle
			exit_with_code (-1)
		end

	execute_exit_application (henv: REST_ENVIRONMENT; a_format_name: detachable STRING; a_args: detachable STRING)
		local
			rep: REST_RESPONSE
			s: STRING
		do
			create rep.make ("exit")
			rep.headers.put_content_type_text_html
			create s.make_empty
			s.append_string ("Exited")
			s.append_string (" <a href=%"" + henv.script_url ("/") + "%">start again</a>%N")
			rep.set_message (s)
			henv.output.put_string (rep.string)
			rep.recycle
			exit_with_code (0)
		end

	exit_with_code (a_code: INTEGER)
		do
			server.shutdown_server
			logger.close;
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
