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

	execute (a_variables: HASH_TABLE [STRING, STRING])
		deferred
		end

feature -- Output

	http_put_string (s: STRING)
		deferred
		end

	http_flush
		deferred
		end

end
