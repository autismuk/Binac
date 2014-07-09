--[[

									Binac, simple disassembler, mainly to check assembler.

--]]

local mneMonics = {}

mneMonics[5] = "a"
mneMonics[15] = "s"
mneMonics[10] = "m"
mneMonics[3] = "d"
mneMonics[2] = "f"

mneMonics[4] = "c"
mneMonics[13] = "h"
mneMonics[12] = "l"
mneMonics[11] = "k"
mneMonics[22] = "+"

mneMonics[23] = "-"
mneMonics[25] = "skip"
mneMonics[20] = "u"
mneMonics[14] = "t"

mneMonics[24] = "bp"
mneMonics[01] = "stop"

function decode(cmd) 
	local opcode = math.floor(cmd / 512)
	local operand = cmd % 512
	opcode = math.floor(opcode / 8) * 10 + opcode % 8
	if mneMonics[opcode] == nil then return "" end
	return ("%-4s %03o"):format(mneMonics[opcode],operand)
end 

for line in io.lines(arg[1]) do 
	local addr,data = line:match("^(%d+)%s*%=%s*(%d+)$")
	addr = tonumber(addr,8) data = tonumber(data,8)
	local i1 = math.floor(data / math.pow(2,15)) % math.pow(2,15)
	local i2 = data % math.pow(2,15)

	local fmt = "%03o : %011o %05o %05o : %-9s %-9s"
	local instr = fmt:format(addr,data,i1,i2,decode(i1),decode(i2))
	print(instr)
end 
