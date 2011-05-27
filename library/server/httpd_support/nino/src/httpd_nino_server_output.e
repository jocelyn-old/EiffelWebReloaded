note
	description: "Summary description for {HTTPD_NINO_SERVER_OUTPUT}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_NINO_SERVER_OUTPUT

inherit
	HTTPD_SERVER_OUTPUT

create
	make,
	make_empty

feature {NONE} -- Initialization

	make_empty
		do
		end

	make (a_nino_output: attached like nino_output)
		do
			make_empty
			set_nino_output (a_nino_output)
		end

feature {HTTPD_NINO_APPLICATION} -- Nino

	set_nino_output (o: like nino_output)
		do
			nino_output := o
		end

	nino_output: detachable HTTP_OUTPUT_STREAM

feature -- Basic operation

	put_string (s: STRING_8)
			-- Send `s' to http client
		do
			print (s)
			if attached nino_output as o then
				o.put_string (s)
			end
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
