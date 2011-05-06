note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	CURL_REST_SERVICE_API

inherit
	REST_SERVICE_API
		redefine
			internal_api_call
		end

feature {NONE} -- Implementation

	internal_api_call (a_api_url: STRING; a_require_credentials: BOOLEAN; a_http_post: BOOLEAN): STRING
			-- REST API call for `a_api_url' with `a_require_credentials' and `a_http_post'
		local
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
			p: POINTER
			a_data: CELL [detachable ANY]
		do
			l_url := a_api_url.string
			if attached application_source as l_app_src then
				append_parameters_to_url (l_url, <<["source", l_app_src]>>)
			end

			curl_handle := curl_easy.init

			curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_url, l_url)
			if a_require_credentials then
				if attached credentials as l_credentials then
					curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_userpwd, l_credentials)
				else
					check credentials_attached: False end
				end
			end
			if a_http_post then
				curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_post, 1)
			end

			curl.global_init
			p := curl.slist_append (p, "Expect:")
			curl_easy.setopt_slist (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_httpheader, p)
			curl.global_cleanup

			curl_easy.set_read_function (curl_handle)
			curl_easy.set_write_function (curl_handle)
			create l_curl_string.make_empty
			curl_easy.setopt_curl_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_writedata, l_curl_string)

			debug ("service")
				io.put_string ("SERVICE: " + l_url)
				io.put_new_line
			end
			l_result := curl_easy.perform (curl_handle)

			create a_data.put (Void)
			l_result := curl_easy.getinfo (curl_handle, {CURL_INFO_CONSTANTS}.curlinfo_response_code, a_data)
			if l_result = 0 and then attached {INTEGER} a_data.item as l_http_status then
				http_status := l_http_status
			else
				http_status := 0
			end

			last_api_call := l_url
			curl_easy.cleanup (curl_handle)
			Result := l_curl_string.string
		end

feature {NONE} -- Implementation

	curl: CURL_EXTERNALS
			-- cURL externals
		once
			create Result
		end

	curl_easy: CURL_EASY_EXTERNALS
			-- cURL easy externals
		once
			create Result
		end

	curl_handle: POINTER
			-- cURL handle

;note
	copyright: "Copyright (c) 1984-2011, Eiffel Software and others"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
