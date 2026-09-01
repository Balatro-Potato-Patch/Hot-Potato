--todo: fix that issue where a bunch of windows appear after a certain point

function generate_windows()
    G.GAME.window_colours = {}
    G.GAME.current_round.current_hand.scores = G.GAME.current_round.current_hand.scores or {}
    for i = 1, 37 do
        G.GAME.window_colours[i] = get_random_colour()
        G.GAME.current_round.current_hand.scores[i] = 0
    end
end

function get_random_colour()
    return {
        pseudorandom("r"), pseudorandom("g"), pseudorandom("b"), 1
    }
end

function product(tbl)
    local total = 1
    for i, v in pairs(tbl) do
        if v ~= 0 then
            total = total * v
        end
    end
    return total
end

SMODS.Scoring_Calculation {
    key = "multiply_but_gay",
    func = function(self, chips, mult, flames)
        return chips * mult * product(G.GAME.current_round.current_hand.scores)
    end,
    text = 'X',
    replace_ui = function(self)
        local w = 4 / (2 + (G.GAME.windows_unlocked or 0) * 1.2 )
        local nodes = {
            {
                n = G.UIT.C,
                config = { align = 'cm', id = 'hand_chips_container' },
                nodes = {
                    SMODS.GUI.score_container({
                        type = 'chips',
                        text = 'chip_text',
                        align = 'cr',
                        w = w,
                        h = w/2,
                        scale = math.max(0.4 - 0.1 * (G.GAME.windows_unlocked or 0), 0.1)
                    })
                }
            },
            SMODS.GUI.operator(0.4 / (1 + (G.GAME.windows_unlocked or 0))),
            {
                n = G.UIT.C,
                config = { align = 'cm', id = 'hand_mult_container' },
                nodes = {
                    SMODS.GUI.score_container({
                        type = 'mult',
                        w = w,
                        h = w/2,
                        scale = math.max(0.4 - 0.1 * (G.GAME.windows_unlocked or 0), 0.1)
                    })
                }
            }
        }
        if G.GAME.windows_unlocked and to_number(G.GAME.windows_unlocked) > 0 then
            for i = 1, G.GAME.windows_unlocked do
                nodes[#nodes + 1] = SMODS.GUI.operator(0.4 / (1 + (G.GAME.windows_unlocked or 0)))
                nodes[#nodes + 1] = window_container(i, math.max(0.4 - 0.1 * (G.GAME.windows_unlocked or 0), 0.1), w, w/2)
            end
        end
        return { n = G.UIT.R, config = { align = "cm", minh = w/2, padding = 0.1 / (1 + (G.GAME.windows_unlocked or 0)) }, nodes = nodes }
    end
}

function window_container(i, scale, w, h)
    return
    {
        n = G.UIT.C,
        config = { align = 'cm', id = 'hand_' .. i .. '_container' },
        nodes = {
            score_container(i, { w = w, h = h, scale = scale })
        }
    }
end

function score_container(i, args)
    local scale = args.scale or 0.4
    local type = i
    local colour = args.colour or G.GAME.window_colours[i]
    local align = args.align or 'cl'
    local func = args.func or 'hand_type_UI_set'
    local text = args.text or i .. '_text'
    local w = args.w or 2
    local h = args.h or 1
    return
    {
        n = G.UIT.R,
        config = { align = align, minw = w, minh = h, r = 0.1, colour = colour, id = 'hand_' .. type .. '_area', emboss = 0.05 },
        nodes = {
            { n = G.UIT.O, config = { func = 'flame_handler', no_role = true, id = 'flame_mult', object = Moveable(0, 0, 0, 0), w = 0, h = 0, _w = w * 1.25, _h = h * 2.5 } },
            align == 'cl' and { n = G.UIT.B, config = { w = 0.1, h = 0.1 } } or nil,
            {
                n = G.UIT.O,
                config = {
                    id = 'hand_' .. type,
                    func = func,
                    text = text,
                    type = type,
                    scale = scale * 2.3,
                    object = DynaText({
                        string = { { ref_table = G.GAME.current_round.current_hand.scores, ref_value = i } },
                        colours = { G.C.UI.TEXT_LIGHT },
                        font = G.LANGUAGES['en-us'].font,
                        shadow = true,
                        float = true,
                        scale = scale * 2.3
                    })
                }
            },
            align ~= 'cl' and { n = G.UIT.B, config = { w = 0.1, h = 0.1 } } or nil,
        }
    }
end

local parse_highlighted_ref = CardArea.parse_highlighted
function CardArea:parse_highlighted(...)
    if G.GAME.modifiers.windows then
        local text, disp_text, poker_hands = G.FUNCS.get_poker_hand_info(self.highlighted)
        if G.GAME.windows_unlocked then
            for i = 1, G.GAME.windows_unlocked do
                if G.GAME.hands[text] then
                    G.GAME.current_round.current_hand.scores[i] = 1 + (G.GAME.hands[text][i] or 0)
                else
                    G.GAME.current_round.current_hand.scores[i] = 0
                end
            end
        end
    end
    parse_highlighted_ref(self, ...)
end

local level_up_handref = level_up_hand
function level_up_hand(c, hand, ...)
    level_up_handref(c, hand, ...)
    if G.GAME.windows_unlocked and to_number(G.GAME.windows_unlocked) > 0 and G.GAME.hands[hand] then
        for i = 1, G.GAME.windows_unlocked do
            G.GAME.hands[hand][i] = (G.GAME.hands[hand][i] or 0) + 1. / i
        end
    end
end

SMODS.Back {
    name = "Window Deck",
    key = "window",
    pos = { x = 0, y = 0 },
    atlas = "hc_decks",
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.blueprint and not context.repetition and G.GAME.blind.boss then
            G.GAME.windows_unlocked = math.min((G.GAME.windows_unlocked or 0) + 1, 37)
            G.bypass_scoring_ui = true
            return {
                message = localize("k_upgrade_ex"),
                colour = G.GAME.window_colours[G.GAME.windows_unlocked] or G.C.RED
            }
        end
    end,
    apply = function()
        G.GAME.modifiers.windows = true
        G.E_MANAGER:add_event(Event {
            func = function()
                generate_windows()
                SMODS.set_scoring_calculation("hpot_multiply_but_gay")
                return true
            end
        })
    end,
    ppu_coder = { "lord.ruby" },
    ppu_artist = { "lord.ruby" },
    ppu_team = { "Horsechicot" },
}
