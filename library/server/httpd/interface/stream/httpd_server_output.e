note
	description: "Summary description for {HTTPD_SERVER_OUTPUT}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_SERVER_OUTPUT

feature -- Basic operation

	put_file_content (fn: STRING)
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
					put_string (f.last_string)
				end
				f.close
			end
		end

	put_header_line (s: STRING)
			-- Send `s' to http client as header line
		do
			put_string (s)
			put_string ("%R%N")
		end

	put_string (s: STRING)
			-- Send `s' to http client
		deferred
		end

	flush
			-- Flush the output to http client	
		do
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
