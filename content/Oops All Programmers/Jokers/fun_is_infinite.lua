SMODS.Joker {
    key = "fun_is_infinite",
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    atlas = "oap_jokers",
    pos = { x = 5, y = 1 },
    config = { extra = { xmult = 1.75 } },
    attributes = { 'xmult' },
    loc_vars = function(self, info_queue, card)
        if not card.ability.eternal then
            info_queue[#info_queue+1] = { key = "eternal", set = "Other" }
        end
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.other_joker and SMODS.is_eternal(context.other_joker, card) then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { "trif" },
    ppu_team = { 'OAP' }
}