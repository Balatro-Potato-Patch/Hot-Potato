-- Common utility functions

--its ease_dollars for plincoins
function ease_plincoins(plink, instant)
    local function _mod(mod)
        local dollar_UI = G.HUD:get_UIE_by_ID('dollar_text_UI')
        mod = mod or 0
        local text = '+$'
        local col = SMODS.Gradients.hpot_plincoin
        if to_big(mod) < to_big(0) then
            text = '-$'
            col = G.C.RED
        end

        G.GAME.plincoins = G.GAME.plincoins + plink

        dollar_UI.config.object:update()
        G.HUD:recalculate()
        --Popup text next to the chips in UI showing number of chips gained/lost
        attention_text({
            text = text .. tostring(math.abs(mod)),
            scale = 0.8,
            hold = 0.7,
            cover = dollar_UI.parent,
            cover_colour = col,
            align = 'cm',
            font = SMODS.Fonts.hpot_plincoin
        })
        dollar_UI.config.object:pop_in(0.01)
        local hpot_dollar_ui = G.shop and G.shop:get_UIE_by_ID('hotpot_currency_plincoins')
        if hpot_dollar_ui then
            attention_text({
                text = text .. tostring(math.abs(mod)),
                scale = hpot_dollar_ui.children[1].children[1].config.object.scale,
                hold = 0.7,
                cover = hpot_dollar_ui,
                cover_colour = col,
                align = 'cm',
                font = SMODS.Fonts.hpot_plincoin
            })
        end

        --Play a chip sound
        play_sound('coin1')
    end
    if instant then
        _mod(plink)
    else
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                _mod(plink)
                return true
            end
        }))
    end
end

--flipping cards, like in Amber Acorn, The Wheel, and Xray challenge
--this function hooks the flip and checks a bool, then terminates if true
--disallow cards to be flipped by setting [card].forever_flipped to true
--make sure it's in the correct facing direction *before* setting this
local big_f = Card.flip
function Card:flip()
    if self.forever_flipped then
        return
    end
    big_f(self)
end

--two new contexts for the cashout screen, called once for every row and one more time for the final added amount
--pk_cashout_row is for changing the values whereas pk_cashout_row_but_just_looking is for reading them after the changes
--check context.pk_cashout_row.dollars for the amounts
--check context.pk_cashout_row.name for if its the total amount or not (== 'bottom' for total, ~= for individual rows)
local cashout_row = add_round_eval_row
function add_round_eval_row(config)
    for i = 1, #G.jokers.cards do
        local effects = eval_card(G.jokers.cards[i], { pk_cashout_row = config })
        if effects.jokers then
            config = effects.jokers.new_config
            --do your own card_eval_status_text
        end
    end
    for i = 1, #G.jokers.cards do
        eval_card(G.jokers.cards[i], { pk_cashout_row_but_just_looking = config })
    end
    return cashout_row(config)
end

--eternal consumables are SUPPOSED to just work out of the box, but maybe something with the new SMODS eternal stuff fucked it. this is so emperor bottlecap can make the bad caps eternal
local pk_can_sell = Card.can_sell_card
function Card:can_sell_card(context)
    if self.ability.set == 'bottlecap' and self.ability.eternal then return false end
    return pk_can_sell(self, context)
end

local pk_win_game = win_game
function win_game()
    check_for_unlock({ type = "cungadero", conditions = #G.GAME.hotpot_ads or 0 })
    check_for_unlock({ type = "aura_farming", conditions = {cons = G.consumeables.config.card_limit or 1, joke = G.jokers.config.card_limit or 1, hand = G.GAME.round_resets.hands or 3}})
    check_for_unlock({ type = "sisyphus"})
    return pk_win_game()
end



local pk_end_round = end_round
function end_round()
    if G.consumeables and #G.consumeables.cards >= 5 then
        -- print("yay 1")
        local thunk = {
            ['c_hpot_pine_1'] = false,
            ['c_hpot_sakura_1'] = false,
            ['c_hpot_susuki_1'] = false,
            ['c_hpot_willow_1'] = false,
            ['c_hpot_paulownia_1'] = false,
        }
        for _, v in ipairs(G.consumeables.cards) do
            -- print("yay 2")
            if v.config.center_key == 'c_hpot_pine_1' then thunk['c_hpot_pine_1'] = true goto skippy end
            if v.config.center_key == 'c_hpot_sakura_1' then thunk['c_hpot_sakura_1'] = true goto skippy end
            if v.config.center_key == 'c_hpot_susuki_1' then thunk['c_hpot_susuki_1'] = true goto skippy end
            if v.config.center_key == 'c_hpot_willow_1' then thunk['c_hpot_willow_1'] = true goto skippy end
            if v.config.center_key == 'c_hpot_paulownia_1' then thunk['c_hpot_paulownia_1'] = true goto skippy end
            ::skippy::
        end
        if thunk['c_hpot_pine_1'] and thunk['c_hpot_sakura_1'] and thunk['c_hpot_susuki_1'] and thunk['c_hpot_willow_1'] and thunk['c_hpot_paulownia_1'] then
            -- print("yay 3")
            check_for_unlock({type = 'five_lights'})
        end
    end
    return pk_end_round()
end

function show_shop()
    if G.shop and G.shop.alignment.offset.py then
        G.shop.alignment.offset.y = G.shop.alignment.offset.py
        G.shop.alignment.offset.py = nil
    end
end

function hide_shop()
    if G.shop and not G.shop.alignment.offset.py then
        G.shop.alignment.offset.py = G.shop.alignment.offset.y
        G.shop.alignment.offset.y = G.ROOM.T.y + 29
    end
end

dump = function(o, level, prefix)
    level = level or 1
    prefix = prefix or '  '
    if type(o) == 'table' and level <= 5 then
        local s = '{ \n'
        for k, v in pairs(o) do
            local format
            if type(k) == 'number' then
                format = '%s[%d] = %s,\n'
            else
                format = '%s["%s"] = %s,\n'
            end
            s = s .. string.format(
                format,
                prefix,
                k,
                -- Compact parent & draw_major to avoid recursion and huge dumps.
                (k == 'parent' or k == 'draw_major') and string.format("'%s'", tostring(v)) or
                dump(v, level + 1, prefix .. '  ')
            )
        end
        return s .. prefix:sub(3) .. '}'
    else
        if type(o) == "string" then
            return string.format('"%s"', o)
        end

        if type(o) == "function" or type(o) == "table" then
            return string.format("'%s'", tostring(o))
        end

        return tostring(o)
    end
end
