local old = G.FUNCS.buy_from_shop
function G.FUNCS.buy_from_shop(e)
    local card = e.config.ref_table
    local area = card.area
    local ret = old(e)
    if ret ~= false and Object.is(card, Card) then
        if area == G.market_jokers and not G.GAME.bm_bought_this_round and next(SMODS.find_card("j_hpot_roi")) then
            G.GAME.bm_bought_this_round = true
            G.E_MANAGER:add_event(Event {
                func = function()
                    ease_cryptocurrency(card.market_cost, true); return true
                end
            })
        end
    end
    return ret
end

local oldu = G.FUNCS.use_card
function G.FUNCS.use_card(e)
    local card = e.config.ref_table
    local area = card.area
    if Object.is(card, Card) then
        if area == G.market_jokers and not G.GAME.bm_bought_this_round and next(SMODS.find_card("j_hpot_roi")) then
            G.GAME.bm_bought_this_round = true
            G.E_MANAGER:add_event(Event {
                func = function()
                    ease_cryptocurrency(card.market_cost, true); return true
                end
            })
        end
    end
    local ret = oldu(e)
    return ret
end

SMODS.Joker {
    key = "roi",
    atlas = "hc_jokers",
    pos = { x = 3, y = 1 },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    ppu_coder = { "cg223" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" },
}