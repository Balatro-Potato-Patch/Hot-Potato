SMODS.Joker { -- tried getting it working, no luck - nxkoo
    key = "shady",
    config = {
        extra = {
            bitcoins = 1,
            uses_remaining = 4,
            total_uses = 4
        }
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.bitcoins,
                card.ability.extra.uses_remaining,
                card.ability.extra.total_uses
            },
        }
    end,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    rarity = 1,
    cost = 3,
    atlas = "hc_jokers",
    ppu_artist = {"pangaea47"},
    ppu_coder = {"Nxkoo"},
    ppu_team = {"Horsechicot"},
    pos = { x = 2, y = 1 },
    attributes = { 'bitcoin', 'reroll' },
    calculate = function(self, card, context)
        if (context.reroll_shop or context.reroll_market) and not context.blueprint and to_number(card.ability.extra.uses_remaining) > 0 then
            card.ability.extra.uses_remaining = card.ability.extra.uses_remaining - 1
            if card.ability.extra.uses_remaining <= 0 then
                return {
                    message = localize('k_extinct_ex'), -- so Shady is a vegetable. ok
                    colour = G.C.RED,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                ease_cryptocurrency(1)
                                card:start_dissolve()
                                return true
                            end
                        }))
                    end
                }
            else
                return {
                    message = number_format(card.ability.extra.uses_remaining),
                    colour = G.C.ORANGE,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                ease_cryptocurrency(1)
                                return true
                            end
                        }))
                    end
                }
            end
        end
    end
}