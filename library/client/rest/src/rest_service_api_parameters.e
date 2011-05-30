note
	description: "Summary description for {REST_SERVICE_API_PARAMETERS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_SERVICE_API_PARAMETERS

create
	make

feature {NONE} -- Initialization

	make (n,m: INTEGER)
			-- Initialize for `n' GET params, and `m' POST params
		do
			create parameters_get.make (n)
			create parameters_post.make (m)
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
