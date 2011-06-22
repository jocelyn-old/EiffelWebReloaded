note
	description: "Summary description for {HTTPD_CGI_SERVER_OUTPUT}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_CGI_SERVER_OUTPUT

inherit
	HTTPD_SERVER_OUTPUT
		undefine
			flush
		end

	CONSOLE
		rename
			make as console_make
		end

create
	make

feature {NONE} -- Initialization

	make
		do
			make_open_stdout ("stdout")
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
