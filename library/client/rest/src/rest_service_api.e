note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	REST_SERVICE_API

inherit
	REFACTORING_HELPER

feature -- Access

	credentials: detachable STRING_32
			-- Username:password format string

	service_api_url: STRING

	format: STRING
			-- Default format

	application_source: detachable STRING
			--	/* Contains the application calling the API */

feature -- Access

	http_status: INTEGER
		--	/* Contains the last HTTP status code returned */

	last_api_call: detachable STRING
		--	/* Contains the last API call */


feature -- status report

	format_is_xml: BOOLEAN
			-- Format is `xml'
		do
			Result := format = xml_id
		end

	format_is_json: BOOLEAN
			-- Format is `json'	
		do
			Result := format = json_id
		end

	format_is_rss: BOOLEAN
				-- Format is `rss'
		do
			Result := format = rss_id
		end

	format_is_atom: BOOLEAN
				-- Format is `atom'
		do
			Result := format = atom_id
		end

feature -- Element change

	set_json_format
			-- Set format to `json'
		do
			format := json_id
		end

	set_xml_format
			-- Set format to `xml'	
		do
			format := xml_id
		end

	set_rss_format
			-- Set format to `rss'	
		do
			format := rss_id
		end

	set_atom_format
			-- Set format to `atom'	
		do
			format := atom_id
		end

	set_service_api_url (a_url: like service_api_url)
		do
			service_api_url := a_url
		end

	set_application_source (a_source: like application_source)
		do
			if a_source /= Void then
				application_source := urlencode (a_source)
			else
				application_source := Void
			end
		end

feature {NONE} -- Implementation

	service_url (a_query: STRING; a_path_param: detachable STRING; a_format: STRING): STRING
			-- Application url for `a_query' and `a_path_param'
		require
			a_query_attached: a_query /= Void
		do
				--| FIXME: some api need the format at the end ...
				--| find a way to support that as well
			Result := url (service_api_url + a_query + "." + a_format, a_path_param)
		ensure
			Result_attached: Result /= Void
		end

	url (a_base_url: STRING; a_path_param: detachable STRING): STRING
			-- url for `a_base_url' and `a_path_param'
		require
			a_base_url_attached: a_base_url /= Void
		do
			create Result.make_from_string (a_base_url)
			if a_path_param /= Void then
				Result.append_string (a_path_param)
			end
		end

	append_parameters_to_url (a_url: STRING; a_parameters: detachable ARRAY [detachable TUPLE [name: STRING; value: STRING]])
			-- Append parameters `a_parameters' to `a_url'
		require
			a_url_attached: a_url /= Void
		local
			i: INTEGER
			l_first_param: BOOLEAN
		do
			if a_parameters /= Void and then a_parameters.count > 0 then
				if a_url.index_of ('?', 1) > 0 then
					l_first_param := False
				elseif a_url.index_of ('&', 1) > 0 then
					l_first_param := False
				else
					l_first_param := True
				end
				from
					i := a_parameters.lower
				until
					i > a_parameters.upper
				loop
					if attached a_parameters[i] as a_param then
						if l_first_param then
							a_url.append_character ('?')
						else
							a_url.append_character ('&')
						end
						a_url.append_string (a_param.name)
						a_url.append_character ('=')
						a_url.append_string (a_param.value)
						l_first_param := False
					end
					i := i + 1
				end
			end
		end

	api_get_auth_call (a_api_url: STRING; params: detachable REST_SERVICE_API_PARAMETERS): like internal_api_call
			-- GET REST API call for `a_api_url'
			-- credential required
		do
			Result := internal_api_call (a_api_url, params, True, False)
		end

	api_get_call (a_api_url: STRING; params: detachable REST_SERVICE_API_PARAMETERS): like internal_api_call
			-- GET REST API call for `a_api_url'
			-- if `a_credentials' provides credentials
		do
			Result := internal_api_call (a_api_url, params, False, False)
		end

	api_post_auth_call (a_api_url: STRING; params: detachable REST_SERVICE_API_PARAMETERS): like internal_api_call
			-- POST REST API call for `a_api_url'
			-- credential required
		do
			Result := internal_api_call (a_api_url, params, True, True)
		end

	api_post_call (a_api_url: STRING; params: detachable REST_SERVICE_API_PARAMETERS; a_credentials: BOOLEAN): like internal_api_call
			-- POST REST API call for `a_api_url'
			-- if `a_credentials' provides credentials
		do
			Result := internal_api_call (a_api_url, params, a_credentials, True)
		end

	internal_api_call (a_api_url: STRING; params: detachable REST_SERVICE_API_PARAMETERS; a_require_credentials: BOOLEAN; a_http_post: BOOLEAN): STRING
			-- REST API call for `a_api_url' with `a_require_credentials' and `a_http_post'
		deferred
		end

feature -- Access: Encoding

	urlencode (s: STRING): STRING
			-- URL encode `s'
		do
			Result := s.string
			Result.replace_substring_all ("#", "%%23")
			Result.replace_substring_all (" ", "%%20")
			Result.replace_substring_all ("%T", "%%09")
			Result.replace_substring_all ("%N", "%%0A")
			Result.replace_substring_all ("/", "%%2F")
			Result.replace_substring_all ("&", "%%26")
			Result.replace_substring_all ("<", "%%3C")
			Result.replace_substring_all ("=", "%%3D")
			Result.replace_substring_all (">", "%%3E")
			Result.replace_substring_all ("%"", "%%22")
			Result.replace_substring_all ("%'", "%%27")
		end

	urldecode (s: STRING): STRING
			-- URL decode `s'
		do
			Result := s.string
			Result.replace_substring_all ("%%23", "#")
			Result.replace_substring_all ("%%20", " ")
			Result.replace_substring_all ("%%09", "%T")
			Result.replace_substring_all ("%%0A", "%N")
			Result.replace_substring_all ("%%2F", "/")
			Result.replace_substring_all ("%%26", "&")
			Result.replace_substring_all ("%%3C", "<")
			Result.replace_substring_all ("%%3D", "=")
			Result.replace_substring_all ("%%3E", ">")
			Result.replace_substring_all ("%%22", "%"")
			Result.replace_substring_all ("%%27", "%'")
			to_implement ("not yet implemented")
		end

	stripslashes (s: STRING): STRING
		do
			Result := s.string
			Result.replace_substring_all ("\%"", "%"")
			Result.replace_substring_all ("\'", "'")
			Result.replace_substring_all ("\/", "/")
			Result.replace_substring_all ("\\", "\")
		end

feature {NONE} -- Constants

	json_id: STRING = "json"

	xml_id: STRING = "xml"

	rss_id: STRING = "rss"

	atom_id: STRING = "atom"

note
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
