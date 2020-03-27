ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('RiZiePersoMenu:getBills', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local bills = {}

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		for i = 1, #result, 1 do
			table.insert(bills, {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			})
		end

		cb(bills)
	end)
end)

ESX.RegisterServerCallback('RiZiePersoMenu:policecount', function(source, cb)
	local xPlayers = ESX.GetPlayers()

	keufco = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			keufco = keufco + 1
		end
	end

	cb(tostring(keufco))
end)

ESX.RegisterServerCallback('RiZiePersoMenu:mecanocount', function(source, cb)
	local xPlayers = ESX.GetPlayers()

	mecanoco = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'mechanic' then
			mecanoco = mecanoco + 1
		end
	end

	cb(tostring(mecanoco))
end)

ESX.RegisterServerCallback('RiZiePersoMenu:concesscount', function(source, cb)
	local xPlayers = ESX.GetPlayers()

	concessco = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'cardealer' then
			concessco = concessco + 1
		end
	end

	cb(tostring(concessco))
end)

ESX.RegisterServerCallback('RiZiePersoMenu:emscount', function(source, cb)
	local xPlayers = ESX.GetPlayers()

	emsco = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'ambulance' then
			emsco = emsco + 1
		end
	end

	cb(tostring(emsco))
end)


RegisterServerEvent('RiZiePersoMenu:animsync')
AddEventHandler('RiZiePersoMenu:animsync', function(target, animationLib, animation, animation2, distans, distans2, height,targetSrc,length,spin,controlFlagSrc,controlFlagTarget,animFlagTarget)
	TriggerClientEvent('RiZiePersoMenu:animsyncTarget', targetSrc, source, animationLib, animation2, distans, distans2, height, length,spin,controlFlagTarget,animFlagTarget)
	TriggerClientEvent('RiZiePersoMenu:animsyncMe', source, animationLib, animation,length,controlFlagSrc,animFlagTarget)
end)

RegisterServerEvent('RiZiePersoMenu:animstop')
AddEventHandler('RiZiePersoMenu:animstop', function(targetSrc)
	TriggerClientEvent('RiZiePersoMenu:animclientstop', targetSrc)
end)


RegisterServerEvent('RiZiePersoMenu:Patron_actionqlq')
AddEventHandler('RiZiePersoMenu:Patron_actionqlq', function(target, job, grade, jobtype, action)
	local xPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if xPlayer.job2.grade_name == 'boss' then
		if action == "recruter" then
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez ~g~recruté ' .. targetXPlayer.name .. '~w~ !')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~embauché par ' .. xPlayer.name .. '~w~ !')
			if jobtype == "job2" then
				targetXPlayer.setJob2(job, grade)
			elseif jobtype == "job1" then
				targetXPlayer.setJob(job, grade)
			end
		elseif action == "virer" then
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez ~r~viré ' .. targetXPlayer.name .. '~w~ !')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~r~viré par ' .. xPlayer.name .. '~w~ !')
			if jobtype == "job2" then
				targetXPlayer.setJob2('unemployed', 0)
			elseif jobtype == "job1" then
				targetXPlayer.setJob('unemployed', 0)
			end
		elseif action == "promouvoir" then
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez ~b~promu ' .. targetXPlayer.name .. '~w~ !')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~b~promu par ' .. xPlayer.name .. '~w~ !')
			if jobtype == "job2" then
				targetXPlayer.setJob2(job, tonumber(grade) + 1)
			elseif jobtype == "job1" then
				targetXPlayer.setJob(job, tonumber(grade) + 1)
			end
		end
	end
end)


------------events menu gang

RegisterServerEvent('RiZiePersoMenu:menotter')
AddEventHandler('RiZiePersoMenu:menotter', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('RiZiePersoMenu:menotter', target)
end)

RegisterServerEvent('RiZiePersoMenu:kidnapper')
AddEventHandler('RiZiePersoMenu:kidnapper', function(target)
  local _source = source
  TriggerClientEvent('RiZiePersoMenu:kidnapper', target, _source)
end)

RegisterServerEvent('RiZiePersoMenu:mettrevehicule')
AddEventHandler('RiZiePersoMenu:mettrevehicule', function(target)
  TriggerClientEvent('RiZiePersoMenu:mettrevehicule', target)
end)

RegisterServerEvent('RiZiePersoMenu:sortirvehicule')
AddEventHandler('RiZiePersoMenu:sortirvehicule', function(target)
    TriggerClientEvent('RiZiePersoMenu:sortirvehicule', target)
end)
