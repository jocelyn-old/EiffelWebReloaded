note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APP_CLIENT

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			json_api: SAMPLE_JSON
			api: SAMPLE_API
			js: JSON_STRING
			jn: JSON_NUMBER
			ja: JSON_ARRAY
			jv: JSON_VALUE
			jo: JSON_OBJECT
			jp: JSON_PARSER
		do
			create api.make ("abc", "def")
--			create api.make (Void, Void)

			if attached api.test ("plain") as l_test then
				print (l_test)
			end
			if attached api.test ("xml") as l_test then
				print (l_test)
			end

			create ja.make_array
			create jo.make
			jo.put (create {JSON_STRING}.make_json ("foobar"), create {JSON_STRING}.make_json ("name"))
			ja.add (jo)
			if attached api.test ("json") as l_test then
				print (l_test)
				create jp.make_parser (l_test)
				if jp.is_parsed and then jp.errors.count > 0 then
					jv := jp.parse_json
				end
			end
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
