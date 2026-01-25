SMODS.Joker {
    key = "sonloaf",
    atlas = "oap_jokers",
    pos = { x = 3, y = 2 },
    rarity = 1,
    blueprint_compat = false,
    hotpot_credits = {
        art = { 'Omegaflowey18' },
        code = { 'factwixard' },
        idea = { 'theAstra' },
        team = { 'O!AP' }
    },
    calculate = function(self, card, context)
        if context.joker_type_destroyed and context.card.config.center.pools and context.card.config.center.pools.Food and G.jokers.config.card_limit > #G.jokers.cards + G.GAME.joker_buffer then
            G.GAME.joker_buffer = G.GAME.joker_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.add_card {
                        set = 'Food',
                        key_append = "sonloaf"
                    }
                    G.GAME.joker_buffer = 0
                    return true
                end
            }))
        end
    end
}
