SMODS.Joker {
    key = 'mega_mushroom',
    rarity = 1,
    cost = 6,
    config = {
        extra = {
            hands_left = 3
        }
    },
    atlas = "oap_jokers",
    pos = { x = 5, y = 0 },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hands_left,
            }
        }
    end,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = false,
    attributes = { 'food', 'hand_type', 'level_up' },
    calculate = function(self, card, context)
        if context.before
            and G.GAME.current_round.hands_left == 0
            and to_number(card.ability.extra.hands_left) > 0 
        then
            if not context.blueprint then
                card.ability.extra.hands_left = card.ability.extra.hands_left - 1
            end
            return {
                level_up = 2
            }
        end
        if context.after and not context.blueprint and card.ability.extra.hands_left <= 0 then
            SMODS.destroy_cards(card, nil, nil, true)
            return {
                message = localize('k_eaten_ex'),
                colour = G.C.FILTER
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'th30ne' },
    ppu_team = { 'OAP' }
}
