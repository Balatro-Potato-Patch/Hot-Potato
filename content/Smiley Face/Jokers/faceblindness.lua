SMODS.Joker {
    key = "faceblindness",
    config = {
        extra = {
            numerator = 1,
            denominator = 3
        }
    },
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.numerator, card.ability.extra.denominator, 'faceblindness')
        return { vars = { numerator, denominator } }
    end,
    rarity = 1,
    blueprint_compat = false,
    cost = 3,
    atlas = "smiley_jokers",
    pos = {x=1,y=1},
    ppu_artist = {"RGBeet"},
    ppu_coder = {"PokéRen"},
    ppu_team = {":)"}
}

-- code is actually in emoticon.lua's hook lmao