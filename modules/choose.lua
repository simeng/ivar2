local ltrim = function(r, s)
	if s == nil then
		s, r = r, "%s+"
	end
	return (string.gsub(s, "^" .. r, ""))
end

math.randomseed(os.time())

return {
	["^:(%S+) PRIVMSG (%S+) :!choose (.+)$"] = function(self, src, dest, msg)
		local hax = {}
		local arr = utils.split(msg, ",[%s]?")

		for k, v in pairs(arr) do
			hax[v] = true
		end

		local i = 0
		for k, v in pairs(hax) do
			i = i + 1
		end

		local seed = math.random(1, #arr)

		if(#arr == 1 or i == 1) then
			self:msg(dest, src, "（　´_ゝ`）ﾌｰﾝ")
		else
			self:msg(dest, src, "%s: %s", src:match"^([^!]+)", ltrim(arr[seed]))
		end
	end
}