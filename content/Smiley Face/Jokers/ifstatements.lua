SMODS.Joker {
    key = "ifstatements",
    config = {
        extra = {
            xmult = 2,
            xchips = 2,
        }
    },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xchips } }
    end,
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    atlas = "smiley_jokers",
    pos = {x=2,y=0},
    attributes = { 'xmult', 'xchips' },
    ppu_coder = {"notmario"},
    ppu_team = {":)"},
    calculate = function(self, card, context)
        if context.joker_main then
            local my_effects = {}
            if math.fmod(to_number(hand_chips), 2) ~= 0 then
                my_effects[#my_effects + 1] = {
                    xchips = card.ability.extra.xchips
                }
            end
            if math.fmod(to_number(mult), 2) ~= 0 then
                my_effects[#my_effects + 1] = {
                    xmult = card.ability.extra.xmult
                }
            end
            return SMODS.merge_effects(my_effects)
        end
    end
}