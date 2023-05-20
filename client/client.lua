local QBCore = exports['qb-core']:GetCoreObject()
local ox_target = exports.ox_target

function DrawText3D(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextDropShadow(0, 0, 0, 55)
		SetTextEdge(0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

local launderOptions = {
    {
        type = Config.TargetType,
        event = Config.TargetEvent,
        icon = Config.TargetIcon,
        label = Config.LaunderOptionText,
    },
}

local function createLaunderPed()
	local genderNumber
	local model = Config.DoorPed
	local gend = "male"
	local coords = vector3(84.23, -1552.1, 29.6)
	local heading = 63.74
	local animDict = "amb@code_human_cross_road@male@idle_a"
	local animName = "idle_c"

	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(1)
	end

	if gend == 'male' then
		genderNumber = 4
	elseif gend == 'female' then 
		genderNumber = 5
	else
		print("No gender has been provided! Check your the configuration!")
	end	

    local x, y, z = table.unpack(coords)
    local ped = CreatePed(genderNum, GetHashKey(model), x, y, z - 1, heading, false, true)
	SetEntityAlpha(ped, 0, false)
    FreezeEntityPosition(ped, true) 
    SetEntityInvincible(ped, true) 
    SetBlockingOfNonTemporaryEvents(ped, true)

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	
    for i = 0, 255, 51 do
        Citizen.Wait(50)
        SetEntityAlpha(ped, i, false)
    end
	ox_target:addLocalEntity(ped, launderOptions)
	return ped
	
end

local function LoadAnimationDiction(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(1)
    end
end

local function OpenDoor()
    local ped = PlayerPedId()
    LoadAnimationDiction("anim@heists@keycard@") 
    TaskPlayAnim(ped, "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0)
    Wait(400)
    ClearPedTasks(ped)
end

local function EnterMoneyLaunder()
    local player = PlayerPedId()
    OpenDoor()
    Wait(500)
    DoScreenFadeOut(250)
    Wait(250)
    SetEntityCoords(player, Config.MoneyLocation["goin"].coords.x, Config.MoneyLocation["goin"].coords.y, Config.MoneyLocation["goin"].coords.z )
    SetEntityHeading(player, 5.0)
    Wait(1000)
    DoScreenFadeIn(250)
end

local function LeaveMoneyLaunder()
    local player = PlayerPedId()
    OpenDoor()
    Wait(500)
    DoScreenFadeOut(250)
    Wait(250)
    SetEntityCoords(player, Config.MoneyLocation["goout"].coords.x, Config.MoneyLocation["goout"].coords.y, Config.MoneyLocation["goout"].coords.z )
    SetEntityHeading(player, 5.0)
    Wait(1000)
    DoScreenFadeIn(250)
end

Citizen.CreateThread(function()
    createLaunderPed()
    while true do
        Wait(0)
        for k,v in pairs(Config.Locations) do
            local launder = vector3(v.x,v.y,v.z)
        local location = GetEntityCoords(PlayerPedId())
        local dist = #(location - launder)
        
        if (dist < 1) then
            DrawText3D(launder.x, launder.y, launder.z,"Press [~r~E~w~] to launder money",0.9)
        end

        if IsControlJustPressed(0, 153) and (dist < 1) then
            local count = exports.ox_inventory:Search('count', Config.MoneyType)
        if count >= 1 then 
            local data = lib.inputDialog("Enter Amount To Wash", {
                {
                    type = "number",
                    label = "Amount",
                    icon = "clipboard"
                 }
            })
            if data == nil then 
                print('it was nil')
            else
            if lib.progressBar({
                duration = Config.WashTime,
                label = 'Washing...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    dict = "amb@prop_human_bum_bin@base",
                    clip = 'base'
                },
            }) then
                ClearPedTasks(ped)
                TriggerServerEvent("supreme_moneylaunder:GetCash", data[1])
             else 
                print('Do stuff when cancelled') 
            end
        end
        else
            TriggerEvent('QBCore:Notify', "You do not have any money to wash")
        end
        end
    end
end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local leave = vector3(Config.MoneyLocation["goin"].coords.x, Config.MoneyLocation["goin"].coords.y, Config.MoneyLocation["goin"].coords.z)
        local locationleave = GetEntityCoords(PlayerPedId())
        local dist = #(locationleave - leave)
        
        if (dist < 1) then
            lib.showTextUI(Config.MoneyWashLeaveText)
        end

        if IsControlJustPressed(0, 153) and (dist < 1) then
            LeaveMoneyLaunder()
            lib.hideTextUI()
        end
    end
end)

RegisterNetEvent('supreme_moneylaunder:GoToMoneyLaunder')
AddEventHandler('supreme_moneylaunder:GoToMoneyLaunder', function()
    EnterMoneyLaunder()
end)
