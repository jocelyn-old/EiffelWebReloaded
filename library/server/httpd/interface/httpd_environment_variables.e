note
	description: "Summary description for {HTTPD_EXECUTION_VARIABLES}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_ENVIRONMENT_VARIABLES

inherit
	HTTPD_VARIABLES
		undefine
			copy, is_equal
		end

	HASH_TABLE [STRING, STRING]

create
	make_with_variables,
	make

feature {NONE} -- Initialization

	make_with_variables (a_vars: HASH_TABLE [STRING, STRING])
			-- Fill with variable from `a_vars'
		do
			make (a_vars.count)
			from
				a_vars.start
			until
				a_vars.after
			loop
				force (a_vars.item_for_iteration, a_vars.key_for_iteration)
				a_vars.forth
			end
		end

feature -- Status report

	variable (a_name: STRING): detachable STRING_8
		do
			Result := item (a_name)
		end

	has_variable (a_name: STRING): BOOLEAN
		do
			Result := has (a_name)
		end

feature -- Element change

	replace_variable (v: STRING; k: STRING)
			-- Replace variable `k'
		do
			force (v, k)
		end

	add_variable (v: STRING; k: STRING)
			-- Add variable `k' with value `v'
		require
			k_attached: k /= Void
			v_attached: k /= Void
		do
			force (v, k)
		end

	delete_variable (k: STRING)
			-- Remove variable `k'
		require
			k_attached: k /= Void
		do
			remove (k)
		end

feature -- Request

	request_uri: detachable STRING
			-- Revision of the CGI specification to which this server complies.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.request_uri)
		end

	request_method: detachable STRING
			-- request method used to access the page
			-- i.e. 'GET', 'HEAD', 'POST', 'PUT', 'DELETE'.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.request_method)
		end

	query_string: detachable STRING
			-- query string, if any, via which the page was accessed.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.query_string)
		end

	path_info: detachable STRING
			-- Contains any client-provided pathname information
			-- trailing the actual script filename but preceding the query string, if available.
			--| For instance, if the current script was accessed via the URL
			--| http://www.example.com/eiffel/path_info.exe/some/stuff?foo=bar, then $_SERVER['PATH_INFO'] would contain /some/stuff.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.path_info)
		end

	orig_path_info: detachable STRING
    		-- Original version of `path_info' before processed by Current environment
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.orig_path_info)
		ensure
			has_path_info_if_attached: Result /= Void implies path_info /= Void
		end

	path_translated: detachable STRING
			-- Filesystem- (not document root-) based path to the current script,
			-- after the server has done any virtual-to-real mapping.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.path_translated)
		end

	content_length: INTEGER
			-- Content length
		do
			if
				attached item ({HTTPD_ENVIRONMENT_NAMES}.content_length) as s and then
				s.is_integer
			then
				Result := s.to_integer
			end
		end

	content_type: detachable STRING
			-- Content type
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.content_type)
		end

	http_user_agent: detachable STRING
			-- Contents of the User-Agent: header from the current request, if there is one.
			-- This is a string denoting the user agent being which is accessing the page.
			-- A typical example is: Mozilla/4.5 [en] (X11; U; Linux 2.2.9 i586).
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.http_user_agent)
		end

	http_host: detachable STRING
			-- Contents of the Host: header from the current request, if there is one.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.http_host)
		end

	http_authorization: detachable STRING
			-- Login:password Base64-encoded authorization
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.http_authorization)
		end

feature -- Not request-specific environment variables

	gateway_interface: detachable STRING
			-- Revision of the CGI specification to which this server complies.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.gateway_interface)
		end

	server_name: detachable STRING
			-- Server's hostname, DNS alias, or IP address.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.server_name)
		end

	server_software: detachable STRING
			-- Name and version of information server answering the request.
		once
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.server_software)
		end

feature -- Request specific environment variables

	auth_type: detachable STRING
			-- Protocol-specific authentication method used to validate user.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.auth_type)
		end

	remote_host: detachable STRING
			-- Hostname making the request.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.remote_host)
		end

	remote_addr: detachable STRING
			-- IP address of the remote host making the request.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.remote_addr)
		end

	remote_ident: detachable STRING
			-- User name retrieved from server if RFC 931 supported.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.remote_ident)
		end

	remote_user: detachable STRING
			-- Username, if applicable.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.remote_user)
		end

	script_name: detachable STRING
			-- Virtual path to the script being executed.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.script_name)
		end

	server_port: detachable STRING
			-- Port number to which request was sent.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.server_port)
		end

	server_protocol: detachable STRING
			-- Name and revision of information protocol of this request.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.server_protocol)
		end

feature -- Headerline based environment variables

	http_accept: detachable STRING
			-- MIME types which the client will accept.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.http_accept)
		end

feature -- Cookie

	http_cookie: detachable STRING
			-- Raw value of the 'Cookie' header sent by the user agent.
		do
			Result := item ({HTTPD_ENVIRONMENT_NAMES}.http_cookie)
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
