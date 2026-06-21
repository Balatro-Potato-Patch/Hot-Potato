local jtemdatlas = SMODS.Atlas {
    path = "Jtem/Decks.png",
    key = "jtemdatlas",
    px = 71,
    py = 95
}

local shader = SMODS.Shader {
    key = "jtem_deckshader",
    path = "deck.fs"
}

local deck = SMODS.Back {
    key = "domn",
    atlas = "jtemdatlas",
    shader = "jtem_deckshader",
    apply = function(self)
        -- Team Name's Addition  Starting deck cards has a random sticker
        G.GAME.modifiers.hpot_all_sticker = true
        -- end
    end,
    calculate = function(self, back, context)
        --Horsechicot Addition  Cards give 0.05 bitcoins when triggered
        if context.post_trigger and (context.other_card.ability and context.other_card.ability.set == 'Joker')
            and not (context.other_context.mod_probability or context.other_context.fix_probability or context.other_context.check_eternal) then
            ease_cryptocurrency(0.05)
        end
        --Oops! All Programmers addition: gain 1 of each currency when boss blind defeated
        --[[if context.round_eval and G.GAME.last_blind and G.GAME.last_blind.boss then
            add_round_eval_plincoins({name='plincoins', plincoins = 1})
            ease_cryptocurrency(1)
            ease_spark_points(1)
            HPTN.ease_credits(1)
        end]] -- Moved into a lovely patch by UnusedParadox
        --Pissdrawer addition: Chips and mult from highest poker hand held in hand is added to scoring
        if context.initial_scoring_step then
            if G.hand and G.hand.cards and #G.hand.cards > 0 then
                local old_hand, old_disp_text = G.FUNCS.get_poker_hand_info(G.play.cards)
                local poker_hand, disp_text = G.FUNCS.get_poker_hand_info(G.hand.cards)
                if G.GAME.hands[old_hand] and G.GAME.hands[poker_hand] then
                    update_hand_text(
                        { nopulse = nil, delay = 0 },
                        { handname = disp_text, level = G.GAME.hands[poker_hand].level, mult = mult, chips = hand_chips }
                    )
                    update_hand_text({ sound = 'chips2', volume = 0.7, pitch = 1.1, delay = 0 },
                        { chips = '+' .. G.GAME.hands[poker_hand].chips, StatusText = true })
                    update_hand_text({ sound = 'multhit1', volume = 0.7, pitch = 1.1, delay = 1.25 },
                        { mult = '+' .. G.GAME.hands[poker_hand].mult, StatusText = true })
                    update_hand_text(
                        { nopulse = nil, delay = 0 },
                        { handname = old_disp_text, level = G.GAME.hands[old_hand].level, mult = mult, chips = hand_chips }
                    )
                    return {
                        chips = G.GAME.hands[poker_hand].chips,
                        remove_default_message = true,
                        extra = {
                            mult = G.GAME.hands[poker_hand].mult,
                            remove_default_message = true
                        }
                    }
                end
            end
        end
    end,
    ppu_artist = { 'Squidguset' },
    ppu_coder = { 'All of us' },
    ppu_team = { 'Everyone' },
}

-- gives the deck a shader (stolen from TMD teehee :3)
SMODS.DrawStep {
    key = 'jtemedition_deck',
    order = 5,
    func = function(self)
        if self.children.back then
            local cback = self.params.galdur_back or (not self.params.viewed_back and G.GAME.selected_back) or
            (self.params.viewed_back and G.GAME.viewed_back)
            if cback then
                local shader = nil
                if cback.effect.center.shader then shader = cback.effect.center.shader end

                -- back has shader
                if (shader
                        -- if this is a sleeve, ignore it
                        and (self.config.center.set ~= "Sleeve"))
                    -- not the stake select from galdur or the stake chips
                    and ((self.area and not self.area.config.stake_select and not self.area.config.stake_chips) or not self.area) then
                    local t = (self.area and self.area.config.type == "deck") or self.config.center.set == "Back"
                    if t and not self.states.drag.is then self.ARGS.send_to_shader = { 1.0, self.ARGS.send_to_shader[2] } end

                    self.children.back:draw_shader(shader, nil, self.ARGS.send_to_shader, t, self.children.center, 0, 0)
                end
            end
        end
    end,
    conditions = { vortex = false, facing = 'back' },
}

HotPotato.currencies = {
    { text = "$", color = G.C.MONEY, font = nil },
    { text = localize('$'), color = SMODS.Gradients.hpot_plincoin, font = SMODS.Fonts.hpot_plincoin },
    { text = "͸", color = G.C.BLUE, font = SMODS.Fonts.hpot_plincoin },
    { text = "£", color = SMODS.Gradients.hpot_advert, font = SMODS.Fonts.hpot_plincoin },
    { text = "c", color = G.C.PURPLE, font = SMODS.Fonts.hpot_plincoin },
}

function add_round_eval_all_currencies(config)
    local config = config or {}
    local width = G.round_eval.T.w - 0.51
    local num_dollars = to_big(1)
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
            table.insert(left_text,
                { n = G.UIT.O, config = { object = DynaText({ string = config.card.loc_name, colours = { G.C.FILTER }, shadow = true, pop_in = 0, scale = 0.6 * scale, silent = true }) } })
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
            return true
        end
    }))
    local dollar_row = 0
    for i = 1, to_number(num_dollars) or 1 do
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
                for _, v in ipairs(HotPotato.currencies) do
                    local r = {
                        n = G.UIT.T,
                        config = {
                            text = v.text,
                            font = v.font,
                            colour = v.color,
                            scale = ((num_dollars > to_big(20) and 0.28) or (num_dollars > to_big(9) and 0.43) or 0.58),
                            shadow = true,
                            hover = true,
                            can_collide = false,
                            juice = true
                        }
                    }
                    play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7 - (num_dollars > to_big(20) and 0.2 or 0))

                    G.round_eval:add_child(r, G.round_eval:get_UIE_by_ID('dollar_row_' .. (dollar_row) ..
                    '_' .. config.name))
                    G.VIBRATION = G.VIBRATION + 0.4
                end
                return true
            end
        }))
    end

    -- might cause issues. Dollars cashout adds up everything and sends "bottom" cashout. Might need similar implementation if more plincoin cashouts are added
    G.GAME.current_round.spark_points = G.GAME.current_round.spark_points + 1
    G.GAME.current_round.credits = G.GAME.current_round.credits + 1
    G.GAME.current_round.cryptocurrency = G.GAME.current_round.cryptocurrency + 1
    G.GAME.current_round.plincoins = G.GAME.current_round.plincoins + 1
end
