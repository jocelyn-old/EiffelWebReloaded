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
			status:="submitted"
		ensure
			order_created: is_valid_status_states (status)
		end

feature -- Access
 	id : STRING
 	location : STRING
 	items: LIST[ITEM]
	status : STRING
	
	is_valid_status_states (a_status: STRING) : BOOLEAN
		--is `a_status' a valid coffee order state
		do
			a_status.to_lower
			Order_states.compare_objects
			Result := Order_states.has (a_status)
		end

	Order_states : ARRAY[STRING]
		-- List of valid status states
		once
			Result := <<"submitted","pay","payed", "cancel","canceled","prepare","prepared","deliver","completed">>
		end

	is_valid_transition (a_status : STRING) :BOOLEAN
		-- Given the correr order state, determine if the transition is valid
		do
			a_status.to_lower
			if status.same_string ("submitted") then
				Result := a_status.same_string ("pay") or  a_status.same_string ("cancel")
			elseif status.same_string ("pay") then
				Result := a_status.same_string ("payed")
			elseif status.same_string ("cancel") then
				Result := a_status.same_string ("canceled")
			elseif status.same_string ("payed") then
				Result := a_status.same_string ("prepared")
			elseif status.same_string ("prepared") then
				Result := a_status.same_string ("deliver")
			elseif status.same_string ("deliver") then
				Result := a_status.same_string ("completed")
			end
		end


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

	set_status (a_status : STRING)
		require
			valid_status: a_status /= Void and then is_valid_status_states (a_status)
			valid_transition : is_valid_transition (a_status)
		do
			status := a_status
		ensure
			location_assigned : location.same_string (a_status)
		end


	add_item (a_item : ITEM)
		require
			valid_item:  a_item /= Void
		do
			items.force (a_item)
		ensure
			has_item : items.has (a_item)
		end

invariant
	order_in_valid_state: is_valid_status_states (status)

end
