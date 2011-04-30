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

	fcgi_environ: POINTER
		do
			Result := fcgi.environ
		end

--	updated_environ_variables: HASH_TABLE [STRING, STRING]
--		local
----			n, l_size,
--			i: INTEGER
--			p, v, null: POINTER
--		do
----			update_eif_environ
----			Result := starting_environment_variables
--
----			p := environ_strings_pointer ($n)
----			from
----				i := 1
----				l_size := 0
----				create Result.make (n)
----			until
----				i > n
----			loop
----				create s.make_from_c (p.plus (l_size))
----				l_size := l_size + s.count + 1
----				if attached separated_variables (s) as t then
----					Result.force (t.value, t.key)
----				end
----				i := i + 1
----			end
--
--			p := fcgi.environ
--			create Result.make (50)
--			if p /= null then
--				from
--					i := 0
--					v := fcgi_i_th_environ (i,p)
--				until
--					v = null
--				loop
--					if attached separated_variables (create {STRING}.make_from_c (v)) as t then
--						Result.force (t.value, t.key)
--					end
--					i := i + 1
--					v := fcgi_i_th_environ (i,p)
--				end
--			end
--		end
--
--	fcgi_i_th_environ (i: INTEGER; p: POINTER): POINTER
--			-- Environment variable at `i'-th position of `p'.
--		require
--			i_valid: i >=0
--		external
--			"C inline use <string.h>"
--		alias
--			"[
--				return ((char **)$p)[$i];
--			]"
--		end

feature -- FCGI connection

	fcgi_listen: INTEGER
			-- Listen to the FCGI input stream
			-- Return 0 for successful calls, -1 otherwise.
		do
			Result := fcgi.accept
		end

--	update_eif_environ
--		external
--			"C inline use <string.h>"
--		alias
--			"[
--				#ifdef EIF_WINDOWS
--					#ifndef GetEnvironmentStringsA
--					 extern LPVOID WINAPI GetEnvironmentStringsA(void);
--					#endif	
--					
--					eif_environ = (char**) GetEnvironmentStringsA();
--				#endif
--			]"
--		end

	fcgi_finish
			-- Finish current request from HTTP server started from
			-- the most recent call to `fcgi_accept'.
		do
			fcgi.finish
		end

	set_fcgi_exit_status (v: INTEGER)
		do
			fcgi.set_exit_status (-2)
		end

feature -- FCGI output

	put_string (a_str: STRING)
			-- Put `a_str' on the FastCGI stdout.
		local
			l_c_str: C_STRING
		do
			l_c_str := c_buffer
			l_c_str.set_string (a_str)
			fcgi.put_string (l_c_str.item, l_c_str.count)
		end

feature -- FCGI input

	read_from_stdin (n: INTEGER)
			-- Read up to n bytes from stdin and store in c_buffer
		local
			l_c_str: C_STRING
			l_count: INTEGER
		do
			last_read_is_empty_ref.set_item (False)
			l_c_str := c_buffer
			l_count := fcgi.read_content_into (l_c_str.item, n)
			last_read_count_ref.set_item (l_count)
			if l_count <= 0 then
				last_read_is_empty_ref.set_item (True)
			end
		end

	copy_from_stdin (n: INTEGER; tf: FILE)
			-- Read up to n bytes from stdin and write to given file
		local
			l_c_str: C_STRING
			num, readsize, writecount: INTEGER
			done: BOOLEAN
			l_fcgi: like fcgi
		do
			--put_trace ("copy_from_stdin, n=" +n.out)
			readsize := n.min (K_input_bufsize)
			--put_trace ("copy_from_stdin, readsize=" +readsize.out)
			l_c_str := c_buffer
			from
				l_fcgi := fcgi
			until done or writecount >= n
			loop
				num := l_fcgi.read_content_into (l_c_str.item, readsize)
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
--RFO			n := fcgi.read_content_into (l_c_str.item, l_c_str.capacity)
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
--RFO			p := fcgi.gets (l_c_str.item)
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
		local
			n: like last_read_count
		do
			n := last_read_count
			create Result.make (n)
			Result.set_count (n)
			c_buffer.read_substring_into (Result, 1, n)
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

feature {NONE} -- Implementation: environment

--	separated_variables (a_var: STRING): detachable TUPLE [value: STRING; key: STRING]
--			-- Given an environment variable `a_var' in form of "key=value",
--			-- return separated key and value.
--			-- Return Void if `a_var' is in incorrect format.
--		require
--			a_var_attached: a_var /= Void
--		local
--			i, j: INTEGER
--			done: BOOLEAN
--		do
--			j := a_var.count
--			from
--				i := 1
--			until
--				i > j or done
--			loop
--				if a_var.item (i) = '=' then
--					done := True
--				else
--					i := i + 1
--				end
--			end
--			if i > 1 and then i < j then
--				Result := [a_var.substring (i + 1, j), a_var.substring (1, i - 1)]
--			end
--		end
--
--	environ_strings_pointer (p_nb: TYPED_POINTER [INTEGER]): POINTER
--			-- Environment variable strings returned by `GetEnvironmentStringsA'
--			-- `p_nb' return the count of environment variables.
--		external
--			"C inline use <string.h>"
--		alias
--			"[
--				#ifdef EIF_WINDOWS
--					#ifndef GetEnvironmentStringsA
--					 extern LPVOID WINAPI GetEnvironmentStringsA(void);
--					#endif	
--					
--					int cnt = 0;
--					LPSTR vars = GetEnvironmentStringsA();
--					char** p = (char**) vars;
--					
--					for (; *vars; vars++) {
--					   while (*vars) { vars++; }
--					   cnt++;
--					}
--					
--					*$p_nb = cnt;
--					return (EIF_POINTER) p;
--				#endif
--			]"
--		end


end
