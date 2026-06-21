SMODS.Joker {
    key = "blunderfarming",
    atlas = "hc_jokers",
    pos = { x = 4, y = 2 },
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    cost = 4,
    config = { extra = { odds = 2 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'blunderfarming')
        return { vars = { numerator, denominator } }
    end,
    ppu_coder = { "Nxkoo" },
    ppu_artist = { "lord.ruby" },
    ppu_team = { "Horsechicot" },
}

local original_add_tag = add_tag
function add_tag(tag, immediate)
    if next(SMODS.find_card("j_hpot_blunderfarming")) and G.CONTROLLER.locks.skip_blind then
        if pseudorandom('blunder', 1, 2) == 1 then
            original_add_tag(Tag(tag.key), immediate)
        end
    end
    original_add_tag(tag, immediate)
end
