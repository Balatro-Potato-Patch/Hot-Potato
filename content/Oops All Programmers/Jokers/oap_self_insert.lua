local choices = { 'trif', 'sadcube', 'astra', 'wix', 'myst', 'lia', 'th30ne' } -- Notice: Same order as sprite sheet
SMODS.Joker {
    key = 'OAP',
    atlas = 'oap_self_insert',
    pos = { x = 0, y = 0 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = {
        extra = {
            effect = 'trif'
        },
        trif_effect = {

        },
        sadcube_effect = {
            modifiers = 2,
            multiplier = 4,
            modifier_resets = 2,
            gain = 1
        },
        astra_effect = {},
        wix_effect = {
            xchips = 1.5
        },
        myst_effect = {
            x_mult = 1,
            count = 0
        },
        th30ne_effect = {
            xmult = 3
        },
    },
    set_ability = function(self, card, initial, delay_sprites)
        local chosen_index = pseudorandom('oap', 1, 7)
        card.ability.extra.effect = choices[chosen_index]
        card.children.center:set_sprite_pos({ x = chosen_index - 1, y = 0 })
    end,
    set_sprites = function(self, card) -- Kept if card is added from debug
        if not card.ability then return end
        for k, v in ipairs(choices) do
            if card.ability.extra and card.ability.extra.effect == v then
                card.children.center:set_sprite_pos({ x = k - 1, y = 0 })
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff) -- Set sprite on card copy
        for k, v in ipairs(choices) do
            if card.ability.extra and card.ability.extra.effect == v then
                if card.quantum then
                    card = card.quantum
                end
                card.children.center:set_sprite_pos({ x = k - 1, y = 0 })
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        local key = 'j_hpot_OAP_' .. card.ability.extra.effect
        local vars = {}

        if card.ability.extra.effect == 'th30ne' then vars = { card.ability.th30ne_effect.xmult } end
        if card.ability.extra.effect == 'wix' then vars = { card.ability.wix_effect.xchips } end
        if card.ability.extra.effect == 'sadcube' then vars = { card.ability.sadcube_effect.modifiers, card.ability
                .sadcube_effect.multiplier, card.ability.sadcube_effect.gain } end
        if card.ability.extra.effect == 'myst' then vars = { card.ability.myst_effect.x_mult } end

        return {
            key = key, vars = vars
        }
    end,

    calculate = function(self, card, context)
        -- th30ne
        if card.ability.extra.effect == 'th30ne' and context.joker_main then
            local aces = {}
            local threes = {}
            for _, playing_card in ipairs(context.scoring_hand) do
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
                            return {
                                xmult = card.ability.th30ne_effect.xmult
                            }
                        end
                    end
                end
            end
        end

        -- theAstra
        if card.ability.extra.effect == 'astra' and context.after and #context.full_hand == 1 and not (context.full_hand[1]:is_face() or context.full_hand[1]:get_id() == 14) and not context.blueprint then
            local initial_card = context.full_hand[1]
            local suit = initial_card.base.suit
            local rank1 = math.floor(initial_card.base.id / 2)
            local rank2 = initial_card.base.id - rank1

            rank1 = rank1 == 1 and 'Ace' or rank1
            rank2 = rank2 == 1 and 'Ace' or rank2

            local card1, card2 = {}, {}

            SMODS.destroy_cards(initial_card)

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    play_sound('slice1')

                    card1 = SMODS.add_card({
                        set = 'Base',
                        rank = '' .. rank1,
                        suit = suit,
                        area = G.play,
                        skip_materialize = true
                    })

                    card2 = SMODS.add_card({
                        set = 'Base',
                        rank = '' .. rank2,
                        suit = suit,
                        area = G.play,
                        skip_materialize = true
                    })

                    card:juice_up(0.3, 0.4)
                    card1:juice_up(0.3, 0.4)
                    card2:juice_up(0.3, 0.4)

                    return true;
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    draw_card(card1.area, G.discard, 1 * 100 / 2, 'down', nil, nil, 0.07, card1)
                    draw_card(card2.area, G.discard, 2 * 100 / 2, 'down', nil, nil, 0.07, card2)
                    return true;
                end
            }))
        end

        --wix
        if card.ability.extra.effect == "wix" and context.individual and context.cardarea == G.play and context.other_card:get_id() == 12 then
            return {
                xchips = card.ability.wix_effect.xchips,
                xchip_message = { message = localize { type = 'variable', key = 'a_xchips', vars = { card.ability.wix_effect.xchips } }, sound = "hpot_forgiveness", volume = 0.5, colour = G.C.CHIPS }
            }
        end

        --SadCube
        if card.ability.extra.effect == 'sadcube' then
            if context.mod_probability and to_number(card.ability.sadcube_effect.modifiers) > 0 then
                if context.from_roll then
                    card.ability.sadcube_effect.modifiers = card.ability.sadcube_effect.modifiers - 1
                end
                return {
                    numerator = context.numerator * card.ability.sadcube_effect.multiplier
                }
            end

            if context.end_of_round and context.cardarea == G.jokers then
                SMODS.scale_card(card, {
                    ref_table = card.ability.sadcube_effect,
                    ref_value = 'modifier_resets',
                    scalar_value = 'gain',
                    message_colour = G.C.GREEN
                })
                card.ability.sadcube_effect.modifiers = card.ability.sadcube_effect.modifier_resets
            end
        end

        -- sorry for the shitty code - myst
        if card.ability.extra.effect == "myst" then
            if G.STATE == G.STATES.HAND_PLAYED and context.modify_scoring_hand and not context.blueprint then
                for _, _card in ipairs(context.scoring_hand) do
                    if _card == context.other_card or SMODS.always_scores(context.other_card) or next(find_joker('Splash')) then
                        if not _card.ability.oap_myst_activated or not _card.ability.oap_myst_activated[card.sort_id] then
                            _card.ability.oap_myst_activated = _card.ability.oap_myst_activated or {}
                            _card.ability.oap_myst_activated[card.sort_id or card.quantum and card.quantum.sort_id] = true

                            if not _card:is_face() then
                                card.ability.myst_effect.count = card.ability.myst_effect.count + 1
                                card:juice_up()
                                SMODS.calculate_effect({
                                    message = localize("k_unscored_ex"),
                                    colour = G.C.PURPLE,
                                }, context.other_card)
                                delay(0.2)
                                return {
                                    remove_from_hand = true,
                                }
                            end
                        end
                    end
                end
            end

            if context.joker_main then
                if card.ability.myst_effect.count > 0 then
                    return {
                        x_mult = card.ability.myst_effect.x_mult * (card.ability.myst_effect.count + 1)
                    }
                end
            end

            if context.after and not context.blueprint then
                for _, v in ipairs(G.playing_cards) do
                    v.ability.oap_myst_activated = nil
                end
                card.ability.myst_effect.count = 0
            end
        end

        -- trif
        if card.ability.extra.effect == "trif" then
            if context.before and #context.full_hand == 5 then
                local chosen = pseudorandom_element({ "enhancement", "edition", "seal", "modification" },
                    "oap_trif_effect")
                local _card = pseudorandom_element(context.full_hand, "oap_trif_card")

                if chosen == "enhancement" then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            _card:flip()
                            play_sound('card1', 1)
                            _card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            _card:set_ability(SMODS.poll_enhancement({ key = "oap_trif", guaranteed = true }))
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            _card:flip()
                            play_sound('tarot2', 0.85, 0.6)
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end

                if chosen == "edition" then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            _card:set_edition(poll_edition("oap_trif", nil, nil, true), true)
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end

                if chosen == "modification" then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            _card:flip()
                            play_sound('card1', 1)
                            _card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            poll_modification(1, _card)
                            reforge_card(_card, true)
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            _card:flip()
                            play_sound('tarot2', 0.85, 0.6)
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end

                if chosen == "seal" then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            _card:set_seal(SMODS.poll_seal({ key = "oap_trif", guaranteed = true }), nil, true)
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
            end
        end

        -- liafeon
        if card.ability.extra.effect == "lia" then
            if context.before and context.scoring_name == "High Card" and G.GAME.current_round.hands_played == 0 then
                for i, v in ipairs(context.scoring_hand) do
                    G.E_MANAGER:add_event(
                        Event({
                            trigger = 'after',
                            delay = 0.15,
                            func = function()
                                v:flip()
                                card:juice_up(0.3, 0.3)
                                play_sound('card1', 0.15); v:juice_up(0.3, 0.3)
                                return true
                            end
                        })
                    )
                    G.E_MANAGER:add_event(
                        Event({
                            trigger = 'after',
                            delay = 0.1,
                            func = function()
                                v:change_suit("Hearts")
                                return true
                            end
                        })
                    )
                    G.E_MANAGER:add_event(
                        Event({
                            trigger = 'after',
                            delay = 0.15,
                            func = function()
                                v:flip()
                                play_sound('tarot2', percent, 0.6)
                                v:juice_up(0.3, 0.3)
                                return true
                            end
                        })
                    )
                end
            end
        end
    end,
    ppu_artist = { 'SadCube' },
    ppu_team = { 'OAP' },
    hpot_unbreedable = true
}
