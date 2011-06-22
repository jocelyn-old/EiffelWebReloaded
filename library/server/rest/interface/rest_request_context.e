note
	description: "Summary description for {REST_REQUEST_CONTEXT}."
	date: "$Date$"
	revision: "$Revision$"

class
	REST_REQUEST_CONTEXT

inherit
	HTTPD_REQUEST_CONTEXT

create {HTTPD_APPLICATION}
	make,
	make_with_authentication

feature -- Format

	request_format: detachable STRING
			-- Request format based on `Content-Type'.
		local
			s: STRING
		do
			s := content_type
			if s.same_string ({HTTP_CONSTANTS}.json_text) then
				Result := {REST_FORMAT_CONSTANTS}.json_name
			elseif s.same_string ({HTTP_CONSTANTS}.json_app) then
				Result := {REST_FORMAT_CONSTANTS}.json_name
			elseif s.same_string ({HTTP_CONSTANTS}.xml_text) then
				Result := {REST_FORMAT_CONSTANTS}.xml_name
			elseif s.same_string ({HTTP_CONSTANTS}.html_text) then
				Result := {REST_FORMAT_CONSTANTS}.html_name
			elseif s.same_string ({HTTP_CONSTANTS}.plain_text) then
				Result := {REST_FORMAT_CONSTANTS}.text_name
			end
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
