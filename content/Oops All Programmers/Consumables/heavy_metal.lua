SMODS.Consumable {
    key = 'heavy_metal',
    set = 'Tarot',
    pos = { x = 0, y = 0 },
    atlas = "oap_tarots",
    config = { max_highlighted = 2, mod_conv = 'm_hpot_oap_lead' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    ppu_artist = { 'SadCube' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}