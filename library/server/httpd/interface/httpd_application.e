note
	description: "Summary description for {HTTPD_APPLICATION}."
	author: ""
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
		local
			rescued: BOOLEAN
			henv: detachable HTTPD_ENVIRONMENT
		do
			if not rescued then
				pre_execute
				create henv.make (enhanced_variables (a_variables), input)
				execute (henv)
				post_execute (henv)
			else
				http_put_string ("Exception occurred%N")
				if attached (create {EXCEPTIONS}).exception_trace as l_trace then
					http_put_string ("<pre>" + l_trace + "</pre>")
				end
				http_flush
				post_execute (henv)
			end
		rescue
			rescued := True
			retry
		end

	pre_execute
			-- Operation processed before `execute'
		do
		end

	post_execute (henv: detachable HTTPD_ENVIRONMENT)
			-- Operation processed after `execute', or on rescue
		do
			if henv /= Void then
				henv.recycle
			end
		end

	execute (henv: HTTPD_ENVIRONMENT)
		deferred
		end

feature -- Input

	input: HTTPD_SERVER_INPUT
			-- Input from httpd server
		deferred
		end

feature -- Output

	http_put_string (s: STRING)
			-- Send `s' to http client
		deferred
		end

	http_flush
			-- Flush the output to http client	
		deferred
		end

feature -- Environment variables

	enhanced_variables (a_variables: HASH_TABLE [STRING, STRING]): HASH_TABLE [STRING, STRING]
			-- Add extra variables that might be useful
		local
			p: INTEGER
		do
			Result := a_variables
				--| do not use `force', to avoid overwriting existing variable
			if attached a_variables.item ("REQUEST_URI") as rq_uri then
				p := rq_uri.index_of ('?', 1)
				if p > 0 then
					Result.put (rq_uri.substring (1, p-1) ,"EIFFEL_SELF")
				else
					Result.put (rq_uri ,"EIFFEL_SELF")
				end
			end
			Result.put (current_unix_time.out, "REQUEST_TIME")
		ensure
			result_attached: Result /= Void
		end

	current_unix_time: DOUBLE
			-- Current unix time
		do
			Result := (create {DATE_TIME}.make_now_utc).definite_duration (create {DATE_TIME}.make_from_epoch (0)).fine_seconds_count
		end

end
