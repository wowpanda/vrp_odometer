local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

MySQL = module("vrp_mysql", "MySQL")

vRPclient = Tunnel.getInterface("vRP","vrp_info")

vRP = Proxy.getInterface("vRP")

MySQL.createCommand("vRP/select_veh","SELECT vehicle FROM vrp_user_vehicles")
MySQL.createCommand("vRP/select_plate","SELECT vehicle_plate FROM vrp_user_vehicles")
MySQL.createCommand("vRP/odometer_table","ALTER TABLE vrp_user_vehicles ADD IF NOT EXISTS odometer INTEGER NOT NULL DEFAULT 0")
MySQL.createCommand("vRP/odometer_add","UPDATE vrp_user_vehicles SET odometer = odometer + @odometer WHERE user_id = @id and vehicle_plate = @plate")
MySQL.createCommand("vRP/select_cond","SELECT * FROM vrp_user_vehicles WHERE vehicle_plate = @plate")

RegisterServerEvent('sendkm')
AddEventHandler('sendkm',function(plate)

  local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})

  local afiseaza = false

  MySQL.query("vRP/select_plate",{}, function(rows, affected)
    local kilo = nil
    if #rows > 0 then
      for i,v in pairs(rows) do
        if plate  == rows[i].vehicle_plate then
          afiseaza = true
        end
      end
    end
    if afiseaza then
      MySQL.query("vRP/select_cond",{plate = plate}, function(faby, affected)
        kilo = faby[1].odometer
        TriggerClientEvent("getkm",player,kilo)
      end)
    end
  end)

end)

RegisterServerEvent('addkm')
AddEventHandler('addkm',function(plate, distance)

	local user_id = vRP.getUserId({source})

	MySQL.query("vRP/odometer_add",{id = user_id,plate=plate, odometer = distance})
end)