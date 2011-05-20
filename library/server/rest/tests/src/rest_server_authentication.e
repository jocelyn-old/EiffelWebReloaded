note
	description: "Summary description for {REST_SERVER_AUTHENTICATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_SERVER_AUTHENTICATION

inherit
	HTTPD_AUTHORIZATION_AUTHENTICATION

feature -- Status report

	is_valid_login_password (a_login, a_password: STRING): BOOLEAN
		do
				--| This is just to test ... !!!
			Result := a_login ~ a_password
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
