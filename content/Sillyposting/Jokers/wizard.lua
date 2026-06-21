SMODS.Atlas({ key = "SillypostingJokers", path = "Sillyposting/Jokers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }):register()

SMODS.Joker {
    key = "wizard_tower",
    blueprint_compat = false,
    rarity = 3,
    cost = 10,
    discovered = true,
    atlas = "SillypostingJokers",
    pos = { x = 0, y = 0 },
    config = { extra = { bonus_highlight = 1 } },
    loc_vars = function (self, info_queue, card)
        local key = self.key
        local append = (card.ability.extra.bonus_highlight == math.floor(card.ability.extra.bonus_highlight)) and "" or "_rounded"
        return { vars = { card.ability.extra.bonus_highlight }, key = key..append }
    end,
    add_to_deck = function (self, card, from_debuff)
        change_max_highlight(card.ability.extra.bonus_highlight)
    end,
    remove_from_deck = function (self, card, from_debuff)
        change_max_highlight(-card.ability.extra.bonus_highlight)
    end,
    ppu_artist = {"Jaydchw"},
    ppu_coder = {"Eris, UnusedParadox"},
    ppu_team = {"Sillyposting"}
}