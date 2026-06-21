SMODS.Joker {
    key = "precognition",
    rarity = 2,
    cost = 6,
    config = {
        mult = 0,
        mult_mod = 4
    },
    atlas = "hc_jokers",
    pos = { x = 3, y = 0 },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    calculate = function(self, card, context)
        if context.pseudorandom_result then
            if context.result == G.GAME.precognition_guess then
                G.GAME.precognition_guess = nil
                SMODS.scale_card(card, {
                    ref_table = card.ability,
                    ref_value = "mult",
                    scalar_value = "mult_mod"
                })
                play_sound("hpot_correct", nil, 0.25)
            else
                play_sound("hpot_buzzer", nil, 0.15)
                G.GAME.precognition_guess = nil
            end
        elseif context.joker_main then
            return {
                mult = card.ability.mult
            }
        end
    end,
    use = function(self, card)
        G.FUNCS.overlay_menu({ definition = create_UIBox_precognition() })
    end,
    can_use = function(self, card)
        return G.GAME.precognition_guess == nil
    end,
    loc_vars = function(self, q, card)
        return {
            vars = {
                card.ability.mult,
                card.ability.mult_mod
            }
        }
    end,
    ppu_coder = { "lord.ruby" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" },
}

function create_UIBox_precognition()
    local t = create_UIBox_generic_options({
        no_back = true,
        contents = {
            create_option_cycle({
                options = { localize("k_success"), localize("k_failure") },
                w = 4.5,
                cycle_shoulders = true,
                opt_callback = "precognition_trigger",
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
                        button = "precognition_confirm",
                        label = { localize("k_confirm") },
                        minw = 4.5,
                        focus_args = { snap_to = true },
                    }),
                },
            },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    UIBox_button({
                        button = "precognition_exit",
                        label = { localize("k_exit") },
                        minw = 4.5,
                        focus_args = { snap_to = true },
                    }),
                },
            },
        },
    })
    return t
end

G.FUNCS.precognition_trigger = function(args)
    G.GAME.precognition_guess = args.cycle_config.current_option == 1 and true or false
end
G.FUNCS.precognition_exit = function(args)
    G.FUNCS:exit_overlay_menu()
    G.GAME.precognition_guess = nil
end
G.FUNCS.precognition_confirm = function(args)
    G.FUNCS:exit_overlay_menu()
    if G.GAME.precognition_guess == nil then
        G.GAME.precognition_guess = true
    end
end

G.FUNCS.can_use_joker = function(e)
    local center = e.config.ref_table.config.center
    if
        center.can_use and center:can_use(e.config.ref_table) and not G.CONTROLLER.locked
    then
        e.config.colour = G.C.GREEN
        e.config.button = "use_joker"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
G.FUNCS.use_joker = function(e)
    local int = G.TAROT_INTERRUPT
    G.TAROT_INTERRUPT = true
    local center = e.config.ref_table.config.center
    if center.use then
        center:use(e.config.ref_table)
    end
    G.TAROT_INTERRUPT = int
end

--i hate my life
local G_UIDEF_use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local abc = G_UIDEF_use_and_sell_buttons_ref(card)
    if (card.area == G.jokers and G.jokers and card.config.center.use) and not card.debuff then
        sell = {
            n = G.UIT.C,
            config = { align = "cr" },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { ref_table = card, align = "cr", padding = 0.1, r = 0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card', handy_insta_action = 'sell' },
                    nodes = {
                        { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                        {
                            n = G.UIT.C,
                            config = { align = "tm" },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", maxw = 1.25 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('b_sell'), colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true } }
                                    }
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm" },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('$'), colour = G.C.WHITE, scale = 0.4, shadow = true } },
                                        { n = G.UIT.T, config = { ref_table = card, ref_value = 'sell_cost_label', colour = G.C.WHITE, scale = 0.55, shadow = true } }
                                    }
                                }
                            }
                        }
                    }
                },
            }
        }
        transition = {
            n = G.UIT.C,
            config = { align = "cr" },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { ref_table = card, align = "cm", padding = 0.1, r = 0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, button = 'use_joker', func = 'can_use_joker', handy_insta_action = 'use' },
                    nodes = {
                        { n = G.UIT.B, config = { w = 0.1, h = 0.3 } },
                        {
                            n = G.UIT.C,
                            config = { align = "tm" },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", maxw = 1.25 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize(card.config.center.use_key or "b_use"), colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true } }
                                    }
                                },
                            }
                        }
                    }
                },
            }
        }
        return {
            n = G.UIT.ROOT,
            config = { padding = 0, colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { padding = 0, align = 'cl' },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cl' },
                            nodes = {
                                sell
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cl' },
                            nodes = {
                                transition
                            }
                        },
                    }
                },
            }
        }
    end
    return abc
end

SMODS.Sound {
    key = "buzzer",
    path = "sfx_buzzer.mp3"
}

SMODS.Sound {
    key = "correct",
    path = "sfx_correct.mp3"
}
