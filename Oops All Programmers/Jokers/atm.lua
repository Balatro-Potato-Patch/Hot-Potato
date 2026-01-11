SMODS.Joker {
    key = 'atm',
    rarity = 1,
    blueprint_compat = false,
    cost = 5,
    atlas = "oap_jokers",
    pos = { x = 8, y = 1 },
    config = {
        extra = {
            money = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money, card.ability.extra.money * (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.czech or 0) } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == "Czech" then
            return {
                message = '+' .. localize('$') .. G.GAME.consumeable_usage_total.czech,
                colour = G.C.MONEY
            }
        end
    end,
    calc_dollar_bonus = function(self, card)
        local uses = (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.czech or 0)
        return to_number(uses) > 0 and (card.ability.extra.money * uses) or nil

    end,
    hotpot_credits = {
        art = { 'SadCube' },
        code = { 'theAstra' },
        idea = { 'theAstra' },
        team = { 'O!AP' }
    }
}
