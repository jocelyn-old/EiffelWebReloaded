deferred class FCGI_I

feature {NONE} -- Initialization

	make
			-- Initialize FCGI interface
		deferred
		end

feature -- Access

	updated_environ_variables: HASH_TABLE [STRING, STRING]
			-- Updated environ variables after `fcgi_listen' is returning.
		deferred
		end

feature -- FCGI interface

	fcgi_listen: INTEGER
			-- Listen to the FCGI input stream
			-- Return 0 for successful calls, -1 otherwise.
		deferred
		end

	fcgi_finish
			-- Finish current request from HTTP server started from
			-- the most recent call to `fcgi_accept'.
		deferred
		end

	set_fcgi_exit_status (v: INTEGER)
		deferred
		end

feature -- Status

	is_interactive: BOOLEAN
			-- Is execution interactive? (for debugging)
		do
		end

feature -- Input

	read_from_stdin (n: INTEGER)
			-- Read up to n bytes from stdin and store in input buffer
		require
			small_enough: n <= buffer_capacity
		deferred
		end


	copy_from_stdin (n: INTEGER; tf: FILE)
			-- Read up to n bytes from stdin and write to given file
		require
--			small_enough: n <= buffer_capacity
			file_exists: tf /= Void
			file_open: tf.is_open_write or tf.is_open_append
		deferred
		end

feature -- Output

	put_string (a_str: STRING)
			-- Put `a_str' on the FastCGI stdout.
		require
			a_str_not_void: a_str /= Void
		deferred
		end

feature -- Implementation		

	buffer_contents: STRING
		deferred
		end

	buffer_capacity: INTEGER
		deferred
		end

	last_read_count: INTEGER
		do
			Result := last_read_count_ref.item
		end

	last_read_is_empty: BOOLEAN
		do
			Result := last_read_is_empty_ref.item
		end

--RFO	last_string: STRING
--RFO		once
--RFO			create Result.make (K_input_bufsize)
--RFO		end

feature {NONE} -- Constants

	last_read_count_ref: INTEGER_REF
		once
			create Result
		end

	last_read_is_empty_ref: BOOLEAN_REF
		once
			create Result
		end

	K_input_bufsize: INTEGER = 1024000

end
