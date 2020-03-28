print("^0======================================================================^7")
print("^0[^4Author^0] ^7:^0 ^RZY#2004^7")
print("^0[^3Version^0] ^7:^0 ^01.0^7")
print("^0[^2Download^0] ^7:^0 ^5https://github.com/Riziebtw/rzy_personalmenu/releases^7")
print("^0[^1Issues^0] ^7:^0 ^5https://github.com/Riziebtw/rzy_personalmenu/issues^7")
print("^0======================================================================^7")


ESX = nil
playerGroup = nil
menuarmeitem = nil
menuiteminv = nil
billinfo = nil

iteminventaire     = {}
armeinventaire     = {}
facturesinventaire = {}
listejoueur = {}

---animation porter
piggyBackAnimNamePlaying = ""
piggyBackAnimDictPlaying = ""
piggyBackControlFlagPlaying = 0

_menuPool = nil



Player = {
	menuopen = false,
    vethaut = true,
    vetbas = true,
    vetch = true,
    vetsac = true,
    vetgilet = true,
    vetlunettes = true,
    vetmasque = true,
    vetchapeau = true,
    -----
    -----
    godmod = false,
    noclip = false,
    supersaut = false,
    staminainfini = false,
    fastrun = false,
    -----
    ----
    ragdoll = false,
    porter = false,
    minimap = true,
    voixchuchoter = false,
    voixnormal = true,
    voixcrier = false
}

Admin = {
    actuellementspec = false
}




Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(50)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    while actualSkin == nil do
        TriggerEvent('skinchanger:getSkin', function(skin) actualSkin = skin end)
        Citizen.Wait(10)
    end

    while playerGroup == nil do
        ESX.TriggerServerCallback('RiZiePersoMenu:getusergroup', function(group) playerGroup = group end)
        Citizen.Wait(10)
    end

    ESX.GetWeaponList = ESX.GetWeaponList()

    _menuPool = NativeUI.CreatePool()
    menuperso = NativeUI.CreateMenu(GetPlayerName(PlayerId()), Config.NomServer)
    menuarmeitem = NativeUI.CreateMenu(GetPlayerName(PlayerId()), "Actions Armes")
    menuiteminv = NativeUI.CreateMenu(GetPlayerName(PlayerId()), "Action Item")
    _menuPool:Add(menuperso)
    _menuPool:Add(menuarmeitem)
    _menuPool:Add(menuiteminv)
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('RiZiePersoMenu:kidnapper')
AddEventHandler('RiZiePersoMenu:kidnapper', function(target)
  IsDragged = not IsDragged
  CopPed = tonumber(target)
end)

RegisterNetEvent('RiZiePersoMenu:sortirvehicule')
AddEventHandler('RiZiePersoMenu:sortirvehicule', function(target)
  local ped = GetPlayerPed(target)
  ClearPedTasksImmediately(ped)
  plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
  local xnew = plyPos.x+2
  local ynew = plyPos.y+2

  SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

RegisterNetEvent('RiZiePersoMenu:mettrevehicule')
AddEventHandler('RiZiePersoMenu:mettrevehicule', function()

  local playerPed = GetPlayerPed(-1)
  local coords = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)

    if DoesEntityExist(vehicle) then

      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil

      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end

      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end

    end

  end

end)


RegisterNetEvent('RiZiePersoMenu:menotter')
AddEventHandler('RiZiePersoMenu:menotter', function()

  IsHandcuffed    = not IsHandcuffed;
  local playerPed = GetPlayerPed(-1)

  Citizen.CreateThread(function()

    if IsHandcuffed then

      RequestAnimDict('mp_arresting')

      while not HasAnimDictLoaded('mp_arresting') do
        Wait(100)
      end

      TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
      SetEnableHandcuffs(playerPed, true)
      SetPedCanPlayGestureAnims(playerPed, false)
      FreezeEntityPosition(playerPed,  true)

    else

      ClearPedSecondaryTask(playerPed)
      SetEnableHandcuffs(playerPed, false)
      SetPedCanPlayGestureAnims(playerPed,  true)
      FreezeEntityPosition(playerPed, false)

    end

  end)
end)

function helpnotif(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function TouslesJoueursCO()
    local joueurs = 0

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            joueurs = joueurs + 1
        end
    end

    return joueurs
end

function ObtenirJoueur()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function SpecJoueur(id)
    local joueur = GetPlayerPed(id)
    Admin.actuellementspec = not Admin.actuellementspec
    if Admin.actuellementspec then
        RequestCollisionAtCoord(GetEntityCoords(joueur))
        NetworkSetInSpectatorMode(true, joueur)
        ESX.ShowNotification('~b~Vous etes en train de spec: ~h~~w~' .. GetPlayerName(id))
    else
        RequestCollisionAtCoord(GetEntityCoords(joueur))
        NetworkSetInSpectatorMode(false, joueur)
        ESX.ShowNotification('~b~Vous avez arreté de spec: ~h~~w~' .. GetPlayerName(id))
    end
end



function JoueurPlusProche(radius)
    local players = ObtenirJoueur()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
	if closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

----- merci korioz pour celui la aussi
function getCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()

    local x = -math.sin(heading * math.pi/180.0)
    local y = math.cos(heading * math.pi/180.0)
    local z = math.sin(pitch * math.pi/180.0)

    local len = math.sqrt(x * x + y * y + z * z)

    if len ~= 0 then
        x = x/len
        y = y/len
        z = z/len
    end

    return x, y, z
end


-- merci à Korioz pour cette fonction
function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end

function startAttitude(lib, anim)
	Citizen.CreateThread(function()
		RequestAnimSet(anim)

		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(0)
		end

		SetPedMotionBlur(PlayerPedId(), false)
		SetPedMovementClipset(PlayerPedId(), anim, true)
	end)
end

function startAnim(lib, anim)
	--helpnotif('TIPS: ~h~Appuyez sur ~r~X~w~ pour arreter l\'animation !') -- enlevez les -- si vous voulez show la notif 
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
	end)
	if IsControlJustPressed(1,188) then
        -- si la touche X est press, ça annule l'emote
        ClearPedTasksImmediately(PlayerPedId())
    end
end

function animsActionScenario(animObj)
    local ped = GetPlayerPed(-1);
    --helpnotif('TIPS: ~h~Appuyez sur ~r~X~w~ pour arreter l\'animation !') -- enlevez les -- si vous voulez show la notif 

    if ped then
        local pos = GetEntityCoords(ped);
        local head = GetEntityHeading(ped);
        TaskStartScenarioInPlace(ped, animObj, 0, false)
        if IsControlJustPressed(1,188) then
        	-- si la touche X est press, ça annule l'emote
        	ClearPedTasksImmediately(PlayerPedId())
        end

    end
end
--------------------------------------------------------------------------------------------------------------

function AddPersoMenu(menu)

    local menuinventaire = _menuPool:AddSubMenu(menu, "Inventaire", "Accédez à votre inventaire")
    local menuarmes = _menuPool:AddSubMenu(menu, "Armes", "Accédez à vos armes")
    local menuportefeuille = _menuPool:AddSubMenu(menu, "Portefeuille", "Accédez à votre portefeuille")
    local menufacture = _menuPool:AddSubMenu(menu, "Factures", "Accédez à vos factures")
    local menuvetement = _menuPool:AddSubMenu(menu, "Vêtements", "Enlevez, remettez vos vêtements ici")
    --local menuaccessoires = _menuPool:AddSubMenu(menu, "Accessoires", "Enlevez, remettez vos accessoires ici")
    local menuanim = _menuPool:AddSubMenu(menu, "Animations", "Faites des animations ici")

    local menuboss = nil
    local menubossjob2 = nil

    if ESX.PlayerData.job.grade_name == "boss" then
    	menuboss = _menuPool:AddSubMenu(menu, "Gestion Entreprise: " .. ESX.PlayerData.job.label, "Gestion de votre entreprise.")

    	local recruterjob1 = NativeUI.CreateItem("Recruter", "Recruter la personne la plus proche de toi")
    	menuboss.SubMenu:AddItem(recruterjob1)

    	local virerjob1 = NativeUI.CreateItem("Virer", "Virer la personne la plus proche de toi")
    	menuboss.SubMenu:AddItem(virerjob1)

    	local promouvoirjob1 = NativeUI.CreateItem("Promouvoir", "Promouvoir la personne la plus proche de toi")
    	menuboss.SubMenu:AddItem(promouvoirjob1)

    	menuboss.SubMenu.OnItemSelect = function(sender, item, index)
		    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestDistance ~= -1 and closestDistance <= 3 then   
			    if item == recruterjob1 then
			    	TriggerServerEvent('RiZiePersoMenu:Patron_actionqlq', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0, 'job1', 'recruter')
			    elseif item == virerjob1 then
				    TriggerServerEvent('RiZiePersoMenu:Patron_actionqlq', GetPlayerServerId(closestPlayer), '', 0, 'job1', 'virer')
				elseif item == promouvoirjob1 then
					TriggerServerEvent('RiZiePersoMenu:Patron_actionqlq', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0, 'job1', 'promouvoir')
			    end
			else
				ESX.ShowNotification('Personne aux alentours !')
			end
	    end
    end
    if Config.DoubleJob == true then
    	if ESX.PlayerData.job2.grade_name == "boss" then
    		menubossjob2 = _menuPool:AddSubMenu(menu, "Gestion Organisation: " .. ESX.PlayerData.job2.label, "Gestion de votre organisation.")
    		
    		local recruterjob2 = NativeUI.CreateItem("Recruter", "Recruter la personne la plus proche de toi")
    		menubossjob2.SubMenu:AddItem(recruterjob2)

    		local virerjob2 = NativeUI.CreateItem("Virer", "Virer la personne la plus proche de toi")
    		menubossjob2.SubMenu:AddItem(virerjob2)

	    	local promouvoirjob2 = NativeUI.CreateItem("Promouvoir", "Promouvoir la personne la plus proche de toi")
	    	menubossjob2.SubMenu:AddItem(promouvoirjob2)

			menubossjob2.SubMenu.OnItemSelect = function(sender, item, index)
			    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestDistance ~= -1 and closestDistance <= 3 then   
				    if item == recruterjob2 then
				    	TriggerServerEvent('RiZiePersoMenu:Patron_actionqlq', GetPlayerServerId(closestPlayer), ESX.PlayerData.job2.name, 0, 'job2', 'recruter')
				    elseif item == virerjob2 then
					    TriggerServerEvent('RiZiePersoMenu:Patron_actionqlq', GetPlayerServerId(closestPlayer), '', 0, 'job1', 'virer')
					elseif item == promouvoirjob2 then
						TriggerServerEvent('RiZiePersoMenu:Patron_actionqlq', GetPlayerServerId(closestPlayer), ESX.PlayerData.job2.name, 0, 'job2', 'promouvoir')
				    end
				else
					ESX.ShowNotification('Personne aux alentours !')
				end
		    end
    	end
    end


    local menudivers = _menuPool:AddSubMenu(menu, "Divers", "Les options diverse")



    -------------------------------ANIMATIOKNS

    --local stopanimbtn = NativeUI.CreateItem("Stopper l'animation", "")
    local stopanimbtn = NativeUI.CreateColouredItem("Stopper l'animation", "", Colours.RedDark, Colours.RedDark)

    stopanimbtn:SetRightBadge(BadgeStyle.Tick)
    menuanim.SubMenu:AddItem(stopanimbtn)

    menuanim.SubMenu.OnItemSelect = function(sender, item, index)
    	if item == stopanimbtn then
    		ClearPedTasksImmediately(PlayerPedId())
    	end
	end


    --------------Sportives
    animsportMenu = _menuPool:AddSubMenu(menuanim.SubMenu, "Sportives")

    local yoga = NativeUI.CreateItem('Faire du Yoga', "Faire l'animation yoga")
	animsportMenu.SubMenu:AddItem(yoga)

    local jogging = NativeUI.CreateItem('Jogging', "Faire l'animation jogging")
	animsportMenu.SubMenu:AddItem(jogging)

    local pompes = NativeUI.CreateItem('Faire des Pompes', "Faire l'animation pompes")
	animsportMenu.SubMenu:AddItem(pompes)

	animsportMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == yoga then
			animsActionScenario("WORLD_HUMAN_YOGA")
		elseif item == jogging then
			animsActionScenario("WORLD_HUMAN_JOG_STANDING")
		elseif item == pompes then
			animsActionScenario("WORLD_HUMAN_PUSH_UPS")
		end
	end
	-------------------FESTIVES
	animfestiveMenu = _menuPool:AddSubMenu(menuanim.SubMenu, "Festives")

    local bierre = NativeUI.CreateItem('Boire une bière', "Faire l'animation pour boire une bière")
	animfestiveMenu.SubMenu:AddItem(bierre)

    local feu = NativeUI.CreateItem('Prés du feu', "Faire l'animation pres du feu")
	animfestiveMenu.SubMenu:AddItem(feu)

    local playmusic = NativeUI.CreateItem('Joueur de la Musique', "Faire l'animation pour jouer de la musique")
	animfestiveMenu.SubMenu:AddItem(playmusic)

    local cigarette = NativeUI.CreateItem('Fumer une Cigarette', "Faire l'animation pour fumer une cigarette")
	animfestiveMenu.SubMenu:AddItem(cigarette)

    local dj = NativeUI.CreateItem('Faire le DJ', "Faire l'animation pour faire le DJ")
	animfestiveMenu.SubMenu:AddItem(dj)

    local guitare = NativeUI.CreateItem('Air Guitar', "Faire l'animation Air Guitar")
	animfestiveMenu.SubMenu:AddItem(guitare)

    local bourre = NativeUI.CreateItem('Bourré sur place', "Faire l'animation Bourré sur place")
	animfestiveMenu.SubMenu:AddItem(bourre)

	local airshagging = NativeUI.CreateItem('Air Shagging', "Faire l'animation air shagging")
	animfestiveMenu.SubMenu:AddItem(airshagging)

	
	animfestiveMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == bierre then
			animsActionScenario("WORLD_HUMAN_PARTYING")
		elseif item == feu then
			animsActionScenario("WORLD_HUMAN_STAND_FIRE")
		elseif item == playmusic then
			animsActionScenario("WORLD_HUMAN_MUSICIAN")
		elseif item == cigarette then
			animsActionScenario("WORLD_HUMAN_SMOKING")
		elseif item == dj then
			startAnim("anim@mp_player_intcelebrationmale@dj", "dj")
		elseif item == guitare then
			startAnim("anim@mp_player_intcelebrationmale@air_guitar", "air_guitar")
		elseif item == bourre then
			startAnim("amb@world_human_bum_standing@drunk@idle_a", "idle_a")
		elseif item == airshagging then
			startAnim("anim@mp_player_intcelebrationfemale@air_shagging", "air_shagging")
		end
	end

	-------------------------------SALUTATIONS
	salutationsMenu = _menuPool:AddSubMenu(menuanim.SubMenu, "Salutations")

    local saluer = NativeUI.CreateItem('Saluer', "Faire l'animation pour saluer")
	salutationsMenu.SubMenu:AddItem(saluer)

    local serrermain = NativeUI.CreateItem('Serrer la main', "Faire l'animation pour serrer la main")
	salutationsMenu.SubMenu:AddItem(serrermain)

    local tcheck = NativeUI.CreateItem('Tcheck', "Faire l'animation pour tcheck")
	salutationsMenu.SubMenu:AddItem(tcheck)

    local tapemen5 = NativeUI.CreateItem('Tappes moi en 5', "Faire l'animation pour faire l'animation tappes moi en 5")
	salutationsMenu.SubMenu:AddItem(tapemen5)

    local ruesalut = NativeUI.CreateItem('Salut Rue', "Faire l'animation pour faire le salut de la rue la vraie")
	salutationsMenu.SubMenu:AddItem(ruesalut)

    local milisalut = NativeUI.CreateItem('Salut Millitaire', "Faire l'animation pour faire le salut millitaire")
	salutationsMenu.SubMenu:AddItem(milisalut)

	salutationsMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == saluer then
			startAnim("gestures@m@standing@casual", "gesture_hello")
		elseif item == serrermain then
			startAnim("mp_common", "givetake1_a")
		elseif item == tcheck then
			startAnim("mp_ped_interaction", "handshake_guy_a")
		elseif item == tapemen5 then
			startAnim("mp_ped_interaction", "highfive_guy_a")
		elseif item == ruesalut then
			startAnim("mp_ped_interaction", "hugs_guy_a")
		elseif item == milisalut then
			startAnim("mp_player_int_uppersalute", "mp_player_int_salute")
		end
	end
	-----------------------------------------TRAVAIL
	travailMenu = _menuPool:AddSubMenu(menuanim.SubMenu, "Travail")

    local serendre = NativeUI.CreateItem('Se rendre', "Faire l'animation pour se rendre")
	travailMenu.SubMenu:AddItem(serendre)

    local pecheur = NativeUI.CreateItem('Pêcheur', "Faire l'animation pour de pêcheur")
	travailMenu.SubMenu:AddItem(pecheur)

    local radio = NativeUI.CreateItem('Parler Radio', "Faire l'animation pour parler radio")
	travailMenu.SubMenu:AddItem(radio)

    local enqueter = NativeUI.CreateItem('Police: enquêter', "Faire l'animation de police pour enquêter")
	travailMenu.SubMenu:AddItem(enqueter)

    local jumelles = NativeUI.CreateItem('Jumelles', "Faire l'animation pour sortir les jumelles")
	travailMenu.SubMenu:AddItem(jumelles)

    local reparervoiture = NativeUI.CreateItem('Réparer le moteur', "Faire l'animation pour réparer le moteur")
	travailMenu.SubMenu:AddItem(reparervoiture)

    local observer = NativeUI.CreateItem('Médecin: observer', "Faire l'animation de médecin pour observer")
	travailMenu.SubMenu:AddItem(observer)

    local photo = NativeUI.CreateItem('Prendre une photo', "Faire l'animation de journaliste pour prendre une photo")
	travailMenu.SubMenu:AddItem(photo)

    local notes = NativeUI.CreateItem('Prendre des notres', "Faire l'animation pour prendre des notes")
	travailMenu.SubMenu:AddItem(notes)

    local sdf = NativeUI.CreateItem('SDF: Faire la manche', "Faire l'animation pour faire la manche")
	travailMenu.SubMenu:AddItem(sdf)

	travailMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == serendre then
			startAnim("random@arrests@busted", "idle_c")
		elseif item == pecheur then
			animsActionScenario("world_human_stand_fishing")
		elseif item == radio then
			startAnim("random@arrests", "generic_radio_chatter") 
		elseif item == enqueter then
			startAnim("amb@code_human_police_investigate@idle_b", "idle_f")
		elseif item == jumelles then
			animsActionScenario("WORLD_HUMAN_BINOCULARS")
		elseif item == reparervoiture then
			startAnim("mini@repair", "fixing_a_ped")
		elseif item == observer then
			animsActionScenario("CODE_HUMAN_MEDIC_KNEEL")
		elseif item == photo then
			animsActionScenario("WORLD_HUMAN_PAPARAZZI")
		elseif item == notes then
			animsActionScenario("WORLD_HUMAN_CLIPBOARD")
		elseif item == notes then
			animsActionScenario("WORLD_HUMAN_CLIPBOARD")
		elseif item == sdf then
			animsActionScenario("WORLD_HUMAN_BUM_FREEWAY")
		end
	end
	------------------------------HUMEURS
	humeurMenu = _menuPool:AddSubMenu(menuanim.SubMenu, "Humeurs")

    local feliciter = NativeUI.CreateItem('Féliciter', "Faire l'animation pour féliciter")
	humeurMenu.SubMenu:AddItem(feliciter)

    local dammed = NativeUI.CreateItem('Dammed', "Faire l'animation dammed")
	humeurMenu.SubMenu:AddItem(dammed)

    local sansblague = NativeUI.CreateItem('Sans Blague', "Faire l'animation sans blague")
	humeurMenu.SubMenu:AddItem(sansblague)

    local doigt = NativeUI.CreateItem('Doigt d\'Honneur', "Faire l'animation doigt d'honeur")
	humeurMenu.SubMenu:AddItem(doigt)

    local enlacer = NativeUI.CreateItem('Enlacer', "Faire l'animation pour enlacer")
	humeurMenu.SubMenu:AddItem(enlacer)

	humeurMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == feliciter then
			animsActionScenario("WORLD_HUMAN_CHEERING")
		elseif item == dammed then
			startAnim('gestures@m@standing@casual', 'gesture_damn')
		elseif item == sansblague then
			startAnim('gestures@m@standing@casual', 'gesture_no_way')
		elseif item == doigt then
			startAnim('mp_player_int_upperfinger', 'mp_player_int_finger_01_enter')
		elseif item == enlacer then
			startAnim('mp_ped_interaction', 'kisses_guy_a')
		end
	end

	---------------------démarches
	demarcheMenu = _menuPool:AddSubMenu(menuanim.SubMenu, "Démarches", "")

	local normalm = NativeUI.CreateItem('Normal M', "")
	demarcheMenu.SubMenu:AddItem(normalm)

	local normalf = NativeUI.CreateItem('Normal F', "")
	demarcheMenu.SubMenu:AddItem(normalf)

	local hommegay = NativeUI.CreateItem('Homme effiminer', "")
	demarcheMenu.SubMenu:AddItem(hommegay)

	local bouffiasse = NativeUI.CreateItem('Bouffiasse', "")
	demarcheMenu.SubMenu:AddItem(bouffiasse)

	local depressifvictime = NativeUI.CreateItem('Dépressif', "")
	demarcheMenu.SubMenu:AddItem(depressifvictime)

	local depressivepute = NativeUI.CreateItem('Dépressive', "")
	demarcheMenu.SubMenu:AddItem(depressivepute)

	local musclecommerzy = NativeUI.CreateItem('Muscle', "")
	demarcheMenu.SubMenu:AddItem(musclecommerzy)

	local hipster = NativeUI.CreateItem('Hipster', "")
	demarcheMenu.SubMenu:AddItem(hipster)

	local business = NativeUI.CreateItem('Business', "")
	demarcheMenu.SubMenu:AddItem(business)

	local intimide = NativeUI.CreateItem('Intimide', "")
	demarcheMenu.SubMenu:AddItem(intimide)

	local bourrer = NativeUI.CreateItem('Bourrer', "")
	demarcheMenu.SubMenu:AddItem(bourrer)

	local malheureux = NativeUI.CreateItem('Malheureux', "")
	demarcheMenu.SubMenu:AddItem(malheureux)

	local triste = NativeUI.CreateItem('Triste', "")
	demarcheMenu.SubMenu:AddItem(triste)

	local choc = NativeUI.CreateItem('Choc', "")
	demarcheMenu.SubMenu:AddItem(choc)

	local sombrecommerzy = NativeUI.CreateItem('Sombre', "")
	demarcheMenu.SubMenu:AddItem(sombrecommerzy)

	local fatiguercommemoiactuellement = NativeUI.CreateItem('Fatiguer', "")
	demarcheMenu.SubMenu:AddItem(fatiguercommemoiactuellement)

	local presser = NativeUI.CreateItem('Presser', "")
	demarcheMenu.SubMenu:AddItem(presser)

	local frimeur = NativeUI.CreateItem('Frimeur', "")
	demarcheMenu.SubMenu:AddItem(frimeur)

	local fier = NativeUI.CreateItem('Fier', "")
	demarcheMenu.SubMenu:AddItem(fier)

	local petitecourse = NativeUI.CreateItem('Petite course', "")
	demarcheMenu.SubMenu:AddItem(petitecourse)

	local pupute = NativeUI.CreateItem('Pupute', "")
	demarcheMenu.SubMenu:AddItem(pupute)

	local impertinente = NativeUI.CreateItem('Impertinente', "")
	demarcheMenu.SubMenu:AddItem(impertinente)

	local arrogante = NativeUI.CreateItem('Arrogante', "")
	demarcheMenu.SubMenu:AddItem(arrogante)

	local blesser = NativeUI.CreateItem('Blesser', "")
	demarcheMenu.SubMenu:AddItem(blesser)

	local tropmanger = NativeUI.CreateItem('Trop manger', "")
	demarcheMenu.SubMenu:AddItem(tropmanger)

	local casual = NativeUI.CreateItem('Casual', "")
	demarcheMenu.SubMenu:AddItem(casual)

	local determiner = NativeUI.CreateItem('Determiner', "")
	demarcheMenu.SubMenu:AddItem(determiner)

	local peureux = NativeUI.CreateItem('Peureux', "")
	demarcheMenu.SubMenu:AddItem(peureux)

	local tropswag = NativeUI.CreateItem('Trop Swag', "")
	demarcheMenu.SubMenu:AddItem(tropswag)

	local travailleur = NativeUI.CreateItem('Travailleur', "")
	demarcheMenu.SubMenu:AddItem(travailleur)

	local brute = NativeUI.CreateItem('Brute', "")
	demarcheMenu.SubMenu:AddItem(brute)

	local rando = NativeUI.CreateItem('Rando', "")
	demarcheMenu.SubMenu:AddItem(rando)

	local gangstere = NativeUI.CreateItem('Gangstère', "")
	demarcheMenu.SubMenu:AddItem(gangstere)

	local gangster = NativeUI.CreateItem('Gangster', "")
	demarcheMenu.SubMenu:AddItem(gangster)

	local franklinenerve = NativeUI.CreateItem('Franklin énervé', "")
	demarcheMenu.SubMenu:AddItem(franklinenerve)

	local mickaelenerve = NativeUI.CreateItem('Michael énervé', "")
	demarcheMenu.SubMenu:AddItem(mickaelenerve)

	demarcheMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == normalm then
			startAttitude("move_m@multiplayer", "move_m@multiplayer")
		elseif item == normalf then
			startAttitude("move_f@multiplayer", "move_f@multiplayer")
		elseif item == hommegay then
			startAttitude("move_m@confident", "move_m@confident")
		elseif item == bouffiasse then
			startAttitude("move_f@heels@c","move_f@heels@c")
		elseif item == depressifvictime then
			startAttitude("move_m@depressed@a","move_m@depressed@a")
		elseif item == depressivepute then
			startAttitude("move_f@depressed@a","move_f@depressed@a")
		elseif item == musclecommerzy then
			startAttitude("move_m@muscle@a","move_m@muscle@a")
		elseif item == hipster then
			startAttitude("move_m@hipster@a","move_m@hipster@a")
		elseif item == business then
			startAttitude("move_m@business@a","move_m@business@a")
		elseif item == intimide then
			startAttitude("move_m@hurry@a","move_m@hurry@a")
		elseif item == bourrer then
			startAttitude("move_m@hobo@a","move_m@hobo@a")
		elseif item == malheureux then
			startAttitude("move_m@sad@a","move_m@sad@a")
		elseif item == triste then
			startAttitude("move_m@leaf_blower","move_m@leaf_blower")
		elseif item == choc then
			startAttitude("move_m@shocked@a","move_m@shocked@a")
		elseif item == sombrecommerzy then
			startAttitude("move_m@shadyped@a","move_m@shadyped@a")
		elseif item == fatiguercommemoiactuellement then
			startAttitude("move_m@buzzed","move_m@buzzed")
		elseif item == presser then
			startAttitude("move_m@hurry_butch@a","move_m@hurry_butch@a")
		elseif item == frimeur then
			startAttitude("move_m@money","move_m@money")
		elseif item == fier then
			startAttitude("move_m@posh@","move_m@posh@")
		elseif item == petitecourse then
			startAttitude("move_m@quick","move_m@quick")
		elseif item == pupute then
			startAttitude("move_f@maneater","move_f@maneater")
		elseif item == impertinente then
			startAttitude("move_f@sassy","move_f@sassy")
		elseif item == arrogante then
			startAttitude("move_f@arrogant@a","move_f@arrogant@a")
		elseif item == blesser then
			startAttitude("move_m@injured","move_m@injured")
		elseif item == tropmanger then
			startAttitude("move_m@fat@a","move_m@fat@a")
		elseif item == casual then
			startAttitude("move_m@casual@a","move_m@casual@a")
		elseif item == determiner then
			startAttitude("move_m@brave@a","move_m@brave@a")
		elseif item == peureux then
			startAttitude("move_m@scared","move_m@scared")
		elseif item == tropswag then
			startAttitude("move_m@swagger@b","move_m@swagger@b")
		elseif item == travailleur then
			startAttitude("move_m@tool_belt@a","move_m@tool_belt@a")
		elseif item == brute then
			startAttitude("move_m@tough_guy@","move_m@tough_guy@")
		elseif item == rando then
			startAttitude("move_m@hiking","move_m@hiking")
		elseif item == gangstere then
			startAttitude("move_m@gangster@ng","move_m@gangster@ng")
		elseif item == gangster then
			startAttitude("move_m@gangster@generic","move_m@gangster@generic")
		elseif item == franklinenerve then
			startAttitude("move_characters@franklin@fire","move_characters@franklin@fire")
		elseif item == mickaelenerve then
			startAttitude("move_characters@michael@fire","move_characters@michael@fire")
		end
	end


    ------------------------ inventaire
    local invCount = nil
    for x=1, #ESX.PlayerData.inventory, 1 do
        local count = ESX.PlayerData.inventory[x].count
        if count > 0 then
            invCount = {}
            local label = ESX.PlayerData.inventory[x].label
            local value = ESX.PlayerData.inventory[x].name
            for x = 1, count, 1 do
                table.insert(invCount, x)
            end

            iteminventaire[value] = NativeUI.CreateListItem(label .. " (" .. count .. ")", invCount, 1)
            menuinventaire.SubMenu:AddItem(iteminventaire[value])

        end
    end

    local utiliseritem = NativeUI.CreateItem('Utiliser', "Utilise l'item choisit")
	menuiteminv:AddItem(utiliseritem)

	local donneritem = NativeUI.CreateItem('Donner', "Donne l'item choisit")
	menuiteminv:AddItem(donneritem)

	local jeteritem = NativeUI.CreateItem('Jeter', "Jete l'item choisit")
	menuiteminv:AddItem(jeteritem)

	local retourmenu = NativeUI.CreateItem('Retour', "Retourne au menu précédent")
	menuiteminv:AddItem(retourmenu)


	menuinventaire.SubMenu.OnListSelect = function(sender, item, index)
		_menuPool:CloseAllMenus(true)
		menuiteminv:Visible(true)
		for i = 1, #ESX.PlayerData.inventory, 1 do
			local label	    = ESX.PlayerData.inventory[i].label
			local count	    = ESX.PlayerData.inventory[i].count
			local value	    = ESX.PlayerData.inventory[i].name
			local usable	= ESX.PlayerData.inventory[i].usable
			local canRemove = ESX.PlayerData.inventory[i].canRemove
			local quantity  = index
			if item == iteminventaire[value] then
				menuiteminv.OnItemSelect = function(sender, item, index)
				if not IsPedSittingInAnyVehicle(PlayerPedId()) then
					if item == utiliseritem then
						if usable then
							TriggerServerEvent('esx:useItem', value)
						else
							ESX.ShowNotification('Cet item n\'est pas utilisable !')
						end
					elseif item == donneritem then
						local playertrouve = false
						closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestDistance ~= -1 and closestDistance <= 3 then
							playertrouve = true
						end

						if playertrouve == true then
							local pedproche = GetPlayerPed(closestPlayer)
							if quantity ~= nil and count > 0 then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', value, quantity)
								_menuPool:CloseAllMenus()
							else
								ESX.ShowNotification('Montant invalide !')
							end
						else
							ESX.ShowNotification('Il n\'y a personne aux alentours !')
						end
						elseif item == jeteritem then
							TriggerServerEvent('esx:removeInventoryItem', 'item_standard', value, quantity)
							_menuPool:CloseAllMenus()
						elseif item == retourmenu then
							_menuPool:CloseAllMenus(true)
							menuinventaire.SubMenu:Visible(true)
						end
					else
						ESX.ShowNotification('Vous ne pouvez pas faire cela dans un véhicule !')
					end
		    	end
			end
		end
	end
	


    -----------------armes
    for i = 1, #ESX.GetWeaponList, 1 do
        if HasPedGotWeapon(PlayerPedId(), GetHashKey(ESX.GetWeaponList[i].name), false) and ESX.GetWeaponList[i].name ~= 'WEAPON_UNARMED' then
            local ammo      = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(ESX.GetWeaponList[i].name))
            local label     = ESX.GetWeaponList[i].label .. ' [x' .. ammo .. ']'
            local value     = ESX.GetWeaponList[i].name

            armeinventaire[value] = NativeUI.CreateItem(label, "")
            armeinventaire[value]:RightLabel("→→→")
            menuarmes.SubMenu:AddItem(armeinventaire[value])


            menuarmes.SubMenu.OnItemSelect = function(sender, item, index)
            	if item == armeinventaire[value] then
					_menuPool:CloseAllMenus(true)
					menuarmeitem:Visible(true)
            	end
        	end
        end
    end

    local donnerarme = NativeUI.CreateItem('Donner', "")
	menuarmeitem:AddItem(donnerarme)

	local retourmenuarme = NativeUI.CreateItem('Retour', "Retourne au menu précédent")
	menuarmeitem:AddItem(retourmenuarme)

	--[[local jeterarme = NativeUI.CreateItem('Jeter', "")
	menuarmeitem.SubMenu:AddItem(jeterarme)--]] -- est-ce vraiment utile? je pense pas et ça me fait rajouter du code pour un truc vraiment pas utilisé

	menuarmes.SubMenu.OnItemSelect = function(sender, item, index)
		_menuPool:CloseAllMenus(true)
		menuarmeitem:Visible(true)
		for i = 1, #ESX.GetWeaponList, 1 do
			if HasPedGotWeapon(PlayerPedId(), GetHashKey(ESX.GetWeaponList[i].name), false) and ESX.GetWeaponList[i].name ~= 'WEAPON_UNARMED' then
				local ammo 		= GetAmmoInPedWeapon(PlayerPedId(), weaponHash)
				local value	    = ESX.GetWeaponList[i].name
				local label	    = ESX.GetWeaponList[i].label
				menuarmeitem.OnItemSelect = function(sender, item, index)
					if item == donnerarme then
						local playertrouve = false
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestDistance ~= -1 and closestDistance <= 3 then
							playertrouve = true
						end
						if playertrouve == true then
							local Pedproche = GetPlayerPed(closestPlayer)
							if not IsPedSittingInAnyVehicle(Pedproche) then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_weapon', value, ammo)
								_menuPool:CloseAllMenus(true)

	            			end
	            		else
	            			print('rzypersomenu: personne autour du joueur')
	            			ESX.ShowNotification('Il n\'y a aucun joueurs aux alentours !')
						end
					elseif item == retourmenuarme then
						_menuPool:CloseAllMenus(true)
						menuarmes.SubMenu:Visible(true)
					end
				end
			end
		end
	end


	--------------------portefeuille

	-------------La liste des possibilités d'action de la list des item money & dirty money
	local MoneyList = {
		'Donner',
		'Jeter'
	}

	local carteID = {
		'Regarder',
		'Montrer'
	}

	--------- basique, on obtient l'argent sur sois, son org et son job.
	local metierport = NativeUI.CreateItem("Métier: " .. ESX.PlayerData.job.label .. " - " .. ESX.PlayerData.job.grade_label, "Ton métier, et ton grade")
    menuportefeuille.SubMenu:AddItem(metierport)
    if Config.DoubleJob == true then
    	local orgaport = NativeUI.CreateItem("Organisation: " .. ESX.PlayerData.job2.label .. " - " .. ESX.PlayerData.job2.grade_label, "Ton organisation, et ton grade")
    	menuportefeuille.SubMenu:AddItem(orgaport)
    end
    local argentport = NativeUI.CreateListItem("Argent: $" .. ESX.Math.GroupDigits(ESX.PlayerData.money), MoneyList, 1, "L'argent que tu as sur toi")
    menuportefeuille.SubMenu:AddItem(argentport)


    --[[ ici on get l'argent qu'il y a sur le "compte" black_money qui nous permet d'obtenir l'argent sale qu'on a sur soit, et on get l'argzent qu'il y a sur le compte 
    "bank" qui nous permet d'obtenir l'argent en banque. Et puis pour chacun des deux comptes on y crée un boutton qui correspond à l'argent.--]]

    local argentsaleport = nil

    for i = 1, #ESX.PlayerData.accounts, 1 do
    	if ESX.PlayerData.accounts[i].name == 'black_money' then
		    argentsaleport = NativeUI.CreateListItem("Argent Sale: $" .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money), MoneyList, 1, "L'argent sale que tu as sur toi")
		    menuportefeuille.SubMenu:AddItem(argentsaleport)
		elseif ESX.PlayerData.accounts[i].name == 'bank' then
		    local argentbanqueport = NativeUI.CreateItem("Banque: $" .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money), "L'argent que tu as en banque")
		    menuportefeuille.SubMenu:AddItem(argentbanqueport)
		end
	end

	local carteidport = nil
	local permisconduireport = nil
	local ppaport = nil

	if Config.jsfouridcard == true then
    	carteidport = NativeUI.CreateListItem("Carte d'identité", carteID, 1, "Regardes ou montres ta carte d'identité")
    	menuportefeuille.SubMenu:AddItem(carteidport)

    	permisconduireport = NativeUI.CreateListItem("Permis de Conduire", carteID, 1, "Regardes ou montres ton permis de conduire")
    	menuportefeuille.SubMenu:AddItem(permisconduireport)

    	ppaport = NativeUI.CreateListItem("Permis de port d'armes", carteID, 1, "Regardes ou montres ton PPA")
    	menuportefeuille.SubMenu:AddItem(ppaport)
    end




	-------------------- on fait les check qu'il nous fait et on trigger les events pour give la tune
	menuportefeuille.SubMenu.OnListSelect = function(sender, item, index)
		if item == argentsaleport or item == argentport then
			if index == 1 then -- index 1 = Donner
				local quantite = KeyboardInput('RIZIE_TXTBOX_AMOUNT', 'Combien d\'argent souhaitez vous donner?', '', 10) -- 10 = le maximum de nombre possible ds la txtbox
				if quantite ~= nil then
					
					quantite = tonumber(quantite)
					if type(quantite) == 'number' then
						quantite = ESX.Math.Round(quantite)
						if quantite > 0 then
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							local playertrouve = false
							if closestDistance ~= -1 and closestDistance <= 3 then
								playertrouve = true
							end

							if playertrouve == true then
								local pedproche = GetPlayerPed(closestPlayer)
								if not IsPedSittingInAnyVehicle(pedproche) then
									if item == argentsaleport then
										TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', 'black_money', quantite)
										_menuPool:CloseAllMenus()
									elseif item == argentport then
										TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_money', 'money', quantite)
										_menuPool:CloseAllMenus()
									end
								end
							else
								ESX.ShowNotification('Il n\'y a personne aux alentours !')
							end
						else
							ESX.ShowNotification('Montant invalide !')
						end
					end
				end
			elseif index == 2 then
				local quantite = KeyboardInput('RIZIE_TXTBOX_AMOUNT', 'Combien d\'argent souhaitez vous jeter?', '', 10) -- 10 = le maximum de nombre possible ds la txtbox
				if quantite ~= nil then
					
					quantite = tonumber(quantite)
					if type(quantite) == 'number' then
						quantite = ESX.Math.Round(quantite)
						if quantite > 0 then
							local pedproche = GetPlayerPed(closestPlayer)
							if not IsPedSittingInAnyVehicle(pedproche) then
								if item == argentsaleport then
									TriggerServerEvent('esx:removeInventoryItem', 'item_account', 'black_money', quantite)
									_menuPool:CloseAllMenus()
								elseif item == argentport then
									TriggerServerEvent('esx:removeInventoryItem', 'item_money', 'money', quantite)
									_menuPool:CloseAllMenus()
								end
							end
						else
							ESX.ShowNotification('Montant invalide !')
						end
					end
				end
			end	
			elseif item == carteidport then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()	
			if index == 1 then -- index 1 == regarder
    			TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
    		elseif index == 2 then -- index 2 == montrer
    			if closestDistance ~= -1 and closestDistance <= 3 then
    				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
    			else
    				ESX.ShowNotification('Il n\'y a personne aux alentours !')
    			end
    		end	
    		elseif item == permisconduireport then
    		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()		
    		if index == 1 then -- tj pareil 1 == regarder
    			TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
    		elseif index == 2 then -- tj pareil
    			if closestDistance ~= -1 and closestDistance <= 3 then
    				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
    			else
    				ESX.ShowNotification('Il n\'y a personne aux alentours !')
    			end
    		end
    		elseif item == ppaport then
    		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()		
    		if index == 1 then -- tj pareil 1 == regarder
    			TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
    		elseif index == 2 then -- tj pareil
    			if closestDistance ~= -1 and closestDistance <= 3 then
    				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
    			else
    				ESX.ShowNotification('Il n\'y a personne aux alentours !')
    			end
    		end
		end
	end

    --------------------------------factures        



    ESX.TriggerServerCallback('RiZiePersoMenu:getBills', function(bills)
        for i = 1, #bills, 1 do
            table.insert(facturesinventaire, bills[i].id)

            facturesinventaire[bills[i].id] = NativeUI.CreateItem(bills[i].label, "")
            facturesinventaire[bills[i].id]:RightLabel("~g~$" .. ESX.Math.GroupDigits(bills[i].amount))
            menufacture.SubMenu:AddItem(facturesinventaire[bills[i].id])
        end

        menufacture.SubMenu.OnItemSelect = function(sender, item, index)
            for i = 1, #bills, 1 do
                if item == facturesinventaire[bills[i].id] then
                    ESX.TriggerServerCallback('esx_billing:payBill', function()
                        _menuPool:CloseAllMenus()
                    end, bills[i].id)
                end
            end
        end
    end)


    -------------------------MENU DIVERS/MENU GANG
    if Config.Gangmenu == true then
        for i = 1, #Config.Gangs, 1 do
            local name = Config.Gangs[i].name
    	    if ESX.PlayerData.job2.name == name then
    		    diversxgangMenu = _menuPool:AddSubMenu(menudivers.SubMenu, "Actions Gang")

    		    local menotter = NativeUI.CreateItem("Menotter", "Menotte le joueur le plus proche de toi")
    		    diversxgangMenu.SubMenu:AddItem(menotter)

    		    local kidnapper = NativeUI.CreateItem("Kidnapper", "Kidnappe le joueur le plus proche de toi")
    		    diversxgangMenu.SubMenu:AddItem(kidnapper)

    		    local mettrevehicle = NativeUI.CreateItem("Mettre de force dans le véhicule", "Mettre de force le joueur le plus proche de toi dans le véhicule")
    		    diversxgangMenu.SubMenu:AddItem(mettrevehicle)

    		    local sortirvehicle = NativeUI.CreateItem("Sortir de force du véhicule", "Sortir de force le joueur le plus proche de toi du véhicule")
    		    diversxgangMenu.SubMenu:AddItem(sortirvehicle)


    		    diversxgangMenu.SubMenu.OnItemSelect = function(sender, item)
    	            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    				if closestDistance ~= -1 and closestDistance <= 3 and not IsPedInAnyVehicle(GetPlayerPed(GetPlayerFromServerId(closestPlayer)), true) then   	
    			        if item == menotter then
    			            TriggerServerEvent('RiZiePersoMenu:menotter', GetPlayerServerId(closestPlayer))
    			        elseif item == kidnapper then
    			            TriggerServerEvent('RiZiePersoMenu:kidnapper', GetPlayerServerId(closestPlayer))
    			        elseif item == mettrevehicle then
    			            TriggerServerEvent('RiZiePersoMenu:mettrevehicle', GetPlayerServerId(closestPlayer))
    			        elseif item == sortirvehicle then
    			            TriggerServerEvent('RiZiePersoMenu:sortirvehicle', GetPlayerServerId(closestPlayer))
    			        end
    			    else
    			    	ESX.ShowNotification('Il n\'y a personne aux alentours !')
    			    end
    	    	end
    		end
        end
	end

    ---------------------MENU DIVERS/ACTIONS
    diversxactionMenu = _menuPool:AddSubMenu(menudivers.SubMenu, "Actions Civil")

    local porter = NativeUI.CreateCheckboxItem("Porter", Player.porter, "Portes le joueur le plus proche de toi")
    diversxactionMenu.SubMenu:AddItem(porter)

    local dormir = NativeUI.CreateCheckboxItem("Dormir", Player.ragdoll, "Vous endormir")
    diversxactionMenu.SubMenu:AddItem(dormir)

    diversxactionMenu.SubMenu.OnCheckboxChange = function(sender, item, checked_)
        if item == dormir then
            Player.ragdoll = not Player.ragdoll

            if not Player.ragdoll then
                Citizen.Wait(1)
            end
        elseif item == minimap then
            Player.minimap = not Player.minimap
            DisplayRadar(Player.minimap)
        elseif item == porter then
        	TriggerEvent('RiZiePersoMenu:porter')
        	_menuPool:CloseAllMenus()
        end
    end

    ------------------------MENU DIVERS/OPTIONS

    diversxoptionsMenu = _menuPool:AddSubMenu(menudivers.SubMenu, "Options")

	local voixlist = {
		'Chuchoter',
		'Normal',
		'Crier'
	}

    local minimap = NativeUI.CreateCheckboxItem("Minimap", Player.minimap, "Afficher ou non la minimap")
    diversxoptionsMenu.SubMenu:AddItem(minimap)

    local sauvegarderperso = NativeUI.CreateItem("Sauvegarder votre Personnage", "Afficher ou non la minimap")
    diversxoptionsMenu.SubMenu:AddItem(sauvegarderperso)

    local quelindex = 2
    if Player.voixchuchoter == true then
    	quelindex = 1
    elseif Player.voixnormal == true then
    	quelindex = 2
    elseif Player.voixcrier == true then
    	quelindex = 3
    end
    local voix = NativeUI.CreateListItem("Voix", voixlist, quelindex, "Changer la distance de parole")
    diversxoptionsMenu.SubMenu:AddItem(voix)

    diversxoptionsMenu.SubMenu.OnItemSelect = function(sender, item)
        if item == sauvegarderperso then
            TriggerEvent('esx_skin:requestSaveSkin', source)
            Citizen.Wait(500)
            ESX.ShowNotification('📌Personnage synchronisé.')
        end
    end

    diversxoptionsMenu.SubMenu.OnListSelect = function(sender, item, index)
        if item == voix then
            if index == 1 then
	            if not Player.voixchuchoter then
					NetworkSetTalkerProximity(2.01)
					Citizen.Wait(250)
					ESX.ShowNotification("Vous etes maintenant en train de chuchoter !")
					Player.voixchuchoter, Player.voixnormal, Player.voixcrier = true, false, false
				else
					ESX.ShowNotification('Vous etes déjà entrain de chuchoter !')
				end
	        elseif index == 2 then
	        	if not Player.voixnormal then
					NetworkSetTalkerProximity(8.01)
					Citizen.Wait(250)
					ESX.ShowNotification("Vous etes maintenant en train de parler normalement !")
					Player.voixchuchoter, Player.voixnormal, Player.voixcrier = false, true, false
				else
					ESX.ShowNotification('Vous etes déjà entrain de parler normalement !')
				end
	        elseif index == 3 then
				NetworkSetTalkerProximity(15.01)
				Citizen.Wait(250)
				ESX.ShowNotification("Vous etes maintenant en train de crier !")
				Player.voixchuchoter, Player.voixnormal, Player.voixcrier = false, false, true
				else
					ESX.ShowNotification('Vous etes déjà entrain de crier !')
	        end
        end
    end

    diversxoptionsMenu.SubMenu.OnCheckboxChange = function(sender, item, checked_)
        if item == minimap then
            Player.minimap = not Player.minimap
            DisplayRadar(Player.minimap)
        end
    end

    ---------------------MENU DIVERS/INFOS

    diversxinfosMenu = _menuPool:AddSubMenu(menudivers.SubMenu, "Infos")

	local joueurs = NativeUI.CreateItem("Nombre de joueurs connectés: " .. tostring(TouslesJoueursCO()), "")
	diversxinfosMenu.SubMenu:AddItem(joueurs)

    ESX.TriggerServerCallback('RiZiePersoMenu:policecount', function(keuf)
    	local keuf = NativeUI.CreateItem("Nombre de policiers connectés: " .. keuf, "")
		diversxinfosMenu.SubMenu:AddItem(keuf)
	end)

    ESX.TriggerServerCallback('RiZiePersoMenu:mecanocount', function(mecanos)
    	local mecanos = NativeUI.CreateItem("Nombre de mécanos connectés: " .. mecanos, "")
		diversxinfosMenu.SubMenu:AddItem(mecanos)
	end)

    ESX.TriggerServerCallback('RiZiePersoMenu:concesscount', function(concess)
    	local concess = NativeUI.CreateItem("Nombre de concessionnaires connectés: " .. concess, "")
		diversxinfosMenu.SubMenu:AddItem(concess)
	end)

    ESX.TriggerServerCallback('RiZiePersoMenu:emscount', function(ems)
    	local ems = NativeUI.CreateItem("Nombre d'EMS connectés: " .. ems, "")
		diversxinfosMenu.SubMenu:AddItem(ems)
	end)

    

    ---------------------MENU VETEMENTS / ACCESSOIRES
    vetementxHabit = _menuPool:AddSubMenu(menuvetement.SubMenu, "Habits")
	vetementxAccessoires = _menuPool:AddSubMenu(menuvetement.SubMenu, "Accessoires")

    local hautvet = NativeUI.CreateCheckboxItem("Haut", Player.vethaut, "Enlever ou mettre votre haut")
    vetementxHabit.SubMenu:AddItem(hautvet)
    local basvet = NativeUI.CreateCheckboxItem("Bas", Player.vetbas, "Enlever ou mettre votre bas")
    vetementxHabit.SubMenu:AddItem(basvet)
    local chaussurevet = NativeUI.CreateCheckboxItem("Chaussures", Player.vetch, "Enlever ou mettre vos chaussures")
    vetementxHabit.SubMenu:AddItem(chaussurevet)
    local sacvet = NativeUI.CreateCheckboxItem("Sac", Player.vetch, "Enlever ou mettre votre sac")
    vetementxHabit.SubMenu:AddItem(sacvet)
    local giletparbvet = NativeUI.CreateCheckboxItem("Gillet par Balle", Player.vetch, "Enlever ou mettre votre gilet par balle")
    vetementxHabit.SubMenu:AddItem(giletparbvet)
    
    vetementxHabit.SubMenu.OnCheckboxChange = function(sender, item, checked_)
        if item == hautvet then
            TriggerEvent('RiZiePersoMenu:haut')
        elseif item == basvet then
            TriggerEvent('RiZiePersoMenu:bas')
        elseif item == chaussurevet then
            TriggerEvent('RiZiePersoMenu:chaussures')
        elseif item == sacvet then
            TriggerEvent('RiZiePersoMenu:sac')
        elseif item == giletparbvet then
            TriggerEvent('RiZiePersoMenu:gilet')
        end
    end

    local accesslunettes = NativeUI.CreateCheckboxItem("Lunettes", Player.vetlunettes, "Enlever ou mettre vos Lunettes")
    vetementxAccessoires.SubMenu:AddItem(accesslunettes)

    local accessmasque = NativeUI.CreateCheckboxItem("Masque", Player.vetmasque, "Enlever ou mettre votre Masque")
    vetementxAccessoires.SubMenu:AddItem(accessmasque)

    local accesschapeau = NativeUI.CreateCheckboxItem("Casque | Chapeau", Player.vetchapeau, "Enlever ou mettre votre Casque ou Chapeau")
    vetementxAccessoires.SubMenu:AddItem(accesschapeau)

    
    vetementxAccessoires.SubMenu.OnCheckboxChange = function(sender, item, checked_)
        if item == accesslunettes then
            TriggerEvent('RiZiePersoMenu:access', "Glasses")
        elseif item == accessmasque then
            TriggerEvent('RiZiePersoMenu:access', "Mask")
        elseif item == accesschapeau then
            TriggerEvent('RiZiePersoMenu:access', "Helmet")
        end
    end

    -------------------------------MENU ADMIN
    for i = 1, #Config.Rank, 1 do
        if playerGroup == Config.Rank[i].name then
            local menuadmin = _menuPool:AddSubMenu(menu, "Modération", "Menu réservé au bg de staff")
            
            -----------------------MENU ADMIN/JOEURS CO
            joueurscoAdmin = _menuPool:AddSubMenu(menuadmin.SubMenu, "Liste des Joueurs Connectés", "Obtient la liste des joueurs connectés")

            for i = 0, 255 do
                if NetworkIsPlayerActive(i) and GetPlayerServerId(i)  ~= 0 then
                    local valuejoueur = GetPlayerServerId(i)
                    local namejoueur = GetPlayerName(i)

                    listejoueur[valuejoueur] = _menuPool:AddSubMenu(joueurscoAdmin.SubMenu, namejoueur, "")

                    specjoueur = NativeUI.CreateCheckboxItem("Spec " .. namejoueur, Admin.actuellementspec, "")
                    listejoueur[valuejoueur].SubMenu:AddItem(specjoueur)

                    kickjoueur = NativeUI.CreateItem("Kick " .. namejoueur, "")
                    listejoueur[valuejoueur].SubMenu:AddItem(kickjoueur)

                    revivejoueur = NativeUI.CreateItem("Revive " .. namejoueur, "")
                    listejoueur[valuejoueur].SubMenu:AddItem(revivejoueur)

                    donnerargentjoueur = NativeUI.CreateItem("Donner de l'argent à " .. namejoueur, "")
                    listejoueur[valuejoueur].SubMenu:AddItem(donnerargentjoueur)

                    tpajoueur = NativeUI.CreateItem("Me TP à " .. namejoueur, "")
                    listejoueur[valuejoueur].SubMenu:AddItem(tpajoueur)

                    listejoueur[valuejoueur].SubMenu.OnItemSelect = function(sender, item)
                        if item == kickjoueur then
                            TriggerServerEvent('RiZiePersoMenu:kickjoueur', valuejoueur)
                            _menuPool:CloseAllMenus()
                        elseif item == revivejoueur then
                            TriggerServerEvent('esx_ambulancejob:revive', valuejoueur)
                        elseif item == donnerargentjoueur then
                            local quantite = KeyboardInput('RIZIE_TXTBOX_AMOUNT', 'Combien d\'argent souhaitez vous donner?', '', 10) -- 10 = le maximum de nombre possible ds la txtbox
                            TriggerServerEvent('RiZiePersoMenu:donnerargent', quantite, valuejoueur)
                            ESX.ShowNotification('~b~Vous avez donné: ~w~' .. tostring(quantite) .. '~b~$ à ~w~' .. namejoueur)
                        elseif item == tpajoueur then
                            SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(valuejoueur))))
                            ESX.ShowNotification('~b~Vous vous etes tp à: ~h~~w~' .. namejoueur)
                        end
                    end

                    listejoueur[valuejoueur].SubMenu.OnCheckboxChange = function(sender, item, checked_)
                        if item == specjoueur then
                            SpecJoueur(i)
                        end
                    end
                end
            end


            ----------------------------------MENU ADMIN BASE


            local godmodstaff = NativeUI.CreateCheckboxItem("GodMod", Player.godmod, "Activez ou désactivez le godmod")
            menuadmin.SubMenu:AddItem(godmodstaff)

            local noclipstaff = NativeUI.CreateCheckboxItem("NoClip", Player.noclip, "Activez ou désactivez le noclip")
            menuadmin.SubMenu:AddItem(noclipstaff)

            local supersautstaff = NativeUI.CreateCheckboxItem("Super Saut", Player.supersaut, "Activez ou désactivez le super saut tah spider man")
            menuadmin.SubMenu:AddItem(supersautstaff)

            local staminastaff = NativeUI.CreateCheckboxItem("Stamina Infinit", Player.staminainfini, "Activez ou désactivez la stamina infinit")
            menuadmin.SubMenu:AddItem(staminastaff)

            local fastrunstaff = NativeUI.CreateCheckboxItem("Fast Run", Player.fastrun, "Activez ou désactivez le fast run")
            menuadmin.SubMenu:AddItem(fastrunstaff)



            menuadmin.SubMenu.OnCheckboxChange = function(sender, item, checked_)
                if item == godmodstaff then
                    Player.godmod = not Player.godmod
                    SetEntityInvincible(PlayerPedId(), Player.godmod)
                    ESX.ShowNotification('~b~Vous avez mit le GodMod en: ~h~~w~' .. tostring(Player.godmod))
                elseif item == noclipstaff then
                    Player.noclip = not Player.noclip
                    if Player.noclip then
                        SetEntityInvincible(PlayerPedId(), true)
                        SetEntityVisible(PlayerPedId(), false, false)
                        ESX.ShowNotification('~b~Vous avez mit le NoClip en: ~h~~w~' .. tostring(Player.noclip))
                    else
                        SetEntityInvincible(PlayerPedId(), false)
                        SetEntityVisible(PlayerPedId(), true, false)
                        ESX.ShowNotification('~b~Vous avez mit le NoClip en: ~h~~w~' .. tostring(Player.noclip))
                    end
                elseif item == supersautstaff then
                    Player.supersaut = not Player.supersaut
                    ESX.ShowNotification('~b~Vous avez mit le Super Saut en: ~h~~w~' .. tostring(Player.supersaut))
                elseif item == staminastaff then
                    Player.staminainfini = not Player.staminainfini
                    ESX.ShowNotification('~b~Vous avez mit la Stamina Infinit en: ~h~~w~' .. tostring(Player.staminainfini))
                elseif item == fastrunstaff then
                    Player.fastrun = not Player.fastrun
                    ESX.ShowNotification('~b~Vous avez mit le Fast Run en: ~h~~w~' .. tostring(Player.fastrun))
                end
            end
        end
    end
end


-------------------------POUR RETIRER OU REMETTRE LES VETEMENTS
RegisterNetEvent('RiZiePersoMenu:haut')
AddEventHandler('RiZiePersoMenu:haut', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.torso_1 ~= skinb.torso_1 then
                vethaut = true
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = skina.torso_1, ['torso_2'] = skina.torso_2, ['tshirt_1'] = skina.tshirt_1, ['tshirt_2'] = skina.tshirt_2, ['arms'] = skina.arms})
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
                vethaut = false
            end

        end)
    end)
end)

RegisterNetEvent('RiZiePersoMenu:bas')
AddEventHandler('RiZiePersoMenu:bas', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtrousers', 'try_trousers_neutral_c'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.pants_1 ~= skinb.pants_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = skina.pants_1, ['pants_2'] = skina.pants_2})
                vetbas = true
            else
                vetbas = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 15, ['pants_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 61, ['pants_2'] = 1})
                end
            end


        end)
    end)
end)

RegisterNetEvent('RiZiePersoMenu:chaussures')
AddEventHandler('RiZiePersoMenu:chaussures', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingshoes', 'try_shoes_positive_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.shoes_1 ~= skinb.shoes_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = skina.shoes_1, ['shoes_2'] = skina.shoes_2})
                vetch = true
            else
                vetch = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 35, ['shoes_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 34, ['shoes_2'] = 0})
                end
            end


        end)
    end)
end)

RegisterNetEvent('RiZiePersoMenu:sac')
AddEventHandler('RiZiePersoMenu:sac', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.bags_1 ~= skinb.bags_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = skina.bags_1, ['bags_2'] = skina.bags_2})
                vetch = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = 0, ['bags_2'] = 0})
                vetsac = false
            end
        end)
    end)
end)

RegisterNetEvent('RiZiePersoMenu:gilet')
AddEventHandler('RiZiePersoMenu:gilet', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.bproof_1 ~= skinb.bproof_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = skina.bproof_1, ['bproof_2'] = skina.bproof_2})
                vetgilet = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = 0, ['bproof_2'] = 0})
                vetgilet = false
            end
        end)
    end)
end)


--- je dois faire le meme système qu'ici pour au dessus, ça évite de call un event différent à chaque fois...
RegisterNetEvent('RiZiePersoMenu:access')
AddEventHandler('RiZiePersoMenu:access', function(accesstype)
    ESX.TriggerServerCallback('esx_accessories:get', function(eskilaunAccessoires, accessorySkin)
        _accessoire = string.lower(accesstype)
        if eskilaunAccessoires then
            TriggerEvent('skinchanger:getSkin', function(skin)
                local accessoire = -1
                local couleur = 0

                if _accessoire == "glasses" then
                    accessoire = 0
                    local lib, anim = 'clothingspecs', 'try_glasses_positive_a'
                    ESX.Streaming.RequestAnimDict(lib, function()
                        TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, 1000, 0, 0, false, false, false)
                    end)
                    Citizen.Wait(1000)
                    ClearPedTasks(PlayerPedId())
                elseif _accessoire == "mask" then
                    accessoire = 0
                    local lib, anim = 'missfbi4', 'takeoff_mask'
                    ESX.Streaming.RequestAnimDict(lib, function()
                        TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, 1000, 0, 0, false, false, false)
                    end)
                    Citizen.Wait(850)
                    ClearPedTasks(PlayerPedId())
                elseif _accessoire == "helmet" then
                    local lib, anim = 'missfbi4', 'takeoff_mask'
                    ESX.Streaming.RequestAnimDict(lib, function()
                        TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, 1000, 0, 0, false, false, false)
                    end)
                    Citizen.Wait(850)
                    ClearPedTasks(PlayerPedId())
                end
                

                if skin[_accessoire .. '_1'] == accessoire then
                    accessoire = accessorySkin[_accessoire .. '_1']
                    couleur = accessorySkin[_accessoire .. '_2']
                    if _accessoire == "glasses" then
                        vetlunettes = true
                    elseif _accessoire == "mask" then
                        vetmasque = true
                    elseif _accessoire == "helmet" then
                        vetchapeau = true
                    end
                else
                    if _accessoire == "glasses" then
                        vetlunettes = false
                    elseif _accessoire == "mask" then
                        vetmasque = false
                    elseif _accessoire == "helmet" then
                        vetchapeau = false
                    end
                end

                local accessorySkin = {}
                accessorySkin[_accessoire .. '_1'] = accessoire
                accessorySkin[_accessoire .. '_2'] = couleur
                TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
            end)
        else
            if _accessoire == "glasses" then
                ESX.ShowNotification('Vous n\'avez pas de lunettes !')
            elseif _accessoire == "mask" then
                ESX.ShowNotification('Vous n\'avez pas de masque !')
            elseif _accessoire == "helmet" then
                ESX.ShowNotification('Vous n\'avez pas de chapeau/ou masque !')
            end
        end
    end, accesstype)
end)
----------------------------------------------------------------------

------------------Porter

RegisterNetEvent('RiZiePersoMenu:porter')
AddEventHandler('RiZiePersoMenu:porter', function()
	if not Player.porter then
		local player = PlayerPedId()	
		lib = 'anim@arena@celeb@flat@paired@no_props@'
		anim1 = 'piggyback_c_player_a'
		anim2 = 'piggyback_c_player_b'
		distans = -0.07
		distans2 = 0.0
		height = 0.45
		spin = 0.0		
		length = 100000
		controlFlagMe = 49
		controlFlagTarget = 33
		animFlagTarget = 1
		local closestPlayer = JoueurPlusProche(3)
		target = GetPlayerServerId(closestPlayer)
		if closestPlayer ~= -1 and closestPlayer ~= nil then
			Player.porter = true
			TriggerServerEvent('RiZiePersoMenu:animsync', closestPlayer, lib, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
		else 
			helpnotif("Personne aux alentours!")
		end
	else
		Player.porter = false
		ClearPedSecondaryTask(GetPlayerPed(-1))
		DetachEntity(GetPlayerPed(-1), true, false)
		local closestPlayer = JoueurPlusProche(3)
		target = GetPlayerServerId(closestPlayer)
		if target ~= 0 then 
			TriggerServerEvent('RiZiePersoMenu:animstop', target)
		end
	end
end,false)

RegisterNetEvent('RiZiePersoMenu:animsyncTarget')
AddEventHandler('RiZiePersoMenu:animsyncTarget', function(target, animationLib, animation2, distans, distans2, height, length,spin,controlFlag)
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	piggyBackInProgress = true
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(GetPlayerPed(-1), targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	piggyBackAnimNamePlaying = animation2
	piggyBackAnimDictPlaying = animationLib
	piggyBackControlFlagPlaying = controlFlag
end)

RegisterNetEvent('RiZiePersoMenu:animsyncMe')
AddEventHandler('RiZiePersoMenu:animsyncMe', function(animationLib, animation,length,controlFlag,animFlag)
	local playerPed = GetPlayerPed(-1)
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	Wait(500)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	piggyBackAnimNamePlaying = animation
	piggyBackAnimDictPlaying = animationLib
	piggyBackControlFlagPlaying = controlFlag
end)


RegisterNetEvent('RiZiePersoMenu:animclientstop')
AddEventHandler('RiZiePersoMenu:animclientstop', function()
	porter = false
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
end)

----------------------------------------------------------------------------

function CreationMenu()
	AddPersoMenu(menuperso)
	_menuPool:RefreshIndex()
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
	    if IsControlJustPressed(0,166) then  -- 166   = F5
	    	-- on évite la dupli des menus si le joueur essaies de l'open  alors qu'il est déjà open
	    	menuperso:Clear()
            menuarmeitem:Clear()
            menuiteminv:Clear()
	        _menuPool:CloseAllMenus(true)
	        --

	        ESX.PlayerData = ESX.GetPlayerData()
	        CreationMenu()
	        menuperso:Visible(not menuperso:Visible())
	        Citizen.Wait(10)
	    end
    end
end)


Citizen.CreateThread(function()
    while true do
        if _menuPool ~= nil then
            _menuPool:ProcessMenus()
        end
        
        Citizen.Wait(0)
    end
end)

-- on refresh le menu à chaque open
Citizen.CreateThread(function()
    while true do
        while _menuPool ~= nil and _menuPool:IsAnyMenuOpen() do
            Citizen.Wait(0)

            if not _menuPool:IsAnyMenuOpen() then
                _menuPool:CloseAllMenus(true)

                iteminventaire = {}
                armeinventaire = {}
                facturesinventaire = {}
                listejoueur = {}

                _menuPool = NativeUI.CreatePool()

                menuarmeitem = NativeUI.CreateMenu(GetPlayerName(PlayerId()), "Actions Armes")
                menuiteminv = NativeUI.CreateMenu(GetPlayerName(PlayerId()), "Action Item")
                menuperso = NativeUI.CreateMenu(GetPlayerName(PlayerId()), Config.NomServer)
                _menuPool:Add(menuperso)
				_menuPool:Add(menuarmeitem)
				_menuPool:Add(menuiteminv)
            end
        end
        Citizen.Wait(0)
    end
end)



------------------dormir----------
Citizen.CreateThread(function()
    while true do
        if Player.ragdoll then -- on fait une check perma si dormir == true, si il est true on fait endormir le mec, si il est false bah rien dutt
            SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
            ResetPedRagdollTimer(PlayerPedId())
        end

        Citizen.Wait(0)
    end
end)


------------action gang
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)


-------------MODERATION

Citizen.CreateThread(function()
    while true do
        if ESX ~= nil then
            ESX.TriggerServerCallback('RiZiePersoMenu:getusergroup', function(group) playerGroup = group end)
            Citizen.Wait(30000)
        else
            Citizen.Wait(200)
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        if Player.noclip then
            local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
            local dx, dy, dz = getCamDirection()
            local speed = 0.5

            SetEntityVelocity(PlayerPedId(), 0.0001, 0.0001, 0.0001)

            if IsControlPressed(0, 32) then
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end

            if IsControlPressed(0, 269) then
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end

            SetEntityCoordsNoOffset(PlayerPedId(), x, y, z, true, true, true)
        end
        if Player.supersaut then
            SetSuperJumpThisFrame(PlayerId(-1))
        end
        if Player.staminainfini then
            RestorePlayerStamina(PlayerId(-1), 1.0)
        end
        if Player.fastrun then
            SetRunSprintMultiplierForPlayer(PlayerId(-1), 2.49) SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
        end
        Citizen.Wait(0)
    end
end)
