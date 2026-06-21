SMODS.Joker {
    key = 'loss',
    atlas = 'oap_jokers',
    pos = {x = 2, y = 1},
    rarity = 3,
    blueprint_compat = true,
    perishable_compat = false,
    eternal_compat = true,
    cost = 7,
    config = {
        extra = {
            Xmult = 1,
            gain = 0.25,
        }
    },
    attributes = { 'xmult', 'breeding' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.gain } }
    end,
    calculate = function(self, card, context)
        if context.mod_probability and context.identifier == 'nursery_breeding' and to_number(context.numerator) >= 0 and not context.blueprint then
            return {
                numerator = context.numerator / 2
            }
        end

        if context.pseudorandom_result and not context.result and context.identifier == 'nursery_breeding' and not context.blueprint then
            SMODS.scale_card(card, {ref_table = card.ability.extra, ref_value = "Xmult", scalar_value = "gain"})
            if to_number(card.ability.extra.Xmult) >= 4 then
                check_for_unlock({type = 'ffingers'})
            end
        end

        if context.joker_main then
            return {
                xmult = card.ability.extra.Xmult
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}