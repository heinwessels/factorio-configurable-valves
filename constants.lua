local constants = { }

---@alias ValveType "overflow" | "top_up" | "one_way"

---@type table<string, SignalID>
constants.signal = {
    each =      { type = 'virtual', name = "signal-each" },
    input =     { type = "virtual", name = "signal-I" },
    output =    { type = "virtual", name = "signal-O" },
}

---@type table<ValveType, CircuitCondition>
constants.valve_types = {
    overflow    = { comparator = '>', first_signal = constants.signal.input,  constant = 80, },
    top_up      = { comparator = '<', first_signal = constants.signal.output, constant = 80, },
    one_way     = { comparator = '>', first_signal = constants.signal.input,  second_signal = constants.signal.output, },
}

if helpers.stage == "runtime" then
    -- Set the conditions to mimic the default threshold settings
    for _, my_valve_type in pairs({"overflow", "top_up"}) do
        local default_threshold = tonumber(settings.startup["configurable-valve-default-threshold-"..my_valve_type].value)
        assert(default_threshold)
        assert(constants.valve_types[my_valve_type].constant)
        constants.valve_types[my_valve_type].constant = tonumber(default_threshold )
    end
end

return constants