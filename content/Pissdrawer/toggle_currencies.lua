function G.FUNCS.toggle_currencies()
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            if not Toggle_currencies then Toggle_currencies = true else Toggle_currencies = false end
            G.HUD:remove()
            G.HUD_blind:remove()
            G.HUD, G.HUD_blind = nil, nil
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.HUD = UIBox {
                        definition = create_UIBox_HUD(),
                        config = { align = ('cli'), offset = { x = -0.7, y = 0 }, major = G.ROOM_ATTACH }
                    }
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.HUD_blind = UIBox {
                        definition = create_UIBox_HUD_blind(),
                        config = { major = G.HUD:get_UIE_by_ID('row_blind_bottom'), align = 'bmi', offset = { x = 0, y = -10 }, bond = 'Weak' }
                    }
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.hand_text_area = {
                        chips = G.HUD:get_UIE_by_ID('hand_chips'),
                        mult = G.HUD:get_UIE_by_ID('hand_mult'),
                        ante = G.HUD:get_UIE_by_ID('ante_UI_count'),
                        round = G.HUD:get_UIE_by_ID('round_UI_count'),
                        chip_total = G.HUD:get_UIE_by_ID('hand_chip_total'),
                        handname = G.HUD:get_UIE_by_ID('hand_name'),
                        hand_level = G.HUD:get_UIE_by_ID('hand_level'),
                        game_chips = G.HUD:get_UIE_by_ID('chip_UI_count'),
                        blind_chips = G.HUD_blind:get_UIE_by_ID('HUD_blind_count'),
                        blind_spacer = G.HUD:get_UIE_by_ID('blind_spacer')
                    }
                    if G.GAME.blind.in_blind then G.GAME.blind:set_blind(G.GAME.round_resets.blind) end
                    return true
                end
            }))
            return true
        end
    }))
end

local uib = UIBox.set_parent_child
function UIBox:set_parent_child(node, parent)
    if node and self then
        return uib(self, node, parent)
    end
end
