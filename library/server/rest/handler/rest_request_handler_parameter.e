note
	description: "Summary description for {REST_REQUEST_HANDLER_PARAMETER}."
	date: "$Date$"
	revision: "$Revision$"

class
	REST_REQUEST_HANDLER_PARAMETER

create
	make

feature {NONE} -- Initialization

	make (n: like name; opt: BOOLEAN)
		do
			name := n
			optional := opt
		end

feature -- Access

	name: STRING

	optional: BOOLEAN

	description: detachable STRING assign set_description

	type: detachable STRING assign set_type

feature -- Element change

	set_description (d: like description)
			-- Set `description' to `d'
		do
			description := d
		end

	set_type (t: like type)
			-- Set `type' to `t'
		do
			type := t
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
