SMODS.Joker {
    key = "folded",
    atlas = "hc_jokers",
    pos = {x=4,y=0},
    rarity = 1,
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { unscoring = 3, mult = 20 } },
    attributes = { 'mult' },
    calculate = function(self, card, context)
        if context.joker_main and (#context.full_hand - #context.scoring_hand) >= card.ability.extra.unscoring then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.mult,
            card.ability.extra.unscoring
        }}
    end,
    ppu_coder = { "Lily Felli" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" },
    pixel_size = { w = 71, h = 62 },
}