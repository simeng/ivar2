local simplehttp = require'simplehttp'
local util = require'util'

customHosts['wikipedia.org'] = function(queue, info)
	local path = info.path

	if(path and path:match('/wiki/(.*)$')) then
		local query = path:match('/wiki/(.*)$')
		local domain = info.host
		simplehttp(
			string.format('https://%s/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&redirects=1&titles=%s', domain, query),

			function(js, url, response)
				local data = util.json.decode(js)
				local list = data.query.pages
				local _, entry = next(list)
				if not entry or not entry.extract then
				queue:done('Missing entry')
				else
					-- Sometimes text is very long, let's try to snip some by
					-- using only first sentence
					local text = entry.extract
					local short_text = text:match('(.-)%.') or text
					-- If first sentence is very short, let's get some more
					--if #short_text < 30
					--short_text = text:match('(.-)\n') or text
					queue:done(short_text .. '.')
				end
			end
		)

		return true
	end
end
