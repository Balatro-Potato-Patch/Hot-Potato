SMODS.Joker {
    key = "thetruehotpotato",
    config = {
        extra = {
            mult_gain = 8,
            total_mult = 0,
            used_positions = {}
        }
    },
    atlas = "hc_jokers",
    pos = {x = 5, y = 1},
    loc_vars = function(self, info_queue, card)
        local main_end = nil
        if card.area and card.area == G.jokers then
            local current_position = nil
            local position_already_used = false
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    current_position = i
                    for _, pos in ipairs(card.ability.extra.used_positions) do
                        if pos == current_position then
                            position_already_used = true
                            break
                        end
                    end
                    break
                end
            end
            local is_active = current_position and not position_already_used
            local max_positions = G.jokers and #G.jokers.cards or 5
            local positions_remaining = max_positions - #card.ability.extra.used_positions
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.4 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                ref_table = card,
                                align = "m",
                                colour = is_active and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or
                                mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8),
                                r = 0.05,
                                padding = 0.06
                            },
                            nodes = {
                                {
                                    n = G.UIT.T,
                                    config = {
                                        text = ' ' .. localize(is_active and 'k_active' or 'k_inactive') .. ' ',
                                        colour = G.C.UI.TEXT_LIGHT,
                                        scale = 0.32 * 0.8
                                    }
                                },
                            }
                        }
                    }
                },
            }
        end

        return {
            vars = {
                card.ability.extra.mult_gain,
                card.ability.extra.total_mult,
                #card.ability.extra.used_positions,
                G.jokers and #G.jokers.cards or 5
            },
            main_end = main_end
        }
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    attributes = { 'food', 'mult', 'scaling', 'reset' },
    rarity = 2,
    cost = 6,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and not context.blueprint then
            local current_position = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    current_position = i
                    break
                end
            end
            if current_position then
                local position_already_used = false
                for _, pos in ipairs(card.ability.extra.used_positions) do
                    if pos == current_position then
                        position_already_used = true
                        break
                    end
                end
                if not position_already_used then
                    local max_positions = G.jokers and #G.jokers.cards or 5
                    table.insert(card.ability.extra.used_positions, current_position)
                    SMODS.scale_card(card, {
                        ref_table = card.ability.extra,
                        ref_value = "total_mult",
                        scalar_value = "mult_gain",
                        scaling_message = {
                            message = #card.ability.extra.used_positions >= max_positions and localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult_gain } } ..
                            ' ' .. localize('k_reset') or localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult_gain } },
                            colour = G.C.MULT
                        }
                    })
                    check_for_unlock({ type = "this_writing_is_fire", conditions = #card.ability.extra.used_positions or 0})
                end
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.total_mult
            }
        end
    end,
    ppu_coder = { "Nxkoo" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" },
}
