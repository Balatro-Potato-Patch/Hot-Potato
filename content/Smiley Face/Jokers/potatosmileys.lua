SMODS.Joker {
    key = "potatosmileys",
    config = {
        extra = {
            mult = 10,
            mult_loss = 1,
        }
    },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_loss } }
    end,
    rarity = 1,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = false,
    cost = 4,
    atlas = "smiley_jokers",
    pos = {x=0,y=1},
    attributes = { 'food', 'mult', 'face' },
    ppu_artist = {"RGBeet"},
    ppu_coder = {"notmario"},
    ppu_team = {":)"},
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if to_big(card.ability.extra.mult - card.ability.extra.mult_loss) <= to_big(0) then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_eaten_ex'),
                    colour = G.C.RED
                }
            else
                card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.mult_loss
                return {
                    message = localize { type = 'variable', key = 'a_mult_minus', vars = { card.ability.extra.mult_loss } },
                    colour = G.C.MULT
                }
            end
        end
    end
}