note
	description: "Summary description for {REST_REQUEST_HANDLER_MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_REQUEST_HANDLER_MANAGER

inherit
	ITERABLE [REST_REQUEST_HANDLER]

create
	make

feature -- Initialization

	make (n: INTEGER)
		do
			create handlers.make (n)
			handlers.compare_objects
		end

feature -- Registration

	register (r: REST_REQUEST_HANDLER)
		do
			handlers.force (r, r.path)
		end

feature -- Access

	handler (a_path: STRING): detachable REST_REQUEST_HANDLER
		require
			a_path_valid: a_path /= Void
		local
			p: INTEGER
			l_path: STRING
		do
			l_path := a_path
			if l_path.is_empty then
				l_path := "/"
			else
				if l_path[1] /= '/' then
					l_path := "/" + l_path
				end
				p := l_path.index_of ('.', 1)
				if p > 0 then
					l_path := l_path.substring (1, p - 1)
				end
			end
			Result := handlers.item (l_path)
		end

	smart_handler (a_path: STRING): detachable REST_REQUEST_HANDLER
		require
			a_path_valid: a_path /= Void
		local
			p: INTEGER
			hds: like handlers
			l_path: STRING
		do
			l_path := a_path
			if not l_path.is_empty then
				if l_path[1] /= '/' then
					l_path := "/" + a_path
				end
				from
					p := l_path.count + 1
				until
					p <= 1 or Result /= Void
				loop
					Result := handler (l_path.substring (1, p - 1))
					if Result = Void then
						p := l_path.last_index_of ('/', p - 1)
					end
				variant
					p
				end
			end
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [REST_REQUEST_HANDLER]
			-- Fresh cursor associated with current structure
		do
			Result := handlers.new_cursor
		end

feature {NONE} -- Implementation

	handlers: HASH_TABLE [REST_REQUEST_HANDLER, STRING]

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
