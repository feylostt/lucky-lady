local monitor, drive, surface, screen, width, height, font, buttons, printer, speaker

MAINFRAME_ID = 0
PAYOUT_FEE = 5

local currencyValues = {
    [ "numismatics:spur" ] = 1,
    [ "numismatics:bevel" ] = 8,
    [ "numismatics:sprocket" ] = 16,
    [ "numismatics:cog" ] = 64,
    [ "numismatics:crown" ] = 512,
    [ "numismatics:sun" ] = 4096
}

function getPlayerBalance(player)
	rednet.send(MAINFRAME_ID, {type="getPlayerBalance", player = player}, "luckyladycasino")
	local _, data = rednet.receive("luckyladycasino")
	if not data then
		return nil
	end
	return data.name, data.balance
end

function setPlayerBalance(player, balance)
	rednet.send(MAINFRAME_ID, {type = "setPlayerBalance", player = player, balance = balance}, "luckyladycasino")
	rednet.receive("luckyladycasino")
	local filePath = fs.combine(drive.getMountPath(), "bal")
	file = fs.open(filePath, "w")
	file.write(tostring(balance))
	file.close()
	return
end

function dropInventory()
	for i = 1,16 do
		turtle.select(i)
		turtle.drop()
	end
end

function countMoney()
	turtle.turnRight()
	local sum = 0
	for i = 1,2 do
		for slot = 1,16 do
			turtle.select(slot)
			local item = turtle.getItemDetail(slot)
			local isValid = false
			for currency,value in pairs(currencyValues) do
				if item and item.name == currency then
					isValid = true
					sum = sum + value * item.count
				end
			end
			if isValid then
				turtle.drop()
			elseif item then
				turtle.turnLeft()
				turtle.drop()
				turtle.turnRight()
			end
		end
	end
	turtle.select(1)
	turtle.turnLeft()
	return sum
end

function dropMoney(amount)
	-- parse vault contents
	local vault = peripheral.find("create:item_vault")
	local barrel = peripheral.find("minecraft:barrel")

	local coins = {
		{
			coin = "numismatics:sun",
			count = 0
		},
		{
			coin = "numismatics:crown",
			count = 0
		},
		{
			coin = "numismatics:cog",
			count = 0
		},
		{
			coin = "numismatics:sprocket",
			count = 0
		},
		{
			coin = "numismatics:bevel",
			count = 0
		},
		{
			coin = "numismatics:spur",
			count = 0
		}
	}

	for k,v in ipairs(vault.items(false)) do
		for key,value in ipairs(coins) do
			if v.name == value.coin then
				value.count = value.count + v.count
			end
		end
	end

	--[[ example vault.items
	{
		{
			count = 64,
			name = "numismatics:spur"
		},
		{
			count = 64,
			name = "numismatics:spur"
		}
	}
	]]

	-- "greedy" algorithm - compare amount to highest available coin and add it to the list of coins to drop
	while amount > 0 do
		for key, table in ipairs(coins) do
			if amount > currencyValues[table.coin] then
				local pushAmount = math.floor(amount / currencyValues[table.coin])
				if table.count < pushAmount then
					pushAmount = table.count
				end
				amount = amount - ( pushAmount * currencyValues[table.coin] )
				table.count = table.count - pushAmount
				vault.pushItem(peripheral.getName(barrel), table.coin, pushAmount)
				print("pushing "..pushAmount.." of "..table.coin)
			end
		end
	end

	turtle.turnRight()
	turtle.select(1)
	while true do
		turtle.suck()
		local item = turtle.getItemDetail(1)
		if item == nil then
			turtle.turnLeft()
			return nil
		end
		local amountDropping = item.count
		turtle.turnLeft()
		turtle.drop(amountDropping)
		turtle.turnRight()
		turtle.drop()
	end
end