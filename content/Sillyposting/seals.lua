SMODS.Atlas({key = "SillypostingSeals", path = "Sillyposting/Seals.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}):register()

SMODS.Seal {
    key = 'plincoin',
    atlas = 'SillypostingSeals',
    pos = { x = 0, y = 0 },
    config = { extra = { plincoin = 1 } },
    badge_colour = HEX('56a786'),

    -- copy pasted from gold seal (thank you N')
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            G.shared_seals[card.seal].role.draw_major = card
            G.shared_seals[card.seal]:draw_shader('dissolve', nil, nil, nil, card.children.center)
            G.shared_seals[card.seal]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center)
        end
    end,

    loc_vars = function(self, info_queue, tag)
		return { vars = {self.config.extra.plincoin} }
	end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play and G.GAME.current_round.hands_played == 0 then
            ease_plincoins(card.ability.seal.extra.plincoin)
            return {
                message = "+$"..card.ability.seal.extra.plincoin,
                colour = G.C.GREEN,
                font = SMODS.Fonts["hpot_plincoin"],
            }
        end
    end,

    ppu_artist = {'Supernova'},
    ppu_coder = {'Jaydchw'},
    ppu_team = {'Sillyposting'}
}
