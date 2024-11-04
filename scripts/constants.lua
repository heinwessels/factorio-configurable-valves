local constants = { }

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

return constants