local configuration = require("__configurable-valves__.scripts.configuration")

---@class ThresholdRendering
---@field render_object LuaRenderObject
---@field default_threshold number
---@field valve LuaEntity?

---@class PlayerData
---@field render_threshold ThresholdRendering?

local shortcuts = { }

---@param threshold number
---@return string
local function format_threshold(threshold)
    return string.format("%d%%", threshold)
end

---@param input "toggle" | "minus" | "plus"
---@param event EventData.CustomInputEvent
local function quick_toggle(input, event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local valve = player.selected
    if not valve then return end
    if valve.name ~= "configurable-valve" and not (
        valve.name == "entity-ghost" and valve.ghost_name == "configurable-valve"
    ) then return end

    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    local circuit_condition = control_behaviour.circuit_condition --[[@as CircuitCondition]]
    local constant = circuit_condition.constant or 50
    local valve_type = configuration.deduce_type(control_behaviour)

    if input == "toggle" then
        valve_type = configuration.next_type(valve_type)
        configuration.set_type(control_behaviour, valve_type, player)
        constant = control_behaviour.circuit_condition.constant
    else
        if not valve_type then
            player.create_local_flying_text{text = {"configurable-valves.unknown-configuration"}, create_at_cursor=true}
            return
        elseif valve_type == "one_way" then
            player.create_local_flying_text{text = {"configurable-valves.configuration-doesnt-support-thresholds"}, create_at_cursor=true}
            return
        end

        constant = (math.floor(constant/10)*10) + (10 * (input == "plus" and 1 or -1 ))
        constant = math.min(100, math.max(0, constant))
        circuit_condition.constant = constant
        control_behaviour.circuit_condition = circuit_condition
    end

    valve.create_build_effect_smoke()
end

---@param player LuaPlayer
---@param valve LuaEntity
local function visualize_config(player, valve)
    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    local circuit_condition = control_behaviour.circuit_condition --[[@as CircuitCondition]]
    local thresholds = circuit_condition.constant
    local valve_type = configuration.deduce_type(control_behaviour)

    if thresholds and thresholds >= 0 and thresholds <= 100 then
        rendering.draw_text{
            text = format_threshold(thresholds),
            surface = valve.surface,
            target = valve,
            color = {1, 1, 1, 0.8},
            scale = 1.5,
            vertical_alignment = "middle",
            players = { player },
            alignment = "center",
            time_to_live = 1, -- We will draw every tick
        }
    end

    if valve_type then
        rendering.draw_text{
            text = {"configurable-valves."..valve_type},
            surface = valve.surface,
            target = {
                entity = valve,
                offset = {0, 0.6} -- Offset a bit above the valve
            },
            color = {1, 1, 1, 0.8},
            scale = 1,
            vertical_alignment = "middle",
            players = { player },
            alignment = "center",
            time_to_live = 1, -- We will draw every tick
        }
    end
end

local function on_tick()
    -- All we're doing is just updating any threshold rendering that any players
    -- might have while selecting a valve. This is to handle quick-toggles, copy-pasting,
    -- multiplayer things, and whetever else might occur. Probably overkill but this function
    -- will be so fast nobody will be able to measure it.

    for _, player in pairs(game.connected_players) do
        local valve = player.selected
        if not valve then goto continue end
        if valve.name ~= "configurable-valve" and not (
            valve.name == "entity-ghost" and valve.ghost_name == "configurable-valve"
        ) then goto continue end

        visualize_config(player, valve)

        ::continue::
    end
end

shortcuts.events = {
    [defines.events.on_tick] = on_tick,
 }
for input, custom_input in pairs({
    toggle = "configurable-valves-switch",
    minus = "configurable-valves-minus",
    plus = "configurable-valves-plus",
}) do
    shortcuts.events[custom_input] = function(e) quick_toggle(input, e) end
end


return shortcuts