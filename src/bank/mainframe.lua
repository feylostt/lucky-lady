rednet.open("bottom")

local DiscordHook = require("DiscordHook")

local databasePath = "db"
local database

if not fs.exists(databasePath) then
	database = {}
	local file = fs.open(databasePath, "w")
	file.write("{}")
	file.close()
else	
	local file = fs.open(databasePath, "r")
	database = textutils.unserialise(file.readAll())
	file.close()
end

print("Database loaded.")

local success, hook = DiscordHook.createWebhook("https://discord.com/api/webhooks/1295862419289145388/azm20HdwjQ_fuFgF4uXlTLGpd3k5qJphBUedRhldvwFObdfia7NNm93D8Z0ySIDkhTGs")
if not success then
	error("Webhook connection failed! Reason: " .. hook)
end

while true do
	local id, data = rednet.receive("luckyladycasino")
	print(textutils.serialise(data))
	hook.send("```"..textutils.serialise(data).."```", "Lucky Lady Casino", "https://styles.redditmedia.com/t5_8pimef/styles/communityIcon_xbgllumw3r8b1.png")
	if data.type == "getPlayerBalance" then
		print("Fetching balance for ", data.player)
		rednet.send(id, database[data.player], "luckyladycasino")
	elseif data.type == "setPlayerBalance" then
		print("Setting balance for ", data.player, " to ", data.balance)
		database[data.player].balance = data.balance
		local file = fs.open(databasePath, "w")
		file.write(textutils.serialise(database))
		file.close()
		rednet.send(id, nil, "luckyladycasino")
	elseif data.type == "addPlayer" then
		print("Adding player: #"..data.player, data.name)
		database[data.player] = {
			name=data.name,
			balance=0
		}
		local file = fs.open(databasePath, "w")
		file.write(textutils.serialise(database))
		file.close()
		rednet.send(id, nil, "luckyladycasino")

	end
end
