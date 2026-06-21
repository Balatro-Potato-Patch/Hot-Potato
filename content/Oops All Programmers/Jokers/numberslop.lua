SMODS.Joker {
    key = 'numberslop',
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    cost = 5,
    atlas = "oap_jokers",
    pos = { x = 3, y = 1 },
    config = {
        extra = {
            Xmult = 2,
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {  card.ability.extra.Xmult } }
    end,
    pools = { Food = true },
    calculate = function(self, card, context)
        if context.after and to_big(G.GAME.blind.chips * 2) < to_big(SMODS.calculate_round_score()) and not context.blueprint then
            SMODS.destroy_cards(card, nil, nil, true)
            return {
                message = localize('k_oap_too_much_slop')
            }
        end

        if context.individual and context.cardarea == G.play and not (context.other_card:is_face() or context.other_card:get_id() == 14) then
            return {
                xmult = card.ability.extra.Xmult
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}