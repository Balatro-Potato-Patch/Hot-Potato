SMODS.Joker {
    key = "electrical_discharge",
    rarity = 2,
    cost = 5,
    atlas = "hc_jokers",
    pos = { x = 5, y = 2 },
    config = { extra = { stored_mult = 0, take = 0.2 } }, -- 20%
    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.take*100,
            card.ability.extra.stored_mult,
        }}
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if context.post_final_scoring_step and not context.blueprint then
            local score = SMODS.calculate_round_score()
            if score > G.GAME.blind.chips then
                local stolen = SMODS.get_scoring_parameter("mult") * card.ability.extra.take
                card.ability.extra.stored_mult = card.ability.extra.stored_mult + stolen
                SMODS.calculate_effect({xmult = (1 - card.ability.extra.take)}, card)
            end
            score = SMODS.calculate_round_score()
            if to_big(score) < to_big(G.GAME.blind.chips) then
                SMODS.calculate_effect({mult = card.ability.extra.stored_mult, message = localize("k_reset")}, card)
                card.ability.extra.stored_mult = 0

            end
        end
    end,
    ppu_coder = {"Lily Felli"},
    ppu_artist = {"pangaea47"},
    ppu_team = {"Horsechicot"},
}
