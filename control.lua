-- Open GUI of hidden combinator
-- /c local c = game.surfaces[1].find_entities_filtered{name="valves-tiny-combinator-input"}[1]; assert(c); game.player.opened = c

local debug = false

local signal_each = { type = 'virtual', name = 'signal-each' }
local signal_input = { type = "virtual", name="signal-I" }
local signal_output = { type = "virtual", name="signal-O" }

---@param valve LuaEntity
local function set_defualt_behaviour(valve)
    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    control_behaviour.circuit_enable_disable = true
    control_behaviour.circuit_condition = {
        comparator = '>',
        first_signal = signal_input,
        constant = 80,
    }
end

-----------------------------------------------------------
--- LOGIC -------------------------------------------------
-----------------------------------------------------------

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

    local behaviour = combinator.get_or_create_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior ]]
    behaviour.parameters = {
        first_signal = signal_each,
        operation = '+',
        second_constant = 0,
        output_signal = is_input and signal_input or signal_output,
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
local function handle_valve_creation(valve)
    local input_guage = valve.surface.create_entity{
        name = "configurable-valve-guage-input",
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(input_guage)
    input_guage.destructible = false
    input_guage.fluidbox.add_linked_connection(31113, valve, 31113-1)
    if debug then assert(has_linked_pipe_connection(valve, input_guage)) end

    local output_guage = valve.surface.create_entity{
        name = "configurable-valve-guage-output",
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(output_guage)
    output_guage.destructible = false
    output_guage.fluidbox.add_linked_connection(31113, valve, 31113+1)
    if debug then assert(has_linked_pipe_connection(valve, output_guage)) end

    create_hidden_combinator(valve, input_guage, true)
    create_hidden_combinator(valve, output_guage, false)

    set_defualt_behaviour(valve)
end

---@param valve LuaEntity
local function handle_valve_destroyed(valve)
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

---@param event EventData.on_player_rotated_entity
script.on_event(defines.events.on_player_rotated_entity, function(event)
    ---@TODO This doesn't work yet
    local valve = event.entity
    if valve.name ~= "configurable-valve" then return end
    for _, name in pairs{
        "configurable-valve-guage-input",
        "configurable-valve-guage-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then entity.direction = valve.direction end
    end
end)

-----------------------------------------------------------
--- DISPATCHER --------------------------------------------
-----------------------------------------------------------

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_entity_cloned
local function on_entity_created(event)
    local entity = event.entity
    if entity.name == "configurable-valve" then
        handle_valve_creation(entity)
    elseif entity.name == "entity-ghost" and entity.ghost_name == "configurable-valve" then
        set_defualt_behaviour(entity)
    end
end

local function on_entity_destroyed(event)
    local entity = event.entity
    if entity.name == "configurable-valve" then
        handle_valve_destroyed(entity)
    end
end

script.on_event(defines.events.on_robot_built_entity, on_entity_created)
script.on_event(defines.events.on_built_entity, on_entity_created)
script.on_event(defines.events.script_raised_built, on_entity_created)
script.on_event(defines.events.script_raised_revive, on_entity_created)
script.on_event(defines.events.on_entity_cloned, on_entity_created)
script.on_event(defines.events.on_space_platform_built_entity, on_entity_created)

script.on_event(defines.events.on_player_mined_entity, on_entity_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_entity_destroyed)
script.on_event(defines.events.on_entity_died, on_entity_destroyed)
script.on_event(defines.events.script_raised_destroy, on_entity_destroyed)
script.on_event(defines.events.on_space_platform_mined_entity, on_entity_destroyed)

