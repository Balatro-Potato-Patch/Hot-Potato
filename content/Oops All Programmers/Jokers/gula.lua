SMODS.Joker {
    key = 'gula',
    rarity = 3,
    blueprint_compat = false,
    perishable_compat = false,
    eternal_compat = true,
    cost = 7,
    atlas = "oap_jokers",
    config = {extra = {x_mult = 1}},
    pos = { x = 8, y = 0 },
    attributes = { 'xmult' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not card.getting_sliced and not context.blueprint then
            local mod = (to_big(G.GAME.plincoins) > to_big(0) and G.GAME.plincoins or 0) * 0.1 + -- Plincoins
            (to_big(G.GAME.cryptocurrency) > to_big(0) and G.GAME.cryptocurrency or 0) * 0.1 + -- Cryptocurrency
            (to_big(G.GAME.spark_points) > to_big(0) and G.GAME.spark_points or 0) * 0.000005 -- Spark Points
            if to_big(G.GAME.plincoins) > to_big(0) then ease_plincoins(-G.GAME.plincoins) end
            if to_big(G.GAME.cryptocurrency) > to_big(0) then ease_cryptocurrency(-G.GAME.cryptocurrency) end
            if to_big(G.GAME.spark_points) > to_big(0) then ease_spark_points(-G.GAME.spark_points) end
            card.ability.extra.x_mult = card.ability.extra.x_mult + mod
            if to_big(mod) > to_big(0) then
                return {
                    message = localize('k_upgrade_ex')
                }
            end
        end
        if context.joker_main then
            return {
                x_mult = card.ability.extra.x_mult
            }
        end
    end,
    ppu_artist = { 'Mysthaps' },
    ppu_coder = { 'Mysthaps' },
    ppu_team = { 'OAP' }
}