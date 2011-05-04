note
	description : "Objects that represent an error"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ERROR

feature -- Access

	code: INTEGER
		deferred
		ensure
			result_not_zero: Result /= 0
		end

	name: STRING
		deferred
		ensure
			result_attached: Result /= Void
		end

	message: detachable STRING_32
			-- Potential error message
		deferred
		end

	parent: detachable ERROR
			-- Eventual error prior to Current

feature -- Change

	set_parent (a_parent: like parent)
			-- Set `parent' to `a_parent'
		do
			parent := a_parent
		end

feature -- Visitor

	process (a_visitor: ERROR_VISITOR)
			-- Process Current using `a_visitor'.
		require
			a_visitor_not_void: a_visitor /= Void
		deferred
		end

invariant
	name_attached: name /= Void

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
