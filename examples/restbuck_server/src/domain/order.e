note
	description: "Summary description for {ORDER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ORDER
create
	make
feature -- Initialization
	make ( an_id : STRING; a_location:STRING)
		do
			create {ARRAYED_LIST[ITEM]}items.make (10)
			set_id(an_id)
			set_location(a_location)
		end
feature -- Access
 	id : STRING
 	location : STRING
 	items: LIST[ITEM]

feature -- element change
	set_id (an_id : STRING)
		require
		 	valid_id :an_id /= Void
		do
			id := an_id
		ensure
			id_assigned : id.same_string (an_id)
		end

	set_location (a_location : STRING)
		require
			valid_location: a_location /= Void
		do
			location := a_location
		ensure
			location_assigned : location.same_string (a_location)
		end

	add_item (a_item : ITEM)
		require
			valid_item:  a_item /= Void
		do
			items.force (a_item)
		ensure
			has_item : items.has (a_item)
		end

end
