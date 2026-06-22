SMODS.Joker {
    key = "jade",
    config = { extra = { coins = 4 } },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.coins } }
    end,
    rarity = 3,
    cost = 10,
    pos = { x = 2, y = 0 },
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'SillypostingJokers',
    --[[calculate = function (self, card, context)
        if context.pk_cashout_row then
            local new_config = context.pk_cashout_row
            if new_config.name == "bottom" then --i would like to add a new row but perkeocoin left literally no information on how that works
                new_config.dollars = new_config.dollars + card.ability.extra.coins
            end]
            add_round_eval_plincoins({ name='plincoins', plincoins = card.ability.extra.coins })
        end
    end,]]--
    attributes = { 'economy', 'plincoin' },
    calc_plincoin_bonus = function(self, card)
        return card.ability.extra.coins
    end,
    
    ppu_artist = {"Jaydchw"},
    ppu_coder = {"UnusedParadox"},
    ppu_team = {"Sillyposting"}
}