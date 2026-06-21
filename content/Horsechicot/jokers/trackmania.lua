SMODS.Joker {
    key = "hc_trackmania",
    config = {
        elapsed = 0,
        def_xmult = 4,
        dec_per_sec = 0.01,
    },
    rarity = 3,
    cost = 6,
    atlas = "hc_jokers",
    pos = { x = 6, y = 4 },
    soul_pos = { x = 7, y = 4 },
    loc_vars = function(self, info_queue, card)
        local t_since_ante = card.ability.elapsed
        local xmult = card.ability.def_xmult - (t_since_ante * card.ability.dec_per_sec)
        xmult = math.max(xmult, 1)
        xmult = math.floor(xmult * 10) / 10
        return {
            vars = {
                card.ability.def_xmult,
                card.ability.dec_per_sec,
                xmult
            }
        }
    end,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            local t_since_ante = card.ability.elapsed
            local xmult = card.ability.def_xmult - (t_since_ante * card.ability.dec_per_sec)
            xmult = math.max(xmult, 1)
            xmult = math.floor(xmult * 10) / 10
            return { xmult = xmult }
        elseif context.beat_boss then
            card.ability.elapsed = 0
        end
    end,
    update = function (self, card, dt)
        if (card.area or (card.quantum and card.quantum.area)) == G.jokers then
            card.ability.elapsed = (card.ability.elapsed or 0) + dt
        end
    end,
    ppu_coder = { "cg223" },
    ppu_artist = { "cg223" },
    ppu_team = { "Horsechicot" }
}
