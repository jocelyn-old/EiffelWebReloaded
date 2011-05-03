note
	description: "Summary description for {HTTPD_ENVIRONMENT_NAMES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_ENVIRONMENT_NAMES

feature -- Access

	request_uri: STRING = "REQUEST_URI"

	request_method: STRING = "REQUEST_METHOD"

	query_string: STRING = "QUERY_STRING"

	content_type: STRING = "CONTENT_TYPE"

	content_length: STRING = "CONTENT_LENGTH"

	path_info: STRING = "PATH_INFO"

	path_translated: STRING = "PATH_TRANSLATED"

	http_user_agent: STRING = "HTTP_USER_AGENT"

	http_authorization: STRING = "HTTP_AUTHORIZATION"

	http_host: STRING = "HTTP_HOST"

	http_cookie: STRING = "HTTP_COOKIE"

	http_from: STRING = "HTTP_FROM"

	http_accept: STRING = "HTTP_ACCEPT"

	gateway_interface: STRING = "GATEWAY_INTERFACE"

	auth_type: STRING = "AUTH_TYPE"

	remote_host: STRING = "REMOTE_HOST"

	remote_addr: STRING = "REMOTE_ADDR"

	remote_ident: STRING = "REMOTE_IDENT"

	remote_user: STRING = "REMOTE_USER"

	script_name: STRING = "SCRIPT_NAME"

	server_name: STRING = "SERVER_NAME"

	server_port: STRING = "SERVER_PORT"

	server_protocol: STRING = "SERVER_PROTOCOL"

	server_software: STRING = "SERVER_SOFTWARE"

feature -- Extra names

	orig_path_info: STRING = "ORIG_PATH_INFO"

end
