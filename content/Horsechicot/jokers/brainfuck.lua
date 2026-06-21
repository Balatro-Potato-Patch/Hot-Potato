SMODS.Joker {
    ppu_artist = { "Pangaea" },
    ppu_coder = { 'cg223' },
    ppu_team = { 'Horsechicot' },
    key = "brainfuck",
    rarity = 3,
    cost = 7,
    atlas = "hc_jokers",
    pos = { x = 4, y = 1 },
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            local cards = context.scoring_hand
            local last = -math.huge
            local should_trigger = #cards >= 5
            if should_trigger then
                --classic straight check
                ---@diagnostic disable-next-line: param-type-mismatch
                for _, card in ipairs(cards) do
                    local id = card:get_id() --
                    if id < last then
                        should_trigger = false
                        break
                    else
                        last = id
                    end
                end
            end
            --make luchador
            if should_trigger then
                return {
                    message = localize("k_hotpot_added"),
                    func = function()
                        G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                        G.E_MANAGER:add_event(Event {
                            func = function()
                                SMODS.add_card { key = "j_luchador" }
                                G.GAME.joker_buffer = 0
                                return true
                            end
                        })
                        delay(0.3)
                    end
                }
            end
        end
    end
}
