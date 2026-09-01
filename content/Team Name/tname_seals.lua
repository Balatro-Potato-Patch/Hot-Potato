SMODS.Seal {
    key = 'hanafuda',
    atlas = 'tname_seals',
    pos = { x = 0, y = 0 },
    config = { extra = { cards = 1 } },
    badge_colour = HEX('800058'),

    calculate = function(self, card, context)
        if context.main_scoring and (context.cardarea == G.play or context.cardarea == "unscored") then
            if G.consumeables.config.card_limit > #G.consumeables.cards + G.GAME.consumeable_buffer then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.add_card {
                            set = "Hanafuda"
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))
            else
                card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_no_room_ex") })
            end
        end
    end,

    
        ppu_artist = { 'Revo' },
        ppu_coder = { 'Revo' },
        idea = { 'Revo' },
	ppu_team = { "Team Name" },
}
