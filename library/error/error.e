note
	description : "Objects that represent an error"
	date        : "$Date$"
	revision    : "$Revision$"

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

end
