SMODS.Joker {
    key = 'art_of_the_deal',
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    atlas = "oap_jokers",
    pos = { x = 2, y = 0 },
    attributes = { 'generation', 'czechs' },
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers and not context.game_over and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.add_card({set = 'Czech', key_append = 'AofD'})
                    card:juice_up(0.3,0.5)
                    G.GAME.consumeable_buffer = 0
                    return true;
                end
            }))
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}