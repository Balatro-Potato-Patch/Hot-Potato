SMODS.Joker {
    key = "timelapse",
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = "hc_jokers",
    pos = {x = 6, y = 1},
    attributes = { 'copying', 'joker' },
    calculate = function(self, card, context)
        local jokers = {}
        for i, v in pairs(G.jokers.cards) do
            if v ~= card then jokers[#jokers+1] = v end
        end
        table.sort(jokers, function(a, b)
            return a.ability.timelapse_order < b.ability.timelapse_order
        end)
        return SMODS.merge_effects({
            jokers[#jokers] and jokers[1] ~= jokers[#jokers] and SMODS.blueprint_effect(card, jokers[#jokers], context) or {},
            jokers[1] and SMODS.blueprint_effect(card, jokers[1], context) or {}
        })
    end,
    loc_vars = function(self, q, card)
        local jokers = {}
        if G.jokers then
            for i, v in pairs(G.jokers.cards) do
                if v ~= card then jokers[#jokers+1] = v end
            end
            table.sort(jokers, function(a, b)
                return a.ability.timelapse_order < b.ability.timelapse_order
            end)
        end
        local other_joker = G.jokers and jokers[1] ~= jokers[#jokers] and jokers[#jokers]
        local other_joker2 = G.jokers and jokers[1]
        local compatible = other_joker and other_joker ~= card and (other_joker.config.center.blueprint_compat or 
                        (other_joker.ability.quantum_1 and other_joker.ability.quantum_1.config.center.blueprint_compat) or 
                        (other_joker.ability.quantum_2 and other_joker.ability.quantum_2.config.center.blueprint_compat))
        local compatible2 = other_joker2 and other_joker2 ~= card and (other_joker2.config.center.blueprint_compat or 
                        (other_joker2.ability.quantum_1 and other_joker2.ability.quantum_1.config.center.blueprint_compat) or 
                        (other_joker2.ability.quantum_2 and other_joker2.ability.quantum_2.config.center.blueprint_compat))
        local none = not jokers[1]
        local main_end = {
            {
                n = G.UIT.C,
                config = { align = "bm", minh = 0.4 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            ref_table = card,
                            align = "m",
                            colour = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8)
                                or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8),
                            r = 0.05,
                            padding = 0.06,
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = " "
                                        .. ((compatible and localize{type = "name_text", set = other_joker.config.center.set, key = other_joker.config.center_key}) or ((none or not other_joker) and localize("k_none")) or localize{type = "name_text", set = other_joker.config.center.set, key = other_joker.config.center_key})
                                        .. " ",
                                    colour = G.C.UI.TEXT_LIGHT,
                                    scale = 0.32 * 0.8,
                                },
                            },
                        },
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            minw = 0.1,
                            align = "m",
                            r = 0.05,
                            padding = 0.06,
                        },
                        nodes = {
    
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            ref_table = card,
                            align = "m",
                            colour = compatible2 and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8)
                                or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8),
                            r = 0.05,
                            padding = 0.06,
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = " "
                                        .. ((compatible2 and localize{type = "name_text", set = other_joker2.config.center.set, key = other_joker2.config.center_key}) or ((none or not other_joker2) and localize("k_none")) or localize{type = "name_text", set = other_joker2.config.center.set, key = other_joker2.config.center_key})
                                        .. " ",
                                    colour = G.C.UI.TEXT_LIGHT,
                                    scale = 0.32 * 0.8,
                                },
                            },
                        },
                    },
                },
            },
        }
        return {
            main_end = main_end
        }
    end,
    ppu_coder = { "lord.ruby" },
    ppu_artist = { "lord.ruby" },
    ppu_team = { "Horsechicot" },
}

local emplace_ref = CardArea.emplace
function CardArea:emplace(card, ...)
    emplace_ref(self, card, ...)
    if self == G.jokers then
        G.GAME.timelapse_order = (G.GAME.timelapse_order or 0) + 1
        card.ability.timelapse_order = G.GAME.timelapse_order
    end
end