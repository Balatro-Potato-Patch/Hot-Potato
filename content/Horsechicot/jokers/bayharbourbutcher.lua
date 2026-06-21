SMODS.DynaTextEffect = SMODS.DynaTextEffect or function() end
SMODS.DynaTextEffect {
    key = "KILL",
    func = function(dynatext, index, letter)
        letter.scale = 1 + (math.abs(math.sin(G.TIMERS.REAL * 3 + index * 0.5)) * 0.4)
    end
} -- if you know how to make the text shakes, lmk i give up

SMODS.Joker {
    key = "bayharbourjoker",
    atlas = "hc_jokers",
    pos = { x = 2, y = 2 },
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    my_pos = i
                    break
                end
            end
            if my_pos and G.jokers.cards[my_pos + 1] and
                not SMODS.is_eternal(G.jokers.cards[my_pos + 1], card) and
                not G.jokers.cards[my_pos + 1].getting_sliced then
                local right_joker = G.jokers.cards[my_pos + 1]
                local sell_value = right_joker.sell_cost
                right_joker.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.joker_buffer = 0
                        ease_cryptocurrency(sell_value)
                        card:juice_up(0.8, 0.8)
                        SMODS.destroy_cards({ right_joker }, true)
                        play_sound('slice1', 0.96 + math.random() * 0.08)
                        return true
                    end
                }))
                return {
                    message = localize("k_hotpot_butcher_killed"),
                    colour = G.C.ORANGE,
                    no_juice = true
                }
            end
        end
    end,
    ppu_coder = { "Nxkoo" },
    ppu_artist = { "lord.ruby" },
    ppu_team = { "Horsechicot" },
}
