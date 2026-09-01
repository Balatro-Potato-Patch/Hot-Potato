local old_draw = G.FUNCS.draw_from_play_to_discard
G.FUNCS.draw_from_play_to_discard = function(e)
    if G.GAME.rescore and to_number(G.GAME.rescore) > 0 and (G.STATE == 1 or G.STATE == 2) then
        G.GAME.rescore = G.GAME.rescore - 1

        G.GAME.rescoring = true
        local cards = {}

        for _,c in pairs(G.play.cards) do
            cards[#cards+1] = c
        end

        G.FUNCS.draw_from_play_to_hand(cards)

        G.E_MANAGER:add_event(Event {
            func = function()
                G.E_MANAGER:add_event(Event {
                    func = function()
                        for _, card in pairs(cards) do
                            card:highlight(true)
                            card.area:add_to_highlighted(card)
                        end
                        return true
                    end,
                    trigger = "after",
                    
                })

                G.E_MANAGER:add_event(Event {
                    func = function()
                        G.FUNCS.play_cards_from_highlighted({ ref_table = {} })
                        return true
                    end,
                    trigger = "after",
                    delay = 0.5,
                })

                G.E_MANAGER:add_event(Event {
                    func = function()
                        G.GAME.rescoring = false
                        if G.GAME.rescore <= 0 then
                            G.FUNCS.draw_from_deck_to_hand()
                        end
                        return true
                    end,
                    trigger = "after",
                    delay = 0.1,
                })
                return true
            end,
            trigger = "after",
            delay = 0.5,
        })
    else
        old_draw(e)
    end
end

local oldhand = ease_hands_played
function ease_hands_played(...)
    if not (G.GAME.rescoring) then
        oldhand(...)
    end
end