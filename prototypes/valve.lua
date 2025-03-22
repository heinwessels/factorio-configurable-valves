local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend{
    {
      type = "item",
      name = "configurable-valve",
      icon = "__configurable-valves__/graphics/configurable-valve/icon.png",
      subgroup = "energy-pipe-distribution",
      order = "b[pipe]-d[configurable-valve]",
      inventory_move_sound = item_sounds.fluid_inventory_move,
      pick_sound = item_sounds.fluid_inventory_pickup,
      drop_sound = item_sounds.fluid_inventory_move,
      place_result = "configurable-valve",
      stack_size = 20,
      random_tint_color = item_tints.iron_rust
    },
    {
      type = "recipe",
      name = "configurable-valve",
      energy_required = 2,
      enabled = false,
      ingredients = {},
      results = {{type="item", name="configurable-valve", amount=1}}
    },
    {
        type = "pump",
        name = "configurable-valve",
        icon = "__configurable-valves__/graphics/configurable-valve/icon.png",
        flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
        localised_description = {"",
          {"entity-description.configurable-valve"},
          " ",
          {"configurable-valves.more-in-factoriopedia"},
        },
        factoriopedia_description = {"",
          {"entity-description.configurable-valve"},
          {"configurable-valves.valve-examples"},
          {"configurable-valves.valve-shortcuts"},
        },
        minable = {mining_time = 0.2, result = "configurable-valve"},
        max_health = 180,
        fast_replaceable_group = "pipe",
        corpse = "pump-remnants",
        dying_explosion = "pump-explosion",
        collision_box = {{-0.29, -0.45}, {0.29, 0.45}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        icon_draw_specification = {scale = 0.5},
        working_sound =
        {
          sound = { filename = "__base__/sound/pump.ogg", volume = 0.3 },
        },
        damaged_trigger_effect = hit_effects.entity(),
        resistances =
        {
          {
            type = "fire",
            percent = 80
          },
          {
            type = "impact",
            percent = 30
          }
        },
        fluid_box =
        {
          volume = 400,
          pipe_covers = pipecoverspictures(),
          pipe_connections =
          {
            {connection_type = "linked", flow_direction = "output", linked_connection_id=31113 + 1 },
            {connection_type = "linked", flow_direction = "input", linked_connection_id=31113 - 1 }
          },
          hide_connection_info = true,
        },
        energy_source = { type = "void" },
        energy_usage = "29kW",
        pumping_speed = settings.startup["configurable-valve-pump-speed"].value / 60, --[[@as number value given per second, convert to per tick]]
        impact_category = "metal",
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,

        animations =
        {
          north =
          {
            filename = "__configurable-valves__/graphics/configurable-valve/north.png",
            width = 128,
            height = 128,
            scale = 0.5,
            line_length = 1,
            frame_count = 1,
            animation_speed = 1,
          },
          east =
          {
            filename = "__configurable-valves__/graphics/configurable-valve/east.png",
            width = 128,
            height = 128,
            scale = 0.5,
            line_length = 1,
            frame_count = 1,
            animation_speed = 1,
          },
          south =
          {
            filename = "__configurable-valves__/graphics/configurable-valve/south.png",
            width = 128,
            height = 128,
            scale = 0.5,
            line_length = 1,
            frame_count = 1,
            animation_speed = 1,
          },
          west =
          {
            filename = "__configurable-valves__/graphics/configurable-valve/west.png",
            width = 128,
            height = 128,
            scale = 0.5,
            line_length = 1,
            frame_count = 1,
            animation_speed = 1,
          }
        },

        circuit_connector = circuit_connector_definitions.create_vector(universal_connector_template, {
          { variation = 24, main_offset = util.by_pixel(-15/2-3, -8.5/2), shadow_offset = util.by_pixel(0, -0.5), show_shadow = false },
          { variation = 26, main_offset = util.by_pixel(13.5/2, 4.5/2), shadow_offset = util.by_pixel(-7, -12.5), show_shadow = true },
          { variation = 24, main_offset = util.by_pixel(-14.5/2-3, -8.5/2), shadow_offset = util.by_pixel(-12.5, 6), show_shadow = false },
          { variation = 26, main_offset = util.by_pixel(-16/2, 3.5/2), shadow_offset = util.by_pixel(-14, 13.5), show_shadow = true },
        }),
        circuit_wire_max_distance = default_circuit_wire_max_distance
    },
}