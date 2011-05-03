note
	description: "Summary description for {HTTPD_SERVER_INPUT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_SERVER_INPUT

feature -- Basic operation

	read_stream (nb_char: INTEGER)
			-- Read a string of at most `nb_char' bound characters
			-- or until end of file.
			-- Make result available in `last_string'.	
		require
			nb_char_positive: nb_char > 0
		deferred
		end

feature -- Access		

	last_string: STRING
			-- Last string read
		deferred
		end

end
