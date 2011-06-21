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

	context_path (a_path: STRING): STRING
			-- Prepared path from context which match requirement
			-- i.e: not empty, starting with '/'
		local
			p: INTEGER
		do
			Result := a_path
			if Result.is_empty then
				Result := "/"
			else
				if Result[1] /= '/' then
					Result := "/" + Result
				end
				p := Result.index_of ('.', 1)
				if p > 0 then
					Result := Result.substring (1, p - 1)
				end
			end
		ensure
			result_not_empty: not Result.is_empty
		end

	handler_by_path (a_path: STRING): detachable REST_REQUEST_HANDLER
		require
			a_path_valid: a_path /= Void
		do
			Result := handlers.item (context_path (a_path))
		ensure
			a_path_unchanged: a_path.same_string (old a_path)
		end

	smart_handler_by_path (a_path: STRING): detachable REST_REQUEST_HANDLER
		require
			a_path_valid: a_path /= Void
		local
			p: INTEGER
			l_path: STRING
		do
			l_path := context_path (a_path)
			from
				p := l_path.count + 1
			until
				p <= 1 or Result /= Void
			loop
				Result := handler_by_path (l_path.substring (1, p - 1))
				if Result = Void then
					p := l_path.last_index_of ('/', p - 1)
				end
			variant
				p
			end
		ensure
			a_path_unchanged: a_path.same_string (old a_path)
		end

	handler (ctx: REST_REQUEST_CONTEXT): detachable REST_REQUEST_HANDLER
		require
			ctx_valid: ctx /= Void and then ctx.path_info /= Void
		do
			Result := handler_by_path (ctx.path_info)
			if Result /= Void then
				if not Result.is_valid_context (ctx) then
					Result := Void
				end
			end
		ensure
			ctx_path_info_unchanged: ctx.path_info.same_string (old ctx.path_info)
		end

	smart_handler (ctx: REST_REQUEST_CONTEXT): detachable REST_REQUEST_HANDLER
		require
			ctx_valid: ctx /= Void and then ctx.path_info /= Void
		do
			Result := smart_handler_by_path (ctx.path_info)
		ensure
			ctx_path_info_unchanged: ctx.path_info.same_string (old ctx.path_info)
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
