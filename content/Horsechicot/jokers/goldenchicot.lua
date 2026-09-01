local function create_boss_bounty_system() -- i give up
    local original_Blind_disable = Blind.disable
    function Blind:disable(...)
        local was_boss = self.boss
        local was_disabled = self.disabled
        local result = original_Blind_disable(self, ...)
        if was_boss and not was_disabled and self.disabled then
            if G.jokers and G.jokers.cards then
                for _, card in ipairs(G.jokers.cards) do
                    if card.config and card.config.center and card.config.center.key == "j_hpot_goldenchicot" then
                        local custom_context = {
                            type = "boss_blind_disabled",
                            blind = self,
                            card = card,
                            blueprint = false
                        }
                        local joker_effect = card.config.center.calculate(card.config.center, card, custom_context)
                        if joker_effect then
                            if joker_effect.dollars then
                                message = localize("k_upgrade_ex")
                                card:juice_up(0.8, 0.8)
                                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + joker_effect.dollars
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        ease_dollars(card.ability.extra.disabled_bosses * card.ability.extra.dollars_per_boss)
                                        G.GAME.dollar_buffer = 0
                                        return true
                                    end
                                }))
                            end
                        end
                    end
                end
            end
        end
        return result
    end
end

create_boss_bounty_system()

SMODS.Joker {
    key = "goldenchicot",
    atlas = "hc_jokers",
    pos = { x = 6, y = 3 },
    ppu_artist = {"lord.ruby"},
    ppu_coder = {"Nxkoo"},
    ppu_team = {"Horsechicot"},
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    cost = 8,
    config = {
        extra = {
            disabled_bosses = 0,
            dollars_per_boss = 4,
            cunt = 1
        }
    },
    attributes = { 'economy', 'boss_blind', 'scaling' },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.dollars_per_boss,
                card.ability.extra.disabled_bosses,
                card.ability.extra.disabled_bosses * card.ability.extra.dollars_per_boss
            }
        }
    end,
    calculate = function(self, card, context)
        if context.type == "boss_blind_disabled" and not context.blueprint then
            SMODS.scale_card(card, {
	            ref_table = card.ability.extra,
                ref_value = "disabled_bosses",
	            scalar_value = "cunt",
    })
        end
    end,
    calc_dollar_bonus = function(self, card)
        return to_number(card.ability.extra.disabled_bosses) > 0 and (card.ability.extra.disabled_bosses * card.ability.extra.dollars_per_boss) or nil
    end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.disabled_bosses = card.ability.extra.disabled_bosses or 0
    end
}
