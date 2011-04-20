deferred class FCGI_IMP

inherit
	FCGI_I
	STRING_HANDLER

feature {NONE} -- Initialization

	make
			-- Initialize FCGI interface
		do
			create fcgi
		end

	fcgi: FCGI_C_API
			-- FastCGI C API primitives


feature -- Access

	updated_environ_variables: HASH_TABLE [STRING, STRING]
		do
			update_eif_environ
			Result := starting_environment_variables
		end

feature -- FCGI Connection

	fcgi_listen: INTEGER
			-- Listen to the FCGI input stream
			-- Return 0 for successful calls, -1 otherwise.
		do
			Result := {FCGI_C_API}.accept
		end

	update_eif_environ
		external
			"C inline use <string.h>"
		alias
			"[
				eif_environ = (char**) environ;
			]"
		end
		
	fcgi_finish
			-- Finish current request from HTTP server started from
			-- the most recent call to `fcgi_accept'.
		do
			{FCGI_C_API}.finish
		end

	set_fcgi_exit_status (v: INTEGER)
		do
			{FCGI}.set_exit_status (-2)
		end

feature -- FCGI output

	put_string (a_str: STRING)
			-- Put `a_str' on the FastCGI stdout.
		local
			l_c_str: C_STRING
		do
			l_c_str := c_buffer
			l_c_str.set_string (a_str)
			{FCGI}.put_string (l_c_str.item, l_c_str.count)
		end

--	fcgi_printf (fmt: STRING; args: FINITE[ANY])
--			-- Put args, formatted per 'fmt' on the FastCGI stdout.
--		local
--			l_c_str: C_STRING
--		do
--			create l_c_str.make (apf.aprintf (fmt, args))
--			{FCGI}.put_string (l_c_str.item, l_c_str.count)
--		end

feature -- FCGI Input

	read_from_stdin (n: INTEGER)
			-- Read up to n bytes from stdin and store in c_buffer
		local
			l_c_str: C_STRING
		do
			last_read_is_empty_ref.set_item (False)
			l_c_str := c_buffer
			last_read_count_ref.set_item ({FCGI}.read_content_into (l_c_str.item, n))
			if last_read_count <= 0 then
				last_read_is_empty_ref.set_item (True)
			end
		end

	copy_from_stdin (n: INTEGER; tf: FILE)
			-- Read up to n bytes from stdin and write to given file
		local
			l_c_str: C_STRING
			num, readsize, writecount: INTEGER
			done: BOOLEAN
		do
			--put_trace ("copy_from_stdin, n=" +n.out)
			readsize := n.min (K_input_bufsize)
			--put_trace ("copy_from_stdin, readsize=" +readsize.out)
			l_c_str := c_buffer
			from
			until done or writecount >= n
			loop
				num := {FCGI}.read_content_into (l_c_str.item, readsize)
				--put_trace ("copy_from_stdin, num=" +num.out)
				if num  = 0 then
					-- EOF
					done := True
				else
					tf.put_managed_pointer (c_buffer.managed_data, 0, num)
					writecount := writecount + num
				end
			end
		end

feature -- I/O Routines

--RFO	read_stdin_into (a_str: STRING)
--RFO			-- Read a string from the `stdin' into `a_str'.
--RFO		require
--RFO			a_str_not_void: a_str /= Void
--RFO		local
--RFO			l_c_str: C_STRING
--RFO			n: INTEGER
--RFO		do
--RFO			l_c_str := c_buffer
--RFO			n := {FCGI}.read_content_into (l_c_str.item, l_c_str.capacity)
--RFO			a_str.set_count (n)
--RFO			l_c_str.read_substring_into (a_str, 1, n)
--RFO		end

--RFO	read_string_into (a_str: STRING)
--RFO		require
--RFO			exists: a_str /= Void
--RFO		local
--RFO			l_c_str: C_STRING
--RFO			p: POINTER
--RFO		do
--RFO			create l_c_str.make_empty (1024)
--RFO			p := {FCGI}.gets (l_c_str.item)
--RFO--			if p /= default_pointer and p = l_c_str.item then
--RFO				a_str.resize (l_c_str.count)
--RFO				l_c_str.read_string_into (a_str)
--RFO--			else
--RFO--				put_error_line ("Bad pointer from gets")
--RFO--			end
--RFO		end

--RFO	read_line
--RFO			-- Read up to the next end of line, or end of input
--RFO			-- Leave result in last_string
--RFO			-- Newline character is absent from result
--RFO		do
--RFO			if last_string = Void then
--RFO				create Result.make (K_input_bufsize)
--RFO			else
--RFO				last_string.wipe_out
--RFO			end
--RFO--			if input_filename /= Void then
--RFO--				io.read_line
--RFO--				last_string.append (io.last_string)
--RFO--			else
--RFO				read_string_into (last_string)
--RFO--			end
--RFO		end

feature -- Status

	buffer_contents: STRING
		do
			create Result.make (last_read_count)
			Result.set_count (last_read_count)
			c_buffer.read_substring_into (Result, 1, last_read_count)
		end

	buffer_capacity: INTEGER
		do
			Result := c_buffer.capacity
		end

feature {NONE} -- Shared buffer

	c_buffer: C_STRING
			-- Buffer for Eiffel to C and C to Eiffel string conversions.
		once
			create Result.make_empty (K_input_bufsize)
		ensure
			c_buffer_not_void: Result /= Void
		end

end
