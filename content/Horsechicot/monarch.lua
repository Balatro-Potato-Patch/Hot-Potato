SMODS.Consumable {
    key = 'monarch',
    set = 'Spectral',
    atlas = "hc_consumables",
    pos = { x = 1, y = 0 },
    ppu_artist = {"lord.ruby"},
    ppu_coder = {"Nxkoo"},
    ppu_team = {"Horsechicot"},
    config = { extra = { spectrals = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.spectrals } }
    end,
    use = function(self, card, area, copier)
        for i = 1, to_number(math.min(card.ability.extra.spectrals, G.consumeables.config.card_limit - #G.consumeables.cards)) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        SMODS.add_card({ set = 'Spectral' })
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit
    end
}