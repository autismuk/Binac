--[[

																				BinAc Assembler in LUA.

--]]

local labels = {} 																				-- maps labels (lower case) => addresses.

--
--			Evaluate term. Returns term and remainder of string.
--

function evaluateTerm(expression)
	expression = expression:lower():gsub("%s+","")												-- make lower case, remove spaces.
	local first = expression:sub(1,1) 															-- look at first character.
	local term 

	term = expression:match("^(0%.[0-9]+)") 													-- is it a decimal value, 0.something.
	if term ~= nil then 
		return toBinary31(tonumber(term)),expression:sub(#term)
	end 

	if first >= "0" and first <= "7" then 														-- begins with a number 0-7.
		term,expression = expression:match("^([0-7]+)(.*)$") 									-- rip off the term.
		return tonumber(term,8),expression
	end 

	if first >= "a" and first <= "z" then 														-- is it a label ?
		term,expression = expression:match("^([a-z][a-z0-9]*)(.*)$") 							-- rip off the term
		assert(labels[term] ~= nil,"Term "..term.." unknown")
		return labels[term],expression
	end 

	if first == "@" then 																		-- begins with a @, this is a decimal number.
		term,expression = expression:match("^%@([0-9]*)(.*)$") 									-- rip off the term.
		return tonumber(term,10),expression
	end 

	if first == "-" then 																		-- negative term.
		term,expression = evaluateTerm(expression:sub(2)) 										-- calculate the negative value.
		return -term,expression 
	end 

	return "???",expression
end 

--
--		Convert a binary number to a 30 bit binary value.
--

function toBinary31(n)
	local bitValue = math.pow(2,29) 															-- this is the most significant bit.
	local floatValue = 0.5 																		-- this is its place value
	local result = 0 
	while bitValue > 0 do 																		-- keep trying each bit value
		if n >= floatValue then 																-- if place value enough
			n = n - floatValue  																-- sub from it
			result = result + bitValue  														-- add bit value to the result
		end 
		floatValue = floatValue / 2 															-- next bit right.
		bitValue = math.floor(bitValue/2)
	end 
	return result 					
end 

---
--- 	Evaluate an expression +,-,*,/ simple l->r no precedence.
---
function evaluateExpression(expression)
	expression = expression:lower():gsub("%s+","")												-- make lower case, remove spaces.
	local term,expression = evaluateTerm(expression) 											-- do first term
	while expression ~= "" do 																	-- there is more ?
		local operator = expression:sub(1,1) 													-- get the operator.
		local term2
		term2,expression = evaluateTerm(expression:sub(2)) 										-- evaluate the second term.
		if operator == "+" then  																-- work out the result
			term = term + term2 
		elseif operator == "-" then 
			term = term - term2
		elseif operator == "*" then 
			term = term * term2 
		elseif operator == "/" then 
			term = term / term2 
		else 
			error("Unknown operator "..operator)
		end
	end 
	return term 
end 

function evaluate(code) 
	if code:find(" ") == nil then return evaluateExpression(code) end 							-- a single value, not an instruction.
	local opcode,operand = code:match("^([a-z]+)%s*(.*)$")
	return evaluateExpression(opcode) + bit32.band(evaluateExpression(operand),tonumber("077777",8))
end 

local opcodes = { a = 5,s = 15, m = 10,d = 3, f = 2 , c = 4, 									-- Binac Opcodes (standard 1950s version)
										h = 13, l = 12, k = 11, u = 20, t = 14}
for operation,opcode in pairs(opcodes) do  														-- work through them
	opcode = opcode % 10 + math.floor(opcode / 10) * 8  										-- decimal to binary.
	labels[operation] = opcode * 512 															-- put them in the labels table.
end

local storage = {} 																				-- 512 element array
local pointer = 0 																				-- current code pointer.			
local isFirstHalf = true 																		-- first or second half ?

print("*** BINAC Assembler ***")
print("Reading in source "..arg[1])

for text in io.lines(arg[1]) do 																-- scan file.
	text = text:match("^%s*(.*)$"):lower():gsub("%s"," "):gsub("%s+"," ")						-- remove leading spaces, tabs, multi spaces, make l/c
	local p = text:find(";") if p ~= nil then text = text:sub(1,p-1) end 						-- remove comments.
	while text:sub(-1,-1) == " " do text = text:sub(1,-2) end 									-- remove trailing spaces.
	if text:sub(1,1) == "." then 																-- is it a label ?
		local label 
		label,text = text:match("^%.([a-z0-9]+)%s*(.*)$") 										-- rip out label and rest of line.
		assert(labels[label] == nil,"Duplicate label "..label) 									-- check not already defined.
		assert(isFirstHalf,"Label in middle of word")											-- must be the first half of the word.
		labels[label] = pointer 																-- set the label pointer.
		-- print(("%s %o"):format(label,pointer))
	end 

	if text ~= "" then 
		if text:sub(1,3) == "org" then 															-- if it is an ORG
			assert(isFirstHalf,"org occurs in middle of word") 									-- must not be in the middle of the word.
			pointer = evaluateExpression(text:sub(4))
		elseif text:sub(1,4) == "word" then 													-- if it is a WORD.
			assert(isFirstHalf,"word occurs in middle of word")									-- must not be in the middle of the word.
			storage[pointer] = { text:match("^word%s*(.*)$") }									-- save the word expression, just one entry, in this pointer.
			pointer = pointer + 1 																-- bump the pointer. 
		else  																					-- it is some form of code, store it in the first or second half of the word.
			if isFirstHalf then 
				storage[pointer] = { text , "25000" } 											-- text+ skip
				isFirstHalf = false 
			else 
				storage[pointer][2] = text 														-- put in second bit.
				isFirstHalf = true 
				pointer = pointer + 1  															-- second half, go to next word.
			end 
		end
	end
end 

print("Evaluating literals")
local addresses = {}
for addr,code in pairs(storage) do 																-- work through all entries
	addresses[#addresses+1] = addr 																-- build a list of addresses.
end 
table.sort(addresses) 																			-- sort into ascending order

local tgt = arg[1]:gsub("%.asm$",".obj")
print("Building code, writing "..#addresses.." words to "..tgt)
local hOut = io.open(tgt,"w")
for _,addr in ipairs(addresses) do
	local code = storage[addr]
	for i = 1,#code do code[i] = evaluate(code[i]) end 											-- evaluate all values.
	if #code == 2 then 																			-- combine them together. 
		code[1] = code[1] * math.pow(2,15) + code[2]
		code[2] = nil 
	end
	hOut:write(("%03o = %010o\n"):format(addr,code[1]))
end 
hOut:close()
print("Done.")