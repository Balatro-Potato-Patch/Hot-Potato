SMODS.Joker {
    key = "upsidedownsmiley",
    config = {
        extra = {
            mult = 4
        }
    },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    atlas = "smiley_jokers",
    pos = {x=0,y=0},
    ppu_coder = {"PokéRen"},
    ppu_team = {"smiley"},
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:is_face() then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end
}