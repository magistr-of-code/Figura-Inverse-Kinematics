--[[

███████╗░█████╗░██████╗░██████╗░██╗██╗░░██╗
██╔════╝██╔══██╗██╔══██╗██╔══██╗██║██║░██╔╝
█████╗░░███████║██████╦╝██████╔╝██║█████═╝░
██╔══╝░░██╔══██║██╔══██╗██╔══██╗██║██╔═██╗░
██║░░░░░██║░░██║██████╦╝██║░░██║██║██║░╚██╗
╚═╝░░░░░╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚═╝╚═╝░░╚═╝
    or Inverse Kinematics


▄▀█ █▀█ █   █▀▄▀█ ▄▀█ █▀▄ █▀▀   █▄▄ █▄█  
█▀█ █▀▀ █   █ ▀ █ █▀█ █▄▀ ██▄   █▄█  █

█▀▄▀█ ▄▀█ ▀▄▀ █▀▄▀█ ▄▀█ █▀▀    █▀▀ █ █ ▄▀█ █▄ █ █▀▀ █▀▀
█ ▀ █ █▀█ █ █ █ ▀ █ █▀█ █▄█ ▄▄ █▄▄ █▀█ █▀█ █ ▀█ █▄█ ██▄

--]]


---@generic T
---@param v? T
---@param message? any
---@param level? integer
---@return T v
local function assert(v, message, level)
  return v or error(message or "Assertion failed!", (level or 1) + 1)
end

---@class InverseKinematics.armature
---@field startVec Vector3
---@field endVec Vector3
local armature = {}
armature.__index = armature

---@param startVec Vector3
---@param endVec Vector3
---@return self
function armature:newArmature(startVec, endVec)
    local instance = setmetatable({}, self)
    instance.startVec=startVec
    instance.endVec=endVec
    return instance
end

---@param startVec Vector3
---@return self
function armature:setStart(startVec)
    self.startVec=startVec
    return self
end

---@param endVec Vector3
---@return self
function armature:setEnd(endVec)
    self.endVec=endVec
    return self
end

---@return Vector3
function armature:getLength()
    return self.endVec:copy():sub(self.startVec)
end

---@param newPos Vector3
---@return self
function armature:update(newPos)
    
    if newPos.xyz==self.startVec.xyz then
        return self
    end

    local lookAtPos = self.startVec:copy()

    self:setStart(newPos:copy())
    self:setEnd(newPos:copy():add(self.endVec:copy():sub(lookAtPos)))

    return self:lookAt(lookAtPos:copy());
end

---@param target Vector3
---@return self
function armature:lookAt(target)
    
    local originalDirection = self:getLength()

    local desiredDirection = target:sub(self.startVec:copy())

    if desiredDirection:length() == 0 then
        self:setEnd(originalDirection)
    end

    local desiredDirectionNormalized = desiredDirection:normalize()

    local originalLength = originalDirection:length()
    local newDirection = desiredDirectionNormalized:mul(originalLength,originalLength,originalLength)

    self:setEnd(self.startVec:copy():add(newDirection))

    return self
end

---@class InverseKinematics.armatureSystem
---@field armatures table
local armatureSystem = {}
armatureSystem.__index = armatureSystem 

---@param root Vector3
---@param size integer
---@param armatureLength number
---@return self
function armatureSystem:newArmatureSystem(root, size,armatureLength)
    local instance = setmetatable({}, self)

    instance.armatures = {armature:newArmature(root:copy(),root:copy():add(0,armatureLength,0))}

    for i = 2, size do
        local prevArm = instance.armatures[i-1]

        instance.armatures[i] = armature:newArmature(
        prevArm.endVec:copy(),
         prevArm.endVec:copy():add(0,armatureLength,0))
    end

    return instance
end

---@param root Vector3
---@param armatureLengths table
---@return self
function armatureSystem:newArmatureSystem(root,armatureLengths)
    local instance = setmetatable({}, self)

    instance.armatures = {armature:newArmature(root:copy(),root:copy():add(0,armatureLengths[1],0))}

    for i = 2, #armatureLengths do
        local prevArm = instance.armatures[i-1]

        instance.armatures[i] = armature:newArmature(
        prevArm.endVec:copy(),
         prevArm.endVec:copy():add(0,armatureLengths[i],0))
    end

    return instance
end

---@param endPoint Vector3
---@return self
function armatureSystem:step(endPoint)
    self.armatures[#self.armatures]:update(endPoint:copy())

    for i = #self.armatures - 1, 1, -1 do
        self.armatures[i]:update(self.armatures[i + 1].endVec:copy())
    end

    local newList = {}

    for i = #self.armatures, 1, -1 do
        table.insert(newList, self.armatures[i])
    end

    self.armatures = newList

    return self
end

---@param endPoint Vector3
---@return self
function armatureSystem:update(endPoint)
    local root = self.armatures[1].startVec:copy()
    self:step(endPoint)
    self:step(root)
    return self
end

return armatureSystem