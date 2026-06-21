SMODS.Joker {
    key = "hc_genghis_khan",
    config = {
        current = 1,
        increment = 0.6
    },
    cost = 6,
    rarity = 2,
    atlas = "hc_jokers",
    pos = {x = 3, y = 4},
    ppu_coder = { "cg223" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" },
    attributes = { 'xmult', 'scaling' },
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.increment, card.ability.current}}
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    calculate = function (self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.current
            }
        elseif context.fathered_child and not context.blueprint then
            SMODS.scale_card(card, {ref_table = card.ability, ref_value = "current", scalar_value = "increment"})
        end
    end
}