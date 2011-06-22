note
	description: "Summary description for {REST_SERVICE_API_PARAMETERS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_SERVICE_API_PARAMETERS

create {REST_SERVICE_API}
	make

feature {NONE} -- Initialization

	make (a_get_capacity, a_post_capacity: INTEGER)
			-- Initialize for `a_get_capacity' GET params, and `a_post_capacity' POST params
		do
			create parameters_get.make (a_get_capacity)
			create parameters_post.make (a_post_capacity)
		end

feature -- Status report

	has_post: BOOLEAN
		do
			Result := not parameters_post.is_empty
		end

feature -- Element change

	add_get_parameter (n: STRING; v: STRING)
			-- Add GET parameter named `n' with value `v'
		do
			parameters_get.force (v,n)
		end

	add_post_parameter (n: STRING; v: STRING)
			-- Add POST parameter named `n' with value `v'	
		do
			parameters_post.force (v,n)
		end

feature -- Clear

	clear
			-- Clear all parameters
		do
			parameters_get.wipe_out
			parameters_post.wipe_out
		end

feature -- Access

	parameters_get: HASH_TABLE [STRING, STRING]
			-- GET parameters data

	parameters_post: HASH_TABLE [STRING, STRING]
			-- POST parameters data	

;note
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
