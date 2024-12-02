---@type data.TechnologyPrototype?
local tech_to_unlock
for _, technology in pairs(data.raw.technology) do
    if technology.effects then			
        for index, effect in pairs(technology.effects) do
            if effect.type == "unlock-recipe" then
                if effect.recipe == "pump" then
                  tech_to_unlock = technology
                  table.insert(tech_to_unlock.effects, index, {
                    type = "unlock-recipe",
                    recipe = "configurable-valve"
                  })
                  break
                end
            end
        end
        if tech_to_unlock then break end
    end
end

---@type data.IngredientPrototype?
local ingredients
for _, recipe in pairs(data.raw.recipe) do
  for _, result in pairs(recipe.results or { }) do
      if result.type == "item" then
          if result.name == "pump" then
            ingredients = recipe.ingredients
            break
          end
      end
  end
  if ingredients then break end
end

data.raw.recipe["configurable-valve"].enabled = tech_to_unlock == nil
data.raw.recipe["configurable-valve"].ingredients = ingredients