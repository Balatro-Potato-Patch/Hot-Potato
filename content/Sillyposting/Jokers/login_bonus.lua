-- this is so incredibly awful
-- realistically there's a better way to do this but i'm programming very late at night so whatever
SMODS.Joker {
    key = "login_bonus",
    config = {extra = {rounds_reset = 3, current_cycle = 0, rewards = {
        [0] = {plincoins = 2, dollars = 3}, -- Also last reward. Maybe not though? Who knows
        {plincoins = 0, dollars = 1},
        {plincoins = 0, dollars = 2},
        {plincoins = 2, dollars = 3}
    }}},
    loc_vars = function(self, info_queue, card)
        local cycle = card.ability.extra.current_cycle + 1
        local vars = { [7] = card.ability.extra.rounds_reset, [8] = cycle,
        [9] = card.ability.extra.rewards[cycle].plincoins, [10] = card.ability.extra.rewards[cycle].dollars}
        for i, v in ipairs(card.ability.extra.rewards) do
            vars[(2*i) - 1] = v.plincoins
            vars[2*i] = v.dollars
        end
        return { vars = vars }
    end,
    rarity = 1,
    cost = 5,
    pos = { x = 5, y = 0 },
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'SillypostingJokers',
    attributes = { 'plincoins', 'economy' },
    calc_plincoin_bonus = function(self, card)
        local cycle = card.ability.extra.current_cycle
        if to_number(card.ability.extra.rewards[cycle].plincoins) > 0 then return card.ability.extra.rewards[cycle].plincoins else return nil end
    end,
    calc_dollar_bonus = function(self, card)
        local cycle = card.ability.extra.current_cycle
        if to_number(card.ability.extra.rewards[cycle].dollars) > 0 then return card.ability.extra.rewards[cycle].dollars else return nil end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.current_cycle = card.ability.extra.current_cycle + 1
            if card.ability.extra.current_cycle >= card.ability.extra.rounds_reset then
                card.ability.extra.current_cycle = 0
            end
        end
    end,
    
    ppu_artist = {"Jaydchw"},
    ppu_coder = {"UnusedParadox"},
    ppu_team = {"Sillyposting"}
}