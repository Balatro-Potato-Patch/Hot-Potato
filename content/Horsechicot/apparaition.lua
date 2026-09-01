SMODS.Consumable {
    key = 'apparition',
    set = 'Spectral',
    pos = { x = 0, y = 0 },
    atlas = 'hc_consumables',
    discovered = true,
    loc_vars = function(self, info_queue, card)
        if not card.edition or not card.edition.hpot_phantasmic then
            info_queue[#info_queue + 1] = G.P_CENTERS.e_hpot_phantasmic
        end
    end,
    use = function(self, card, area, copier)
        local viable_cards = {}
        for _,_c in ipairs(G.consumeables.cards) do -- basically filterings
            if not (_c.edition and _c.edition.key) and _c ~= card then
                table.insert(viable_cards, _c)
            end
        end
        local card = pseudorandom_element(viable_cards, pseudoseed("apparition"))
        if card then
            card:set_edition("e_hpot_phantasmic")
        end
    end,
    can_use = function(self, card)
        if not (G.consumeables and #G.consumeables.cards > 0) then
            return false
        end
        -- if some of cards in consumables slot don't have edition then you can use it...
        for _,_c in ipairs(G.consumeables.cards) do
            if not (_c.edition and _c.edition.key) and _c ~= card then -- check if it is not itself too
                return true
            end
        end
        -- ...otherwise you can't use it (duh)
        return false
    end,
    ppu_artist = {'lord.ruby'},
    ppu_coder = {'lord.ruby'},
    ppu_team = {'Horsechicot'}
}