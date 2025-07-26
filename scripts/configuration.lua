local constants = require("__configurable-valves__.constants")

local configuration = { }

---@param behaviour LuaPumpControlBehavior
---@param valve_type ValveType
---@param player LuaPlayer?
function configuration.set_type(behaviour, valve_type, player)
    behaviour.circuit_condition = constants.valve_types[valve_type]
    ---@TODO Set custom threshold set per player setting
end

---@param behaviour LuaPumpControlBehavior
---@param player LuaPlayer?
function configuration.initialize(behaviour, player)
    if behaviour.circuit_enable_disable then
        -- This valve's condition has already been set. Don't overwrite it.
        -- Probably cause this is a ghost of a dead valve, or from a blueprint.
        return
    end

    behaviour.circuit_enable_disable = true
    configuration.set_type(behaviour, "overflow", player)
end

---@param behaviour LuaPumpControlBehavior
---@return ValveType?
function configuration.deduce_type(behaviour)
    local circuit_condition = behaviour.circuit_condition --[[@as CircuitCondition]]
    local first = circuit_condition.first_signal and circuit_condition.first_signal.name
    local second = circuit_condition.second_signal and circuit_condition.second_signal.name
    if first == "signal-I" and not second and circuit_condition.comparator == ">" then
        return "overflow"
    elseif first == "signal-O" and not second and circuit_condition.comparator == "<" then
        return "top_up"
    elseif first == "signal-I" and second == "signal-O" and circuit_condition.comparator == ">" then
        return "one_way"
    end
end

---Get the next valve type in a cyclical fashion.
---@param valve_type ValveType?
---@return ValveType
function configuration.next_type(valve_type)
    local new_valve_type = valve_type and next(constants.valve_types, valve_type)
    if not new_valve_type then new_valve_type = next(constants.valve_types) end
    assert(new_valve_type, "Failed finding valve after: "..(valve_type or "nil"))
    return new_valve_type
end

return configuration