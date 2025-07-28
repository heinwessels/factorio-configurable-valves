
--- Explanation:
--- If you want your valves to also be managed by this mod then you need to add
--- your valves name to the following mod-data prototype. This will allow my mod to
--- manage your valves thresholds, hidden entities, etc. Please see the `data.ConfigurableValvesModValveConfig`
--- for other options you can set for your valve.
--- 
--- Something like
--- ```lua
--- local valves = data.raw["mod-data"]["mod-configurable-valves"].data.valves
--- ---@cast valves table<string, data.ConfigurableValvesModValveConfig>
--- valves["my-custom-valve"] = { name = "my-custom-valve" }
--- ```
--- 
--- Remember to add an dependency to this mod in your `info.json` file, and and
--- your valve prototypes to the `mod-data` during `data.lua`.

---@class data.ConfigurableValvesModValveConfig
---@field name string name of the entity
---@field ignore_techs boolean? if true the valves mod will not interfere with the tech tree regarding these valve prototypes
---@field threshold_visualization_scale float? to apply to the threshold visualization number, default is 1.0
---@field type_visualization_scale float? to apply to the valve type visualization, default is 1.0
---@field type_visualization_offset MapPosition? to apply to the valve type visualization, default is {0, 0}
---@field gauge_name string? name of the gauge to use for this valve, default is "configurable-valve-guage". Will be appended with "-input" or "-output"

data:extend{
    {
        type = "mod-data",
        name = "mod-configurable-valves",
        data = {
            ---@type table<string, data.ConfigurableValvesModValveConfig>
            valves = {
                ["configurable-valve"] = { name = "configurable-valve" },
            }
        }
    },
}