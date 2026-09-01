SMODS.Joker {
    key = "sonloaf",
    atlas = "oap_jokers",
    pos = { x = 3, y = 2 },
    rarity = 1,
    blueprint_compat = false,
    ppu_artist = { 'Omegaflowey18' },
    ppu_coder = { 'factwixard' },
    ppu_team = { 'OAP' },
    attributes = { 'generation' },
    calculate = function(self, card, context)
        if context.joker_type_destroyed and context.card:has_attribute('food') and G.jokers.config.card_limit > #G.jokers.cards + G.GAME.joker_buffer then
            G.GAME.joker_buffer = G.GAME.joker_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.add_card {
                        attribute = 'food',
                        key_append = "sonloaf"
                    }
                    G.GAME.joker_buffer = 0
                    return true
                end
            }))
        end
    end
}
