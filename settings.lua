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
})