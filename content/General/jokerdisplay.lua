if not JokerDisplay then return end

-- Hide display on joker click for buttons
local card_highlight_ref = Card.highlight
function Card:highlight(highlighted)
    card_highlight_ref(self, highlighted)
    if self.ability.set == "Joker" then
        if not ((self.joker_display_values or {}).disabled) ~= (not highlighted) then
            self:joker_display_toggle()
        end
    end
end

---@type table<string,JDJokerDefinition>
local jd_def = JokerDisplay.Definitions

jd_def["j_joker"] = { -- Joker
    -- Definition left intentionally empty
}

jd_def["j_hpot_antidsestablishmentarianism"] = { -- Antidisestablishmentarianism
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "active_text" },
    },
    calc_function = function(card)
        local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and
            ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == 'Boss'))
        local all_debuffed = true
        if disableable then
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                all_debuffed = #scoring_hand >= 3
                if all_debuffed then
                    for _, played_card in pairs(JokerDisplay.current_hand) do
                        if not played_card.debuff then
                            all_debuffed = false
                            break
                        end
                    end
                end
            end
        end
        local is_hand = all_debuffed and 'k_active' or "jdis_inactive"
        card.joker_display_values.active = disableable and all_debuffed
        card.joker_display_values.active_text = localize(disableable and is_hand or 'ph_no_boss_active')
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children[1] then
            reminder_text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.RED
            reminder_text.children[1].config.scale = card.joker_display_values.active and 0.35 or 0.3
            return true
        end
        return false
    end
}

jd_def["j_hpot_iou"] = { -- I.O.U
    -- Definition left intentionally empty
}

jd_def["j_hpot_banana_of_doom"] = { -- Banana of Doom
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            }
        }
    },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_doom')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_bayharbourjoker"] = {                                         -- Bay Harbour Joker
    text = {
        { text = "+$",                             font = "hpot_plincoin" }, -- TODO: Fix font (might be a JokerDisplay issue)
        { ref_table = "card.joker_display_values", ref_value = "crypto" },
    },
    text_config = { colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } },
    calc_function = function(card)
        local my_pos
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                my_pos = i
                break
            end
        end
        local sell_value = 0
        if my_pos and G.jokers.cards[my_pos + 1] then
            local right_joker = G.jokers.cards[my_pos + 1]
            sell_value = right_joker.sell_cost
        end
        card.joker_display_values.crypto = sell_value
    end
}

jd_def["j_hpot_blunderfarming"] = { -- Blunderfarming
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'blunderfarming')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_brainfuck"] = { -- --[----->+<]>---.+++++.+.------.++++++++++++.+++++.
    text = {
        { text = "+", },
        { ref_table = "card.joker_display_values", ref_value = "adds", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.FILTER },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local should_trigger = false
        if text ~= 'Unknown' then
            should_trigger = #scoring_hand >= 5
            local last = -math.huge
            if should_trigger then
                for _, scored_card in ipairs(scoring_hand) do
                    local id = scored_card:get_id()
                    if id < last then
                        should_trigger = false
                        break
                    else
                        last = id
                    end
                end
            end
        end

        card.joker_display_values.adds = should_trigger and 1 or 0
    end
}

jd_def["j_hpot_bungaloid"] = { -- Bungaloid
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "active", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.FILTER },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        local active = false
        local _, poker_hands, _ = JokerDisplay.evaluate_hand()
        if poker_hands["Full House"] and next(poker_hands["Full House"]) then
            active = true
        end
        card.joker_display_values.active = active and 1 or 0
        card.joker_display_values.localized_text = localize("Full House", 'poker_hands')
    end
}

jd_def["j_hpot_cardstack"] = { -- Card Stack
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.numerator,
            card.ability.extra.denominator, 'hc_cardstack')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_chocolate_bar"] = { -- Chocolate Bar
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_chocolate_bar')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_chocolate_milk"] = { -- Chocolate Milk (SEAMLESSLY VANILLA JOKER)
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xchips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS
        }
    },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_chocolate_milk')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_cloverpit"] = { -- Clover Pit
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.GOLD },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local dollars = 0
        local text, _, _ = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" and G.GAME.hands[text] then
            dollars = math.max(G.GAME.hands[text].mult, 0)
        end
        card.joker_display_values.dollars = dollars
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hpot_cloverpit")
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_diy"] = { -- DIY
    -- TODO
}

jd_def["j_hpot_electrical_discharge"] = { -- Electrical Discharge
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "stored_mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.UI.TEXT_INACTIVE }
}

jd_def["j_hpot_folded"] = { -- Folded Joker
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local active = false
        if text ~= 'Unknown' then
            active = (#JokerDisplay.current_hand - #scoring_hand) >= to_number(card.ability.extra.unscoring)
        end
        card.joker_display_values.mult = active and card.ability.extra.mult or 0
    end
}

jd_def["j_hpot_balatro_free_smods_download_2025"] = { -- Balatro SMODS free download working 2025
    reminder_text = {
        { text = "(" },
        { text = "$",         colour = G.C.GOLD },
        { ref_table = "card", ref_value = "sell_cost", colour = G.C.GOLD },
        { text = ")" },
    },
    reminder_text_config = { scale = 0.35 }
}

jd_def["j_hpot_hc_genghis_khan"] = { -- Genghis Khan
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "current", retrigger_type = "exp" }
            }
        }
    },
}

jd_def["j_hpot_goldenchicot"] = { -- Golden Chicot
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars", retrigger_type = "mult" }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
        card.joker_display_values.dollars = card.ability.extra.disabled_bosses * card.ability.extra.dollars_per_boss
    end
}

jd_def["j_hpot_thetruehotpotato"] = { -- Hot Potato
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.mult = card.ability.extra.total_mult
        local current_position = nil
        local position_already_used = false
        if card.area == G.jokers then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    current_position = i
                    for _, pos in ipairs(card.ability.extra.used_positions) do
                        if pos == current_position then
                            position_already_used = true
                            break
                        end
                    end
                    break
                end
            end
        end
        local is_active = current_position and not position_already_used
        card.joker_display_values.active = localize(is_active and 'k_active' or "jdis_inactive")
    end
}

jd_def["j_hpot_idle"] = { -- Idle Joker
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
        { text = "(" },
        { ref_table = "card.ability.extra",        ref_value = "score",         colour = G.C.FILTER },
        { text = ")" },
    },
    calc_function = function(card)
        local score = (#tostring(card.ability.extra.score))
        card.joker_display_values.dollars = score * card.ability.extra.money
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ") "
    end
}

jd_def["j_hpot_inacargobox"] = { -- In a Cargo Box?
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        local valid_deliveries = G.GAME.hp_jtem_delivery_queue and #G.GAME.hp_jtem_delivery_queue or 0
        card.joker_display_values.xmult = card.ability.extra.xmult_per_delivery ^ valid_deliveries
    end
}

jd_def["j_hpot_lockin"] = { -- Lock In
    -- Definition left intentionally empty
}

jd_def["j_hpot_lotus"] = { -- Lotus Flower
    -- Definition left intentionally empty
}

jd_def["j_hpot_notajoker"] = { -- This is not a Joker
    -- Definition left intentionally empty
}

jd_def["j_hpot_selfinserting"] = { -- Obligatory Self Inserts of the Hot Potato Mod
    mod_function = function(card, mod_joker)
        return { x_mult = ((card.config.center.pools or {}).self_inserts and mod_joker.ability.extra.xmult_per_self_insert ^ JokerDisplay.calculate_joker_triggers(mod_joker) or nil) }
    end
}

jd_def["j_hpot_panic_attack"] = { -- Panic Attack
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_participation_award"] = { -- Participation Award
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_hpot_precognition"] = { -- Precognition
    text = {
        { text = "+" },
        { ref_table = "card.ability", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_hpot_prosopagnosia"] = { -- Mr. Joker Encounters a Secondhand Vanity: Tulpamancers Prosopagnosia
    text = {
        { text = "x" },
        { ref_table = "card.joker_display_values", ref_value = "count" },
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local count = 0
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:is_face() then
                    count = count +
                        JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        card.joker_display_values.count = count
    end
}

jd_def["j_hpot_roi"] = { -- Return on Investment
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.active = localize(not G.GAME.bm_bought_this_round and 'k_active' or "jdis_inactive")
    end
}

jd_def["j_hpot_c_sharp"] = { -- C#
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "left",  colour = G.C.FILTER },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "reset", colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_shady"] = { -- Shady Joker
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "uses_remaining", colour = G.C.FILTER },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "total_uses",     colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_notbaddragon"] = { -- Terrible Dragon
    text = {
        { text = "+",                              colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
        { text = " +",                             colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult",  colour = G.C.MULT },
    },
    calc_function = function(card)
        local valid_jokers = 0
        if G.jokers and G.jokers.cards then
            for _, joker in ipairs(G.jokers.cards) do
                if joker ~= card and not joker.ability.hp_jtem_mood then
                    valid_jokers = valid_jokers + 1
                end
            end
        end

        card.joker_display_values.chips = card.ability.extra.chips_per_joker * valid_jokers
        card.joker_display_values.mult = card.ability.extra.mult_per_joker * valid_jokers
    end
}

jd_def["j_hpot_apocalypse"] = { -- The Apocalypse
    text = {
        {
            border_nodes = {
                { ref_table = "card.joker_display_values", ref_value = "text" }
            },
        }
    },
    calc_function = function(card)
        card.joker_display_values.text = ""
        local triggers = JokerDisplay.calculate_joker_triggers(card)
        if card.ability.horseman == "ruby" then
            card.joker_display_values.text = "X" .. JokerDisplay.number_format(get_currency_mult() ^ triggers)
        end
        if card.ability.horseman == "cg" then
            card.joker_display_values.text = "+" ..
                JokerDisplay.number_format(card.ability.extra.chips_mod * Horsechicot.num_jokers() * triggers)
        end
        if card.ability.horseman == "lily" then
            local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds,
                'hpot_apocalypse_lily')
            card.joker_display_values.text = "(" ..
                localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } } .. ")"
        end
        if card.ability.horseman == "baccon" then
            card.joker_display_values.text = "X" ..
                JokerDisplay.number_format((#JokerDisplay.current_hand == card.ability.extra.cards_needed and card.ability.extra.xmult or 1) ^
                    triggers)
        end
        if card.ability.horseman == "nxkoo" then
            local xmult = 1
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:get_id() == 14 then
                        if scoring_card:is_suit("Hearts") then
                            xmult = xmult *
                                (card.ability.extra.hxmult ^
                                    JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand))
                        else
                            xmult = xmult *
                                (card.ability.extra.axmult ^
                                    JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand))
                        end
                    end
                end
            end
            card.joker_display_values.text = "X" .. JokerDisplay.number_format(xmult ^ triggers)
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children[1] and text.children[1].children[1] then
            local border_config = text.children[1].config
            local text_config = text.children[1].children[1].config

            if card.ability.horseman == "ruby" or card.ability.horseman == "baccon"
                or card.ability.horseman == "nxkoo" then
                border_config.colour = G.C.MULT
                text_config.colour = G.C.UI.TEXT_LIGHT
            end
            if card.ability.horseman == "cg" then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.CHIPS
            end
            if card.ability.horseman == "lily" then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.GREEN
            end
            if card.ability.horseman == "pangaea" then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.CLEAR
            end
            return true
        end
        return false
    end
}

jd_def["j_hpot_timelapse"] = { -- Timelapse
    -- TODO: If someone wants to figure out double blueprint with jokerdisplay go ahead
}

jd_def["j_hpot_hc_trackmania"] = { -- Trackmania
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        local t_since_ante = card.ability.elapsed
        local xmult = card.ability.def_xmult - (t_since_ante * card.ability.dec_per_sec)
        xmult = math.max(xmult, 1)
        xmult = math.floor(xmult * 10) / 10
        card.joker_display_values.xmult = xmult
    end
}

jd_def["j_hpot_truman"] = { -- Truman
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        local teams = {}
        for i, jkr in pairs(G.jokers.cards) do
            local team = jkr.config.center.hotpot_credits and jkr.config.center.hotpot_credits.team
            if team then
                for _, real_team in pairs(team) do
                    teams[real_team] = (teams[real_team] or 0) + 1
                end
            end
        end
        local highest_num = -1
        for _, team_count in pairs(teams) do
            if team_count > highest_num then
                highest_num = team_count
            end
        end
        card.joker_display_values.xmult = highest_num * card.ability.extra.base_mult
    end
}

jd_def["j_hpot_yapper"] = { -- The Yapper
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        card.joker_display_values.mult = string.len(card.ability.current) * card.ability.amt
    end
}

jd_def["j_hpot_nxkoodead"] = { -- Nxkoo found dead
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        local save = G.PROFILES[G.SETTINGS.profile]
        card.joker_display_values.xmult = math.min(
            (math.floor((save.JtemNXkilled or 0) / card.ability.extra.per) * card.ability.extra.gain) + 1, 15)
    end
}

jd_def["j_hpot_retriggered"] = { -- what if there was a joker that retriggered
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        return (joker_card.ability.extra.retriggers * JokerDisplay.calculate_joker_triggers(joker_card)) or 0
    end
}

jd_def["j_hpot_greedybastard"] = { -- Greedy Bastard
    text = {
        { text = "+" },
        { ref_table = "card.ability", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_hpot_jtemj"] = { -- J
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_jtemo"] = { -- O
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_jtemk"] = { -- K
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_jteme"] = { -- E
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_jtemr"] = { -- R
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_labubu"] = { -- Joker Glass Bridge
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    extra = {
        {
            { ref_table = "card.joker_display_values", ref_value = "count" },
            { text = "x" },
            { text = "$",                              font = "hpot_plincoin", colour = { ref_table = SMODS.Gradients, ref_value = "hpot_plincoin" } }, -- TODO: Fix font
            { ref_table = "card.ability.extra",        ref_value = "cion",     font = "hpot_plincoin",                                               colour = { ref_table = SMODS.Gradients, ref_value = "hpot_plincoin" } },
            { text = "?" },
        }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if SMODS.has_enhancement(scoring_card, "m_glass") then
                    count = count + 1
                end
            end
        end
        card.joker_display_values.count = count
    end
}

jd_def["j_hpot_jtem_slop_live"] = { -- Welcome back, to Slop Live
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extras", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_empty_can"] = { -- Empty Can
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "used",         colour = G.C.FILTER },
        { text = "/" },
        { ref_table = "card.ability.extra",        ref_value = "consumeables", colour = G.C.FILTER },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.used = card.ability.consumeables_used or 0
    end
}

jd_def["j_hpot_spam"] = { -- Spam with eggs
    -- Definition left intentionally empty
}

jd_def["j_hpot_dupedshovel"] = { -- Duped Spade
    -- Definition left intentionally empty
}

jd_def["j_hpot_silly"] = { -- スティルインラブ Still in Love
    -- Definition left intentionally empty
}

jd_def["j_hpot_jtem_flash"] = { -- We are Jtem
    text = {
        { text = "x" },
        { ref_table = "card.joker_display_values", ref_value = "count" }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:is_face() then
                    count = count + 1
                end
            end
        end
        card.joker_display_values.count = count
    end
}

jd_def["j_hpot_jtem_special_week"] = { -- スペーシャルウィーク Special Week
    -- Definition left intentionally empty
}

jd_def["j_hpot_99_bottles"] = { -- 99 Bottles of Coke on the Wall
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        card.joker_display_values.mult = card.ability.extra.mult *
            (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.bottlecap or 0)
    end
}

jd_def["j_hpot_american_healthcare"] = { -- American Healthcare
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.active = (not card.ability.extra.this_round and localize("jdis_active") or localize("jdis_inactive"))
    end
}

jd_def["j_hpot_art_of_the_deal"] = { -- Art of the Deal
    -- Definition left intentionally empty
}

jd_def["j_hpot_atm"] = { -- ATM
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        local uses = to_number(G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.Czech or 0)
        card.joker_display_values.dollars = uses > 0 and (card.ability.extra.money * uses) or 0
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end
}

jd_def["j_hpot_box_of_frogs"] = { -- Box of Frogs
    -- Definition left intentionally empty
}

jd_def["j_hpot_charlie"] = { -- Chipper Charlie
    -- Definition left intentionally empty
}

jd_def["j_hpot_melvin"] = { -- Molten Melvin
    -- Definition left intentionally empty
}

jd_def["j_hpot_commit_farmer"] = { -- Commit Farmer
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        card.joker_display_values.xmult = card.ability.extra.xmult_inc *
            (card.ability.extra.commits[G.GAME.current_round.hpot_commit_farmer_team:lower()] or 0) +
            card.ability.extra.xmult_base
    end
}

jd_def["j_hpot_death_note"] = { -- Death Note
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "idol_card", colour = G.C.FILTER },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.idol_card = localize { type = 'variable', key = "jdis_rank_of_suit", vars = { localize(card.ability.extra.rank, 'ranks'), localize(card.ability.extra.suit, 'suits_plural') } }
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children[2] then
            reminder_text.children[2].config.colour = lighten(G.C.SUITS[card.ability.extra.suit], 0.35)
        end
        return false
    end
}

jd_def["j_hpot_fine_print"] = { -- Fine Print
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        local a = card.ability.extra.effects
        local xmult = card.ability.extra.xmult

        if a.no_suit then
            for i = 1, #context.full_hand do
                if context.full_hand[i]:is_suit(a.no_suit.name) then
                    xmult = 1
                end
            end
        end

        if a.no_rank then
            for i = 1, #context.full_hand do
                if context.full_hand[i]:get_id() == a.no_rank.id then
                    xmult = 1
                end
            end
        end

        if a.no_full_slots and #G.jokers.cards >= G.jokers.config.card_limit then
            xmult = 1
        end

        if a.empty_consumables and #G.consumeables.cards > 0 then
            xmult = 1
        end

        if a.no_rare then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i]:is_rarity("Rare") then
                    xmult = 1
                end
            end
        end

        if a.no_small and G.GAME.blind:get_type() == "Small" then
            xmult = 1
        end

        if a.no_first_hand and G.GAME.current_round.hands_played == 0 then
            xmult = 1
        end
        card.joker_display_values.xmult = xmult
    end
}

jd_def["j_hpot_fun_is_infinite"] = { -- Fun is Infinite
    mod_function = function(card, mod_joker)
        return { x_mult = (SMODS.is_eternal(card, mod_joker) and mod_joker.ability.extra.xmult ^ JokerDisplay.calculate_joker_triggers(mod_joker) or nil) }
    end
}

jd_def["j_hpot_gula"] = { -- Gula
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_loss"] = { -- Loss
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "Xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_mega_mushroom"] = { -- Mega Mushroom
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "hands_left", colour = G.C.FILTER },
        { text = "/" },
        { text = "3",                       colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_numberslop"] = { -- Numberslop
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        local xmult = 1
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if not (scoring_card:is_face() or scoring_card:get_id() == 14) then
                    xmult = xmult *
                        (card.ability.extra.Xmult ^
                            JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand))
                end
            end
        end
        card.joker_display_values.xmult = xmult
    end
}

jd_def["j_hpot_OAP"] = { -- Oops! A Programmer
    text = {
        {
            border_nodes = {
                { ref_table = "card.joker_display_values", ref_value = "text" }
            },
        }
    },
    calc_function = function(card)
        card.joker_display_values.text = ""
        local triggers = JokerDisplay.calculate_joker_triggers(card)
        if card.ability.extra.effect == 'trif' then
            card.joker_display_values.text = "(" ..
                localize(#JokerDisplay.current_hand == 5 and 'k_active' or "jdis_inactive") .. ")"
        end
        if card.ability.extra.effect == 'sadcube' then
        end
        if card.ability.extra.effect == 'astra' then
            local active = #JokerDisplay.current_hand == 1 and
                not (JokerDisplay.current_hand[1]:is_face() or JokerDisplay.current_hand[1]:get_id() == 14)
            card.joker_display_values.text = "(" ..
                localize(active and 'k_active' or "jdis_inactive") .. ")"
        end
        if card.ability.extra.effect == 'wix' then
            local xchips = 1
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:get_id() == 12 then
                        xchips = xchips *
                            (card.ability.wix_effect.xchips ^
                                JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand))
                    end
                end
            end
            card.joker_display_values.text = "X" .. JokerDisplay.number_format(xchips ^ triggers)
        end
        if card.ability.extra.effect == 'myst' then
            local xmult = 1
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if not scoring_card:is_face() then
                        xmult = xmult + card.ability.myst_effect.x_mult *
                            JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
            card.joker_display_values.text = "X" .. JokerDisplay.number_format(xmult ^ triggers)
        end
        if card.ability.extra.effect == 'th30ne' then
            local xmult = 1
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                local aces = {}
                local threes = {}
                for _, playing_card in ipairs(scoring_hand) do
                    if playing_card:get_id() == 3 then
                        table.insert(threes, playing_card)
                    elseif playing_card:get_id() == 14 then
                        table.insert(aces, playing_card)
                    end
                end
                if #aces > 0 and #threes > 0 then
                    for _, ace in ipairs(aces) do
                        for _, three in ipairs(threes) do
                            if SMODS.has_no_suit(ace) or SMODS.has_no_suit(three) or
                                (ace.base.suit ~= three.base.suit
                                    and not SMODS.has_any_suit(ace)
                                    and not SMODS.has_any_suit(three)) then
                                xmult = card.ability.th30ne_effect.xmult
                                break
                            end
                        end
                        if xmult ~= 1 then
                            break
                        end
                    end
                end
            end
            card.joker_display_values.text = "X" .. JokerDisplay.number_format(xmult ^ triggers)
        end
        if card.ability.extra.effect == 'lia' then
            local text, _, _ = JokerDisplay.evaluate_hand()
            local active = text == "High Card" and G.GAME.current_round.hands_played == 0
            card.joker_display_values.text = "(" ..
                localize(active and 'k_active' or "jdis_inactive") .. ")"
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children[1] and text.children[1].children[1] then
            local border_config = text.children[1].config
            local text_config = text.children[1].children[1].config

            if card.ability.extra.effect == 'myst' or card.ability.extra.effect == 'th30ne' then
                border_config.colour = G.C.MULT
                text_config.colour = G.C.UI.TEXT_LIGHT
            end
            if card.ability.extra.effect == "wix" then
                border_config.colour = G.C.CHIPS
                text_config.colour = G.C.UI.TEXT_LIGHT
            end
            if card.ability.extra.effect == 'lia' or card.ability.extra.effect == 'astra'
                or card.ability.extra.effect == 'trif' then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.UI.TEXT_INACTIVE
            end
            if card.ability.extra.effect == "sadcube" then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.CLEAR
            end
            return true
        end
        return false
    end
}

jd_def["j_hpot_ouroboros"] = { -- Ouroboros
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "Xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_paper_jam"] = { -- Paper Jam
    -- Definition left intentionally empty
}

jd_def["j_hpot_pump_and_dump"] = {                                    -- Pump And Dump
    text = {
        { text = "+$",                      font = "hpot_plincoin" }, -- TODO: Fix font
        { ref_table = "card.ability.extra", ref_value = "crypto" },
    },
    text_config = { colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
            { text = "X0",                             colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } }
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_pump_and_dump')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_sonloaf"] = { -- Son Loaf
    -- Definition left intentionally empty
}

jd_def["j_hpot_tori_gate"] = { -- Tori Gate
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        card.joker_display_values.chips = card.ability.extra.chips *
            ((G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.Hanafuda or 0) + card.ability.extra.joy_hanafuda_count)
    end
}

jd_def["j_hpot_trolley_operator"] = { -- Trolley Operator
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        local in_play = not not next(G.play.cards)
        card.joker_display_values.dollars = ((#G.hand.cards - (in_play and 0 or #JokerDisplay.current_hand)) == 5) and
            card.ability.extra.money or 0
    end
}

jd_def["j_hpot_undying"] = { -- Jimbo The Undying
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "Xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_wumpus"] = { -- Wumpus
    -- Definition left intentionally empty
}

jd_def["j_hpot_fortnite"] = { -- 19 Plincoin Fortnite Card
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "bosses", colour = G.C.FILTER },
        { text = "/" },
        { text = "3",                       colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_plink"] = { -- Plink
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        card.joker_display_values.mult = card.ability.extra.mult * G.GAME.balls_dropped
    end
}

jd_def["j_hpot_metal_detector"] = { -- Metal Detector
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "skipped", colour = G.C.FILTER },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "needs",   colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_tribcoin"] = { -- Tribcoin
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        card.joker_display_values.xmult = 1 + math.max(0, G.GAME.plincoins * card.ability.extra.Xmult)
    end
}

jd_def["j_hpot_adspace"] = { -- Adspace
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        card.joker_display_values.chips = card.ability.extra.chips * #G.GAME.hotpot_ads
    end
}

jd_def["j_hpot_kitchen_gun"] = { -- Kitchen Gun
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_kitchen_gun')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_tv_dinner"] = { -- TV Dinner
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_hpot_free_to_use"] = { -- Free To Use
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.num, card.ability.extra.den,
            'free_to_use')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_direct_deposit"] = { -- Direct Deposit
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "so_far",  colour = G.C.FILTER },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "dollars", colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_bank_teller"] = { -- Bank Teller
    -- Definition left intentionally empty
}

jd_def["j_hpot_balatro_premium"] = { -- Balatro **PREMIUM**
    text = {
        { text = "-$" },
        { ref_table = "card.ability.extra", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end
}

jd_def["j_hpot_skimming"] = { -- Skimming
    text = {
        { text = "+$" },
        { ref_table = "card.ability.extra", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end
}

jd_def["j_hpot_recycling"] = { -- Recycling
    -- Definition left intentionally empty
}

jd_def["j_hpot_dont_touch_that_dial"] = {                               -- Don't Touch That Dial!
    text = {
        { text = "+$",                        font = "hpot_plincoin" }, -- TODO: Fix font
        { ref_table = "G.GAME.current_round", ref_value = "discards_left" },
    },
    text_config = { colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end
}

jd_def["j_hpot_tipping_point"] = { -- Tipping Point
    -- Definition left intentionally empty
}

jd_def["j_hpot_local_newspaper"] = { -- Local Newspaper
    -- Definition left intentionally empty
}

jd_def["j_hpot_ruan_mei"] = { -- Ruan Mei
    -- Definition left intentionally empty
}

jd_def["j_hpot_minimum_prize_guarantee"] = { -- Minimum Prize Guarantee
    -- Definition left intentionally empty
}

jd_def["j_hpot_kindergarten"] = { -- Kindergarten
    mod_function = function(card, mod_joker)
        return {
            x_mult = card.ability.is_nursery_smalled and
                mod_joker.ability.extra.xmult ^ JokerDisplay.calculate_joker_triggers(mod_joker) or nil
        }
    end
}

jd_def["j_hpot_social_credit"] = { -- Social Credit
    text = {
        { ref_table = "card.joker_display_values", ref_value = "sign" },
        { text = "c.", },
        { ref_table = "card.joker_display_values", ref_value = "credits" },
    },
    text_config = { colour = G.C.PURPLE },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    extra = {
        {
            { text = "(", },
            { ref_table = "card.ability.extra", ref_value = "social_credit", colour = G.C.RED },
            { text = ")", },
        }
    },
    extra_config = { scale = 0.35 },
    calc_function = function(card)
        card.joker_display_values.credits = card.ability.extra.credit_gain *
            math.floor(card.ability.extra.social_credit / card.ability.extra.conversion_rate)
        card.joker_display_values.sign = card.joker_display_values.credits >= 0 and "+" or "-"
        card.joker_display_values.credits = math.abs(card.joker_display_values.credits)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end
}

jd_def["j_hpot_togore"] = { -- Togore
    -- Definition left intentionally empty
}

jd_def["j_hpot_goblin_tinkerer"] = { -- Goblin Tinkerer
    -- Definition left intentionally empty
}

jd_def["j_hpot_vremade_joker"] = { -- vremade_Joker
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT }
}

jd_def["j_hpot_smods"] = { -- SMODS
    -- Definition left intentionally empty
}

jd_def["j_hpot_red_deck_joker"] = { -- Red Deck Joker
    reminder_text = {
        { text = "(" },
        { text = "+",                              colour = G.C.RED },
        { ref_table = "card.joker_display_values", ref_value = "discards", colour = G.C.RED },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.discards = card.ability.extra.discards *
            (math.floor((G.playing_cards and #G.playing_cards or 1) / card.ability.extra.cards_req))
    end
}

jd_def["j_hpot_blue_deck_joker"] = { -- Blue Deck Joker
    reminder_text = {
        { text = "(" },
        { text = "+",                              colour = G.C.BLUE },
        { ref_table = "card.joker_display_values", ref_value = "hands", colour = G.C.BLUE },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.hands = card.ability.extra.hands *
            (math.floor((G.playing_cards and #G.playing_cards or 1) / card.ability.extra.cards_req))
    end
}

jd_def["j_hpot_yellow_deck_joker"] = { -- Yellow Deck Joker
    reminder_text = {
        { text = "(" },
        { text = "+$",                             colour = G.C.GOLD },
        { ref_table = "card.joker_display_values", ref_value = "hands", colour = G.C.GOLD },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.hands = card.ability.extra.dollars *
            (math.floor((G.playing_cards and #G.playing_cards or 1) / card.ability.extra.cards_req))
    end
}

jd_def["j_hpot_polymorph"] = { -- Polymorphine
    -- Definition left intentionally empty
}

jd_def["j_hpot_golden_apple"] = { -- Golden Apple
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "uses_left", colour = G.C.FILTER },
        { text = "/" },
        { text = "5",                       colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_hangman"] = { -- Hangman
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "n_seen",  colour = G.C.FILTER },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "n_ranks", colour = G.C.FILTER },
        { text = ")" },
    },
}

jd_def["j_hpot_jade"] = {                                             -- Jade Joker
    text = {
        { text = "+$",                      font = "hpot_plincoin" }, -- TODO: Fix font
        { ref_table = "card.ability.extra", ref_value = "coins" },
    },
    text_config = { colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end
}

jd_def["j_hpot_joker_forge"] = { -- Joker Forge
    -- Definition left intentionally empty
}

jd_def["j_hpot_login_bonus"] = {                                                                                                                  -- Login Bonus
    text = {
        { text = "+$",                             font = "hpot_plincoin", colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } }, -- TODO: Fix font
        { ref_table = "card.joker_display_values", ref_value = "coins",    colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } },
        { text = " +$",                            colour = G.C.GOLD },
        { ref_table = "card.joker_display_values", ref_value = "dollars",  colour = G.C.GOLD },
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
        local cycle = card.ability.extra.current_cycle + 1
        card.joker_display_values.coins = card.ability.extra.rewards[cycle].plincoins
        card.joker_display_values.dollars = card.ability.extra.rewards[cycle].dollars
    end
}

jd_def["j_hpot_magic_factory"] = { -- Magic Factory
    -- Definition left intentionally empty
}

jd_def["j_hpot_slop"] = { -- TV Slop
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_wizard_tower"] = { -- Wizard Tower
    -- Definition left intentionally empty
}

jd_def["j_hpot_emoticon"] = { -- Emoticon
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
    calc_function = function(card)
        local xmult = 1
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:is_face(false, { ignore_emoticon = true }) then
                    xmult = xmult *
                        (card.ability.extra.x_mult ^
                            JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand))
                end
            end
        end
        card.joker_display_values.xmult = xmult
    end
}

jd_def["j_hpot_faceblindness"] = { -- Face Blindness
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.numerator,
            card.ability.extra.denominator, 'faceblindness')
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_hpot_ifstatements"] = { -- 1000000 If Statements
    -- Definition left intentionally empty
}

jd_def["j_hpot_plinkodemayo"] = {                                            -- Plinko de Mayo
    text = {
        { text = "+$",                             font = "hpot_plincoin" }, -- TODO: Fix font
        { ref_table = "card.joker_display_values", ref_value = "coins",   retrigger_type = 'mult' },
    },
    text_config = { colour = { ref_table = SMODS.Gradients, ref_value = "hpot_advert" } },
    calc_function = function(card)
        local coins = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:get_id() == 5 then
                    coins = coins +
                        (card.ability.extra.plincoins *
                            JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand))
                end
            end
        end
        card.joker_display_values.coins = coins
    end
}

jd_def["j_hpot_potatosmileys"] = { -- Potato Smileys
    text = {
        { text = "+", },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = 'mult' },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local mult = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:is_face() then
                    mult = mult +
                        (card.ability.extra.mult *
                            JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand))
                end
            end
        end
        card.joker_display_values.mult = mult
    end
}

jd_def["j_hpot_upsidedownsmiley"] = { -- Upside-down Smiley Face
    text = {
        { text = "+", },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = 'mult' },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == 'back') and not playing_card.debuff and playing_card:is_face() then
                    count = count + JokerDisplay.calculate_card_triggers(playing_card, nil, true)
                end
            end
        end
        card.joker_display_values.mult = card.ability.extra.mult * count
    end
}

jd_def["j_hpot_nxkoo_joker"] = { -- Halo
    -- Definition left intentionally empty
}

jd_def["j_hpot_grand_finale"] = { -- Grand Finale
    -- Definition left intentionally empty
}

jd_def["j_hpot_grand_diagonal"] = { -- Grand Diagonal
    -- Definition left intentionally empty
}

jd_def["j_hpot_grand_spectral"] = { -- Grand Spectral
    -- Definition left intentionally empty
}

jd_def["j_hpot_grand_brachial"] = { -- Grand Brachial
    -- TODO: If someone wants to figure out double blueprint with jokerdisplay go ahead
}

jd_def["j_hpot_grand_chocolatier"] = { -- Grand Chocolatier
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_aries_card"] = { -- Aries Card
    -- Definition left intentionally empty
}

jd_def["j_hpot_tname_postcard"] = { -- Postcard
    text = {
        {
            border_nodes = {
                { ref_table = "card.joker_display_values", ref_value = "text" }
            },
        }
    },
    calc_function = function(card)
        local members = { "Corobo", "GhostSalt", "GoldenLeaf", "Jogla", "Revo", "Violet" }
        local current_member = members[G.GAME.current_team_name_member or 1]
        card.joker_display_values.text = ""
        local triggers = JokerDisplay.calculate_joker_triggers(card)
        if current_member == 'Corobo' then
            card.joker_display_values.text = "X" ..
                JokerDisplay.number_format(card.ability.extra.functions.Corobo.a ^ triggers)
        end
        if current_member == 'GhostSalt' then
            card.joker_display_values.text = "X" ..
                JokerDisplay.number_format(card.ability.extra.functions.GhostSalt[1] ^ (#G.consumeables.cards * triggers))
        end
        if current_member == 'GoldenLeaf' then
            card.joker_display_values.text = "+c." ..
                JokerDisplay.number_format(card.ability.extra.functions.GoldenLeaf[1] * triggers)
        end
        if current_member == 'Jogla' then
        end
        if current_member == 'Revo' then
        end
        if current_member == 'Violet' then
            local dollars = 0
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_suit("Spades") or scoring_card:is_suit("Hearts") then
                        dollars = dollars +
                            card.ability.extra.functions.Violet[1] *
                            JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
            card.joker_display_values.text = "+$" ..
                JokerDisplay.number_format(dollars * triggers)
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children[1] and text.children[1].children[1] then
            local border_config = text.children[1].config
            local text_config = text.children[1].children[1].config

            local members = { "Corobo", "GhostSalt", "GoldenLeaf", "Jogla", "Revo", "Violet" }
            local current_member = members[G.GAME.current_team_name_member or 1]

            if current_member == 'Corobo' or current_member == 'GhostSalt' then
                border_config.colour = G.C.MULT
                text_config.colour = G.C.UI.TEXT_LIGHT
            end
            if current_member == 'Violet' then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.GOLD
            end
            if current_member == 'GoldenLeaf' then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.PURPLE
            end
            if current_member == 'Jogla' or current_member == 'Revo' then
                border_config.colour = G.C.CLEAR
                text_config.colour = G.C.CLEAR
            end
            return true
        end
        return false
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        local members = { "Corobo", "GhostSalt", "GoldenLeaf", "Jogla", "Revo", "Violet" }
        local current_member = members[G.GAME.current_team_name_member or 1]
        return (current_member == "Revo" and playing_card:is_suit("Spades")) and
            joker_card.ability.extra.functions.Revo.rep * JokerDisplay.calculate_joker_triggers(joker_card) or 0
    end
}

jd_def["j_hpot_jankman"] = { -- JankMan
    text = {
        {
            border_nodes = {
                { text = "x " },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
                { text = "  m" },
            },
        }
    },
    calc_function = function(card)
        local stickers = 0
        for k, _ in pairs(SMODS.Stickers) do
            if card.ability[k] == true then
                stickers = stickers + 1
            end
        end
        card.joker_display_values.xmult = card.ability.extra.xmult + card.ability.extra.xmultg * stickers
    end
}

jd_def["j_hpot_sunset"] = { -- Sunset
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "add", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" },
    },
    calc_function = function(card)
        local is_active = false
        if card.ability.extra.availability then
            for _, v in ipairs(JokerDisplay.current_hand) do
                if v:is_suit(card.ability.extra.suit) then
                    is_active = true
                    break
                end
            end
        end
        card.joker_display_values.add = is_active and 1 or 0
        card.joker_display_values.active = localize(card.ability.extra.availability and 'k_active' or "jdis_inactive")
    end
}

jd_def["j_hpot_graveyard"] = { -- Graveyard
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        }
    },
    calc_function = function(card)
        card.joker_display_values.xmult = card.ability.extra.xmult +
            card.ability.extra.xmultg * card.ability.extra.destroyed
    end
}

jd_def["j_hpot_sticker_master"] = { -- Sticker Master
    text = {
        { text = "+", },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = 'mult' },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        card.joker_display_values.mult = card.ability.extra.mult *
            sticker_check(G.jokers.cards, nil, { "hpot_jtem_mood" })
    end
}

jd_def["j_hpot_missing_texture"] = { -- Missing Texture
    text = {
        {
            dynatext = {
                string = (
                    function()
                        local r_mult = {}
                        local jank = ""
                        for i = -20, 45 do
                            if i < 0 then
                                jank = "- c."
                            else
                                jank = "+ c."
                            end
                            r_mult[#r_mult + 1] = jank .. math.abs(i)
                        end
                        return r_mult
                    end
                )(),
                colours = { G.C.PURPLE },
                pop_in_rate = 9999999,
                silent = true,
                random_element = true,
                pop_delay = 0.5,
                scale = 0.4,
                min_cycle_time = 0
            }
        }
    }
}

jd_def["j_hpot_power_plant"] = { -- Power Plant
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
        card.joker_display_values.dollars = card.ability.extra.dollars *
            sticker_check(add_tables({ G.jokers.cards, G.playing_cards }), "hpot_uranium")
    end
}

jd_def["j_hpot_sticker_dealer"] = { -- Sticker Addict
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_credits_ex"] = { -- Credits EX
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        },
    },
    reminder_text = {
        { text = "+c.",                            colour = G.C.PURPLE },
        { ref_table = "card.joker_display_values", ref_value = "credits",       colour = G.C.PURPLE },
        { text = " " },
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
        card.joker_display_values.credits = card.ability.extra.credits * card.ability.extra.hands
    end
}

jd_def["j_hpot_leek"] = { -- Leek Hotpot
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            },
        }
    },
}

jd_def["j_hpot_aurae_joker"] = { -- Aurae Joker
    -- Definition left intentionally empty
}
