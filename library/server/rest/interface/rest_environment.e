note
	description: "Summary description for {REST_ENVIRONMENT}."
	date: "$Date$"
	revision: "$Revision$"

class
	REST_ENVIRONMENT

inherit
	HTTPD_ENVIRONMENT
		redefine
			analyze
		end

create {HTTPD_APPLICATION}
	make

feature -- Basic operation

	analyze
			-- Analyze environment, and set various attributes
		do
			Precursor
			if not has_error then
				validate_cookies
				if not authenticated then
					validate_http_authorization
				end
			end
		end

	validate_cookies
		do
		end

	validate_http_authorization
		do
			if
				attached authentication as auth and then
				attached auth.validation (Current) as auth_data
			then
				if auth_data.authenticated then
					authenticated := True
					authenticated_login := auth_data.identifier
				else
					authenticated := False
					authenticated_login := Void
				end
			end
		end

feature -- Authentication

	authentication: detachable HTTPD_AUTHENTICATION
			-- Optional authentication system	

feature -- Authentication report

	authenticated: BOOLEAN

	authenticated_login: detachable STRING_GENERAL

invariant
	valid_login_if_authenticated: authenticated implies (attached authenticated_login as l and then not l.is_empty)

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
