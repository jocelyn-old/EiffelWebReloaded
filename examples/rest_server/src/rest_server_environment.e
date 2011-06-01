note
	description: "Summary description for {REST_SERVER_ENVIRONMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_SERVER_ENVIRONMENT

inherit
	REST_ENVIRONMENT
		redefine
			authentication,
			validate_cookies,
			initialize
		end

create {HTTPD_APPLICATION}
	make

feature {NONE} -- Initialize

	initialize
		do
			create authentication
			Precursor
		end

feature -- Basic operation

	validate_cookies
		do
			if
				attached cookies as l_cookies and then
				attached l_cookies.item ("uuid") as l_uuid and then
				attached l_cookies.item ("auth") as l_auth and then
				attached l_cookies.item ("user") as l_user
			then
				authenticated := l_auth.value_is_string ("yes")
				authenticated_login := l_user.value
			end
		end

feature -- Authentication		

	authentication: detachable REST_SERVER_AUTHENTICATION
			-- Optional authentication system

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
