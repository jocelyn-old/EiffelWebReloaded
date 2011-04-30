note
	description: "Summary description for {HTTPD_ENVIRONMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make (a_vars: like execution_variables)
		do
			execution_variables := a_vars
			create error_handler.make
			analyze
		end

feature -- Basic operation

	analyze
			-- Analyze environment, and set various attributes
		do
			extract_variables
			if not has_error then
				validate_http_cookie
			end
		end

feature -- Status report

	has_error: BOOLEAN
		do
			Result := error_handler.has_error
		end

	error_handler: ERROR_HANDLER

feature -- Access: variable

	execution_variables: HASH_TABLE [STRING, STRING]

	variable (a_name: STRING): detachable STRING
			-- Execution environment variable related to `a_name'
		require
			a_name_valid: a_name /= Void and then not a_name.is_empty
		do
			Result := execution_variables.item (a_name)
		end

feature -- Access

	request_uri: detachable STRING
	request_method: detachable STRING
	http_user_agent: detachable STRING
	http_authorization: detachable STRING
	http_host: detachable STRING
	query_string: detachable STRING
	content_type: detachable STRING
	content_length: INTEGER
	http_path_translated: detachable STRING
	http_cookie: detachable STRING
	http_from: detachable STRING

feature -- Element change

	set_http_host (s: detachable STRING)
		do
			http_host := s
			-- analyze_http_host
		end

	set_content_type (t: detachable STRING)
		do
			content_type := t
		end

	set_content_length (n: INTEGER)
		do
			content_length := n
		end

	set_query_string (s: detachable STRING)
		do
			query_string := s
		end

	set_http_path_translated (s: detachable STRING)
		do
			http_path_translated := s
			-- analyze_http_path_translated
		end

feature {NONE} -- Implementation

	report_bad_request_error (a_message: detachable STRING)
			-- Report error
		local
			e: HTTPD_ERROR
		do
			create e.make ({HTTP_STATUS_CODE}.bad_request)
			if a_message /= Void then
				e.set_message (a_message)
			end
			error_handler.add_error (e)
		end

	extract_variables
			-- Extract relevant environment variables
		local
			s: detachable STRING
		do
			s := variable (REQUEST_URI_name)
			if s /= Void and then not s.is_empty then
				request_uri := s
			else
				report_bad_request_error ("Missing URI")
			end
			if not has_error then
				s := variable (REQUEST_METHOD_name)
				if s /= Void and then not s.is_empty then
					request_method := s
				else
					report_bad_request_error ("Missing request method")
				end
			end
			if not has_error then
				http_user_agent := variable (HTTP_USER_AGENT_name)
				http_authorization := variable (HTTP_AUTHORIZATION_name)
--				analyze_authorization
			end
			if not has_error then
				if attached variable (HTTP_HOST_name) as l_host and then not l_host.is_empty then
					set_http_host (l_host)
				else
					report_bad_request_error ("Missing host header")
				end
			end
			if not has_error then
				set_query_string (variable (QUERY_STRING_name))
				s := variable (CONTENT_TYPE_name)
				if s /= Void and then not s.is_empty then
					set_content_type (s)
				end
				s := variable (CONTENT_LENGTH_name)
				if s /= Void and then s.is_integer then
					set_content_length (s.to_integer)
				end
				set_http_path_translated (variable (HTTP_PATH_TRANSLATED_name))
				http_cookie := variable (HTTP_COOKIE_name)
				http_from := variable (HTTP_FROM_name)
			end
		end

	validate_http_cookie
		do
			if attached http_cookie as l_cookie and then not l_cookie.is_empty then

			end
		end

feature -- Variable names

	REQUEST_URI_name: STRING = "REQUEST_URI"

	REQUEST_METHOD_name: STRING = "REQUEST_METHOD"

	QUERY_STRING_name: STRING = "QUERY_STRING"

	CONTENT_TYPE_name: STRING = "CONTENT_TYPE"

	CONTENT_LENGTH_name: STRING = "CONTENT_LENGTH"

	HTTP_USER_AGENT_name: STRING = "HTTP_USER_AGENT"

	HTTP_AUTHORIZATION_name: STRING = "HTTP_AUTHORIZATION"

	HTTP_HOST_name: STRING = "HTTP_HOST"

	HTTP_PATH_TRANSLATED_name: STRING = "HTTP_PATH_TRANSLATED"

	HTTP_COOKIE_name: STRING = "HTTP_COOKIE"

	HTTP_FROM_name: STRING = "HTTP_FROM"

end
