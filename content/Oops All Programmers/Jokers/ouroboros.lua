SMODS.Joker {
    key = 'ouroboros',
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    cost = 8,
    config = {
        extra = {
            Xmult = 1,
            gain = 1 / 3
        }
    },
    atlas = "oap_jokers",
    pos = { x = 3, y = 0 },
    attributes = { 'xmult', 'destroy_card' },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.card_added and context.card.ability.set == 'Joker' and #G.jokers.cards >= G.jokers.config.card_limit and not (context.card.ability.card_limit and context.card.ability.card_limit >= 1) and not context.blueprint then
            local eligible_cards = {}

            for k, v in pairs(G.jokers.cards) do
                if v ~= card and v ~= context.card and not SMODS.is_eternal(v, card) then
                    eligible_cards[#eligible_cards + 1] = v
                end
            end

            if next(eligible_cards) then
                local destroy_card = pseudorandom_element(eligible_cards)
                SMODS.destroy_cards({ destroy_card })

                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = 'Xmult',
                    scalar_value = 'gain',
                    message_colour = G.C.MULT
                })
            else
                SMODS.destroy_cards({ card }, true)
            end
        end

        if context.joker_main and to_big(card.ability.extra.Xmult) > to_big(1) then
            return {
                xmult = card.ability.extra.Xmult
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}

local cfbs = G.FUNCS.check_for_buy_space
G.FUNCS.check_for_buy_space = function(card)
    if next(SMODS.find_card('j_hpot_ouroboros')) and card.ability.set == 'Joker' then
        return true
    end
    return cfbs(card)
end

local csfb = G.FUNCS.can_select_from_booster
G.FUNCS.can_select_from_booster = function(e)
    csfb(e)
    if next(SMODS.find_card('j_hpot_ouroboros')) and e.config.ref_table.ability.set == 'Joker' then
        e.config.colour = G.C.GREEN
        e.config.button = 'use_card'
    end
end