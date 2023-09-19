-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.

X_COLS = 7
X_WIDTH = 30
Y_ROWS = 18
Y_HEIGHT = 30

X_BUFFER = (960 / 2) - (X_COLS * X_WIDTH / 2)
Y_BUFFER = 50


function tetris_random_board(w,h)
	local width = w
	local height = h
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

function tetris_rotate_piece(matrix,piece)
	if not matrix then
		print("tetris_move_piece: no matrix?") 
		return false
	elseif not piece then 
		print("tetris_move_piece: no piece?") 
		return false
	end 
	px = piece[2].x
	py = piece[2].y
-- 	x2 = (y1 + px - py)
-- 	y2 = (px + py - x1 - q)
	local newPiece = table_clone(piece)
	for i = 1, #piece do
		newPiece[i].x = piece[i].y + px - py
		newPiece[i].y = px + py - piece[i].x - 1
		if (not tetris_is_open_space(matrix, newPiece[i].x, newPiece[i].y)) then
			print("failed rotate")
			return false
		end
	end
	for i = 1, #piece do
		piece[i].x = newPiece[i].x
		piece[i].y = newPiece[i].y
	end
	return true
end


function tetris_move_piece(matrix,piece,dx,dy)
	if not matrix then
		print("tetris_move_piece: no matrix?") 
		return false
	elseif not piece then 
		print("tetris_move_piece: no piece?") 
		return false
	end 
	
	for i = 1, #piece do
		mi = piece[i].x + dx
		mj = piece[i].y + dy
		if (not tetris_is_open_space(matrix, mi, mj)) then
			return false
		end
	end
	for i = 1, #piece do
		piece[i].x = piece[i].x + dx
		piece[i].y = piece[i].y + dy
	end
	return true
end

function tetris_random_piece(matrix)
	local output = {}
	local mi = math.floor(#matrix / 2)
	local mj = #matrix[1]
	for i = mi,mi+3 do
		local piece = {x = i, y = mj}
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
	return (tetris_is_valid_space(matrix, i, j) and not matrix[i][j])
end

function tetris_is_line_full(matrix, lineNo)
	for i=1,#matrix do
		if tetris_is_open_space(matrix, i, lineNo) then return false end
	end
	return true
end

function tetris_is_valid_space(matrix, i, j)
	return ((i <= #matrix) and (i >= 1) and (j >= 1) and (j <= #matrix[1]))
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
	for j = lineNo,(#matrix[1] - 1) do
		for i = 1, #matrix do
			matrix[i][j] = matrix[i][j + 1]
		end
	end
	for i = 1, #matrix do -- top line
		matrix[i][#matrix[1]] = false
	end
end

function tetris_kill_lines(matrix)
	for j=#matrix[1],1,-1 do
		if tetris_is_line_full(matrix, j) then
			print("full line: " .. j)
			tetris_line_erase(matrix, j)
			return true
		end
	end
	return false
end


function i2x(i)
	return (i - 1) * X_WIDTH + X_BUFFER
end

function j2y(j)
	return (j - 1) * Y_HEIGHT + Y_BUFFER
end

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