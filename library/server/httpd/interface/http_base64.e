note
	description: "Summary description for {HTTP_BASE64}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_BASE64

feature -- base64 encoder

	encoded_string (s: STRING): STRING_8
			-- base64 encoded value of `s'.
		require
			s_not_void: s /= Void
		local
			i,n: INTEGER
			c: INTEGER
			f: SPECIAL [BOOLEAN]
			base64chars: STRING_8
		do
			base64chars := character_map
			from
				n := s.count
				i := (8 * n) \\ 6
				if i > 0 then
					create f.make_filled (False, 8 * n + (6 - i))
				else
					create f.make_filled (False, 8 * n)
				end
				i := 0
			until
				i > n - 1
			loop
				c := s.item (i + 1).code
				f[8 * i + 0] := c.bit_test(7)
				f[8 * i + 1] := c.bit_test(6)
				f[8 * i + 2] := c.bit_test(5)
				f[8 * i + 3] := c.bit_test(4)
				f[8 * i + 4] := c.bit_test(3)
				f[8 * i + 5] := c.bit_test(2)
				f[8 * i + 6] := c.bit_test(1)
				f[8 * i + 7] := c.bit_test(0)
				i := i + 1
			end
			from
				i := 0
				n := f.count
				create Result.make (n // 6)
			until
				i > n - 1
			loop
				c := 0
				if f[i + 0] then c := c + 0x20 end
				if f[i + 1] then c := c + 0x10 end
				if f[i + 2] then c := c + 0x8 end
				if f[i + 3] then c := c + 0x4 end
				if f[i + 4] then c := c + 0x2 end
				if f[i + 5] then c := c + 0x1 end
				Result.extend (base64chars.item (c + 1))
				i := i + 6
			end

			i := s.count \\ 3
			if i > 0 then
				from until i > 2 loop
					Result.extend ('=')
					i := i + 1
				end
			end
		ensure
			Result_not_void: Result /= Void
		end

	decoded_string (v: STRING): STRING
			-- base64 decoded value of `s'.	
		require
			valid_string: v /= Void
			legal_length: v.is_empty or v.count >= 4
		local
			byte_count: INTEGER
			pos, n: INTEGER
			byte1, byte2, byte3, byte4, tmp1, tmp2: INTEGER
			done: BOOLEAN
			c: CHARACTER
			base64chars: STRING_8
		do
			base64chars := character_map
			n := v.count
			create Result.make (n)

			from
				pos := 0
			invariant
				n = v.count
			until
				(pos >= n) or done
			loop
				byte_count := 0

				if pos < n then
					c := v[pos + 1]
					byte1 := base64chars.index_of (c, 1) - 1
					byte_count := byte_count + 1

					if pos + 1 < n then
						c := v[pos + 2]
						byte2 := base64chars.index_of (c, 1) - 1
						byte_count := byte_count + 1

						if pos + 2 < n then
							c := v[pos + 3]
							if c /= '=' then
								byte3 := base64chars.index_of (c, 1) - 1
								byte_count := byte_count + 1
							end

							if pos + 3 < n then
								c := v[pos + 4]
								if c /= '=' then
									byte4 := base64chars.index_of (c, 1) - 1
									byte_count := byte_count + 1
								end
							end
						end
					end
				end
				pos := pos + byte_count

				done := byte_count < 4

				if byte_count > 1 then
					tmp1 := byte1.bit_shift_left (2) & 0xff
					tmp2 := byte2.bit_shift_right (4) & 0x03
					Result.extend ((tmp1 | tmp2).to_character_8)
					if byte_count > 2 then
						tmp1 := byte2.bit_shift_left (4) & 0xff
						tmp2 := byte3.bit_shift_right (2) & 0x0f
						Result.extend ((tmp1 | tmp2).to_character_8)
						if byte_count > 3 then
							Result.extend(
								((byte4 | byte3.bit_shift_left(6))& 0xff).to_character_8)
						end
					end
				end
			end
		ensure
			result_exists: Result /= Void
		end

feature {NONE} -- Constants

	character_map: STRING = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

end
