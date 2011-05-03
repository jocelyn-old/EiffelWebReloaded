note
	description: "Summary description for {HTTPD_FCGI_SERVER_INPUT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_FCGI_SERVER_INPUT

inherit
	HTTPD_SERVER_INPUT

	STRING_HANDLER

create
	make

feature {NONE} -- Initialization

	make (a_fcgi: like fcgi)
		require
			valid_fcgi: a_fcgi /= Void
		do
			fcgi := a_fcgi
			initialize
		end

	initialize
			-- Initialize Current
		do
			create last_string.make_empty
		end

feature -- Basic operation

	read_stream (nb_char: INTEGER)
			-- Read a string of at most `nb_char' bound characters
			-- or until end of file.
			-- Make result available in `last_string'.	
		do
			fcgi.fill_string_from_stdin (last_string, nb_char)
		end

feature -- Access		

	last_string: STRING
			-- Last string read	

feature {NONE} -- Implementation

	fcgi: FCGI
			-- Bridge to FCGI world

end
