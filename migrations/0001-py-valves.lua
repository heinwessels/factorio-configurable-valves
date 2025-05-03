-- This migration turns all the old 1.1 py-valves into a configurable valve
-- with the correct circuit conditions

local util = require("util")
local constants = require("__configurable-valves__.constants")

if not script.active_mods["pyindustry"] then return end
if settings.startup["configurable-valve-disable-py-migration"].value then return end

local replace_behaviour = {
    ["py-overflow-valve"]   = { behaviour = constants.valve_types.overflow },
    ["py-underflow-valve"]  = { behaviour = constants.valve_types.top_up,     invert_direction = true },
    ["py-check-valve"]      = { behaviour = constants.valve_types.one_way,  invert_direction = true },
}

for _, surface in pairs(game.surfaces) do
    for entity_name, config in pairs(replace_behaviour) do
        for _, entity in pairs(surface.find_entities_filtered{name = entity_name}) do
            local position = entity.position
            local direction = entity.direction
            local force = entity.force
            entity.destroy{raise_destroy = true}

            if config.invert_direction then
                direction = util.oppositedirection(direction)
            end

            local valve = surface.create_entity{
                name = "configurable-valve",
                position = position,
                force = force,
                direction = direction,
                raise_built = true,
            }
            if valve then
                local control_behaviour = valve.get_or_create_control_behavior()
                ---@cast control_behaviour LuaPumpControlBehavior
                control_behaviour.circuit_enable_disable = true
                assert(config.behaviour)
                control_behaviour.circuit_condition = config.behaviour
            end
        end
    end
end