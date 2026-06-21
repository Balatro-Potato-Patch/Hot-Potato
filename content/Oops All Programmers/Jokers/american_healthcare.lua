SMODS.Joker {
    key = 'american_healthcare',
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    rarity = 3,
    cost = 7,
    atlas = "oap_jokers",
    pos = { x = 2, y = 2 },
    config = {
        extra = {
            xmult = 1,
            inc = 0.25,
            dollar_loss = 3,
            this_round = false
        }
    },
    attributes = { 'xmult', 'breeding' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.inc, card.ability.extra.xmult, card.ability.extra.dollar_loss } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult,
            }
        end
        if context.pregnant and not card.ability.extra.this_round and not context.blueprint then
            card.ability.extra.this_round = true
            SMODS.scale_card(card, {ref_table = card.ability.extra, ref_value = "xmult", scalar_value = "inc"})
            return {
                dollars = -card.ability.extra.dollar_loss
            }
        end
        if context.starting_shop then
            card.ability.extra.this_round = false
            juice_card_until(card, function() return not (card.ability.extra.this_round or G.STATE == G.STATES.BLIND_SELECT) end, true)
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'trif' },
    ppu_team = { 'OAP' }
}

local old = G.FUNCS.nursery_breed
function G.FUNCS.nursery_breed(e)
    old(e)
    SMODS.calculate_context {
        pregnant = true
    }
end