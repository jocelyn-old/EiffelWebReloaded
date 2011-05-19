note
	description: "Summary description for {HTTPD_AUTHORIZATION_AUTHENTICATION_DATA}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_AUTHORIZATION_AUTHENTICATION_DATA

inherit
	HTTPD_AUTHENTICATION_DATA

create
	make

feature {NONE} -- Initialization

	make (u: STRING_GENERAL)
		do
			identifier := u
		end

feature -- Access

	authenticated: BOOLEAN = True

	identifier: STRING_GENERAL

invariant
	identifier_attached: identifier /= Void

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

