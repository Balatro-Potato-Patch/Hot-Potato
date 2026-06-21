SMODS.Joker {
    key = "notajoker",
    rarity = 2,
    cost = 5,
    atlas = "hc_jokers",
    pos = {x = 5, y = 0},
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    ppu_coder = {"lord.ruby"},
    ppu_artist = {"pangaea47"},
    ppu_team = {"Horsechicot"},
}

local createcard_ref = create_card
function create_card(...)
    local card = createcard_ref(...)
    if G.STATE == G.STATES.SHOP and card.config.center.set == "Joker" and next(SMODS.find_card("j_hpot_notajoker")) then
        local c = HotPotato.get_random_consumable()
        card:set_ability(c)
    end
    return card
end

function HotPotato.get_random_consumable()
    local cards = {}
    for i, v in pairs(G.P_CENTER_POOLS.Consumeables) do
        if not v.hidden and not v.no_collection then
            cards[#cards+1] = v
        end
    end
    return pseudorandom_element(cards, pseudoseed("hpot_notajoker"))
end