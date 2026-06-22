SMODS.Joker {
    key = "slop",
    config = { extra = { xmult = 2 } },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    atlas = "TeamNameAnims1",
    pos = { x = 7, y = 4 },
    hpot_anim = {
        { xrange = { first = 7, last = 9 }, y = 4, t = 0.1 },
        { xrange = { first = 7, last = 11 }, y = 5, t = 0.1 }
    },
    pos_extra = { x = 0, y = 5 },
    hpot_anim_extra = {
        { x = 0, y = 5, t = 0.075 },
        { x = 1, y = 5, t = 0.125 },
        { x = 2, y = 5, t = 0.175 },
        { x = 3, y = 5, t = 0.3 },
        { x = 2, y = 5, t = 0.175 },
        { x = 1, y = 5, t = 0.125 },
        { x = 0, y = 5, t = 0.075 },
        { x = 4, y = 5, t = 0.125 },
        { x = 5, y = 5, t = 0.175 },
        { x = 6, y = 5, t = 0.3 },
        { x = 5, y = 5, t = 0.175 },
        { x = 4, y = 5, t = 0.125 }
    },
    rarity = 1,
    cost = 4,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    attributes = { 'xmult', 'food', 'ads' },
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.close_ad and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound("tarot1")
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.3,
                        blockable = false,
                        func = function()
                            card:remove()
                            return true
                        end
                    }))
                    return true
                end
            }))
            return {
                message = localize("k_eaten_ex")
            }
        end
    end,
    in_pool = function (self, args)
        return G.GAME.pool_flags.tv_dinner_eaten
    end,
    ppu_artist = { 'UnusedParadox, Jaydchw' },
    ppu_coder = { 'Eris' },
    ppu_team = { 'Sillyposting' },
}