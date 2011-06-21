note
	description: "Summary description for {APPLICATION_REQUEST_CONTEXT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION_REQUEST_CONTEXT

inherit
	HTTPD_REQUEST_CONTEXT
		redefine
			analyze,
			initialize
		end

create {HTTPD_APPLICATION}
	make

feature {NONE} -- Initialize

	initialize
		do
			create authenticated_login.make_empty
			Precursor
		end

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
		local
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

	validate_http_authorization
		do
			if attached http_authorization_login_password as l_login_password then
				authenticated := l_login_password.login.same_string ("abc") and
								 l_login_password.password.same_string ("def")
				if authenticated then
					authenticated_login := l_login_password.login
				end
			end
		end

feature -- Authentication

	authenticated: BOOLEAN

	authenticated_login: STRING

end
