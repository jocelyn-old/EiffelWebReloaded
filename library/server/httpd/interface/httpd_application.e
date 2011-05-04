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

	call_execute (a_variables: HASH_TABLE [STRING, STRING])
			-- Call execute
			--| Note: you can redefine this feature, if you want to optimize
			--| as much as possible a very simple query
			--| without fetching GET, POST, ... data
		local
			rescued: BOOLEAN
			henv: detachable like new_environment
		do
			if not rescued then
				pre_execute
				henv := new_environment (a_variables)
				execute (henv)
				post_execute (henv, Void)
			else
				post_execute (henv, (create {EXCEPTION_MANAGER}).last_exception)
			end
		rescue
			rescued := True
			retry
		end

	pre_execute
			-- Operation processed before `execute'
		do
		end

	post_execute (henv: detachable like new_environment; e: detachable EXCEPTION)
			-- Operation processed after `execute', or on rescue
		do
			if henv /= Void then
				henv.recycle
			end
		end

	execute (henv: like new_environment)
			-- Execute the request
		deferred
		end

feature -- Environment

	new_environment (a_vars: HASH_TABLE [STRING, STRING]): HTTPD_ENVIRONMENT
			-- New httpd environment based on `a_vars' and `input'
			--| note: you can redefine this function to create your own
			--| descendant of HTTPD_ENVIRONMENT , or even to reuse/recycle existing
			--| instance of HTTPD_ENVIRONMENT
		do
			create Result.make (a_vars, input)
		end

feature -- Input

	input: HTTPD_SERVER_INPUT
			-- Input from httpd server
		deferred
		end

feature -- Output

	http_put_exception_trace
			-- Print exception trace is any
		do
			if attached (create {EXCEPTIONS}).exception_trace as l_trace then
				http_put_string ("Exception occurred%N")
				http_put_string ("<pre>" + l_trace + "</pre>")
				http_flush
			end
		end

	http_put_file_content (fn: STRING)
			-- Send the content of file `fn'
		local
			f: RAW_FILE
		do
			create f.make (fn)
			if f.exists and then f.is_readable then
				f.open_read
				from
				until
					f.exhausted
				loop
					f.read_stream (1024)
					http_put_string (f.last_string)
				end
				f.close
			end
		end

	http_put_header_line (s: STRING)
			-- Send `s' to http client as header line
		do
			http_put_string (s)
			http_put_string ("%R%N")
		end

	http_put_string (s: STRING)
			-- Send `s' to http client
		deferred
		end

	http_flush
			-- Flush the output to http client	
		deferred
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
