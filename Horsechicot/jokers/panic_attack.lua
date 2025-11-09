SMODS.Joker {
    hotpot_credits = Horsechicot.credit('lord.ruby', 'pangaea47', 'pangaea47'),
    key = "panic_attack",
    cost = 5,
    rarity = 2,
    atlas = "hc_jokers",
    pos = { x = 0, y = 3 },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = {
            xmult = 3,
            xmult_base = 3,
            xmult_mod = 0.1
        }
    },
    calculate = function(self, card, context)
        if (context.end_of_round and not context.blueprint and not context.individual and G.GAME.blind_on_deck == "Boss" and not context.repetition) then
            card.ability.extra.xmult = card.ability.extra.xmult_base
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.before then
            G.GAME.scoring = true
        end
        if context.after then
            G.E_MANAGER:add_event(Event{
                trigger = "after",
                func = function()
                    G.GAME.scoring = nil
                    return true
                end
            })
        end
    end,
    this_function_runs_every_fucking_second = function(self, card)
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult - card.ability.extra.xmult_mod)
    end,
    loc_vars = function(self, q, card)
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.xmult_mod,
                card.ability.extra.xmult_base
            }
        }
    end
}

local this_dt_is_updated_every_fucking_frame = 0
local update_ref = Game.update
function Game:update(dt)
    update_ref(self, dt)
    if G.jokers and G.GAME.scoring then
        this_dt_is_updated_every_fucking_frame = this_dt_is_updated_every_fucking_frame + dt
        if this_dt_is_updated_every_fucking_frame > 1 then
            for i, v in pairs(G.jokers.cards) do
                if v.config.center.this_function_runs_every_fucking_second then
                    v.config.center:this_function_runs_every_fucking_second(v)
                end
            end
            this_dt_is_updated_every_fucking_frame = 0
        end
    end
end