SMODS.Joker {
    key = "participation_award",
    rarity = 1,
    cost = 1,
    atlas = "hc_jokers",
    pos = {x = 5, y = 3},
    config = { extra = { chips = 1} },
    loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = 'hc_nxko_comment', set = 'Other' }
        return {vars = { card.ability.extra.chips }}
    end,
    ppu_coder = { "baccon" },
    ppu_artist = { "baccon" },
    ppu_team = { "Horsechicot" },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            return { chips = card.ability.extra.chips }
        end
    end
}
