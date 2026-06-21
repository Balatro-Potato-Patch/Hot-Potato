SMODS.Joker {
    key = "diy",
    atlas = "hc_jokers",
    pos = { x = 7, y = 2 },
    rarity = 3,
    cost = 10,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    add_to_deck = function(self, card)
        if not G.GAME.hotpot_diy then
            G.GAME.DIY_OPEN = true
            G.FUNCS.overlay_menu({ definition = create_UIBox_diy() })
        end
    end,
    calculate = function(self, card, context)
        if HotPotato.diy_trigger(self, card, context) then
            return HotPotato.diy_effect(self, card, context)
        end
    end,
    loc_vars = function(self, q, card)
        if G.GAME.hotpot_diy then
            return {
                key = "j_hpot_diy_full",
                vars = {
                    localize(HotPotato.trigger_options[G.GAME.hotpot_diy.trigger]),
                    localize(HotPotato.effect_options[G.GAME.hotpot_diy.effect])
                }
            }
        end
    end,
    ppu_coder = { "lord.ruby" },
    ppu_artist = { "lord.ruby" },
    ppu_team = { "Horsechicot" },
}

--used in the UI, set them in localization files
HotPotato.trigger_options = {
    "hpot_diy_hand_played",
    "hpot_diy_tarot_sold",
    "hpot_diy_plinko_played",
    "hpot_diy_end_of_round",
    "hpot_diy_organs_harvested",
    "hpot_diy_reforging"
}
HotPotato.effect_options = {
    "hpot_diy_earn_dollars",
    "hpot_diy_earn_plincoins",
    "hpot_diy_earn_credits",
    "hpot_diy_earn_sparks",
    "hpot_diy_earn_crypto",
    "hpot_diy_random_consumable",
    "hpot_diy_random_card"
}
--as in the order they are above. if HotPotato.diy_trigger(blah) then
function HotPotato.diy_trigger(self, card, context)
    if not G.GAME.hotpot_diy then return end
    if G.GAME.hotpot_diy.trigger == 1 then
        return context.joker_main
    elseif G.GAME.hotpot_diy.trigger == 2 then
        return context.selling_card and context.card.config.center.set == "Tarot"
    elseif G.GAME.hotpot_diy.trigger == 3 then
        return context.plinko_started
    elseif G.GAME.hotpot_diy.trigger == 4 then
        return context.end_of_round and context.main_eval
    elseif G.GAME.hotpot_diy.trigger == 5 then
        return context.organs_harvested
    elseif G.GAME.hotpot_diy.trigger == 6 then
        return context.reforging
    end
end

--effect triggered by above if. again, order as they are in that table up there
function HotPotato.diy_effect(self, card, context)
    if not G.GAME.hotpot_diy then return end
    if G.GAME.hotpot_diy.effect == 1 then
        ease_dollars(2)
    elseif G.GAME.hotpot_diy.effect == 2 then
        ease_plincoins(0.5)
    elseif G.GAME.hotpot_diy.effect == 3 then
        HPTN.ease_credits(0.1)
    elseif G.GAME.hotpot_diy.effect == 4 then
        ease_spark_points(1000)
    elseif G.GAME.hotpot_diy.effect == 5 then
        ease_cryptocurrency(0.25)
    elseif G.GAME.hotpot_diy.effect == 6 then
        return {
            message = localize { type = 'variable', key = 'a_cards', vars = { 1 } },
            func = function()
                if G.GAME.consumeable_buffer + #G.consumeables.cards < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event {
                        trigger = "after",
                        func = function()
                            SMODS.add_card { area = G.consumeables, set = "Consumeables" }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    })
                end
            end
        }
    elseif G.GAME.hotpot_diy.effect == 7 then
        local edition = pseudorandom_element(G.P_CENTER_POOLS.Edition, pseudoseed("hpot_diy")).key
        local enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed("hpot_diy")).key
        while G.P_CENTERS[enhancement].no_doe or G.GAME.banned_keys[enhancement] do
            enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed("hpot_diy")).key
        end
        local seal = pseudorandom_element(G.P_CENTER_POOLS.Seal, pseudoseed("hpot_diy")).key
        local card = SMODS.create_card {
            set = "Playing Card",
            seal = seal,
            edition = edition,
            key = enhancement
        }
        table.insert(G.playing_cards, card)
        G.deck:emplace(card)
        card:add_to_deck()
    end
end

--[[

Triggers:
When Hand is Played         DONE
When [POKER HAND] is discarded
When [POKER HAND] is played

Effects:
Gain $2         DONE
Gain 0.5 Plincoin         DONE
Gain 0.1 Credits         DONE
Gain 1000 Joker Exchange         DONE
Gain B.0.25         DONE
Create a random consumable (Must have room)         DONE
]] --

function create_UIBox_diy()
    local trigger_options = {}
    for i, v in pairs(HotPotato.trigger_options) do
        trigger_options[#trigger_options + 1] = localize(v)
    end
    local effect_options = {}
    for i, v in pairs(HotPotato.effect_options) do
        effect_options[#effect_options + 1] = localize(v)
    end
    local t = create_UIBox_generic_options({
        no_back = true,
        contents = {
            create_option_cycle({
                options = trigger_options,
                w = 7.5,
                cycle_shoulders = true,
                opt_callback = "diy_option_trigger",
                current_option = 1,
                colour = G.C.RED,
                no_pips = true,
                focus_args = { snap_to = true, nav = "wide" },
            }),
            create_option_cycle({
                options = effect_options,
                w = 7.5,
                cycle_shoulders = true,
                opt_callback = "diy_option_effect",
                current_option = 1,
                colour = G.C.RED,
                no_pips = true,
                focus_args = { snap_to = true, nav = "wide" },
            }),
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    UIBox_button({
                        button = "diy_apply",
                        label = { localize("k_apply") },
                        minw = 4.5,
                        focus_args = { snap_to = true },
                    }),
                },
            },
        },
    })
    return t
end

function G.FUNCS.diy_apply()
    G.FUNCS:exit_overlay_menu()
    G.GAME.DIY_OPEN = false
    G.GAME.hotpot_diy = G.GAME.hotpot_diy or {}
    G.GAME.hotpot_diy.effect = G.GAME.hotpot_diy.effect or 1
    G.GAME.hotpot_diy.trigger = G.GAME.hotpot_diy.trigger or 1
end

G.FUNCS.diy_option_effect = function(args)
    G.GAME.hotpot_diy = G.GAME.hotpot_diy or {}
    G.GAME.hotpot_diy.effect = args.cycle_config.current_option
end

G.FUNCS.diy_option_trigger = function(args)
    G.GAME.hotpot_diy = G.GAME.hotpot_diy or {}
    G.GAME.hotpot_diy.trigger = args.cycle_config.current_option
end

local keypressed_ref = love.keypressed
function love.keypressed(key, ...)
    if key ~= "escape" or not G.GAME.DIY_OPEN then
        return keypressed_ref(key, ...)
    end
end

local keyreleased_ref = love.keyreleased
function love.keyreleased(key, ...)
    if key ~= "escape" or not G.GAME.DIY_OPEN then
        return keyreleased_ref(key, ...)
    end
end
