SMODS.Joker {
    key = 'trolley_operator',
    rarity = 3,
    blueprint_compat = false,
    cost = 8,
    atlas = "oap_jokers",
    pos = { x = 7, y = 1 },
    config = {
        extra = {
            money = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,
    calculate = function(self, card, context)
        if context.before and #G.hand.cards == 5 and not context.blueprint then
            local chosen_card = pseudorandom_element(G.hand.cards)
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.destroy_cards({ chosen_card }) -- again, no eternal check
                    return true;
                end
            }))
            return {
                dollars = card.ability.extra.money
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}