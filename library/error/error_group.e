note
	description : "Objects that represent a group of errors"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ERROR_GROUP

inherit
	ERROR

create
	make

feature {NONE} -- Initialization

	make (a_errors: LIST [ERROR])
			-- Initialize `Current'.
		do
			name := a_errors.count.out + " errors"
			create {ARRAYED_LIST [ERROR]} sub_errors.make (a_errors.count)
			sub_errors.fill (a_errors)
		end

feature -- Access

	code: INTEGER = -1

	name: STRING

	message: detachable STRING_32
		do
			create Result.make_from_string (name)
			from
				sub_errors.start
			until
				sub_errors.after
			loop
				if 
					attached sub_errors.item as e and then
					attached e.message as m
				then

					Result.append_character ('%N')
					Result.append_string (m)
				end
				sub_errors.forth
			end
		end

	sub_errors: LIST [ERROR]
			-- Error contained by Current

feature -- Visitor

	process (a_visitor: ERROR_VISITOR)
			-- Process Current using `a_visitor'.
		do
			a_visitor.process_group (Current)
		end


end
