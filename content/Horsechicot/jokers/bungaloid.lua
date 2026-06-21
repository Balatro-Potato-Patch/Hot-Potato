SMODS.Joker {
    key = "bungaloid",
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    rarity = 3,
    cost = 6,
    atlas = "hc_jokers",
    pos = { x = 1, y = 4 },
    ppu_artist = {"pangaea47"},
    ppu_coder = {"Nxkoo"},
    ppu_team = {"Horsechicot"},
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = { localize('Full House', 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands['Full House']) then
            local hot_potato_cards = {}
            for i, v in pairs(G.P_CENTER_POOLS.Joker) do
                if v.original_mod and v.original_mod.id == HotPotato.id and v.rarity ~= 4 then
                    hot_potato_cards[#hot_potato_cards + 1] = v
                end
            end
            if #hot_potato_cards > 0 and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                return {
                    message = localize('k_plus_joker'),
                    colour = G.C.BLUE,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local selected_card = pseudorandom_element(hot_potato_cards, 'selfglazing')
                                SMODS.add_card {
                                    set = 'Joker',
                                    key = selected_card.key,
                                    key_append = 'baked_potato'
                                }
                                G.GAME.joker_buffer = 0
                                return true
                            end
                        }))
                    end
                }
            elseif #hot_potato_cards == 0 then
                return { message = localize("k_hotpot_how"), colour = G.C.RED }
            end
        end
    end
}
