SMODS.Joker {
    key = "balatro_free_smods_download_2025",
    rarity = 2,
    cost = 5,
    atlas = "hc_jokers",
    pos = { x = 6, y = 2 },
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card and not context.blueprint then
            card.ability.extra_value = card.ability.extra_value + context.card.sell_cost
            card:set_cost()
            return {
                message = localize("k_val_up"),
                colour = G.C.MONEY
            }
        end
    end,
    ppu_coder = { "Lily Felli" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" }
}

-- this is very easy but i spent 30 minutes confused about lsp stuff not working
--.... i spelt it smdos instead of smods.

-- dumbass bitch -nxkoo