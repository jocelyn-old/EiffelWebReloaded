note
	description: "Summary description for {HTTPD_APPLICATION}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_APPLICATION

feature -- Access

	request_count: INTEGER
		deferred
		end

feature -- Basic operation

	launch
		deferred
		end

feature -- Execution

	call_execute (a_variables: HASH_TABLE [STRING, STRING]; a_input: HTTPD_SERVER_INPUT; a_output: HTTPD_SERVER_OUTPUT)
			-- Call execute
			--| Note: you can redefine this feature, if you want to optimize
			--| as much as possible a very simple query
			--| without fetching GET, POST, ... data
		local
			rescued: BOOLEAN
			ctx: detachable like new_request_context
		do
			if not rescued then
				pre_execute
				ctx := new_request_context (a_variables, a_input, a_output)
				execute (ctx)
				post_execute (ctx)
			else
				rescue_execute (ctx, (create {EXCEPTION_MANAGER}).last_exception)
			end
		rescue
			rescued := True
			retry
		end

	pre_execute
			-- Operation processed before `execute'
		do
		end

	post_execute (ctx: detachable like new_request_context)
			-- Operation processed after `execute', or after `rescue_execute'
		do
			if ctx /= Void then
				ctx.recycle
			end
		end

	rescue_execute (ctx: detachable like new_request_context; e: detachable EXCEPTION)
			-- Operation processed after `execute', or on rescue
		do
			post_execute (ctx)
		end

	execute (ctx: like new_request_context)
			-- Execute the request
		deferred
		end

feature {NONE} -- Environment

	new_request_context (a_vars: HASH_TABLE [STRING, STRING]; a_input: HTTPD_SERVER_INPUT; a_output: HTTPD_SERVER_OUTPUT): HTTPD_REQUEST_CONTEXT
			-- New httpd environment based on `a_vars' and `input'
			--| note: you can redefine this function to create your own
			--| descendant of HTTPD_REQUEST_CONTEXT , or even to reuse/recycle existing
			--| instance of HTTPD_REQUEST_CONTEXT
		do
			create Result.make (a_vars, a_input, a_output)
		end

feature -- Output

	http_put_exception_trace (ctx: like new_request_context)
			-- Print exception trace is any
		do
			if attached (create {EXCEPTIONS}).exception_trace as l_trace then
				http_put_string ("Exception occurred%N", ctx)
				http_put_string ("<pre>" + l_trace + "</pre>", ctx)
				http_flush (ctx)
			end
		end

	http_put_file_content (fn: STRING; ctx: like new_request_context)
			-- Send the content of file `fn'
		local
			f: RAW_FILE
			o: like {HTTPD_REQUEST_CONTEXT}.output
		do
			create f.make (fn)
			if f.exists and then f.is_readable then
				o := ctx.output
				f.open_read
				from
				until
					f.exhausted
				loop
					f.read_stream (1024)
					o.put_string (f.last_string)
				end
				f.close
			end
		end

	http_put_header_line (s: STRING; ctx: like new_request_context)
			-- Send `s' to http client as header line
		do
			ctx.output.put_header_line (s)
		end

	http_put_string (s: STRING; ctx: like new_request_context)
			-- Send `s' to http client
		do
			ctx.output.put_string (s)
		end

	http_flush (ctx: like new_request_context)
			-- Flush the output to http client	
		do
			ctx.output.flush
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
