SMODS.Joker {
    key = 'paper_jam',
    rarity = 1,
    blueprint_compat = true,
    cost = 6,
    config = {
        extra = {
            retriggers = 4,
            chosen_card = nil
        }
    },
    atlas = "oap_jokers",
    pos = { x = 6, y = 0 },
    pixel_size = { h = 77 },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.retriggers
            }
        }
    end,
    calculate = function(self, card, context)
        if context.before
            and context.main_eval
            and #context.scoring_hand >= 5 then
            card.ability.extra.chosen_card = pseudorandom_element(context.scoring_hand)
        end
        if context.repetition
            and card.ability.extra.chosen_card
            and context.other_card == card.ability.extra.chosen_card then
            return {
                repetitions = card.ability.extra.retriggers
            }
        end
        if context.after then
            card.ability.extra.chosen_card = nil
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'th30ne' },
    ppu_team = { 'OAP' }
}
