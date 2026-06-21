SMODS.Joker {
    key = "inacargobox",
    atlas = "hc_jokers",
    pos = { x = 7, y = 3 },
    ppu_artist = {"lord.ruby"},
    ppu_coder = {"Nxkoo"},
    ppu_team = {"Horsechicot"},
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 8,
    config = { extra = { xmult_per_delivery = 2.5 } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult_per_delivery
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local valid_deliveries = to_number(G.GAME.hp_jtem_delivery_queue and #G.GAME.hp_jtem_delivery_queue or 0)
            if valid_deliveries > 0 then
                for i = 1, valid_deliveries do
                    SMODS.calculate_effect({ xmult = card.ability.extra.xmult_per_delivery }, card)
                end
            end
        end
    end
}
