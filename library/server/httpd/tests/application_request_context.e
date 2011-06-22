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
			validate_cookies,
			validate_authentication
		end

create {HTTPD_APPLICATION}
	make


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
				authenticated_identifier := l_user.value
			end
		end

	validate_authentication
		do
			if attached http_authorization_login_password as l_login_password then
				authenticated := l_login_password.login.same_string ("abc") and
								 l_login_password.password.same_string ("def")
				if authenticated then
					authenticated_identifier := l_login_password.login
				end
			end
		end

end
