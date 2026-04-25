local constants = require("__configurable-valves__.constants")
local valve_types_array = { }
for valve_type in pairs(constants.valve_types) do
    table.insert(valve_types_array, valve_type)
end

data:extend({
    {
        type = "int-setting",
        name = "configurable-valve-pump-speed",
        setting_type = "startup",
        minimum_value = 60,
        maximum_value = 24000,
        default_value = 1200,
    },
    {
        type = "bool-setting",
        name = "configurable-valve-disable-py-migration",
        setting_type = "startup",
        order = "z[migration]-a[py]",
        default_value = false,
        hidden = mods["pyindustry"] == nil
    },
    {
        type = "string-setting",
        name = "configurable-valve-default-type",
        setting_type = "runtime-per-user",
        order = "a[valve]-a[py]",
        default_value = "overflow",
        allowed_values = valve_types_array,
    },
})