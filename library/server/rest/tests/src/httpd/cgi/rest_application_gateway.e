deferred class
	REST_APPLICATION_GATEWAY

inherit
	HTTPD_CGI_APPLICATION

feature -- Access

	gateway_name: STRING = "CGI"

end
