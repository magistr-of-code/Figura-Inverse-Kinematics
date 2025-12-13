local InverseKinematics = require("InverseKinematics")
local TenticleAPI = require("Tenticle")

--[[
▀█▀ █▀▀ █▄ █ █▀▄ █▀█ █ █   █▀
 █  ██▄ █ ▀█ █▄▀ █▀▄ █ █▄▄ ▄█

█▀▄▀█ ▄▀█ █▀▄ █▀▀   █▄▄ █▄█  
█ ▀ █ █▀█ █▄▀ ██▄   █▄█  █

█▀▄▀█ ▄▀█ ▀▄▀ █▀▄▀█ ▄▀█ █▀▀    █▀▀ █ █ ▄▀█ █▄ █ █▀▀ █▀▀
█ ▀ █ █▀█ █ █ █ ▀ █ █▀█ █▄█ ▄▄ █▄▄ █▀█ █▀█ █ ▀█ █▄█ ██▄
--]]

--Settings
    --Length of one joint
TenticleAPI.length = 0.05
    --Amount of bones the tenticle will have
TenticleAPI.bones = 5/TenticleAPI.length
    --Scale of each joint (May impact accuracy if too big)
TenticleAPI.scale = 1.25

local headNames = {
    default_head = {
        model = vanilla_model.PLAYER
    },
    --Name of the tenticle block
    ["Tendril Block"] = {
        model = models.model.Skull.TendrilHead
    }
}

--==--

local tenticles = {}

function events.tick()
    TenticleAPI.onTick(tenticles,headNames)
end

function events.skull_render(delta, block, item, entity, mode)
    for _, value in pairs(headNames) do
        if value ~= headNames.default_head then
            value.model:setVisible(false)
        end
    end

    if mode ~= "BLOCK" then
        return false
    end

    local data = block:getEntityData()

    if data == nil then
        return false
    end

    if data.custom_name == nil then
        return false
    end

    local name = parseJson(data.custom_name)
    local head = headNames[name] or headNames.default_head

    head.model:setVisible(true)
  
    if head.model == models.model.Skull.TendrilHead then
        TenticleAPI.onRender(tenticles,block)
    end
end