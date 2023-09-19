-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.

function tetris_random_board()
	local width = 5
	local height = 9
	local matrix = make_matrix(width, height, false)
	for i = 1, width do
		for j = 1,3 do
			if (math.random(0,1) == 0) then
				matrix[i][j] = true
			end
		end
	end
	return matrix
end

function tetris_random_piece()
	local output = {}
	for i = 1,4 do
		local piece = {x = i, y = 6}
		table.insert(output, piece)
	end
	return output
end

function make_matrix(width,height,defaultval)
	local matrix = {}
	for i = 1, width do
		matrix[i] = {}
		for j = 1, height do
			matrix[i][j] = defaultval
		end
	end
	return matrix
end

-- function tetris_init(matrix, empty_prototype)
-- end
-- 
function tetris_is_open_space(matrix, i, j)
	return (not matrix[i][j] and tetris_is_valid_space(matrix, i, j))
end
	
function tetris_is_valid_space(matrix, i, j)
	return ((i <= #matrix) and (i >= 1) and (j >= 1) and (j <= #matrix[1]))
end

function tetris_tick(matrix, piece)
	if not matrix then
		print("tetris_tick: no matrix?") 
		return false
	elseif not piece then 
		print("tetris_tick: no piece?") 
		return false
	end 
	for i = 1, #piece do
		mi = piece[i].x
		mj = piece[i].y - 1
		if (not tetris_is_open_space(matrix, mi, mj)) then
			return false
		end
	end
	for i = 1, #piece do
		piece[i].y = piece[i].y - 1
	end
	return true
end

function tetris_place_piece(matrix, piece)
	if not matrix then
		print("tetris_place_piece: no matrix?") 
		return false
	elseif not piece then 
		print("tetris_place_piece: no piece?") 
		return false
	end 
	for i = 1, #piece do
		local mi = piece[i].x
		local mj = piece[i].y
		-- if (tetris_is_open_space(matrix, mi, mj)) then
		matrix[mi][mj] = true
		-- end
	end
	return true
end

function tetris_to_string(matrix)
	local output = "\n"
	local cell = ""
	for j = 1, #matrix[1] do
		for i = 1, #matrix do
			if matrix[i][j] then
				cell = "X"
			else
				cell = "."
			end
			output = output .. cell
		end
		output = output .. "\n"
	end
	return output
end

function tetris_line_erase(matrix,lineNo)
	for j = lineNo,#matrix[1] do
		for i = 1, #matrix do
			matrix[i][j] = matrix[i][j + 1]
		end
	end
	for i = 1, #matrix do -- top line
		matrix[i][#matrix[1]] = false
	end
end

X_WIDTH = 50
X_BUFFER = 50
Y_HEIGHT = 50
Y_BUFFER = 50

function i2x(i)
	return (i - 1) * X_WIDTH + X_BUFFER
end

function j2y(j)
	return (j - 1) * Y_HEIGHT + Y_BUFFER
end

-- function table_equals( a, b )
-- 	if type(a) ~= type(b) then return false end
-- 	if type(a) ~= "table" then
-- 		return tostring(a) == tostring(b)
-- 	end
-- 	if #a ~= #b then return false end
-- 	if #a == 0 then return true end
-- 	for k,v in pairs(a) do
-- 		print("a: " .. k .. table2string(v))
-- 		if not table_equals(a[k], b[k]) then return false end
-- 	end
-- 	for k,v in pairs(b) do
-- 		print("b: " .. k .. table2string(v))
-- 		if not table_equals(a[k], b[k]) then return false end
-- 	end
-- 	return true
-- end

function table_equals(a,b)
	return table2string(a) == table2string(b)
end

function table2string(t)
	if type(t) ~= "table" then return tostring(t) end
	local toprint = ""
	for k, v in pairs(t) do
		toprint = toprint .. "\"" .. k .. "\" = "
		if (type(v) ~= "table") then
			toprint = toprint .. tostring(v) .. ", "
		else
			toprint = toprint .. "{ " .. table2string(v) .. " }, "
		end
	end
	return toprint
end


function table_equals_test00()
	local result = table_equals({}, {}) and not table_equals({1}, {}) and not table_equals({}, {2}) 
	result = result and not table_equals({}, {"1"}) and table_equals({a = "1"},{a = "1"})
	result = result and not table_equals({}, {"1"}) and not table_equals({a = "1"},{a = "1", {}})
	result = result and table_equals({a = "1", {b = "a"}},{a = "1", {b = "a"}})
	local foo = {a = "1", {c = 2, b = "a"}, 3}
	local bar = {{b = "b", c = 2}, a = "1", 3}
	result = result and not table_equals(foo,bar)
	print("### table equals test: " .. tostring(result))
end


function table_clone( t )
	if type(t) ~= "table" then return t end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = table_clone(v)
		else
			target[k] = v
		end
	end
	setmetatable(target, meta)
	return target
end

function tetris_test_00()
	local b = tetris_random_board()
	local p = tetris_random_piece()
	print(tetris_to_string(b))
	tetris_line_erase(b, #b[1])
	print(tetris_to_string(b))
	tetris_tick(b,p)
	tetris_place_piece(b,p)
	print(tetris_to_string(b))
end


-- table_equals_test00()
-- tetris_test_00()