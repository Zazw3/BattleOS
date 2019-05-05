-- Turtle Soldier Mk 1

os.loadAPI("toolbelt.lua")

kMaxDist = 30
kMagazineSize = 20
kReloadTime = 3.5
entityWhitelist = {["zazw3"]=true}
firstAttack = true;

-- 2D or 3D magnitude
function dist(x,y,z)
  z = z or 0
  return math.sqrt((x*x) + (y*y) + (z*z))
end

-- Cartesian to Spherical coordinates.  
-- Angles in Degrees.
-- Psi Measured from -ve Z axis
-- Theta measured from ZX plane.
function cartesean2spherical(x, y, z)
  local PI = 3.14
  local r = dist(x,y,z)
  local psi = math.atan2(-x, z) * (180/PI)
  local theta = math.atan2(-y, dist(x, z)) * (180/PI)

  return r, theta, psi
end

function shout(msg)
  local chatBox = toolbelt.equipAndBind("chatBox", "left")
  chatBox.say(os.getComputerLabel()..": "..msg, 64, true, os.getComputerLabel())
end

toolbelt.init()

local laser = toolbelt.equipAndBind("plethora:laser", "right")

while true do
  local shotsTally = 0
  while shotsTally <= kMagazineSize do
    sleep(0.3)
    local sensor = toolbelt.equipAndBind("plethora:sensor", "left")
    local entities = sensor.sense()
    for _,e in ipairs(entities) do
      if entityWhitelist[e.name] then
        if dist(e.x, e.y, e.z) <= kMaxDist then
          if firstAttack then
            shout("Target Sighted, Open Fire!")
            firstAttack = false
          end
          
          local r, theta, psi = cartesean2spherical(e.x, e.y, e.z)
          laser.fire(psi, theta, 1) 
          shotsTally = shotsTally + 1
        end 
      end
    end
  end
  shout("Reloading")
  sleep(kReloadTime)
  shotsTally = 0
end
