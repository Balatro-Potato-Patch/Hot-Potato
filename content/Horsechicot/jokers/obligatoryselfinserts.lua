SMODS.Atlas {
    key = "selfinserts",
    path = "Horsechicot/selfinserts.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "selfinserting",
    rarity = 3,
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    atlas = "selfinserts",
    pos = { x = 0, y = 0 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_per_self_insert } }
    end,
    config = {
        extra = {
            xmult_per_self_insert = 2.5,
        }
    },
    attributes = { 'xmult' },
    calculate = function(self, card, context)
        if context.other_joker then
            local pools = context.other_joker.config.center.pools or {}
            if pools.self_inserts then
                return { xmult = card.ability.extra.xmult_per_self_insert }
            end
        end
    end,
    ppu_artist = { "Haya" },
    ppu_coder = { "theAstra" },
    ppu_team = { "Horsechicot" },
}

SMODS.ObjectType {
    key = 'self_inserts',
    default = 'j_hpot_apocalypse',
    cards = {
        j_hpot_apocalypse = true,
        j_hpot_jtem_flash = true,
        j_hpot_OAP = true,
        j_hpot_tname_postcard = true,
    },
}
