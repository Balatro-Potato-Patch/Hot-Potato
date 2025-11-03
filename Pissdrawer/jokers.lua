SMODS.Joker {
    key = 'minimum_prize_guarantee',
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    atlas = "pdr_joker",
    pos = { x = 5, y = 1 },
    hotpot_credits = {
        idea = { 'SDM_0' },
        art = { 'Tacashumi' },
        code = { 'SDM_0' },
        team = { 'Pissdrawer' }
    },
    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable and G.plinko_rewards and context.area == G.plinko_rewards then
            if context.consumeable.ability.set == 'bottlecap' and context.consumeable.ability.extra.chosen == 'Bad' then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            SMODS.add_card {
                                set = 'Czech',
                                key_append = 'j_hpot_minimum_prize_guarantee'
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)
                    }))
                    return {
                        message = localize('k_plus_czech'),
                        colour = G.C.SECONDARY_SET.Czech,
                    }
                end
            end
        end
        return nil, true
    end,
}

SMODS.Joker {
    key = 'pwiz',
    loc_txt = { name = 'Piss Wizard', text = { '{C:money}Piss{} escaped the drawer :/' } },
    rarity = 1,
    cost = 5,
    atlas = "pdr_joker",
    pos = { x = 0, y = 0 },
    hotpot_credits = {
        idea = { 'fey <3' },
        art = { 'SDM_0' },
        code = { 'fey <3' },
        team = { 'Pissdrawer' }
    },
    add_to_deck = function(self, card)
        for i, v in pairs(G.C) do
            if (type(G.C[i][1]) == 'number') or SMODS.Gradient[i] then G.C[i] = HEX('DCBA1E') end
        end
    end,
    no_collection = true,
    in_pool = function(self, args)
        return false
    end
}

SMODS.Joker {
    key = 'kindergarten',
    rarity = 3,
    cost = 7,
    blueprint_compat = true,
    atlas = "pdr_joker",
    pos = { x = 0, y = 1 },
    config = { extra = { xmult = 1.75 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    hotpot_credits = {
        idea = { 'SDM_0' },
        art = { 'deadbeet' },
        code = { 'SDM_0' },
        team = { 'Pissdrawer' }
    },
    calculate = function(self, card, context)
        if context.other_joker and context.other_joker.ability.is_nursery_smalled then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
    in_pool = function()
        if G.jokers and G.jokers.cards then
            for _, v in ipairs(G.jokers.cards) do
                if v.ability.is_nursery_smalled then
                    return true
                end
            end
        end
        return false
    end
}

--#region BULLSHIT FOR SOCIAL CREDIT
HotPotato.allcalcs = HotPotato.allcalcs or {
    "main_eval",
    "beat_boss",
    "hook",
    "before",
    "after",
    "main_scoring",
    "individual",
    "repetition",
    "edition",
    "pre_joker",
    "post_joker",
    "joker_main",
    "final_scoring_step",
    "remove_playing_cards",
    "debuffed_hand",
    "end_of_round",
    "pre_discard",
    "discard",
    "open_booster",
    "skipping_booster",
    "buying_card",
    "selling_card",
    "reroll_shop",
    "ending_shop",
    "first_hand_drawn",
    "hand_drawn",
    "using_consumeable",
    "skip_blind",
    "playing_card_added",
    "card_added",
    "check_enhancement",
    "post_trigger",
    "modify_scoring_hand",
    "ending_booster",
    "starting_shop",
    "blind_disabled",
    "blind_defeated",
    "press_play",
    "ignore_debuff",
    "debuff_hand",
    "check",
    "stay_flipped",
    "modify_hand",
    "drawing_cards",
    "pseudorandom_result",
    "result",
    "initial_scoring_step",
    "joker_type_destroyed",
    "check_eternal",
    "trigger",
    "change_rank",
    "change_suit",
    "rank_increase",
    "round_eval",
    "money_altered",
}
local maozedong = win_game
function win_game()
    local ret = maozedong()
    if next(SMODS.find_card('j_hpot_social_credit')) then
        HPTN.set_credits(0)
    end
    return ret
end

SMODS.Sound {
    key = 'gong',
    path = 'sfx_asiangong.ogg'
}

--#endregion

SMODS.Joker {
    key = 'social_credit',
    atlas = "pdr_joker",
    pos = {
        x = 2,
        y = 0
    },
    config = {
        china = 'piss',
        trig = false,
        extra = {
            credit_gain = 0.1,
            social_credit = 0,
            social_credit_max = 1,
            conversion_rate = 2000,
            has_been_added = false
        }
    },
    hotpot_credits = {
        idea = { 'deadbeet' },
        art = { 'deadbeet' },
        code = { 'deadbeet' },
        team = { 'Pissdrawer' }
    },
    unlocked = true,
    discovered = false,
    rarity = 1,
    cost = 5,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    loc_vars = function(self, info_queue, card)
        local key
        local fucking = G.GAME.seeded and "_budget" or ""
        key = (self.key .. fucking)
        return {
            vars = {
                card.ability.extra.credit_gain,
                card.ability.extra.social_credit,
                card.ability.extra.social_credit_max,
                card.ability.extra.conversion_rate
            },
            key = key
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        if not card.ability.extra.has_been_added then
            card.ability.extra.has_been_added = true
            card.ability.china = (HotPotato and HotPotato.allcalcs[math.floor(pseudorandom('china', 1, #HotPotato.allcalcs))]) or
                'piss'
            card:add_sticker('perishable', true)
        end
    end,
    calculate = function(self, card, context)
        if context.game_over then
            HPTN.set_credits(0)
        end
        local hpt = card.ability.extra
        if context[card.ability.china] and card.ability.trig == false and not context.blueprint then
            card.ability.trig = true
            card.ability.china = (HotPotato and HotPotato.allcalcs[math.floor(pseudorandom('china', 1, #HotPotato.allcalcs))])
            hpt.social_credit_max = pseudorandom('social_credit', -1005000, 1000000)
            hpt.social_credit = hpt.social_credit + hpt.social_credit_max
            if to_number(hpt.social_credit) < 0 then
                return {
                    message = localize("k_hotpot_badsocial"),
                    colour = G.C.RED,
                    sound = 'hpot_gong'
                }
            else
                return {
                    message = localize("k_hotpot_goodsocial"),
                    sound = 'hpot_gong'
                }
            end
        end
        if context.end_of_round then
            HPTN.ease_credits(hpt.credit_gain * math.floor(hpt.social_credit / hpt.conversion_rate))
        end
        if context.selling_self and not context.blueprint then
            return {
                message = 'No! Bad!',
                HPTN.set_credits(0)
            }
        end
        if context.post_trigger and context.other_card == card and card.ability.trig == true then
            card.ability.trig = false
        end
    end,
    in_pool = function(self, args)
        return true, { allow_duplicates = true }
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') then
            if to_number(card.ability.extra.social_credit) < 0 then
                card.children.center:set_sprite_pos({ x = 3, y = 0 })
            else
                card.children.center:set_sprite_pos({ x = 2, y = 0 })
            end
        end
    end
}

SMODS.Joker {
    key = 'togore',
    hotpot_credits = {
        idea = { 'Tacashumi' },
        art = { 'Tacashumi' },
        code = { 'fey <3' },
        team = { 'Pissdrawer' }
    },
    config = { extra = { chips = 3 } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.chips
            }
        }
    end,
    rarity = 3, cost = 3,
    blueprint_compat = true,
    atlas = 'pdr_joker',
    pos = { x = 5, y = 0 },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
            return {
                message = '+' .. card.ability.extra.chips .. ' Chips', colour = G.C.CHIPS
            }
        end
    end
}

SMODS.Joker {
    key = 'goblin_tinkerer',
    rarity = 2,
    blueprint_compat = false,
    cost = 6,
    atlas = "pdr_joker",
    pos = { x = 4, y = 0 },
    config = { extra = 0.5 },
    loc_vars = function(self, info_queue, card)
        return { vars = { math.floor(card.ability.extra * 100) } }
    end,
    hotpot_credits = {
        idea = { 'SDM_0' },
        art = { 'SDM_0' },
        code = { 'SDM_0' },
        team = { 'Pissdrawer' }
    },
    add_to_deck = function(self, card, from_debuff)
        G.GAME.goblin_acquired = true
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.goblin_acquired = nil
    end,
    calculate = function(self, card, context)
        if context.reforging and not context.free and not context.blueprint then
            if context.currency == "DOLLAR" then
                ease_dollars(math.floor((G.GAME.cost_dollars - context.card.ability.reforge_dollars) * card.ability
                    .extra))
            elseif context.currency == "CREDIT" then
                HPTN.ease_credits(math.floor((G.GAME.cost_credits - context.card.ability.reforge_credits) *
                    card.ability.extra))
            elseif context.currency == "SPARKLE" then
                ease_spark_points(math.floor((G.GAME.cost_sparks - context.card.ability.reforge_sparks) *
                    card.ability.extra))
            elseif context.currency == "PLINCOIN" then
                ease_plincoins(math.floor((G.GAME.cost_plincoins - context.card.ability.reforge_plincoins) *
                    card.ability.extra))
            elseif context.currency == "CRYPTOCURRENCY" then
                ease_cryptocurrency(math.floor((G.GAME.cost_cryptocurrency - context.card.ability.reforge_cryptocurrency) *
                    card.ability.extra))
            end
            card:juice_up()
        end
    end,
}

SMODS.Joker {
    key = "birthdayboy",
    loc_txt = {
        name = "Birthday Boy",
        text = { { "Happy Birthday, N'!" }, { 'Where would Jujutsu', 'Jokers be without you...' } }
    },
    hotpot_credits = {
        idea = { "deadbeet, BepisFever" },
        art = { "deadbeet" },
        code = { "deadbeet" },
        team = { "Pissdrawer" }
    },
    atlas = "pdr_joker",
    pos = { x = 6, y = 0 },
    soul_pos = { x = 7, y = 0 },
    unlocked = true,
    discovered = true,
    rarity = 4,
    no_collection = true,
    in_pool = function(self, args)
        return false
    end
}

SMODS.Joker {
    key = "vremade_joker",
    hotpot_credits = {
        idea = { "N'" },
        art = { "LocalThunk" },
        code = { "N'" },
        team = { "Pissdrawer" }
    },
    rarity = 1,
    blueprint_compat = true,
    cost = 2,
    config = { extra = { mult = 4 }, },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

-- Vanilla Remade reference lmao
-- First we save the original function to a local variable
-- This will also save any other hooks made before
local card_add_to_deck_ref = Card.add_to_deck
-- Then we make another function with the same parameters as the original
-- As a reminder, this is equivalent to `function Card.add_to_deck(self, from_debuff)`
function Card:add_to_deck(from_debuff)
    local function log(...) end

    -- Here we optionally add any code we want to run before the function
    log("Doing something before the original code")

    -- We then run the original and save its return to a variable
    -- (The arguments, in this case `self` and `from_debuff`, can be modified by your code if necessary)
    -- Keep in mind the original function could also have multiple return values.
    local ret = card_add_to_deck_ref(self, from_debuff)

    -- Here we optionally add any code we want to run after the function
    log("Doing something after the original code")

    -- Finally we return the original return.
    -- (`ret` can be modified by your code if necessary)

    -- This is where we deviate from the example to add the achievement
    if self.config.center_key == "j_hpot_vremade_joker" then
        check_for_unlock({ type = 'candyland_tobu' })
    end

    -- Now back to the example

    return ret
end

SMODS.Joker {
    key = "smods",
    hotpot_credits = {
        idea = { "Eremel" },
        art = { "SDM_0" },
        code = { "SDM_0" },
        team = { "Pissdrawer" }
    },
    config = { extra = { queue_rounds = 0, order_quips = { 1, 2, 3, 4, 5, 6 } } },
    atlas = "pdr_joker",
    pos = { x = 1, y = 1 },
    soul_pos = { x = 2, y = 1 },
    rarity = 4,
    cost = 0,
    discovered = true,
    in_pool = function(self, args)
        return false
    end
}

SMODS.Joker {
    key = "red_deck_joker",
    hotpot_credits = {
        idea = { "Tacashumi" },
        art = { "SDM_0" },
        code = { "SDM_0" },
        team = { "Pissdrawer" }
    },
    config = { extra = { discards = 1, cards_req = 20 } },
    loc_vars = function(self, info_queue, card)
        local discards = card.ability.extra.discards *
            (math.floor((G.playing_cards and #G.playing_cards or 1) / card.ability.extra.cards_req))
        return { vars = { card.ability.extra.discards, card.ability.extra.cards_req, discards } }
    end,
    atlas = "pdr_joker",
    pos = { x = 4, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local discards = to_number(card.ability.extra.discards *
                        (math.floor(#G.playing_cards / card.ability.extra.cards_req)))
                    if discards > 0 then
                        if G.GAME.selected_back.name == 'Red Deck' then
                            check_for_unlock({ type = 'deck_joker', conditions = #G.playing_cards })
                        end
                        ease_discard(discards, nil, true)
                    end
                    return true
                end
            }))
            return nil, true
        end
    end
}

SMODS.Joker {
    key = "blue_deck_joker",
    hotpot_credits = {
        idea = { "Tacashumi" },
        art = { "SDM_0" },
        code = { "SDM_0" },
        team = { "Pissdrawer" }
    },
    config = { extra = { hands = 1, cards_req = 20 } },
    loc_vars = function(self, info_queue, card)
        local hands = card.ability.extra.hands *
            (math.floor((G.playing_cards and #G.playing_cards or 1) / card.ability.extra.cards_req))
        return { vars = { card.ability.extra.hands, card.ability.extra.cards_req, hands } }
    end,
    atlas = "pdr_joker",
    pos = { x = 6, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local hands = to_number(card.ability.extra.hands *
                        (math.floor(#G.playing_cards / card.ability.extra.cards_req)))
                    if hands > 0 then
                        if G.GAME.selected_back.name == 'Blue Deck' then
                            check_for_unlock({ type = 'deck_joker', conditions = #G.playing_cards })
                        end
                        ease_hands_played(hands)
                    end
                    return true
                end
            }))
            return nil, true
        end
    end
}

SMODS.Joker {
    key = "yellow_deck_joker",
    hotpot_credits = {
        idea = { "Tacashumi" },
        art = { "SDM_0" },
        code = { "SDM_0" },
        team = { "Pissdrawer" }
    },
    config = { extra = { dollars = 3, cards_req = 20 } },
    loc_vars = function(self, info_queue, card)
        local dollars = card.ability.extra.dollars *
            (math.floor((G.playing_cards and #G.playing_cards or 1) / card.ability.extra.cards_req))
        return { vars = { card.ability.extra.dollars, card.ability.extra.cards_req, dollars } }
    end,
    atlas = "pdr_joker",
    pos = { x = 7, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local dollars = to_number(card.ability.extra.dollars *
                        (math.floor(#G.playing_cards / card.ability.extra.cards_req)))
                    if dollars > 0 then
                        if G.GAME.selected_back.name == 'Yellow Deck' then
                            check_for_unlock({ type = 'deck_joker', conditions = #G.playing_cards })
                        end
                        SMODS.calculate_effect {
                            card = card,
                            dollars = dollars
                        }
                    end
                    return true
                end
            }))
            return nil, true
        end
    end
}

SMODS.Joker {
    key = "polymorph",
    loc_txt = {
        name = "Polymorphine",
        text = {
            "On {C:attention}selecting a blind{}, all",
            'Jokers to the {C:attention}left{} of this',
            'card become the {C:attention}next',
            'Joker relative to the',
            '{C:attention}collection order'
        }
    },
    hotpot_credits = {
        idea = { "Tacashumi" },
        art = { "Tacashumi" },
        code = { "fey <3" },
        team = { "Pissdrawer" }
    },
    atlas = "pdr_polymorphine",
    rarity = 3,
    blueprint_compat = false,
    cost = 8,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local area = card.area or G.jokers
            local pos = find_self(card, area.cards)
            if not pos then return end
            if pos ~= 1 then
                for i = 1, pos - 1 do
                    local blard = card.area.cards[i]
                    local order = jokerOrder[blard.config.center.key] + 1
                    if order >= #G.P_CENTER_POOLS.Joker then order = 1 end
                    if blard.config.center.set == 'Joker' then
                        blard:set_ability(G.P_CENTER_POOLS.Joker[order])
                        blard:juice_up()
                    end
                end
            end
        end
    end
}
