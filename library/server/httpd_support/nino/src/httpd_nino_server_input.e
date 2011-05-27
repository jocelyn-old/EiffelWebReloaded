note
	description: "Summary description for {HTTPD_NINO_SERVER_INPUT}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_NINO_SERVER_INPUT

inherit
	HTTPD_SERVER_INPUT

create
	make,
	make_empty

feature {NONE} -- Initialization

	make_empty
		do
			create last_string.make_empty
		end

	make (a_nino_input: attached like nino_input)
		do
			make_empty
			set_nino_input (a_nino_input)
		end

feature {HTTPD_NINO_APPLICATION} -- Nino

	set_nino_input (i: like nino_input)
		do
			nino_input := i
		end

	nino_input: detachable HTTP_INPUT_STREAM

feature -- Basic operation

	read_stream (nb_char: INTEGER)
			-- Read a string of at most `nb_char' bound characters
			-- or until end of file.
			-- Make result available in `last_string'.	
		do
			if attached nino_input as i then
				i.read_stream (nb_char)
				last_string := i.last_string
			else
				last_string.wipe_out
			end
		end

feature -- Access		

	last_string: STRING
			-- Last string read	

;note
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
