----Modifier par Sarah------
ESX               = nil
local playerCars = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- 
function OpenCloseVehicle()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)

	local vehicle = nil

	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 70)
	end

	ESX.TriggerServerCallback('esx_vehiclelock:requestPlayerCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local locked = GetVehicleDoorLockStatus(vehicle)
			if locked == 1 then -- if unlocked
				SetVehicleDoorsLocked(vehicle, 2)	
                SetVehicleLights(vehicle, 2)
                Wait(200)
                SetVehicleLights(vehicle, 0)
                --StartVehicleHorn(vehicle, 100, 1, false)
                Wait(200)
                SetVehicleLights(vehicle, 2)
                Wait(400)
                SetVehicleLights(vehicle, 0)	
				-- PlayVehicleDoorCloseSound(vehicle, 1)
				TriggerEvent('InteractSound_CL:PlayOnOne', 'lock', 1.0)
				ESX.ShowNotification("Vous avez ~r~fermé~s~ le véhicule.")
			elseif locked == 2 then -- if locked
				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleLights(vehicle, 2)
                Wait(200)
                SetVehicleLights(vehicle, 0)
                --StartVehicleHorn(vehicle, 100, 1, false)
                Wait(200)
                SetVehicleLights(vehicle, 2)
                Wait(400)
                SetVehicleLights(vehicle, 0)
				-- PlayVehicleDoorOpenSound(vehicle, 0)
				TriggerEvent('InteractSound_CL:PlayOnOne', 'unlock', 1.0)
				ESX.ShowNotification("Vous avez ~g~ouvert~s~ le véhicule.")
			end
		else
			ESX.ShowNotification("~r~Vous n'avez pas les clés de ce véhicule.")
		end
	end, GetVehicleNumberPlateText(vehicle))
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlJustPressed(1, 303) then
			OpenCloseVehicle()
		end
	end
end)


Citizen.CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end

    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 303) then -- When you press "U"
               TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
        end
    end
end)



	

------------------------------------------------------------------------------------------------regulateur
local speedLimit = 0
Citizen.CreateThread( function()
    while true do 
        Citizen.Wait( 0 )   
        local ped = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleModel = GetEntityModel(vehicle)
        local speed = GetEntitySpeed(vehicle)
        local inVehicle = IsPedSittingInAnyVehicle(ped)
        local float Max = GetVehicleMaxSpeed(vehicleModel)
        if ped and inVehicle then
            if IsControlJustPressed(1, 73) then
                if (GetPedInVehicleSeat(vehicle, -1) == ped) then
                    if CruiseControl == 0 then
                        speedLimit = speed
                        SetEntityMaxSpeed(vehicle, speedLimit)
						drawNotification("~y~Régulateur: ~g~Active\n~s~MAX speed ".. math.floor((speedLimit*3.6)+1).."kmh")
						Citizen.Wait(1000)
				        DisplayHelpText("Ajuster votre vitesse avec ~Page Up~ - ~Page Down~")
						PlaySound(-1, "COLLECTED", "HUD_AWARDS", 0, 0, 1)
                        CruiseControl = 1
                    else
                        SetEntityMaxSpeed(vehicle, Max)
						drawNotification("~y~Régulateur: ~r~Désactivé")						
                        CruiseControl = 0
                    end
                else
				    drawNotification("Action disponible en voiture")						
                end
            elseif IsControlJustPressed(1, 27) then
                if CruiseControl == 1 then
                    speedLimit = speedLimit + 0.276
                    SetEntityMaxSpeed(vehicle, speedLimit)
					PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
					DisplayHelpText("Vitesse Maximale ".. math.floor((speedLimit*3.6)+1).. "kmh")
                end
            elseif IsControlJustPressed(1, 173) then
                if CruiseControl == 1 then
                    speedLimit = speedLimit - 0.276 --1.38
					if speedLimit < 0 then speedLimit = 0 end
                    SetEntityMaxSpeed(vehicle, speedLimit)
					PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)	
					DisplayHelpText("Vitesse Maximale ".. math.floor((speedLimit*3.6)+1).. "kmh")
                end
            end
        end
    end
end)

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end