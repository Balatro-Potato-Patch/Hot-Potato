SMODS.Joker {
    key = "magic_factory",
    blueprint_compat = false,
    rarity = 2,
    cost = 6,
    discovered = true,
    atlas = "SillypostingJokers",
    pos = { x = 6, y = 0 },
    config = { extra = { bonus_highlight = -1, consumable_req = 2 } },
    attributes = { 'generation', 'modify_card' },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.consumable_req, math.abs(card.ability.extra.bonus_highlight) } }
    end,
    add_to_deck = function (self, card, from_debuff)
        change_max_highlight(card.ability.extra.bonus_highlight)
    end,
    remove_from_deck = function (self, card, from_debuff)
        change_max_highlight(-card.ability.extra.bonus_highlight)
    end,
    calculate = function(self, card, context) -- Everyone say thank you N for vanillaremade perkeo
        if context.setting_blind and #G.consumeables.cards + G.GAME.consumeable_buffer <= G.consumeables.config.card_limit and not context.blueprint then
            local can_create = true
            for _, v in ipairs(G.consumeables.cards) do
                if v.edition and v.edition.key == "e_negative" then
                    can_create = false
                end
            end
            if can_create then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
			            local allcons = {}
			            for k, _ in pairs(SMODS.ConsumableTypes) do
		            		table.insert(allcons, k)
			            end
			            local sett = pseudorandom_element(allcons)
		            	SMODS.add_card({
		            		set = sett,
                            edition = "e_negative"
		            	})
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
                return {message = localize("k_duplicated_ex")}
            end
        end
    end,
    
    ppu_artist = {"Jaydchw"},
    ppu_coder = {"UnusedParadox"},
    ppu_team = {"Sillyposting"}
}