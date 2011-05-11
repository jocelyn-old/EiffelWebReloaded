note
	description: "Summary description for {SAMPLE}."
	author: "Jocelyn Fiat"
	date: "$Date: 2010-12-16 15:08:03 +0100 (jeu., 16 déc. 2010) $"
	revision: "$Revision: 65 $"

class
	SAMPLE_API

inherit
	NET_REST_SERVICE_API
--	CURL_REST_SERVICE_API	

	REFACTORING_HELPER

create
	make,
	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: detachable STRING)
		do
			set_service_api_url ("http://127.0.0.1:8180/sample/sample.exe/api/")
--			set_service_api_url ("http://localhost:8180/sample/sample.exe/api/")			
			if a_username /= Void and a_password /= Void then
				username := a_username.string
				password := a_password.string
				credentials := a_username + ":" + a_password
			end
			application_source := Void

			format := json_id
		end

	make_with_source (a_username, a_password: detachable STRING; a_source: like application_source)
		do
			make (a_username, a_password)
			set_application_source (a_source)
		end

feature -- Sample: Help Methods

	test (a_format: STRING): like api_get_auth_call
			--Returns the string "ok" in the requested format with a 200 OK HTTP status code.			
			-- URL: http://localhost:8180/sample/sample.exe/api/test.format
			--Formats: xml, json
			--Method(s): GET
		require
			valid_format: format_is_xml or format_is_json
		do
			Result := api_get_auth_call (service_url ("test." + a_format, Void))
		end

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
