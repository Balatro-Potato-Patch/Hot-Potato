SMODS.Joker {
    key = "plinkodemayo",
    config = {
        extra = {
            plincoins = 1
        }
    },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.plincoins } }
    end,
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    atlas = "smiley_jokers",
    pos = {x=2,y=1},
    ppu_artist = {"RGBeet"},
    ppu_coder = {"notmario"},
    ppu_team = {"smiley"},
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 5 then
            ease_plincoins(card.ability.extra.plincoins)
        end
    end
}