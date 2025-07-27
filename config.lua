local config = { }

---@class ConfigurableValveConfig : data.ConfigurableValvesModValveConfig
---@field valve_mode ValveMode
---@field default_threshold float based on the prototype
---@field gauge_name string

---@type table<string, ConfigurableValveConfig>
---@diagnostic disable-next-line: assign-type-mismatch
config.valves = prototypes.mod_data["mod-configurable-valves"].data.valves

--- Fill in the information for each valve
for valve_name, valve_config in pairs(config.valves) do
    local prototype = prototypes.entity[valve_name]
    assert(prototype, "Failed to find prototype for: "..valve_name)
    valve_config.gauge_name = valve_config.gauge_name or "configurable-valve-guage"
end

---@param entity LuaEntity
---@return ConfigurableValveConfig?
function config.get_useful_valve_config(entity)
    local valve_config = config.valves[entity.name]
    if valve_config then return valve_config end

    if entity.name ~= "entity-ghost" then return end
    valve_config = config.valves[entity.ghost_name]
    if valve_config then return valve_config end
end

return config