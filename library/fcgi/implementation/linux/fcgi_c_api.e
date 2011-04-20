note
	description: "Wrappers around FastCGI C API."
	date: "$Date$"
	revision: "$Revision$"

class
	FCGI

feature -- Connection

	accept: INTEGER
			-- Accept a Fast CGI connection.
			-- Return 0 for successful calls, -1 otherwise.
		external
			"C inline use %"fcgi_stdio.h%""
		alias
			"return FCGI_Accept();"
		end

	finish
			-- Finished current request from HTTP server started from
			-- the most recent call to `fcgi_accept'.
		external
			"C inline use %"fcgi_stdio.h%""
		alias
			"FCGI_Finish();"
		end

	set_exit_status (v: INTEGER)
			-- Set the exit status for the most recent request
		external
			"C inline use %"fcgi_stdio.h%""
		alias
			"[
				FCGI_SetExitStatus($v);
			]"
		end

feature -- Input

	read_content_into (a_buffer: POINTER; a_length: INTEGER): INTEGER
			-- Read content stream into `a_buffer' but no more than `a_length' character.
		external
			"C inline use %"fcgi_stdio.h%""
		alias
			"[
				{
					size_t n;
					if (! FCGI_feof(FCGI_stdin)) {
						n = FCGI_fread($a_buffer, 1, $a_length, FCGI_stdin);
					} else {
						 n = 0;
					}
					return n;
				}
			]"
		end


	gets (s: POINTER): POINTER
			-- gets() reads a line from stdin into the buffer pointed to
			-- by s until either a terminating newline or EOF, which it
			-- replaces with '\0'
			-- No check for buffer overrun is performed
		external
			"C inline use %"fcgi_stdio.h%""
		alias
			"[
				return FCGI_gets($s);
			]"
		end

feature -- Output

	put_string (v: POINTER; n: INTEGER)
		external
			"C inline use %"fcgi_stdio.h%""
		alias
			"[
				FCGI_fwrite($v, 1, $n, FCGI_stdout);
			]"
		end


end
