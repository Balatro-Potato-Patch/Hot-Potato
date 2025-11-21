function sticker_check(area, sticker, blacklist) -- make "sticker" a table check?
    local amount = 0
    for k, v in pairs(area) do
        if v and v.ability then
            if sticker then
                if v.ability[sticker] or v[sticker] then
                    amount = amount + 1
                end
            else
                for l, b in pairs(SMODS.Stickers) do

                    if blacklist then
                        for kk, vv in pairs(blacklist) do
                            if l ~= vv then
                                if v.ability[l] or v[l] then
                                    amount = amount + 1
                                end
                            end
                        end
                    else
                        if v.ability[l] or v[l] then
                            amount = amount + 1
                        end
                    end
                end
            end
        else
            amount = 0
        end
    end
    return amount
end


function remove_all_stickers(card)
    if card then
        for k, v in pairs(SMODS.Stickers) do
            if (card.ability[k] or card[k]) and k ~= 'hpot_jtem_mood' then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        SMODS.Stickers[k]:apply(card, false)
                        return true
                    end
                }))
            end
        end
    end
end

--- Polls a random sticker from the set of stickers according to a uniform distribution.
---
--- @param guaranteed boolean Controls whether or not you are guaranteed to get a sticker.
---
--- @param card table|nil The card to consider. If it's provided, the stickers that the card has (if it has any) are excluded from the sticker pool.
function poll_sticker(guaranteed, card, seed, blacklist)
    guaranteed = guaranteed or false

    local stickers = {}
    local ability = card and card.ability or {}

    for k, v in pairs(SMODS.Stickers) do
        -- Check if the current sticker is on the current card (if the current card exists)
        if (card and (ability[k] or card[k])) or k == "hpot_jtem_mood" then
            goto poll_sticker_skip
        end

        -- Append the sticker to the array
    if blacklist then
        for kk, vv in pairs(blacklist) do
            if v.key ~= vv then
                stickers[#stickers + 1] = v
            end
        end
    else
        stickers[#stickers + 1] = v
    end

        ::poll_sticker_skip::
    end

    if #stickers == 0 then return nil end

    -- Check if chance to get sticker is met
    local candidate = pseudorandom_element(stickers, seed and pseudoseed(seed) or nil)
    if guaranteed or pseudorandom("poll_sticker_rate") < tonumber(candidate.rate) then
        return candidate.key
    end

    return nil
end

--- Polls a random modification from the set of modifications according to their weighted probabilities.
---
--- @param chance number A multiplier on the chance of receiving any modification. Defaults to a 20% chance (value = 1/5) to give a modification if not specified.
---
--- @param card table|nil The card to consider. If it's provided, the modification that the card has (if it does) is excluded from the modification pool.
---
--- @param morality table|nil A table specifying which categories of modifications are eligible. The fields `GOOD`, `BAD`, and `MISC` are all booleans. Defaults to all fields being true if not specified.
---
--- @param odds table|nil A table specifying relative odds for each morality category. The fields `GOOD`, `BAD`, and `MISC` are all numbers which are normalized across enabled categories to sum to 100% (value = 1).
---  Defaults to GOOD = 1/2, BAD = 1/2, MISC = 0 if not specified
function poll_modification(chance, card, morality, odds)
    chance = chance or 1 / 5
    card = card or nil

    morality = morality or {} -- Target for which kind of modifications we're targetting specifically
    morality.GOOD = (morality.GOOD == nil) and true or morality.GOOD
    morality.BAD = (morality.BAD == nil) and true or morality.BAD
    morality.MISC = (morality.MISC == nil) and true or morality.MISC

    odds = odds or {}
    odds.GOOD = odds.GOOD or 1 / 2 -- Odds for a good modification
    odds.BAD = odds.BAD or 1 / 2 -- Odds for a bad modification
    odds.MISC = odds.MISC or 0 -- Odds for any modification that slips through the cracks

    -- Make sure the odds add up to 100% no matter what
    local sanity_sum = (morality.GOOD and odds.GOOD) + (morality.BAD and odds.BAD) + (morality.MISC and odds.MISC)
    if sanity_sum ~= 1 then
        if sanity_sum == 0 then -- If there are no odds
            odds.GOOD = 1 / 2
            odds.BAD = 1 / 2
            odds.MISC = (morality.GOOD or morality.BAD) and 0 or 1
        end

        -- Normalize the odds
        sanity_sum = (morality.GOOD and odds.GOOD) + (morality.BAD and odds.BAD) + (morality.MISC and odds.MISC)

        odds.GOOD = odds.GOOD / sanity_sum
        odds.BAD = odds.BAD / sanity_sum
        odds.MISC = odds.MISC / sanity_sum
    end

    local good_modifications = {}
    local bad_modifications = {}
    local misc_modifications = {}

    local ability = card and card.ability or nil
    for k, v in pairs(HPTN.Modifications) do
        if card and ability[k] then
            goto poll_modification_skip
        end

        if v.morality == "GOOD" then
            good_modifications[#good_modifications + 1] = v
        elseif v.morality == "BAD" then
            bad_modifications[#bad_modifications + 1] = v
        else
            misc_modifications[#misc_modifications + 1] = v
        end

        ::poll_modification_skip::
    end

    local random_value = pseudorandom("poll_modification")

    if morality.GOOD and #good_modifications > 0 then
        if random_value < odds.GOOD * chance then
            return pseudorandom_element(good_modifications)
        end
        random_value = random_value - odds.GOOD * chance
    end
    if morality.BAD and #bad_modifications > 0 then
        if random_value < odds.BAD * chance then
            return pseudorandom_element(bad_modifications)
        end
        random_value = random_value - odds.BAD * chance
    end
    if morality.MISC and #misc_modifications > 0 then
        if random_value < odds.MISC * chance then
            return pseudorandom_element(misc_modifications)
        end
    end

    return nil
end


-- idk how to use corobo's Function
function random_modif(m, card)
    local vvrrr = {}
    for k, v in pairs(HPTN.Modifications) do
        if v.morality == m then
            if card then
                if not card.ability[k] then
                    table.insert(vvrrr, v)
                end
            else
                table.insert(vvrrr, v)
            end
        end
    end
    return pseudorandom_element(vvrrr)
end

--- Gets the key for the modification of a card, located in card.ability.
---
--- @param card table|nil The card to consider for modification inquiry.
function get_modification(card)
    if not card then return nil end

    local ability = card.ability
    for k, v in pairs(HPTN.Modifications) do
        if ability[k] then
            return k
        end
    end

    return nil
end

--- Reforges a card, replacing its current modification (if it has one) with its new one.
---
--- @param card table|nil The card to consider for reforging.
function reforge_card(card, free, currency)
    if not card then return nil end

    local reforge_degree_v2_voucher_acquired = G.GAME.used_vouchers
    ["v_hpot_masters"]                                                             -- Reforging can never result in a bad modifier

    local chance = 1                                                               -- 100% chance to get a modification when you reforge
    -- card param is given by the parameter to this function
    local morality = reforge_degree_v2_voucher_acquired and { GOOD = true, BAD = false, MISC = false } or
    { GOOD = true, BAD = true, MISC = true }
    local odds = reforge_degree_v2_voucher_acquired and { GOOD = 1, BAD = 0, MISC = 0 } or
    { GOOD = 1 / 2, BAD = 1 / 2, MISC = 0 }

    local old_modification = get_modification(card)
    local new_modification = poll_modification(chance, card, morality, odds)

    if old_modification then
        HPTN.Modifications[old_modification]:apply(card, false)
    end
    if new_modification then
        card:juice_up()
        HPTN.Modifications[new_modification.key]:apply(card, true)
        if not free then
            card.ability.reforge_count = (card.ability.reforge_count or 0) + 1
        end
    end
    SMODS.calculate_context({ reforging = true, card = card, free = free or false, currency = currency })
end


-- dont see this
function apply_modification(card,modif)
    if not card then return nil end
    
    local old_modification = get_modification(card)
    if old_modification then
     HPTN.Modifications[old_modification]:apply(card, false)
    end

    HPTN.Modifications[modif]:apply(card, true)

    card:juice_up()

end

--- Checks the amount of money it would cost to reforge a given card, in dollars.
---
--- @param card table|nil The card to consider for reforging.
function reforge_cost(card)
    if not card then return nil end

    local cost_initial = (card.ability.reforge_count or 0) + (card.ability.sell_cost or 0)

    local discount = reforge_discounts()
    local cost_final = cost_initial - discount

    return cost_final
end

-- 5 am
-- not needed
--- @param card table|nil Card to give reforge values
function ready_to_reforge(card)
    card = card or G.reforge_area.cards[1]
    if not card.ready_for_reforging then
        card.ready_for_reforging = true

        card.ability.reforge_dollars = 0
        card.ability.reforge_credits = 0
        card.ability.reforge_sparks = 0
        card.ability.reforge_plincoins = 0
        card.ability.reforge_cryptocurrency = 0
    end
end

--- @param card table|nil to update the card's values
function set_card_reforge(card, currency)
    card = card or G.reforge_area.cards[1]
    card.ability.reforge_dollars = reforge_cost(card)                                       -- get the reforge cost
    card.ability.reforge_credits = convert_currency(reforge_cost(card), "DOLLAR", "CREDIT") -- convert the reforge cost to other currencties and set the card abilities accordingly
    card.ability.reforge_sparks = convert_currency(reforge_cost(card), "DOLLAR", "SPARKLE")
    card.ability.reforge_plincoins = convert_currency(reforge_cost(card), "DOLLAR", "PLINCOIN")
    card.ability.reforge_cryptocurrency = convert_currency(reforge_cost(card), "DOLLAR", "CRYPTOCURRENCY")
end

--- @param card table|nil Card to use to update the costs
function update_reforge_cost(card)
    card = card or G.reforge_area.cards[1]
    if not G.GAME.used_vouchers["v_hpot_intership"] then                         -- discarded voucher feel free to add it
        G.GAME.cost_dollars = G.GAME.cost_dollars +
        card.ability.reforge_dollars                                             -- update the price with card's ability table
        G.GAME.cost_credits = G.GAME.cost_credits + card.ability.reforge_credits
        G.GAME.cost_sparks = G.GAME.cost_sparks + card.ability.reforge_sparks
        card.ability.reforge_plincoins = card.ability.reforge_plincoins or 10
        G.GAME.cost_plincoins = G.GAME.cost_plincoins + card.ability.reforge_plincoins
        G.GAME.cost_cryptocurrency = G.GAME.cost_cryptocurrency + card.ability.reforge_cryptocurrency
    else
        G.GAME.cost_dollars = card.ability.reforge_dollars -- if the voucher exists stop updating
        G.GAME.cost_credits = card.ability.reforge_credits
        G.GAME.cost_sparks = card.ability.reforge_sparks
        G.GAME.cost_plincoins = card.ability.reforge_plincoins or card.ability.reforge_plincoins_default
        G.GAME.cost_cryptocurrency = card.ability.reforge_cryptocurrency
    end

    if card.saved_last_reforge then     -- update the card values if there is a last saved table (i dont remember why i added this but there were issues)
        card.ability.reforge_dollars = card.ability.reforge_dollars_default
        card.ability.reforge_credits = card.ability.reforge_credits_default
        card.ability.reforge_sparks = card.ability.reforge_sparks_default
        card.ability.reforge_plincoins = card.ability.reforge_plincoins_default or 10
        card.ability.reforge_cryptocurrency = card.ability.reforge_cryptocurrency_default

        card.saved_last_reforge = false                -- set last reforged to false

        card.ability.reforge_dollars_default = nil     -- set the saved value table to nil
        card.ability.reforge_credits_default = nil
        card.ability.reforge_sparks_default = nil
        card.ability.reforge_plincoins_default = nil
        card.ability.reforge_cryptocurrency_default = nil
    end
end

-- reseting the reforge cost
function reset_reforge_cost() -- reset the cost to defults
    G.GAME.cost_dollars = G.GAME.cost_dollar_default
    G.GAME.cost_credits = G.GAME.cost_credit_default
    G.GAME.cost_sparks = G.GAME.cost_spark_default
    G.GAME.cost_plincoins = G.GAME.cost_plincoin_default
    G.GAME.cost_cryptocurrency = G.GAME.cost_cryptocurrency_default
end

-- save final values

-- not needed (?)
--- @param card table|nil to save the card's values
function final_ability_values(card) -- save the card's final values ( so it scales / resets probably iirc )
    card = card or G.reforge_area.cards[1]

    card.ability.reforge_dollars_default = card.ability.reforge_dollars
    card.ability.reforge_credits_default = card.ability.reforge_credits
    card.ability.reforge_sparks_default = card.ability.reforge_sparks
    card.ability.reforge_plincoins_default = card.ability.reforge_plincoins
    card.ability.reforge_cryptocurrency_default = card.ability.reforge_cryptocurrency

    card.ability.reforge_dollars = G.GAME.cost_dollars - G.GAME.cost_dollar_default
    card.ability.reforge_credits = G.GAME.cost_credits - G.GAME.cost_credit_default
    card.ability.reforge_sparks = G.GAME.cost_sparks - G.GAME.cost_spark_default
    card.ability.reforge_plincoins = G.GAME.cost_plincoins - G.GAME.cost_plincoin_default
    card.ability.reforge_cryptocurrency = G.GAME.cost_cryptocurrency - G.GAME.cost_cryptocurrency_default

    card.saved_last_reforge = true
end

--- Totals up all of the flat-rate discounts available for reforging. Feel free to list more here when needed.
function reforge_discounts() -- unused
    local total = 0

    if G.GAME.used_vouchers["v_hpot_costcutting"] then -- discarded voucher feel free to add it
        total = total + 2
    end
    return total
end

--- Converts currency from one type into another type.
---
--- @param amount number The amount of money in the original starting currency.
--- @param starting_currency "DOLLAR"|"CREDIT"|"SPARKLE"|"PLINCOIN"|"CRYPTOCURRENCY" The currency to convert from. Valid options for currencies currently include: "DOLLAR", "CREDIT", "SPARKLE", "PLINCOIN".
--- @param ending_currency "DOLLAR"|"CREDIT"|"SPARKLE"|"PLINCOIN"|"CRYPTOCURRENCY" The currency to convert to. Valid options for currencies currently include: "DOLLAR", "CREDIT", "SPARKLE", "PLINCOIN".
function convert_currency(amount, starting_currency, ending_currency)
    local money                      = amount or 0
    starting_currency                = starting_currency or "PLINCOIN"
    ending_currency                  = ending_currency or "PLINCOIN"
    -- First, convert everything into plincoin, the MOST valuable of all of the currencies.
    local dollar_to_plincoin         = 3
    local credit_to_plincoin         = 15
    local sparkle_to_plincoin        = 12495
    local cryptocurrency_to_plincoin = 4

    if ending_currency == "DOLLAR" then
        money = money * dollar_to_plincoin
    elseif ending_currency == "CREDIT" then
        money = money * credit_to_plincoin
    elseif ending_currency == "SPARKLE" then
        money = money * sparkle_to_plincoin
    elseif ending_currency == "CRYPTOCURRENCY" then
        money = money * cryptocurrency_to_plincoin
    elseif starting_currency ~= "PLINCOIN" then
        return nil
    end

    -- Next, convert from plincoin into the desired currency.
    local plincoin_to_dollar         = 1 / dollar_to_plincoin
    local plincoin_to_credit         = 1 / credit_to_plincoin
    local plincoin_to_sparkle        = 1 / sparkle_to_plincoin
    local plincoin_to_cryptocurrency = 1 / cryptocurrency_to_plincoin

    if starting_currency == "DOLLAR" then
        money = money * plincoin_to_dollar
    elseif starting_currency == "CREDIT" then
        money = money * plincoin_to_credit
    elseif starting_currency == "SPARKLE" then
        money = money * plincoin_to_sparkle
    elseif ending_currency == "CRYPTOCURRENCY" then
        money = money * plincoin_to_cryptocurrency
    elseif starting_currency ~= "PLINCOIN" then
        return nil
    end

    return math.ceil(money)
end

function add_tables(tables) -- yet again, there is probably a better way to do this but im lazy to find how
    local ful_tab = {}
    for i = 1, #tables do
        for i2 = 1, #tables[i] do
            ful_tab[#ful_tab + 1] = tables[i][i2]
        end
    end
    return ful_tab
end

-- probably shouldve made this a global function but whatever
function HPTN.ease_credits(amount, instant)
    if not G.GAME.seeded then
    amount = to_number(amount or 0)
    if ExtraCredit and (amount > to_number(0)) then
        amount = amount * 3
    end
    local function _mod(mod) -- Taken from ease_plincoins()
        local dollar_UI = G.HUD:get_UIE_by_ID('dollar_text_UI')
        mod = mod or 0
        local text = '+c.'
        local col = G.C.PURPLE
        if to_number(mod) < to_number(0) then
            text = '-c.'
            col = G.C.RED
        end

        if type(G.PROFILES[G.SETTINGS.profile].TNameCredits) == "table" then G.PROFILES[G.SETTINGS.profile].TNameCredits = 0 end
        G.PROFILES[G.SETTINGS.profile].TNameCredits = to_number(G.PROFILES[G.SETTINGS.profile].TNameCredits + amount)
        G.GAME.credits_text = G.PROFILES[G.SETTINGS.profile].TNameCredits

            dollar_UI.config.object:update()
            if amount ~= 0 then
                G.HUD:recalculate()
                --Popup text next to the chips in UI showing number of chips gained/lost
                attention_text({
                    text = text .. tostring(math.abs(mod)),
                    scale = 0.8,
                    hold = 0.7,
                    cover = dollar_UI.parent,
                    cover_colour = col,
                    align = 'cm',
                })
                dollar_UI.config.object:pop_in(0.01)
                local hpot_dollar_ui = G.shop and G.shop:get_UIE_by_ID('hotpot_currency_TNameCredits')
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
                if amount > to_number(0) then
                    play_sound("hpot_tname_gaincred")
                else
                    play_sound("hpot_tname_losecred")
                end
            end

    end

    if instant then
        _mod(amount)
    else
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                _mod(amount)
                return true
            end
        }))
    end

    G:save_progress()
else
    amount = to_number(amount or 0)
    if ExtraCredit and (amount > to_number(0)) then
        amount = amount * 3
    end
    local function _mod(mod) -- Taken from ease_plincoins()
        local dollar_UI = G.HUD:get_UIE_by_ID('dollar_text_UI')
        mod = mod or 0
        local text = '+e.'
        local col = G.C.ORANGE
        if to_number(mod) < to_number(0) then
            text = '-e.'
            col = G.C.RED
        end

        G.GAME.budget = G.GAME.budget + amount
        G.GAME.credits_text = G.GAME.budget

            dollar_UI.config.object:update()
            if amount ~= 0 then
                G.HUD:recalculate()
                --Popup text next to the chips in UI showing number of chips gained/lost
                attention_text({
                    text = text .. tostring(math.abs(mod)),
                    scale = 0.8,
                    hold = 0.7,
                    cover = dollar_UI.parent,
                    cover_colour = col,
                    align = 'cm',
                })
                --Play a chip sound
                if amount > to_number(0) then
                    play_sound("hpot_tname_gaincred")
                else
                    play_sound("hpot_tname_losecred")
                end
            end

    end

    if instant then
        _mod(amount)
    else
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                _mod(amount)
                return true
            end
        }))
    end

    G:save_progress()
end
end

function HPTN.set_credits(amount)
    if not G.GAME.seeded then
    G.PROFILES[G.SETTINGS.profile].TNameCredits = amount
    G.GAME.credits_text = G.PROFILES[G.SETTINGS.profile].TNameCredits
    else
    G.GAME.budget = amount
    G.GAME.credits_text = G.GAME.budget
    end
end

function HPTN.check_if_enough_credits(cost)
    if not G.GAME.seeded then
    local credits = G.PROFILES[G.SETTINGS.profile].TNameCredits
    if to_big(credits - cost) >= to_big(0) then
        return true
    end
    return false
else
    local credits = G.GAME.budget
    if to_big(credits - cost) >= to_big(0) then
        return true
    end
    return false
end
end

G.FUNCS.credits_UI_set = function(e)
    local new_chips_text = number_format(G.GAME.seeded and G.GAME.budget or G.PROFILES[G.SETTINGS.profile].TNameCredits)
    if G.GAME.credits_text ~= new_chips_text then
        e.config.scale = math.min(0.8, scale_number(G.GAME.seeded and G.GAME.budget or G.PROFILES[G.SETTINGS.profile].TNameCredits, 1.1))
        G.GAME.credits_text = new_chips_text
    end
end


function add_round_eval_credits(config) --taken straight from plincoin.lua (yet again thank you to whoever added these)
    local config = config or {}
    local width = G.round_eval.T.w - 0.51
    local num_dollars = to_big(config.credits or 1)
    local scale = 0.9

    if not G.round_eval.divider_added then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.25,
            func = function()
                local spacer = {
                    n = G.UIT.R,
                    config = { align = "cm", minw = width },
                    nodes = {
                        { n = G.UIT.O, config = { object = DynaText({ string = { '......................................' }, colours = { G.C.WHITE }, shadow = true, float = true, y_offset = -30, scale = 0.45, spacing = 13.5, font = G.LANGUAGES['en-us'].font, pop_in = 0 }) } }
                    }
                }
                G.round_eval:add_child(spacer, G.round_eval:get_UIE_by_ID('bonus_round_eval'))
                return true
            end
        }))
    end
    delay(0.6)
    G.round_eval.divider_added = true

    delay(0.2)

    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.5,
        func = function()
            --Add the far left text and context first:
            local left_text = {}
            if config.name == 'credits' then
                table.insert(left_text,
                    { n = G.UIT.T, config = { text = number_format(config.credits), font = config.font, scale = 0.8 * scale, colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE, shadow = true, juice = true } })
                if G.GAME.modifiers.hands_to_credits then
                    table.insert(left_text,
                        { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = G.GAME.seeded and 'hotpot_budget_cashout2' or 'hotpot_credits_cashout2', vars = { (G.GAME.credits_cashout or 0), (G.GAME.credits_cashout2 or 0) } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
                else
                    table.insert(left_text,
                        { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = G.GAME.seeded and 'hotpot_budget_cashout' or 'hotpot_credits_cashout', vars = { G.GAME.credits_cashout or 0 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
                end
            elseif string.find(config.name, 'joker') then
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = localize { type = 'name_text', set = config.card.config.center.set, key = config.card.config.center.key }, colours = { G.C.FILTER }, shadow = true, pop_in = 0, scale = 0.6 * scale, silent = true }) } })
            end
            local full_row = {
                n = G.UIT.R,
                config = { align = "cm", minw = 5 },
                nodes = {
                    { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.55, minh = 0.61, align = "cl" }, nodes = left_text },
                    { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.45, align = "cr" },      nodes = { { n = G.UIT.C, config = { align = "cm", id = 'dollar_' .. config.name }, nodes = {} } } }
                }
            }

            G.round_eval:add_child(full_row, G.round_eval:get_UIE_by_ID('bonus_round_eval'))
            play_sound('cancel', config.pitch or 1)
            play_sound('highlight1', (1.5 * config.pitch) or 1, 0.2)
            if config.card and config.card.juice_up then config.card:juice_up(0.7, 0.46) end
            return true
        end
    }))
    local dollar_row = 0
    if num_dollars > to_big(60) then
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.38,
            func = function()
                G.round_eval:add_child(
                    {
                        n = G.UIT.R,
                        config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. config.name },
                        nodes = {
                            { n = G.UIT.O, config = { object = DynaText({ string = G.GAME.seeded and "e" or "c", colours = { G.GAME.seeded and G.C.ORANGE or G.C.PURPLE }, shadow = true, pop_in = 0, scale = 0.65, float = true }) } }
                        }
                    },
                    G.round_eval:get_UIE_by_ID('dollar_' .. config.name))

                play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7)
                play_sound('coin6', 1.3, 0.8)
                return true
            end
        }))
    else
        for i = 1, to_number(num_dollars or 1) do
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.18 - ((num_dollars > to_big(20) and 0.13) or (num_dollars > to_big(9) and 0.1) or 0),
                func = function()
                    if i % 30 == 1 then
                        G.round_eval:add_child(
                            { n = G.UIT.R, config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. config.name }, nodes = {} },
                            G.round_eval:get_UIE_by_ID('dollar_' .. config.name))
                        dollar_row = dollar_row + 1
                    end

                    local r = { n = G.UIT.T, config = { text = G.GAME.seeded and "e" or "c", colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE, scale = ((num_dollars > to_big(20) and 0.28) or (num_dollars > to_big(9) and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true } }
                    play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7 - (num_dollars > to_big(20) and 0.2 or 0))

                    if config.name == 'blind1' then
                        G.GAME.current_round.dollars_to_be_earned = G.GAME.current_round.dollars_to_be_earned:sub(2)
                    end

                    G.round_eval:add_child(r, G.round_eval:get_UIE_by_ID('dollar_row_' .. (dollar_row) ..
                    '_' .. config.name))
                    G.VIBRATION = G.VIBRATION + 0.4
                    return true
                end
            }))
        end
    end

    -- might cause issues. Dollars cashout adds up everything and sends "bottom" cashout. Might need similar implementation if more plincoin cashouts are added - im leaving this in
    G.GAME.current_round.credits = G.GAME.current_round.credits + config.credits
end

function HPTN.perc(mod, perc) -- get precentage
    local per = (mod / 100) * perc
    return per
end

function Card:remove_sticker_calc(sticker, card) -- for blunder sticker
    sticker:removed(self, card)
end

function Card:apply_sticker_calc(sticker, card) -- for blunder sticker
    sticker:applied(self, card)
end

G.FUNCS.change_page_jx = function()  -- why the fuck is this here ???
    if G.GAME.first_page_stuff_and_shit then
        G.GAME.first_page_stuff_and_shit = nil
        G.FUNCS.exit_overlay_menu()
        G.FUNCS.hp_open_full_jx_top_up()
    else
        G.GAME.first_page_stuff_and_shit = true
        G.FUNCS.exit_overlay_menu()
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu {
            definition = G.UIDEF.hp_jtem_buy_jx("credits")
        }
    end
end


--[[HPTN.wheel_areas = { -- i am lazy :pray:
    'wheel_area',
    'wheel_area2',
    'wheel_area3',
    'wheel_area4',
    'wheel_area6',
    'wheel_area7',
    'wheel_area8',
    'wheel_area9',
}

function Card:in_wheel()
    for k, v in pairs(HPTN.wheel_areas) do
        if self.area == G[v] then
            return true
        end
    end
    return false
end]]

function noping_it(card, colour)
    if not colour then
        colour = G.C.SECONDARY_SET.Tarot
    end
    if not card then
        return
    end
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.4,
        func = function()
            attention_text({
                text = localize("k_nope_ex"),
                scale = 1.3,
                hold = 1.4,
                major = card,
                backdrop_colour = colour,
                align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and "tm" or "cm",
                offset = {
                    x = 0,
                    y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0
                },
                silent = true
            })
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.06 * G.SETTINGS.GAMESPEED,
                blockable = false,
                blocking = false,
                func = function()
                    play_sound("tarot2", 0.76, 0.4)
                    return true
                end
            }))
            play_sound("tarot2", 1, 0.4)
            card:juice_up(0.3, 0.5)
            return true
        end
    }))
end
