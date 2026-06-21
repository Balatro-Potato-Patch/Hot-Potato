SMODS.Joker {
    key = 'wumpus',
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    cost = 4,
    atlas = "oap_jokers",
    pos = { x = 4, y = 1 },
    config = {
        extra = {
            money = 5,
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {  card.ability.extra.money } }
    end,
    calculate = function(self, card, context)
        if context.joker_type_destroyed and context.card ~= card and context.card.config.center_key ~= 'j_hpot_wumpus' and not context.blueprint then
            return {
                no_destroy = true,
                dollars = card.ability.extra.money,
                func = function()
                    SMODS.destroy_cards({ card })
                end
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}