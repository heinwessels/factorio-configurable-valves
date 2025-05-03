local configuration = require("__configurable-valves__.scripts.configuration")

local shortcuts = { }

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
    local msg = {"", {"configurable-valves."..valve_type}}
    if constant then table.insert(msg, ": "..tostring(constant).."%") end
    player.create_local_flying_text{text = msg, position = valve.position, speed = 20}
end

shortcuts.events = { }
for input, custom_input in pairs({
    toggle = "configurable-valves-switch",
    minus = "configurable-valves-minus",
    plus = "configurable-valves-plus",
}) do
    shortcuts.events[custom_input] = function(e) quick_toggle(input, e) end
end


return shortcuts