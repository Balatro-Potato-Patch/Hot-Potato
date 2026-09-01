SMODS.Joker{
    key = "cloverpit",
    atlas = "hc_jokers",
    pos = { x = 5, y = 4 },
    rarity = 2,
    blueprint_compat = false,
    cost = 10,
    config = {
        extra = {
            odds = 6
        }
    },
    attributes = { 'chance', 'economy' },
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'hpot_cloverpit', 1, card.ability.extra.odds) then
                if G.GAME.dollars_ante and to_big(G.GAME.dollars_ante) > to_big(0) then
                    G.E_MANAGER:add_event(Event{
                        func = function()
                            ease_dollars(-(G.GAME.dollars_ante or 0))
                            G.GAME.dollars_ante = 0
                            return true
                        end
                    })
                end
            else
                if to_big(G.GAME.hands[context.scoring_name].mult) > to_big(0) then
                    G.E_MANAGER:add_event(Event{
                        func = function()
                            ease_dollars(G.GAME.hands[context.scoring_name].mult)
                            return true
                        end
                    })
                end
            end
        end
    end,
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hpot_cloverpit")
        return { vars = { numerator, denominator } }
    end,
    ppu_artist = {"pangaea47"},
    ppu_coder = {"lord.ruby"},
    ppu_team = {"Horsechicot"},
}

local ease_ref = ease_dollars
function ease_dollars(mod, ...)
    ease_ref(mod, ...)
    if to_big(mod) > to_big(0) then
        G.GAME.dollars_ante = (G.GAME.dollars_ante or 0) + mod
    end
end