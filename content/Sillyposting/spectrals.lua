SMODS.Atlas({key = "SillypostingSpectrals", path = "Sillyposting/Spectrals.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}):register()

-- Arcade Machine
SMODS.Consumable {
    key = 'arcade_machine',
    set = 'Spectral',
    pos = { x = 0, y = 0 },
    atlas = 'SillypostingSpectrals',
    config = { extra = { seal = 'hpot_plincoin' }, max_highlighted = 1 },
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local key = self.key
        if card.ability.max_highlighted > 1 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { key = key, vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for _, i in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function() 
                    i:set_seal(card.ability.extra.seal, nil, true)
                    return true
                end
            }))
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,

    ppu_artist = {'Jaydchw', 'Supernova'},
    ppu_coder = {'Jaydchw'},
    ppu_team = {'Sillyposting'}
}
