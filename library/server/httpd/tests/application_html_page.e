note
	description: "Summary description for {APPLICATION_HTML_PAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION_HTML_PAGE

inherit
	HTML_PAGE
		redefine
			set_body,
			initialize,
			compute
		end

create
	make

feature {NONE} -- Initialization

	initialize
		do
			Precursor
			create body_header.make_empty
			create body_menu.make_empty
			create body_main.make_empty
			create body_footer.make_from_string ("-- Eiffel Web Solution : Sample --")
		end

feature -- Access

	body_header: STRING assign set_body_header
	body_menu: STRING assign set_body_menu
	body_main: STRING assign set_body_main
	body_footer: STRING assign set_body_footer

feature -- Element change

	set_body (s: like body)
		do
			-- do nothing
		end

	set_body_header (s: STRING)
		do
			body_header := s
		end

	set_body_menu (s: STRING)
		do
			body_menu := s
		end

	set_body_main (s: STRING)
		do
			body_main := s
		end

	set_body_footer (s: STRING)
		do
			body_footer := s
		end

feature -- Output

	compute
		local
			original_body: like body
		do
			original_body := body
			body := computed_body (original_body)
			Precursor
			body := original_body
		end

	computed_body (b: like body): STRING
		do
			create Result.make (128)
			Result.append_string ("<div id=%"header%">" + body_header + "</div>%N")
			Result.append_string ("<div id=%"menu%">" + body_menu + "</div>%N")
			Result.append_string ("<div id=%"main%">")
			Result.append_string (body_main)
			if not b.is_empty then
				Result.append_string (b)
			end
			Result.append_string ("</div>%N")
			Result.append_string ("<div id=%"footer%">" + body_footer + "</div>%N")
		end

end
