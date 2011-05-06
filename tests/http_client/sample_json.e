note
	description: "Summary description for {SAMPLE_JSON}."
	author: "Jocelyn Fiat"
	date: "$Date: 2010-12-16 14:37:13 +0100 (jeu., 16 déc. 2010) $"
	revision: "$Revision: 64 $"

class
	SAMPLE_JSON

inherit
	SAMPLE_I

create
	make,
	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: detachable STRING)
		do
			create sample_api.make (a_username, a_password)
			sample_api.set_json_format
		end

	make_with_source (a_username, a_password: detachable STRING; a_source: STRING)
		do
			make (a_username, a_password)
			sample_api.set_application_source (a_source)
		end

feature -- Sample: Status Methods

--	public_timeline: detachable LIST [SAMPLE_STATUS]
--		do
--			if attached sample_api.public_timeline as s then
--				if attached parsed_json (s) as j then
--					Result := sample_statuses (Void, j)
--				end
--			end
--		end
--
--	status (a_id: INTEGER): detachable SAMPLE_STATUS
--			-- single status, specified by the id parameter below.
--			-- The status's author will be returned inline.
--		do
--			if attached sample_api.show_status (a_id) as s then
--				if attached parsed_json (s) as j then
--					Result := sample_status (Void, j)
--				end
--			end
--		end

feature -- Sample: Account Methods

--	verify_credentials: detachable SAMPLE_USER
--		local
--			err: DEVELOPER_EXCEPTION
--		do
--			if attached sample_api.verify_credentials as s then
--				if attached parsed_json (s) as j then
--					if attached string_value_from_json (j, "error") as l_error then
--						create err
--						err.set_message (l_error)
--						err.raise
--					elseif attached {JSON_ARRAY} json_value (j, "errors") as l_array then
--						create err
--						if attached string_value_from_json (l_array.i_th (1), "message") as l_err_message then
--							err.set_message (l_err_message)
--						end
--						err.raise
--					else
--						Result := sample_user (Void, j)
--					end
--				else
--					print (s)
--				end
--			end
--		end
--
--	end_session
--		local
--			s: STRING
--		do
--			s := sample_api.end_session
--		end

feature -- Sample: Help Methods

	test: detachable STRING
		do
			Result := sample_api.test ("json")
		end

feature -- Implementation

	print_last_json_data
			-- Print `last_json' data
		do
			internal_print_json_data (last_json, "  ")
		end

feature {NONE} -- Implementation

	sample_api: SAMPLE_API
			-- Sample object

	last_json: detachable JSON_VALUE

	parsed_json (a_json_text: STRING): detachable JSON_VALUE
		local
			j: JSON_PARSER
		do
			create j.make_parser (a_json_text)
			Result := j.parse_json
			last_json := Result
		end

	json_value (a_json_data: detachable JSON_VALUE; a_id: STRING): detachable JSON_VALUE
		local
			l_id: JSON_STRING
			l_ids: LIST [STRING]
		do
			Result := a_json_data
			if Result /= Void then
				if a_id /= Void and then not a_id.is_empty then
					from
						l_ids := a_id.split ('.')
						l_ids.start
					until
						l_ids.after or Result = Void
					loop
						create l_id.make_json (l_ids.item)
						if attached {JSON_OBJECT} Result as v_data then
							if v_data.has_key (l_id) then
								Result := v_data.item (l_id)
							else
								Result := Void
							end
						else
							Result := Void
						end
						l_ids.forth
					end
				end
			end
		end

	internal_print_json_data (a_json_data: detachable JSON_VALUE; a_offset: STRING)
		local
			obj: HASH_TABLE [JSON_VALUE, JSON_STRING]
		do
			if attached {JSON_OBJECT} a_json_data as v_data then
				obj	:= v_data.map_representation
				from
					obj.start
				until
					obj.after
				loop
					print (a_offset)
					print (obj.key_for_iteration.item)
					if attached {JSON_STRING} obj.item_for_iteration as j_s then
						print (": " + j_s.item)
					elseif attached {JSON_NUMBER} obj.item_for_iteration as j_n then
						print (": " + j_n.item)
					elseif attached {JSON_BOOLEAN} obj.item_for_iteration as j_b then
						print (": " + j_b.item.out)
					elseif attached {JSON_NULL} obj.item_for_iteration as j_null then
						print (": NULL")
					elseif attached {JSON_ARRAY} obj.item_for_iteration as j_a then
						print (": {%N")
						internal_print_json_data (j_a, a_offset + "  ")
						print (a_offset + "}")
					elseif attached {JSON_OBJECT} obj.item_for_iteration as j_o then
						print (": {%N")
						internal_print_json_data (j_o, a_offset + "  ")
						print (a_offset + "}")
					end
					print ("%N")
					obj.forth
				end
			end
		end

	integer_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): INTEGER
		do
			if
				attached {JSON_NUMBER} json_value (a_json_data, a_id) as v and then
				v.numeric_type = v.integer_type
			then
				Result := v.item.to_integer
			end
		end

	boolean_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): BOOLEAN
		do
			if attached {JSON_BOOLEAN} json_value (a_json_data, a_id) as v then
				Result := v.item
			end
		end

	string_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): detachable STRING
		do
			if attached {JSON_STRING} json_value (a_json_data, a_id) as v then
				Result := v.item
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
