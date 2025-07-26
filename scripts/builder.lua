local constants = require("__configurable-valves__.constants")
local configuration = require("__configurable-valves__.scripts.configuration")
local config = require("__configurable-valves__.config")

local builder = { }
local debug = false

---@param this LuaEntity
---@param that LuaEntity
---@return boolean
local function has_linked_pipe_connection(this, that)
    for index=1,#this.fluidbox do
        for _, connection in pairs(this.fluidbox.get_pipe_connections(index)) do
            if connection.connection_type == "linked" and connection.target then
                if connection.target.owner == that then
                    return true
                end
            end
        end
    end
    return false
end

---@param valve LuaEntity
---@param is_input boolean else it's an output
---@return LuaEntity
local function create_hidden_guage(valve, is_input)
    local guage = valve.surface.create_entity{
        name = "configurable-valve-guage-" .. (is_input and "input" or "output"),
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(guage)
    guage.destructible = false
    guage.fluidbox.add_linked_connection(31113, valve, 31113 + (is_input and -1 or 1))
    if debug then assert(has_linked_pipe_connection(valve, guage)) end
    return guage
end

---@param valve LuaEntity
---@param guage LuaEntity?
---@param is_input boolean else it's an output
---@return LuaWireConnector
local function create_hidden_combinator(valve, guage, is_input)
    local combinator = valve.surface.create_entity{
        name = "valves-tiny-combinator-" .. (is_input and "input" or "output"),
        position = valve.position,
        force = valve.force,
        create_build_effect_smoke = false
    }
    assert(combinator)
    combinator.destructible = false

    local behaviour = combinator.get_or_create_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior ]]
    behaviour.parameters = {
        first_signal = constants.signal.each,
        operation = '+',
        second_constant = 0,
        output_signal = is_input and constants.signal.input or constants.signal.output,
    }

    local combinator_output_connector = combinator.get_wire_connector(defines.wire_connector_id.combinator_output_green, true)
    local valve_connector = valve.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    valve_connector.connect_to(combinator_output_connector, false, defines.wire_origin.script)

    if guage then
        local combinator_input_connector = combinator.get_wire_connector(defines.wire_connector_id.combinator_input_green, true)
        local guage_connector = guage.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        guage_connector.connect_to(combinator_input_connector, false, defines.wire_origin.script)
    end

    return combinator_output_connector
end

---@param valve LuaEntity
---@param player LuaPlayer?
function builder.build(valve, player)
    local input_guage = create_hidden_guage(valve, true)
    local output_guage = create_hidden_guage(valve, false)

    create_hidden_combinator(valve, input_guage, true)
    create_hidden_combinator(valve, output_guage, false)

    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    configuration.initialize(control_behaviour, player)
end

---@param valve LuaEntity
function builder.destroy(valve)
    for _, name in pairs{
        "configurable-valve-guage-input",
        "configurable-valve-guage-output",
        "valves-tiny-combinator-input",
        "valves-tiny-combinator-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then entity.destroy() end
    end
end

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_entity_cloned
local function on_entity_created(event)
    local entity = event.entity or event.destination
    local player = event.player_index and game.get_player(event.player_index) or nil

    local valve_config = config.get_useful_valve_config(entity)
    if not valve_config then return end

    if entity.name ~= "entity-ghost" then
        if event.name == defines.events.on_entity_cloned then
            -- If it's a clone event they destroy it and recreate it to make sure all the parts are there.
            -- This is in case a mod calls `entity.clone(...)`. If it's an area or brush clone then all
            -- the components will already be cloned so it won't be duplicated, cause this event is only
            -- called _after_ all entities have been cloned.
            builder.destroy(entity)
        end

        builder.build(entity, player)
    else -- This is a ghost
        local control_behaviour = entity.get_or_create_control_behavior()
        ---@cast control_behaviour LuaPumpControlBehavior
        configuration.initialize(control_behaviour, player)
    end
end

local function on_entity_destroyed(event)
    local entity = event.entity
    local valve_config = config.get_useful_valve_config(entity)
    if not valve_config then return end
    builder.destroy(entity)
end

---@param event EventData.on_player_rotated_entity|EventData.on_player_flipped_entity
local function on_entity_changed_direction(event)
    local valve = event.entity
    local valve_config = config.get_useful_valve_config(valve)
    if not valve_config then return end

    for _, name in pairs{
        "configurable-valve-guage-input",
        "configurable-valve-guage-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then
            entity.direction = valve.direction
            entity.mirroring = valve.mirroring -- Technically not required, because the valves just rotate.
        end
    end
end

local function on_entity_changed_position(event)
    local valve = event.entity
    local valve_config = config.get_useful_valve_config(valve)
    if not valve_config then return end

    for _, name in pairs{
        "configurable-valve-guage-input",
        "configurable-valve-guage-output",
        "valves-tiny-combinator-input",
        "valves-tiny-combinator-output",
    } do
        local entity = valve.surface.find_entity(name, event.start_pos)
        if entity then
            assert(entity.teleport(valve.position), "Failed teleporting "..name)
        end
    end
end

builder.events = {
    [defines.events.on_robot_built_entity] = on_entity_created,
    [defines.events.on_built_entity] = on_entity_created,
    [defines.events.script_raised_built] = on_entity_created,
    [defines.events.script_raised_revive] = on_entity_created,
    [defines.events.on_entity_cloned] = on_entity_created,
    [defines.events.on_space_platform_built_entity] = on_entity_created,

    [defines.events.on_player_mined_entity] = on_entity_destroyed,
    [defines.events.on_robot_mined_entity] = on_entity_destroyed,
    [defines.events.on_entity_died] = on_entity_destroyed,
    [defines.events.script_raised_destroy] = on_entity_destroyed,
    [defines.events.on_space_platform_mined_entity] = on_entity_destroyed,

    [defines.events.on_player_rotated_entity] = on_entity_changed_direction,
    [defines.events.on_player_flipped_entity] = on_entity_changed_direction,
}

local function setup_picker_dollies_compat()
    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_entity_changed_position)
    end
end

builder.on_init = setup_picker_dollies_compat
builder.on_load = setup_picker_dollies_compat

return builder