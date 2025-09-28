local base = data.raw["arithmetic-combinator"]["arithmetic-combinator"]

local function tiny_combinator(name)
    return {
        type = "arithmetic-combinator",
        name = name,
        icon = "__base__/graphics/icons/arithmetic-combinator.png",
        flags = {
            "not-repairable",
            "not-on-map",
            "not-deconstructable",
            "not-blueprintable",
            "not-flammable",
            "not-upgradable",
            "not-in-kill-statistics",
            "hide-alt-info",
            "placeable-off-grid" -- To be directly above pump position
        },
        selectable_in_game = false,
        selection_priority = 1,
        hidden = true,
        minable = {mining_time = 0.1, result = "arithmetic-combinator"},
        max_health = 150,
        collision_mask = { layers = { } },
        icon_draw_specification = { scale = 0 },
        energy_source = { type = "void", },
        active_energy_usage = "1kW",
        input_connection_bounding_box = {{-0.5, 0}, {0.5, 1}},
        output_connection_bounding_box = {{-0.5, -1}, {0.5, 0}},
        circuit_wire_max_distance = 1,
        activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
        screen_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
        input_connection_points = base.input_connection_points,
        output_connection_points = base.output_connection_points,
        activity_led_light = base.activity_led_light,
        screen_light = base.screen_light,
        activity_led_sprites = base.activity_led_sprites,
    }
end

-- We create separate versions to easily find the one we want in control
data:extend{
    tiny_combinator("valves-tiny-combinator-input"),
    tiny_combinator("valves-tiny-combinator-output"),
}
