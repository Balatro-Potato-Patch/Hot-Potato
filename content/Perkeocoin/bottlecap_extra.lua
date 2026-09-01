-- Disable this if it's too much
if false then
    return
end

local colors = {
    Common = G.C.BLUE,
    Uncommon = G.C.GREEN,
    Rare = G.C.RED,
    Legendary = G.C.PURPLE,
    Bad = G.C.DARK_EDITION,
}

SMODS.Shader { key = "bottlecap", path = "bottlecap.fs" }

local function calculate_color(color)
    
    local color_shift = math.sin(G.TIMERS.REAL % (2 * math.pi)) * 0.16
    if color_shift > 0 then
        return darken(color, color_shift)
    else
        return lighten(color, color_shift)
    end
end

local game_update = Game.update
function Game:update(...)
    colors.Common = calculate_color(G.C.BLUE)
    colors.Uncommon = calculate_color(G.C.GREEN)
    colors.Rare = calculate_color(G.C.RED)
    colors.Legendary = calculate_color(SMODS.Gradients["hpot_plincoin"])
    colors.Bad = calculate_color(G.C.GREY)

    return game_update(self, ...)
end

SMODS.DrawStep {
    key = 'bottlecap_rarity',
    order = -20,
    func = function(self)
        if self.children.center and self.config.center.set == 'bottlecap' and self.area and (self.area == G.plinko_rewards  --[[or self.area == G.wheel_rewards]] )and colors[self.ability.extra.chosen] then
            local radius = 0.28

            if not self.children.rarity then
                self.children.rarity = Sprite(self.children.center.T.x, self.children.center.T.y, self.children.center.T.w*2, self.children.center.T.h*2, G.ASSET_ATLAS["ui_1"], {x = 2, y = 0})

                self.children.rarity:define_draw_steps({{
                    shader = 'hpot_bottlecap',
                    other_obj = self.children.center,
                    ms = self.ability.extra.chosen == 'Legendary' 
                            and 2.75 * 1.5
                            or 2.67 * 1.5,
                    mx = self.children.center.T.w*1.1,
                    my = self.children.center.T.h*1.1,
                    send = {
                        {name = 'radius_squared', func = function () return 
                            (radius * (0.95 + math.sin(G.TIMERS.REAL * 1.3) * 0.05)) ^2
                        end},
                        {name = 'color', ref_table = colors, ref_value = self.ability.extra.chosen},
                        {name = 'image_details', ref_table = self.children.rarity, ref_value = 'image_dims'},
                        {name = 'texture_details', ref_table = self.children.rarity.RETS, ref_value = 'get_pos_pixel'},
                    }
                }})
                self.children.rarity.states.visible = false
            else

                self.children.rarity:get_pos_pixel()
                self.children.rarity.states.visible = true
                self.children.rarity:draw() -- uhhh I cba figuring out how to draw it before center
                self.children.rarity.states.visible = false
            end

        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

