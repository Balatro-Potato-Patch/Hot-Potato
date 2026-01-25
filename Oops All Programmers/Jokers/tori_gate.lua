SMODS.Joker {
    key = 'tori_gate',
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    atlas = "oap_jokers",
    pos = { x = 6, y = 1 },
    config = {
        extra = {
            chips = 20,
            joy_hanafuda_count = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chips * ((G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.hanafuda or 0) + card.ability.extra.joy_hanafuda_count) } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == "Hanafuda" then
            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips * G.GAME.consumeable_usage_total.hanafuda } },
                colour = G.C.CHIPS
            }
        end
        if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, "m_joy_hanafuda") then
            card.ability.extra.joy_hanafuda_count = card.ability.extra.joy_hanafuda_count + 1
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips *
                    ((G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.hanafuda or 0) + card.ability.extra.joy_hanafuda_count)
            }
        end
    end,
    hotpot_credits = {
        art = { 'th30ne' },
        code = { 'theAstra' },
        idea = { 'theAstra' },
        team = { 'O!AP' }
    }
}
