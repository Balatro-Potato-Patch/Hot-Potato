SMODS.Joker {
    key = 'pump_and_dump',
    rarity = 2,
    cost = 7,
    config = {
        extra = {
            crypto = 2,
            odds = 6
        }
    },
    atlas = "oap_jokers",
    pos = { x = 7, y = 0 },
    blueprint_compat = false,
    attributes = { 'bitcoin', 'economy', },
    loc_vars = function(self, info_queue, card)
        local new_numerator, new_denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds,
            'hpot_pump_and_dump')
        return {
            vars = {
                card.ability.extra.crypto,
                new_numerator,
                new_denominator
            }
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round
            and context.game_over == false
            and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'hpot_pump_and_dump', 1, card.ability.extra.odds) then
                ease_cryptocurrency(-G.GAME.cryptocurrency)
            else
                ease_cryptocurrency(card.ability.extra.crypto)
            end
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'th30ne' },
    ppu_team = { 'OAP' }
}
