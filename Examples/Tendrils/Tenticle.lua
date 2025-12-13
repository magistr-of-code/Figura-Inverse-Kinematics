---@generic T
---@param v? T
---@param message? any
---@param level? integer
---@return T v
local function assert(v, message, level)
  return v or error(message or "Assertion failed!", (level or 1) + 1)
end

local InverseKinematics = require("InverseKinematics")

local tenticleApi = {}

--Tenticle stuff idk.

function distanceTo(v1, v2)
    local dx = v2.x - v1.x
    local dy = v2.y - v1.y
    local dz = v2.z - v1.z

    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function pointToRotation(targetX, targetY, targetZ, originX, originY, originZ)
    originX = originX or 0
    originY = originY or 0
    originZ = originZ or 0
    
    local dx = targetX - originX
    local dy = targetY - originY
    local dz = targetZ - originZ
    
    -- Yaw (rotation around Y axis)
    local yaw = math.atan2(dx, dz)
    
    -- Pitch (rotation around X axis)
    local horizontalDistance = math.sqrt(dx * dx + dz * dz)
    local pitch = -math.atan2(dy, horizontalDistance)
    
    -- Roll (rotation around Z axis)
    local roll = 0
    
    return pitch, yaw, roll
end

function pointToRotationDegrees(targetX, targetY, targetZ, originX, originY, originZ)
    local pitch, yaw, roll = pointToRotation(targetX, targetY, targetZ, originX, originY, originZ)
    return math.deg(pitch), math.deg(yaw), math.deg(roll)
end

function vectorsToRotationDegrees(targetVec,originVec)
    return pointToRotationDegrees(targetVec.x,targetVec.y,targetVec.z,originVec.x,originVec.y,originVec.z)
end

---@param tenticles table
---@param headNames table
function tenticleApi.onTick(tenticles,headNames)
    for key, tenticle in pairs(tenticles) do
        if tenticle == nil then
            return
        end

        if tenticle.armatureSystem == nil then
            tenticles[key] = nil
            return
        end

        data = world.getBlockState(tenticle.armatureSystem.armatures[1].startVec):getEntityData()

        local name = tenticle.armatureSystem.armatures[1].startVec:copy():sub(0.5,0,0.5):toString()

        if data == nil then
            for _, part in pairs(models.model.Tendril.Tendrils:getChildren()) do
                if part:getName() == name then
                    part:remove()
                end
            end
            
            tenticles[key] = nil
            return
        end

        if data.custom_name == nil then
            for _, part in pairs(models.model.Tendril.Tendrils:getChildren()) do
                if part:getName() == name then
                    part:remove()
                end
            end
            
            tenticles[key] = nil
            return
        end

        name = parseJson(data.custom_name)

        local head = headNames[name] or headNames.default_head
    
        if head.model ~= models.model.Skull.TendrilHead then
             for _, part in pairs(models.model.Tendril.Tendrils:getChildren()) do
                if part:getName() == name then
                    part:remove()
                end
            end
            
            tenticles[key] = nil
            return
        end
    end
end

---@param tenticles table
---@param block BlockState
function tenticleApi.onRender(tenticles,block)

    local tenticle = tenticles[block:getPos():toString()]

    if tenticle == nil then
            tenticle = {
                armatureSystem=nil,
                chosenPoint=nil,
                ticks=0,
                waitTicks=0,
                lastWorldTime=0.0
            }
    end

    

    if tenticle.lastWorldTime==0.0 then
        tenticle.lastWorldTime=world:getTime()
    end

    if tenticle.lastWorldTime~=world:getTime() then

        tenticle.lastWorldTime=world:getTime()

        if tenticle.armatureSystem == nil or tenticle.armatureSystem.armatures[1].startVec ~= block:getPos():add(0.5,0,0.5) then
            
            --Creation
            tenticle.armatureSystem=InverseKinematics:newArmatureSystemOfSize(block:getPos():add(0.5,0,0.5),tenticleApi.bones,tenticleApi.length)
            tenticle.chosenPoint=nil
            tenticle.ticks=0
            tenticle.waitTicks=0
            tenticle.lastWorldTime=world:getTime()

            local coolPart = models.model.Tendril.Tendrils:newPart(block:getPos():toString(),"World")
            
            for key, value in pairs(tenticle.armatureSystem.armatures) do
                local sizeXY = (1-key/tenticleApi.bones) * tenticleApi.scale
                coolPart:addChild(models.model.Tendril.Copy:copy("cube"):setVisible(true):setParentType("World"):setScale(sizeXY,sizeXY,tenticleApi.length))
            end
        else

            for index, part in pairs(models.model.Tendril.Tendrils:getChildren()) do
                if part:getName() == block:getPos():toString() then
                    for key, value in pairs(tenticle.armatureSystem.armatures) do
                        part:getChildren()[key]:setPos(value.startVec:copy():mul(16,16,16))
                        part:getChildren()[key]:setOffsetRot(pointToRotationDegrees(value.endVec:copy().x,value.endVec:copy().y,value.endVec:copy().z,value.startVec:copy().x,value.startVec:copy().y,value.startVec:copy().z))
                    end
                end
            end
            

            if tenticle.chosenPoint == nil then
                local random = math.random(3)

                ::tryAgain::
                
                if random == 1 then
                    ---@type Player
                    local nearestPlayer
                
                    for key, value in pairs(world:getPlayers()) do
                        if nearestPlayer == nil then
                            nearestPlayer = value
                        end

                        if distanceTo(nearestPlayer:getPos(0),tenticle.armatureSystem.armatures[1].startVec) > distanceTo(value:getPos(0),tenticle.armatureSystem.armatures[1].startVec) then
                            nearestPlayer = value
                        end
                    end
                    if distanceTo(nearestPlayer:getPos(0),tenticle.armatureSystem.armatures[1].startVec) > tenticleApi.length*tenticleApi.bones then
                        random = 2
                        goto tryAgain
                    end

                    tenticle.chosenPoint = nearestPlayer:getPos(0):copy():add(0,1,0)
                elseif random == 2 then
                    local randomPoint = vec(math.random(-tenticleApi.length*tenticleApi.bones,tenticleApi.length*tenticleApi.bones),math.random(tenticleApi.length*tenticleApi.bones),math.random(-tenticleApi.length*tenticleApi.bones,tenticleApi.length*tenticleApi.bones))

                    tenticle.chosenPoint = randomPoint:add(tenticle.armatureSystem.armatures[1].startVec)
                end
            else
                tenticle.ticks=tenticle.ticks+1
                local deltaLerp = tenticle.ticks/40 
                local endPos = tenticle.armatureSystem.armatures[#tenticle.armatureSystem.armatures].endVec
                tenticle.armatureSystem:update(vec(math.lerp(endPos.x,tenticle.chosenPoint.x,deltaLerp),math.lerp(endPos.y,tenticle.chosenPoint.y,deltaLerp),math.lerp(endPos.z,tenticle.chosenPoint.z,deltaLerp)))

                if tenticle.ticks>=40 then
                    tenticle.ticks=0
                    tenticle.waitTicks=math.random(40)
                    tenticle.chosenPoint=nil
                end
            end
        end
    end
    tenticles[block:getPos():toString()] = tenticle
end

return tenticleApi