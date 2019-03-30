local odometer = 0

RegisterNetEvent('getkm')
AddEventHandler('getkm', function(kilo)
  if kilo < 1000 then
    odometer = "0 KM"
  else
    odometer = round(kilo/1000).." KM"
  end
end)

RegisterNetEvent('get_benzina')
AddEventHandler('get_benzina', function(benzina)
end)

function onScreen(content,x,y)
        SetTextFont(4)
        SetTextProportional(0)
        SetTextScale(0.5, 0.5)
        SetTextEntry("STRING")
        AddTextComponentString(content)
        DrawText(x+0.005, y-0.075)
        DrawRect(x+0.05, y-0.01, 0.100, 0.130,0,0,0,100)
        DrawRect(x, y-0.01, 0.0025, 0.130,255,30,30,255)
end

function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function lock()
  if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
    if IsControlJustPressed(1,303) then
      veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
      local locked = GetVehicleDoorLockStatus(veh) >= 2
      if locked then -- unlock
        SetVehicleDoorsLockedForAllPlayers(veh, false)
        SetVehicleDoorsLocked(veh,1)
        SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
        notify("Ai descuiat masina.")
      else -- lock
        SetVehicleDoorsLocked(veh,2)
        SetVehicleDoorsLockedForAllPlayers(veh, true)
        notify("Ai incuiat masina.")
      end
    end
  else 
    if IsControlJustPressed(1,303) then
      veh =  GetVehiclePedIsIn(GetPlayerPed(-1), true)
      
      local locked = GetVehicleDoorLockStatus(veh) >= 2
      if locked then -- unlock
        SetVehicleDoorsLockedForAllPlayers(veh, false)
        SetVehicleDoorsLocked(veh,1)
        SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
        notify("Ai descuiat masina.")
      else -- lock
        SetVehicleDoorsLocked(veh,2)
        SetVehicleDoorsLockedForAllPlayers(veh, true)
        notify("Ai incuiat masina.")
      end
    end
  end
end

Citizen.CreateThread(function()
  while true do
        Citizen.Wait(0)
        player = GetPlayerPed(-1)
        lock()
        local spd = round(GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false))*3.78)
        plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
        local fuel    = math.ceil(round(GetVehicleFuelLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false)), 1))
        if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
            local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            if GetVehicleDoorLockStatus(veh) >= 2 then
                status = "Incuiata"
            else
                status = "Descuiata"
            end
            if fuel < 1 then
              tfuel = "0 Litri"
            else
              tfuel = fuel.." Litri"
            end
            onScreen("~r~Viteza ~w~"..spd.." KM/H \n".."~r~Status ~w~"..status.."\n~r~Odometer ~w~"..tostring(odometer).."\n~r~Combustibil ~w~"..tostring(tfuel), 0.9,0.8)
        end
    end
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
      TriggerServerEvent('sendkm', GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false)))
    end
  end
end)

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
        player = GetPlayerPed(-1)
        pos1 = GetEntityCoords(player)
        Citizen.Wait(1000)
        pos2 = GetEntityCoords(player)
        distance = Vdist(pos1,pos2)
        plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
        TriggerServerEvent("addkm",plate,distance)
      end
    end
end)

function notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true, false)
  end
