local click = Blind.click
function Blind:click()
    local found = SMODS.find_card("j_hpot_idle")
    if next(found) then
        self.states.drag.can = false

        for _,joker in pairs(found) do
            joker.ability.extra.score = joker.ability.extra.score + joker.ability.extra.gain
            card_eval_status_text(joker, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), instant = true})
            --[[
            SMODS.scale_card(joker, {
                ref_table = joker.ability.extra,
                ref_value = "score",
                scalar_value = "gain",
            })
            ]]
        end

        self:juice_up()
    else
        self.states.drag.can = true
    end

    click(self)
    
end

SMODS.Joker {
    key = "idle",
    rarity = 1,
    cost = 5,
    atlas = "hc_jokers",
    pos = {x = 2, y = 0},
    config = { extra = { score = 0, gain = 1, money = 1 } },
    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.gain,
            card.ability.extra.money,
            card.ability.extra.score,
        }}
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calc_dollar_bonus = function(self, card)
        local score = (#tostring(card.ability.extra.score))
        card.ability.extra.score = 0
        SMODS.calculate_effect({message = localize("k_reset")}, card)
        return score > 0 and (score * card.ability.extra.money) or nil
    end,
    ppu_coder = { "Lily Felli" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" }
}
