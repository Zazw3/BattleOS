--TODO: Handle Attempts to equip an already iequiped item in the other slot.
local toolslots = {}
local nTools = 0
local equiped = {["left"] = nil, ["right"] = nil}
local kPeripheralNames = {["plethora:module"]="plethora:module", ["peripheralsplusone:chat_box"]="chatBox"}
local kPlethoraDamageLookup = {[1]="plethora:laser", [2] = "plethora:scanner", [3]="plethora:sensor", [6]="plethora:glasses"}

function addExplicitly(name, slot)
    toolslots[name] = slot
end

function init()
  local startSlot = turtle.getSelectedSlot()
  local emptySlot = nil

  -- Look for tools in the turtles inventory
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item ~= nil then
      local peripheralName = kPeripheralNames[item.name]
      if peripheralName ~= null then
        if peripheralName == "plethora:module" then
          peripheralName = kPlethoraDamageLookup[item.damage];
        end
          toolslots[peripheralName] = i
          nTools = nTools + 1
      end 
    else
      emptySlot = i
    end       
  end    

  --If there's no empty slots, try to use another tools's slot
  if emptySlot == nil and nTools > 0 then
    _, emptySlot = nextvar(toolslots)
  end

  -- Check for currently equiped tools
  if emptySlot ~= nil then
    turtle.select(emptySlot)
    for _,side in ipairs({"left", "right"}) do
      if equipOn(side) then
        local item = turtle.getItemDetail(emptySlot) 
        if item ~= nil then
          local peripheralName = kPeripheralNames[item.name]
          if peripheralName ~= nil then
            if peripheralName == "plethora:module" then
              peripheralName = kPlethoraDamageLookup[item.damage];
            end
            toolslots[peripheralName] = -1
            equiped[side] = peripheralName;
            nTools = nTools + 1
          end
        end
        equipOn(side)
      end
    end
  else
    print("Warning: Toolbelt couldn't check what tools are currently equiped")
  end

  turtle.select(startSlot)
end

function equipOn(side)
    if side == "left" or side == 0 then
        return turtle.equipLeft()
    else
        return turtle.equipRight()
    end
end

function dumpToolbelt()
  for k,v in pairs(toolslots) do
    print(k.." in slot "..v)
  end
  print("Equiped Left: "..(equiped.left or "Nothing"))
  print("Equiped Right: "..(equiped.right or "Nothing"))
end

-- Equips the tool with given ID. Default side is left.
function equip(id, side)
  local startSlot = turtle.getSelectedSlot()
  side = side or "left"
  if toolslots[id] ~= nil then
    if toolslots[id] < 0 then
      return true -- Tool already equiped
    end
    turtle.select(toolslots[id])
    if equiped[side] ~= nil then
      toolslots[equiped[side]] = toolslots[id] --Set the old tool's slot to the one we've currently selected. 
    end
    toolslots[id] = -1 -- Mark the new tool as equiped
    equiped[side] = id
    local equipSuccess = equipOn(side)
    turtle.select(startSlot)
    return equipSuccess;
  else
    print("No tool registered with id "..id) 
    return false    
  end
end

function equipAndBind(id, side)
  side = side or "left"
  if equip(id, side) then
    return peripheral.wrap(side)
  end
  return nil
end
