
PissDrawer = {
    shop_scale = 0.85
}
PissDrawer.Shop = {}

local menu = G.FUNCS.go_to_menu
G.FUNCS.go_to_menu = function(e)
    local ret = menu(e)
    PissDrawer.Shop.active_tab = nil
    return ret
end

local runstart = Game.start_run
Game.start_run = function(self, args)
    local ret = runstart(self, args)
    PissDrawer.Shop.active_tab = nil
    return ret
end

local calcreroll = calculate_reroll_cost
calculate_reroll_cost = function(...)
    if not HotPotato.adding_from_storage then
        calcreroll(...)
    end
end

SMODS.Atlas({
    key = 'pissdrawer_shop',
    path = 'Pissdrawer/shop_buttons.png',
    px = 66,
    py = 66
})

SMODS.Atlas({
    key = 'pissdrawer_shop_icons',
    path = 'Pissdrawer/shop_icons.png',
    px = 36,
    py = 36
})

SMODS.Atlas({
    key = 'pissdrawer_shop_sign_currency',
    path = 'Pissdrawer/shop_sign_currency.png',
    px = 113,
    py = 57,
    frames = 4,
    atlas_table = 'ANIMATION_ATLAS'
})

SMODS.Atlas({
    key = 'pissdrawer_shop_sign_training',
    path = 'Pissdrawer/shop_sign_training.png',
    px = 113,
    py = 57,
    frames = 4,
    atlas_table = 'ANIMATION_ATLAS'
})

function PissDrawer.Shop.is_temp_joker_area(area)
    return area and (
        area == G.train_jokers
        or area == G.reforge_area
        or area == G.nursery_father
        or area == G.nursery_mother
        or (PissDrawer.Shop.is_tab_swap and (
            area == G.shop_jokers
            or area == G.shop_vouchers
            or area == G.shop_booster
        ))
    )
end

local pissdrawer_cardarea_align_cards = CardArea.align_cards
function CardArea:align_cards()
    pissdrawer_cardarea_align_cards(self)
    if self.config.hotpot_shop or self.config.wheel_rewards then
        for _, card in ipairs(self.cards or {}) do
            if not card.pissdrawer then
                card.pissdrawer = PissDrawer.shop_scale
                card:hotpot_resize(PissDrawer.shop_scale)
                if self.config.wheel_rewards then
                    card.pissdrawer = PissDrawer.shop_scale ^ 2
                    card:hotpot_resize(PissDrawer.shop_scale)  
                end
            end
        end
    else
         for _, card in ipairs(self.cards or {}) do
            if card.pissdrawer then
                card:hotpot_resize(1/card.pissdrawer)
                card.pissdrawer = nil
            end
        end
    end
    if self == G.wheel_rewards and #self.cards > 1 then
        -- Align wheel rewards in a circle
        local self_w = math.max(self.T.w, 3.2)
        local positions = PissDrawer.Shop.circle_coords(G.CARD_W * 1.25, 8)
        for i = 1, math.min(#self.cards, 8) do
            local card = self.cards[i]
            card.T.x = self.T.x + self.T.w/2 - (G.CARD_W * PissDrawer.shop_scale^2)/2 + positions[i].x + (G.CARD_W*(PissDrawer.shop_scale^2) - card.T.w)/2
            card.T.y = self.T.y + self.T.h/2 - (G.CARD_H * PissDrawer.shop_scale^2)/2 + positions[i].y + (G.CARD_H*(PissDrawer.shop_scale^2) - card.T.h)/2
            if i % 4 == 0 then
                card.T.r = 0.3
            elseif i % 4 == 2 then
                card.T.r = -0.3
            end
        end
    end
    if self == G.wheel_arrow and #self.cards > 0 then
        self.cards[1].T.y = self.cards[1].T.y - 3.15
        self.cards[1].T.x = self.cards[1].T.x - 0.15
    end
end

function PissDrawer.Shop.circle_coords(radius, numCards)
    local coords = {}
    for i = 0, numCards - 1 do
        local angle = (2 * math.pi * i / numCards)
        local x = radius * math.cos(angle) * 0.9
        local y = radius * math.sin(angle) * 0.9
        if i % 2 == 1 then
            x = x * 0.85
            y = y * 1.1
        end
        table.insert(coords, {x = x, y = y})
    end
    return coords
end


function PissDrawer.Shop.currency_node(args)
    assert(type(args) == 'table', 'No table provided to shop_currency_node')

    return {n=G.UIT.C, config = {align = 'cm', id = 'hotpot_currency_'..(args.id or args.ref_value), minh = args.minh or 0.6, minw = args.minw or 2, colour = G.C.DYN_UI.BOSS_MAIN, r = 0.1}, nodes = {
                {n=G.UIT.R, config = {align='cm'}, nodes = {
                    {n=G.UIT.O, config={object = DynaText({string = {{ref_table = args.ref_table or G.GAME, ref_value = args.ref_value, prefix = args.symbol}},
                        maxw = args.maxw or 2, colours = {args.colour}, font = args.font, shadow = true, spacing = 2, bump = not args.no_bump, scale = args.scale or 0.5})}}
                }}
            }}
end

function PissDrawer.Shop.currency_display()
    local jank = 
    PissDrawer.Shop.currency_node({
        symbol = localize('hotpot_reforge_credits'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.PURPLE, ref_value =
    'TNameCredits', ref_table = G.PROFILES[G.SETTINGS.profile], no_bump = true
    })
    if G.GAME.seeded then
        jank = 
    PissDrawer.Shop.currency_node({
        symbol = localize('hotpot_reforge_budget'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.ORANGE, ref_value =
    'budget', ref_table = G.GAME, no_bump = true, id = 'TNameCredits'
    })
    end
    return {
       n=G.UIT.R,
        config = { align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.1 },
        nodes = {
            PissDrawer.Shop.currency_node({
                symbol = localize('$'), colour = G.C.GOLD, ref_value = 'dollars', no_bump = true
            }),
            PissDrawer.Shop.currency_node({
                symbol = '$', font = SMODS.Fonts.hpot_plincoin, colour = SMODS.Gradients["hpot_plincoin"], ref_value =
            'plincoins'
            }),
            PissDrawer.Shop.currency_node({
                symbol = '£', font = SMODS.Fonts.hpot_plincoin, colour = SMODS.Gradients["hpot_advert"], ref_value =
            'cryptocurrency'
            }),
            PissDrawer.Shop.currency_node({
                symbol = localize('hotpot_reforge_sparks'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.BLUE, ref_value =
            'spark_points', no_bump = true
            }),
            jank,
            not G.GAME.modifiers.hpot_plinko_4ever and {
               n=G.UIT.C,
                config = { align = 'cm', minh = 0.6, minw = 0.6, outline = 1, outline_colour = G.C.BLUE, colour = G.C.DYN_UI.BOSS_MAIN, r = 0.1, padding = 0.05, hover = true, button = 'open_exchange', func = 'can_open_exchange', button_dist = 0.1, shadow = true, shadow_height = 0.25 },
                nodes = {
                    {n=G.UIT.O, config = { object = Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['hpot_pissdrawer_shop_icons'], { x = 1, y = 0 }) } },
                }
            }
        }
    }
end
-- PIN
function PissDrawer.Shop.currency_display_small(args)
    local args = args or {}
    local minh, minw, maxw, scale = 0.5, 1.4, 1.4, 0.4
    local jank = PissDrawer.Shop.currency_node({
            symbol = localize('hotpot_reforge_credits'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.PURPLE, ref_value = 'TNameCredits', ref_table = G.PROFILES[G.SETTINGS.profile], no_bump = true, minh = minh, minw = minw, maxw = maxw, scale = scale
        })
        if G.GAME.seeded then
jank = PissDrawer.Shop.currency_node({
            symbol = localize('hotpot_reforge_budget'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.ORANGE, ref_value = 'budget', ref_table = G.GAME, no_bump = true, minh = minh, minw = minw, maxw = maxw, scale = scale
        })
        end
    local currencies = {
        PissDrawer.Shop.currency_node({
            symbol = localize('$'), colour = G.C.GOLD, ref_value = 'dollars', no_bump = true, minh = minh, minw = minw, maxw = maxw, scale = scale
        }),
        PissDrawer.Shop.currency_node({
            symbol = '$', font = SMODS.Fonts.hpot_plincoin, colour = SMODS.Gradients["hpot_plincoin"], ref_value = 'plincoins', minh = minh, minw = minw, maxw = maxw, scale = scale
        }),
        PissDrawer.Shop.currency_node({
            symbol = '£', font = SMODS.Fonts.hpot_plincoin, colour = SMODS.Gradients["hpot_advert"], ref_value = 'cryptocurrency', minh = minh, minw = minw, maxw = maxw, scale = scale
        }),
        PissDrawer.Shop.currency_node({
            symbol = localize('hotpot_reforge_sparks'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.BLUE, ref_value = 'spark_points', no_bump = true, minh = minh, minw = minw, maxw = maxw, scale = scale
        }),
        jank
    }

    if args.remove_dollars then
        table.remove(currencies, 1)
    end

    return {n=G.UIT.R, config = {align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.1}, nodes = currencies }
end

function PissDrawer.Shop.tab_button(args)
    assert(type(args) == 'table', 'No table provided to shop_tab_button')
    local notify = false
    if args.destination == "hotpot_jtem_toggle_delivery" then
        for _, obj in ipairs(G.GAME.hp_jtem_delivery_queue) do
            if obj.rounds_passed == obj.rounds_total then
                notify = true
                break
            end
        end
    end

    return
        {n=G.UIT.C, config = {align = 'bm'}, nodes = {
            {n=G.UIT.R, config = {align = 'tl', padding = 0.1, r = 0.1, colour = G.C.DYN_UI.MAIN, minh = 0.75, hover = true, func = 'shop_tab_active', button = 'toggle_shop_tab', destination = args.destination, id = 'hotpot_shop_tab_'..args.destination}, nodes = {
                {n=G.UIT.R, config = {align = 'cl'}, nodes = {
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS[args.atlas or 'hpot_jtem_pkg'], { x = args.x or 0, y = args.y or 0 })}},
                    {n=G.UIT.T, config = {text= args.label or ' no label', colour =G.C.WHITE, scale = 0.35, shadow = true}},
                    notify and {
                        n=G.UIT.C,
                        config = { maxw = 0, maxh = 0, w = 0, h = 0, minw = 0, minh = 0 },
                        nodes={
                            {n=G.UIT.O, config = {
                                maxw = 0, maxh = 0, w = 0, h = 0, minw = 0, minh = 0,
                                object = UIBox{
                                    definition = hp_jtem_create_UIBox_card_alert({ bg_col = G.C.RED }), 
                                    config = { align= "tri", offset = {x = 0.3, y = -0.3}}
                                }
                            }},
                        }
                    }
                }},
            }}
        }}
end

G.FUNCS.shop_tab_active = function(e)
    if
        PlinkoLogic.STATE == PlinkoLogic.STATES.IN_PROGRESS
        or PlinkoLogic.STATE == PlinkoLogic.STATES.REWARD
        or Wheel.STATE.SPUN
    then
        e.config.button = nil
    else
        e.config.button = "toggle_shop_tab"
    end
    if e.config.id == PissDrawer.Shop.active_tab then
        e.config.colour = lighten(G.C.DYN_UI.MAIN, 0.2)
        if e.config.minh ~= 1.1 then
            e.config.minh = 1.1
            e.UIBox:recalculate()
            e.UIBox:recalculate()
        end
    else
        e.config.colour = G.C.DYN_UI.BOSS_MAIN
        if e.config.minh ~= 0.75 then
            e.config.minh = 0.75
            e.UIBox:recalculate()
            e.UIBox:recalculate()
        end
    end
end

G.FUNCS.toggle_shop_tab = function(e)
    if PissDrawer.Shop.active_tab.exchange then
        PissDrawer.Shop.active_tab.exchange.config.colour = G.C.BLACK
    end
    PissDrawer.Shop.active_tab = e.config.id
    G.FUNCS[e.config.destination]()
end

G.FUNCS.can_open_exchange = function(e)
    if
        PlinkoLogic.STATE == PlinkoLogic.STATES.IN_PROGRESS
        or PlinkoLogic.STATE == PlinkoLogic.STATES.REWARD
        or Wheel.STATE.SPUN
    then
        e.config.button = nil
    else
        e.config.button = "open_exchange"
    end
    if not (PissDrawer.Shop.active_tab and PissDrawer.Shop.active_tab.exchange) then
        e.config.outline_colour = G.C.BLUE
    end
end

G.FUNCS.open_exchange = function(e)
    PissDrawer.Shop.active_tab = {exchange = e}
    e.config.colour = darken(G.C.BLUE, 0.2)
    e.config.outline_colour = lighten(G.C.BLUE, 0.4)
    PissDrawer.Shop.change_shop_sign("hpot_pissdrawer_shop_sign_currency")
    PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.currency_exchange)
end

G.FUNCS.open_nursery = function(e)
    PissDrawer.Shop.active_tab = "hotpot_nursery"
    PissDrawer.Shop.change_shop_sign('hpot_nursery_sign')
    PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.nursery, PissDrawer.Shop.create_nursery_areas, PissDrawer.Shop.reload_shop_areas, PissDrawer.Shop.area_keys.nursery)
    G.STATE = G.STATES.NURSERY
    ease_background_colour({new_colour = HEX("75cdff"), special_colour = HEX("ff8ff4"), tertiary_colour = darken(G.C.BLACK,0.1), contrast = 3})
end

G.FUNCS.open_plinko = function(e)
    PissDrawer.Shop.active_tab = "hotpot_plinko"
    PissDrawer.Shop.change_shop_sign('hpot_plinko_sign')
    PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.plinko, nil, PissDrawer.Shop.gen_plinko)
    G.STATE = G.STATES.PLINKO
    G.STATE_COMPLETE = false
    PlinkoLogic.STATE = PlinkoLogic.STATES.IDLE
    ease_background_colour({new_colour = HEX("75cdff"), special_colour = HEX("ff8ff4"), tertiary_colour = darken(G.C.BLACK,0.1), contrast = 3})
end

G.FUNCS.open_wheel = function(e)
    PissDrawer.Shop.active_tab = "hotpot_wheel"
    PissDrawer.Shop.change_shop_sign('hpot_tname_arrow_sign')
    PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.wheel, nil, set_wheel)
    G.STATE = G.STATES.WHEEL
    ease_background_colour({new_colour = G.C.GOLD, special_colour = G.C.BLACK, tertiary_colour = darken(G.C.BLACK,0.4), contrast = 3})
end

PissDrawer.Shop.gen_plinko = function()
    PlinkoLogic.f.generate_rewards()
    PlinkoUI.f.adjust_rewards()
end

PissDrawer.Shop.change_shop_sign = function(atlas, sound)
    local sign_sprite = G.SHOP_SIGN.UIRoot.children[1].children[1].children[1].config.object
    ease_background_colour_blind(G.STATES.SHOP)
    G.HP_JTEM_DELIVERY_VISIBLE = nil
    simple_add_event(function()
        sign_sprite.pinch.y = true
        delay(0.5)
        simple_add_event(function()
            sign_sprite.atlas = G.ANIMATION_ATLAS[atlas]
            sign_sprite.pinch.y = false
            return true
        end)
        return true
    end, { trigger = "after", delay = 0 })
    if type(sound) ~= 'table' then
        sound = {key = sound}
    end
    play_sound(sound.key or "hpot_sfx_whistleup", sound.percent or nil, sound.volume or 0.25)
end

PissDrawer.Shop.change_shop_panel = function(shop_ui, pre, post, areas)
    if PlinkoLogic.STATE ~= PlinkoLogic.STATES.CLOSED then PlinkoLogic.STATE = PlinkoLogic.STATES.CLOSED; G.STATE = G.STATES.SHOP end
    if G.STATE == G.STATES.WHEEL then G.STATE = G.STATES.SHOP end
    if G.STATE == G.STATES.NURSERY then G.STATE = G.STATES.SHOP end
    PissDrawer.Shop.is_tab_swap = true
    local main_shop_body = G.shop:get_UIE_by_ID('main_shop_body')
    main_shop_body:remove()
    PissDrawer.Shop.is_tab_swap = nil
    if pre then pre() end
    main_shop_body.UIBox:add_child(shop_ui(), main_shop_body)
    if post then post(areas) end
    main_shop_body.UIBox:recalculate()
    if #G.jokers.highlighted > 0 then
        for _, joker in ipairs(G.jokers.highlighted) do
            joker:highlight(true)
        end
    end
end

G.FUNCS.return_to_shop = function()
    PissDrawer.Shop.change_shop_sign("shop_sign")
    PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.main_shop, PissDrawer.Shop.create_shop_areas, PissDrawer.Shop.reload_shop_areas, PissDrawer.Shop.area_keys.shop)
    ease_background_colour_blind(G.STATES.SHOP)
end

G.FUNCS.hotpot_pissdrawer_toggle_training = function()
    PissDrawer.Shop.change_shop_sign("hpot_pissdrawer_shop_sign_training")
    PissDrawer.Shop.change_shop_panel(G.UIDEF.hotpot_pd_training_section, PissDrawer.Shop.create_training_areas, PissDrawer.Shop.reload_shop_areas, PissDrawer.Shop.area_keys.training)
    ease_background_colour({new_colour = HEX("FF850BA4"), special_colour = HEX("FF8C6927"), tertiary_colour = HEX("FFDD7EFF"), contrast = 8})
end

local shop = G.UIDEF.shop
function G.UIDEF.shop()
    PissDrawer.Shop.create_shop_areas()
    shop()
    PissDrawer.Shop.active_tab = 'hotpot_shop_tab_return_to_shop'
    if G.GAME.modifiers.no_shop_jokers then
        return {n=G.UIT.ROOT, config = {align = 'cl', colour = G.C.CLEAR}, nodes={
                    {n=G.UIT.C, config = {align = 'cm'}, nodes = {
                        -- Buttons across top of shop to swtich between different shop areas
                        {n=G.UIT.R, config = {align = 'bl', minh = 0.8, colour = G.C.CLEAR, padding = -0.2}, nodes = not G.GAME.modifiers.hpot_plinko_4ever and { -- Don't show these tab nodes if playing Plinko 4Ever
                            {n=G.UIT.B, config = {w = 0.92, h=0.1}},
                            PissDrawer.Shop.tab_button({
                                atlas = 'hpot_pissdrawer_shop_icons', destination = 'return_to_shop', label = ' Shop'
                            }),
                            {n=G.UIT.B, config = {w = 0.67, h=0.1}},
                            PissDrawer.Shop.tab_button({
                                atlas = 'hpot_tname_shop_reforge', destination = 'hotpot_tname_toggle_reforge', label = ' Reforge'
                            }),
                            {n=G.UIT.B, config = {w = 0.67, h=0.1}},
                            PissDrawer.Shop.tab_button({
                                atlas = 'hpot_horsechicot_market', destination = 'hotpot_horsechicot_toggle_market', label = ' Black Market'
                            }),
                            {n=G.UIT.B, config = {w = 0.67, h=0.1}},
                            PissDrawer.Shop.tab_button({
                                atlas = 'hpot_pissdrawer_shop_icons', x = 2, destination = 'hotpot_pissdrawer_toggle_training', label = ' Training'
                            }),
                        }},
                        -- Main shop nodes
                        {n=G.UIT.R, config = {align = 'cm', colour = G.C.DYN_UI.MAIN, padding = 0.08, r = 0.1}, nodes = {
                            {n=G.UIT.C, config={align = "cm", padding = 0.1, emboss = 0.05, r = 0.1, colour = G.C.DYN_UI.BOSS_MAIN}, nodes={
                                -- Currency container
                                PissDrawer.Shop.currency_display(),
                                -- spacer
                                {n=G.UIT.R, config={minh = 0.2}},
                                -- Top shop row
                                {n=G.UIT.R, config = {id = 'main_shop_body', align = 'cm'}, nodes = {
                                    PissDrawer.Shop.main_shop()
                                }},
                                {n=G.UIT.R, config={minh = 0.5}},
                            }},
                        }},
                    }},
                }}
    end
    return {n=G.UIT.ROOT, config = {align = 'cl', colour = G.C.CLEAR}, nodes={
                {n=G.UIT.C, config = {align = 'cm'}, nodes = {
                    -- Buttons across top of shop to swtich between different shop areas
                    {n=G.UIT.R, config = {align = 'bl', minh = 0.8, colour = G.C.CLEAR, padding = -0.2}, nodes = not G.GAME.modifiers.hpot_plinko_4ever and { -- Don't show these tab nodes if playing Plinko 4Ever
                        {n=G.UIT.B, config = {w = 0.75, h=0.1}},
                        PissDrawer.Shop.tab_button({
                            atlas = 'hpot_pissdrawer_shop_icons', destination = 'return_to_shop', label = ' Shop'
                        }),
                        {n=G.UIT.B, config = {w = 0.55, h=0.1}},
                        PissDrawer.Shop.tab_button({
                            atlas = 'hpot_jtem_pkg', destination = 'hotpot_jtem_toggle_delivery', label = ' Deliveries'
                        }),
                        {n=G.UIT.B, config = {w = 0.55, h=0.1}},
                        PissDrawer.Shop.tab_button({
                            atlas = 'hpot_tname_shop_reforge', destination = 'hotpot_tname_toggle_reforge', label = ' Reforge'
                        }),
                        {n=G.UIT.B, config = {w = 0.55, h=0.1}},
                        PissDrawer.Shop.tab_button({
                            atlas = 'hpot_horsechicot_market', destination = 'hotpot_horsechicot_toggle_market', label = ' Black Market'
                        }),
                        {n=G.UIT.B, config = {w = 0.55, h=0.1}},
                        PissDrawer.Shop.tab_button({
                            atlas = 'hpot_pissdrawer_shop_icons', x = 2, destination = 'hotpot_pissdrawer_toggle_training', label = ' Training'
                        }),
                    }},
                    -- Main shop nodes
                    {n=G.UIT.R, config = {align = 'cm', colour = G.C.DYN_UI.MAIN, padding = 0.08, r = 0.1}, nodes = {
                        {n=G.UIT.C, config={align = "cm", padding = 0.1, emboss = 0.05, r = 0.1, colour = G.C.DYN_UI.BOSS_MAIN}, nodes={
                            -- Currency container
                            PissDrawer.Shop.currency_display(),
                            -- spacer
                            {n=G.UIT.R, config={minh = 0.2}},
                            -- Top shop row
                            {n=G.UIT.R, config = {id = 'main_shop_body', align = 'cm'}, nodes = {
                                PissDrawer.Shop.main_shop()
                            }},
                            {n=G.UIT.R, config={minh = 0.5}},
                        }},
                    }},
                }},
            }}
    end

function PissDrawer.Shop.main_shop()
    -- Reroll button for unknown goddamn reason just stuck, so I'll unstuck it
    G.E_MANAGER:add_event(Event({
        blocking = false,
        no_delete = true,
        func = function()
            local reroll = G.shop and G.shop:get_UIE_by_ID('shop_reroll')
                if reroll and reroll.UIBox then
                reroll.UIBox:recalculate()
            end
            return true
        end,
    }))
    return
    {n=G.UIT.C, nodes = {
        {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                {n=G.UIT.R,config={id = 'next_round_button', align = "cm", minw = 1.8, minh = 1.3, r=0.15,colour = G.C.RED, one_press = true, button = 'toggle_shop', hover = true,shadow = true}, nodes = {
                    {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'y', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                        {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                            {n=G.UIT.T, config={text = localize('b_next_round_1'), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                        }},
                        {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                            {n=G.UIT.T, config={text = localize('b_next_round_2'), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                        }}
                    }},
                }},
                {n=G.UIT.R, config={id = 'shop_reroll', align = "cm", minw = 1.8, minh = 1.3, r=0.15,colour = G.C.GREEN, button = 'reroll_shop', func = 'can_reroll', hover = true,shadow = true}, nodes = {
                    {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'x', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                        {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                            {n=G.UIT.T, config={text = localize('k_reroll'), scale = 0.4, colour = G.C.WHITE, shadow = true}},
                        }},
                        {n=G.UIT.R, config={align = "cm", maxw = 1.3, minw = 1}, nodes={
                            {n=G.UIT.T, config={text = localize('$'), scale = 0.7, colour = G.C.WHITE, shadow = true}},
                            {n=G.UIT.T, config={ref_table = G.GAME.current_round, ref_value = 'reroll_cost', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                        }}
                    }}
                }},
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, emboss = 0.05, minw = 8.0}, nodes={
                {n=G.UIT.O, config={object = G.shop_jokers}},
            }},
            {n=G.UIT.C, config = {align='cm', padding = 0.1}, nodes = {
                {n=G.UIT.R, config={align = "cm", minw = 0.5, maxw = 0.7, minh = 0.8, r=0.15,colour = G.C.CLEAR, id = "show_plinko_button", button = 'open_plinko', shadow = true}, nodes = {
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 0.9, 0.9, G.ASSET_ATLAS['hpot_pissdrawer_shop'], { x = 0, y = 0 }), shadow = true, hover = true, button_dist = 0.63}},
                }},

                {n=G.UIT.R, config={align = "cm", minw = 0.5, maxw = 0.7, minh = 0.8, r=0.15,colour = G.C.CLEAR, id = "show_wheel_button", button = 'open_wheel', shadow = true}, nodes = {
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 0.9, 0.9, G.ASSET_ATLAS['hpot_pissdrawer_shop'], { x = 1, y = 0 }), shadow = true, hover = true, button_dist = 0.63}},
                }},

                {n=G.UIT.R, config={align = "cm", minw = 0.5, maxw = 0.7, minh = 0.8, r=0.15,colour = G.C.CLEAR, id = "show_nursery_button", button = 'open_nursery', shadow = true}, nodes = {
                    {n=G.UIT.O, config = {object = Sprite(0, 0, 0.9, 0.9, G.ASSET_ATLAS['hpot_pissdrawer_shop'], { x = 2, y = 0 }), shadow = true, hover = true, button_dist = 0.63}},
                    (to_number(G.GAME.breeding_rounds_passed) >= (G.GAME.quick_preggo and 2 or 3)) and {
                        n=G.UIT.C,
                        config = { maxw = 0, maxh = 0, w = 0, h = 0, minw = 0, minh = 0 },
                        nodes={
                            {n=G.UIT.O, config = {
                                maxw = 0, maxh = 0, w = 0, h = 0, minw = 0, minh = 0,
                                object = UIBox{
                                    definition = hp_jtem_create_UIBox_card_alert({ bg_col = G.C.RED }), 
                                    config = { align= "tri", offset = {x = 0.2, y = -0.2}}
                                }
                            }},
                        }
                    }
                }},
            }}
        }},
        -- spacer
        {n=G.UIT.R, config={minh = 0.1}},
        -- bottom shop row
        {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, emboss = 0.05}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.BLACK, maxh = G.shop_vouchers.T.h+0.4}, nodes={
                    {n=G.UIT.T, config={text = localize{type = 'variable', key = 'ante_x_voucher', vars = {G.GAME.round_resets.ante}}, scale = 0.45, colour = G.C.L_BLACK, vert = true}},
                    {n=G.UIT.O, config={object = G.shop_vouchers}},
                }},
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, emboss = 0.05}, nodes={
                {n=G.UIT.O, config={object = G.shop_booster}},
            }},
        }}
    }}
end

function hpot_hover_button_name(name)
    return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.C, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {shadow = true, text = name, colour = G.C.UI.TEXT_LIGHT, scale = 0.45}},
            }},
        }}
    }}
end

local ui_hover_ref = UIElement.hover
function UIElement:hover(...)
    local ret = ui_hover_ref(self,...)

    if self.config and (self.config.id == "show_plinko_button" or self.config.id == "show_wheel_button" or self.config.id == "show_nursery_button") then
        local pos = {x = 0, y = -0.15}
        local destination = {x = 0, y = 0}
        if not self.config.original_offset then
            self.config.original_offset = copy_table(self.role.offset)
        end
        for i,_ in pairs(destination) do
            destination[i] = pos[i] + (self.config.original_offset[i] - self.role.offset[i])
        end
        G.E_MANAGER.queues[self.config.id] = G.E_MANAGER.queues[self.config.id] or {}
        G.E_MANAGER:clear_queue(self.config.id)
        self:ease_move(destination, 6, self.config.id, true, true)

        G.GAME.name_popup = (G.GAME.name_popup or 0) + 1
        local popup = G.GAME.name_popup
        repeat
            if self.children["name_popup"..popup] then
                popup = popup + 1
            end
        until not self.children["name_popup"..popup]
        local node_name = "name_popup"..popup
        self.children[node_name] = UIBox{
            definition = hpot_hover_button_name(self.config.id == "show_plinko_button" and localize("k_plinko") or self.config.id == "show_wheel_button" and localize("k_wheel") or self.config.id == "show_nursery_button" and localize("k_nursery")),
            config = {
                align = "tmi", 
                offset = {x = 0, y = -0.4},
                parent = self
            }
        }
        local text_node = self.children[node_name].UIRoot.children[1].children[1].children[1]
        text_node.states.hover.can = false
        text_node:ease_move{x = 0, y = -0.125}
    end

    return ret
end

local ui_stop_hover_ref = UIElement.stop_hover
function UIElement:stop_hover(...)
    local ret = ui_stop_hover_ref(self,...)

    if self.config and (self.config.id == "show_plinko_button" or self.config.id == "show_wheel_button" or self.config.id == "show_nursery_button") then
        local pos = {x = 0, y = -0.15}
        local destination = {x = 0, y = 0}
        if not self.config.original_offset then
            self.config.original_offset = copy_table(self.role.offset)
        end
        for i,_ in pairs(destination) do
            destination[i] = pos[i] + (self.config.original_offset[i] - pos[i] - self.role.offset[i])
        end
        G.E_MANAGER.queues[self.config.id] = G.E_MANAGER.queues[self.config.id] or {}
        G.E_MANAGER:clear_queue(self.config.id)
        self:ease_move(destination, 6, self.config.id, true, true)

        for i,v in pairs(self.children) do
            if string.find(i, "name_popup") then
                v:remove()
                self.children[i] = nil
                G.GAME.name_popup = (G.GAME.name_popup or 1) - 1
            end
        end
    end

    return ret
end

function PissDrawer.Shop.delivery_shop()
    local ret = {n=G.UIT.C, nodes = {
        PissDrawer.Shop.help_button('delivery_help'),
        {n=G.UIT.R, config = {align = 'cm', padding = 0.05}, nodes = {
            {n=G.UIT.C, config = {padding = 0.15, colour = G.C.L_BLACK, r = 0.2, emboss = 0.05, align = "tm" }, nodes = {
                {n=G.UIT.C, config = {align = "cm", padding = 0.2, r = 0.2, colour = G.C.BLACK}, nodes = {
                    {n=G.UIT.R, config = {align = "cm"}, nodes = {
                        {n=G.UIT.T, config = { text = localize("hpot_delivery_queue"), scale = 0.45, colour = G.C.L_BLACK }}
                    }},
                    {n=G.UIT.R, nodes = {
                        {n=G.UIT.B, config = {w = 0.4, h = 1.2}}
                    }},
                    {n=G.UIT.R, nodes = {
                        {n=G.UIT.O, config = {object = G.hp_jtem_delivery_queue}},
                    }},
                }}
            }},
            {n=G.UIT.C, config = { padding = 0.15, colour = G.C.L_BLACK, r = 0.2, emboss = 0.05, align = "tm" }, nodes = {
                {n=G.UIT.C, config = {align = "cm", padding = 0.2, r = 0.2, colour = G.C.BLACK}, nodes = {
                    {n=G.UIT.R, config = {minw = 0.5, align = "cm"}, nodes = {
                        {n=G.UIT.T, config = { text = localize("hpot_special_deals"), scale = 0.45, colour = G.C.L_BLACK }}
                    }},
                    {n=G.UIT.R, nodes = {
                        {n=G.UIT.B, config = {w = 0, h = 1}}
                    }},
                    {n=G.UIT.R, nodes = {
                        {n=G.UIT.O, config = {object = G.hp_jtem_delivery_special_deals}},
                    }},
                }}
            }}
        }},
    }}
    if G.GAME.hp_jtem_should_allow_custom_order then
        ret.nodes[#ret.nodes + 1] = {n=G.UIT.R, config = {minh = 2, align = 'tr', padding = 0.05}, nodes = {
            {n=G.UIT.R, config = {minw = 6.7, align = 'cm'}, nodes = {
                {n=G.UIT.C, config = { colour = G.C.RED, align = "cm", padding = 0.05, r = 0.1, minw = 2.8, minh = 1, shadow = true,
                 button = 'hotpot_jtem_delivery_request_item', func = "hp_jtem_can_request_joker", hover = true }, nodes = {
                    G.GAME.hp_jtem_should_allow_custom_order and
                    {n=G.UIT.C, config = {padding = 0.05}, nodes = {
                        {n=G.UIT.R, config = { align = "cm" }, nodes = {
                            {n=G.UIT.T, config = { text = localize("hotpot_request_joker_line_1"), scale = 0.5, colour = G.C.WHITE}},
                        }},
                        {n=G.UIT.R, config = { align = "cm" }, nodes = {
                            {n=G.UIT.T, config = { text = localize("hotpot_request_joker_line_3"), scale = 0.35, colour = G.C.WHITE}},
                        }}
                    }} or {n=G.UIT.C, config = {padding = 0.05}, nodes = {
                        {n=G.UIT.R, config = { align = "cm" }, nodes = {
                            {n=G.UIT.T, config = { text = localize("hotpot_request_joker_line_2"), scale = 0.5, colour = G.C.WHITE}},
                        }},
                        {n=G.UIT.R, config = { align = "cm" }, nodes = {
                            {n=G.UIT.T, config = { text = localize({set = 'Voucher', key = 'v_hpot_right_at_your_door', type = 'name_text'}), scale = 0.4, colour = G.C.WHITE}},
                        }}
                    }}
                }}
            }}
        }}
    else
        ret.nodes[#ret.nodes + 1] = {n=G.UIT.R, config = {minh = 2, align = 'tr', padding = 0.05}, nodes = {
            {n=G.UIT.R, config = {minw = 6.7, align = 'cm'}}
        }}
    end
    return ret
end

G.FUNCS.update_modification_info = function(e)
    for _, child in ipairs(e.children) do
        child.children[1].config.text = ''
    end
    if G.reforge_area.cards[1] and get_modification(G.reforge_area.cards[1]) then
        local mod = get_modification(G.reforge_area.cards[1])
        e.children[1].children[1].config.text = localize({set = 'Modification', key = mod, type = 'name_text'})
        e.children[1].children[1].config.colour = HPTN.Modifications[mod].morality == 'GOOD' and G.C.GREEN or G.C.RED
        local amod = HPTN.Modifications[get_modification(G.reforge_area.cards[1])]
        local loc_vars = (amod.loc_vars and amod:loc_vars({}, G.reforge_area.cards[1]) or {}).vars
        local desc = localize({set = 'Modification', key = mod, type = 'raw_descriptions', vars = loc_vars})
        for i, line in ipairs(desc) do
            if e.children[i+1] then
                e.children[i+1].children[1].config.text = desc[i]
            end
        end
    end
    e.UIBox:recalculate()
end

function PissDrawer.Shop.reforge_shop()
    local name = {}
    if G.reforge_area.cards[1] then
        localize({desc_nodes = name, set = 'Modification', key = get_modification(G.reforge_area.cards[1]), type = 'name'})
    end
    return
    {n=G.UIT.C, config = {minh = 10, align = 'tm'}, nodes = {
        PissDrawer.Shop.help_button('reforge_help'),
        {n=G.UIT.R, config = {align = 'cm', padding = 0.05}, nodes = {
            {n=G.UIT.C, config = {align = 'cm', minw = 4.5, colour = G.C.CLEAR, padding = 0.1, func = 'update_modification_info'}, nodes = {
                G.reforge_area.cards[1] and name or nil,
                {n=G.UIT.R, config = {align = 'cm', padding = 0.2}, nodes = {
                    {n=G.UIT.T, config = {text = '', scale = 0.8, colour = G.C.WHITE}}
                }},
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n=G.UIT.T, config = {text = '', scale = 0.35, colour = G.C.WHITE}}
                }},
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n=G.UIT.T, config = {text = '', scale = 0.35, colour = G.C.WHITE}}
                }},

            }},
            {n=G.UIT.C, config = {minw = 0.3}},
            {n=G.UIT.C, config = {align = 'cm'}, nodes = {

                {n=G.UIT.C, config = {padding = 0.15, colour = G.C.L_BLACK, r = 0.2, emboss = 0.05, align = "tm", minw = 0.5 }, nodes = {
                    {n=G.UIT.C, config = {align = "cm", padding = 0.2, r = 0.2, colour = G.C.BLACK}, nodes = {
                        {n=G.UIT.R, config = {align = "cm"}, nodes = {
                            {n = G.UIT.T, config = {text = localize("k_place_card_text"), colour = G.C.GREY, scale = 0.4, align = "tm"}},
                        }},
                        {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                            {n = G.UIT.C, nodes = {
                                {n=G.UIT.O, config = {object = G.reforge_area}},
                            }},
                            {n = G.UIT.C, config = { minw = 0.45 }},
                        }},
                    }}
                }},
            }}
        }},
        {n=G.UIT.R, config = {align = 'cm'}, nodes = {
            {n=G.UIT.C, config = {padding = -0.1}, nodes = {
                {n=G.UIT.R, config = {padding = 0.2, colour = G.C.CLEAR, align = 'cm'}, nodes = {
                    PissDrawer.Shop.reforge_button({currency = 'dollars'}),
                    PissDrawer.Shop.reforge_button({currency = 'credits', font = SMODS.Fonts.hpot_plincoin,}),
                    PissDrawer.Shop.reforge_button({currency = 'sparks', font = SMODS.Fonts.hpot_plincoin,}),
                }},
                {n=G.UIT.R, config = {padding = 0.2, colour = G.C.CLEAR, align = 'cm'}, nodes = {
                    PissDrawer.Shop.reforge_button({currency = 'plincoins', font = SMODS.Fonts.hpot_plincoin,}),
                    PissDrawer.Shop.reforge_button({currency = 'cryptocurrency', font = SMODS.Fonts.hpot_plincoin,}),
                }}
            }}
        }}
    }}
end

PissDrawer.Shop.reforge_button = function(args)
    local internal = args.currency
    if args.currency == "credits" and G.GAME.seeded then
        args.currency = "budget"
        args.colour = G.C.ORANGE
    end
    return
    {n = G.UIT.C, config = {minw = 2, align = 'cm', r=0.1, padding = 0.1, emboss = 0.1, colour = args.colour or G.C.L_BLACK, currency = internal, button = 'reforge_with_'..internal, func = 'can_reforge', hover = true, button_dist = 0.5}, nodes = {
        {n=G.UIT.C, config = {padding = 0.1}, nodes = {
            {n=G.UIT.R, nodes = {
                {n=G.UIT.O, config={id = 'text_'..internal, object = DynaText({string = {{ref_table = args.ref_table or G.GAME, ref_value = 'cost_'..internal, prefix = localize('hotpot_reforge_'..args.currency)}},
                        maxw = 2, colours = {args.text_colour}, font = args.font, shadow = true, spacing = 1, scale = 0.5})}}
            }}
        }}
    }}
end


PissDrawer.Shop.help_button = function(func)
    return
    {n=G.UIT.R, config = {align = 'br', padding = -0.3}, nodes = {
        {n=G.UIT.C, config = {align = 'tm', colour = G.C.RED, r = 0.8, padding = 0.025, minw = 0.5, minh = 0.6, emboss = 0.05, hover = true, button = func, button_dist = 0.1}, nodes = {
            {n=G.UIT.T, config = {text = '?', colour = G.C.WHITE, scale = 0.35}}
        }},
        {n=G.UIT.C, config = {minw = 0.85}}
    }}
end

G.FUNCS.plinko_help = function()
    G.FUNCS.hotpot_info{menu_type = "hotpot_plinko"}
end

G.FUNCS.wheel_help = function()
    G.FUNCS.hotpot_info{menu_type = "hotpot_wheel"}
end

G.FUNCS.delivery_help = function()
    G.FUNCS.hotpot_info{menu_type = "hotpot_delivery"}
end

G.FUNCS.reforge_help = function()
    G.FUNCS.hotpot_info{menu_type = "hotpot_reforge"}
end

G.FUNCS.black_market_help = function()
    G.FUNCS.hotpot_info{menu_type = "hotpot_black_market"}
end

G.FUNCS.training_help = function()
    G.FUNCS.hotpot_info{menu_type = "hotpot_training"}
end

G.FUNCS.wallet_explain = function()
    G.FUNCS.hotpot_info{menu_type = "hotpot_wallet_explain"}
end

PissDrawer.Shop.area_keys = {}

PissDrawer.Shop.area_keys.shop = {
    'shop_jokers', 'shop_vouchers', 'shop_booster'
}
PissDrawer.Shop.area_keys.delivery = {
    'hp_jtem_delivery_queue', 'hp_jtem_delivery_special_deals'
}
PissDrawer.Shop.area_keys.reforge = {
    'reforge_area'
}
PissDrawer.Shop.area_keys.black_market = {
    'market_jokers'
}
PissDrawer.Shop.area_keys.training = {
    'train_jokers'
}
PissDrawer.Shop.area_keys.nursery = {
    'nursery_father', 'nursery_mother', 'nursery_child'
}
PissDrawer.Shop.area_keys.plinko = {
    'plinko_rewards'
}
PissDrawer.Shop.area_keys.wheel = {
    'wheel_rewards'
}

local car = CardArea.remove
function CardArea:remove()
    for _, tab in pairs(PissDrawer.Shop.area_keys) do
        for _, key in ipairs(tab) do
            if self == G[key] then PissDrawer.Shop['load_'..key] = self:save() end
        end
    end
    car(self)
end


function PissDrawer.Shop.reload_shop_areas(keys)
    for _, key in ipairs(keys) do
        if PissDrawer.Shop['load_'..key] then
            G[key]:load(PissDrawer.Shop['load_'..key])
            for k, v in ipairs(G[key].cards) do
                if key == 'hp_jtem_delivery_queue' then
                    local temp_str = { str = (v.ability.hp_delivery_obj.rounds_passed .. "/" .. v.ability.hp_delivery_obj.rounds_total) }
                    local args = generate_currency_string_args(v.ability.hp_jtem_currency_bought)
                    hpot_jtem_create_delivery_boxes(v, { { ref_table = temp_str, ref_value = 'str', object = v.ability.hp_delivery_obj } }, args)
                elseif key == 'hp_jtem_delivery_special_deals' then
                    local args = generate_currency_string_args(v.ability.hp_jtem_currency_bought)
                    hpot_jtem_create_special_deal_boxes(v, {{prefix = args.symbol, ref_table = v.ability, ref_value = "hp_jtem_currency_bought_value"}}, args)
                elseif key == 'reforge_area' or key == 'train_jokers' or key == 'nursery_father' or key == 'nursery_mother' or key == 'nursery_child' then
                elseif key == 'market_jokers' then
                    create_market_card_ui(v)
                else
                    create_shop_card_ui(v)
                end
                if v.ability.consumeable then v:start_materialize() end
            end
            PissDrawer.Shop['load_'..key] = nil
        end
    end
end

local pissdrawer_save_run = save_run
function save_run()
    for _, tab in pairs(PissDrawer.Shop.area_keys) do
        for _, key in ipairs(tab) do
            if G[key] and G[key].cards then PissDrawer.Shop['load_'..key] = G[key]:save() end
        end
    end
    pissdrawer_save_run()
    G.culled_table = G.culled_table or {}
    G.culled_table.pissdrawer_shop = {}
    for _, tab in pairs(PissDrawer.Shop.area_keys) do
        for _, key in ipairs(tab) do
            G.culled_table.pissdrawer_shop[key] = PissDrawer.Shop['load_'..key] and recursive_table_cull(PissDrawer.Shop['load_'..key])
        end
    end
end

local pissdrawer_start_run = Game.start_run
function Game:start_run(args)
    local save = args.savetext
    PissDrawer.Shop.market_spawn = false
    for _, tab in pairs(PissDrawer.Shop.area_keys) do
        for _, key in ipairs(tab) do
            PissDrawer.Shop['load_'..key] = nil
        end
    end
    if save and save.pissdrawer_shop then
        for key, v in pairs(save.pissdrawer_shop) do
            if key == 'market_jokers' then PissDrawer.Shop.market_spawn = true end
            PissDrawer.Shop['load_'..key] = v
        end
    end
    local ret = pissdrawer_start_run(self, args)
end

function PissDrawer.Shop.create_shop_areas()
    G.shop_jokers = CardArea(
      G.hand.T.x+0,
      G.hand.T.y+G.ROOM.T.y + 9,
      math.min(G.GAME.shop.joker_max*1.02*G.CARD_W,3.6*G.CARD_W),
      1.15*G.CARD_H * PissDrawer.shop_scale,
      {card_limit = G.GAME.shop.joker_max, type = 'shop', highlight_limit = 1, negative_info = true, hotpot_shop = true})


     G.shop_vouchers = CardArea(
        G.hand.T.x+0,
        G.hand.T.y+G.ROOM.T.y + 9,
        2.1*G.CARD_W,
        1.05*G.CARD_H * PissDrawer.shop_scale,
        {card_limit = 1, type = 'shop', highlight_limit = 1, hotpot_shop = true})

    G.shop_booster = CardArea(
        G.hand.T.x+0,
        G.hand.T.y+G.ROOM.T.y + 9,
        2.4*G.CARD_W,
        1.15*G.CARD_H * PissDrawer.shop_scale,
        {card_limit = 2, type = 'shop', highlight_limit = 1, card_w = 1.22*G.CARD_W, hotpot_shop = true})
end

function PissDrawer.Shop.create_reforge_areas()
    G.reforge_area = CardArea(
        0, 0, G.CARD_W, G.CARD_H,
        {card_limit = 1, type = "shop", highlight_limit = 1, hotpot_shop = true}
    )
end

function PissDrawer.Shop.create_training_areas()
    G.train_jokers = CardArea(
        G.hand.T.x + 0,
        G.hand.T.y + G.ROOM.T.y + 9,
        math.min(1.02 * G.CARD_W, 4.08 * G.CARD_W) - 0.25,
        1.05 * G.CARD_H,
        { card_limit = 1, type = 'shop', highlight_limit = 1, negative_info = true, hotpot_shop = true }
    )
end

function PissDrawer.Shop.create_black_market_areas()
    G.GAME.shop.market_joker_max = G.GAME.shop.market_joker_max or 2
    G.market_jokers = CardArea(
      G.hand.T.x + 0,
      G.hand.T.y + G.ROOM.T.y + 9,
      math.min(G.GAME.shop.market_joker_max * 1.02 * G.CARD_W, 4.08 * G.CARD_W),
      1.05 * G.CARD_H,
      { card_limit = G.GAME.shop.market_joker_max, type = 'shop', highlight_limit = 1, negative_info = true, hotpot_shop = true })
end

function PissDrawer.Shop.create_nursery_areas()
    G.nursery_father = CardArea(
            G.hand.T.x - 1,
            G.hand.T.y + G.ROOM.T.y + 9,
            math.min(1.02 * G.CARD_W, 4.08 * G.CARD_W) - 0.3,
            1.05 * G.CARD_H,
            { card_limit = 1, type = 'shop', highlight_limit = 1, negative_info = true, hotpot_shop = true })
    G.nursery_mother = CardArea(
        G.hand.T.x + 1,
        G.hand.T.y + G.ROOM.T.y + 9,
        math.min(1.02 * G.CARD_W, 4.08 * G.CARD_W) - 0.3,
        1.05 * G.CARD_H,
        { card_limit = 1, type = 'shop', highlight_limit = 1, negative_info = true, hotpot_shop = true })
    G.nursery_child = CardArea(
        G.hand.T.x + 1,
        G.hand.T.y + G.ROOM.T.y + 9,
        math.min(1.02 * G.CARD_W, 4.08 * G.CARD_W) * 0.75,
        1.05 * G.CARD_H * 0.75,
        { card_limit = 1, type = 'shop', highlight_limit = 1, negative_info = true,})
end

SMODS.draw_ignore_keys.hpot_reforge_button = true
SMODS.draw_ignore_keys.hpot_move_to_train = true
SMODS.draw_ignore_keys.hp_nursery_buttons = true


SMODS.Atlas({
    key = 'nursery_icons',
    path = 'Pissdrawer/nursery_icons.png',
    px = 49,
    py = 49
})

SMODS.Atlas({
    key = 'nursery_icons_lblack',
    path = 'Pissdrawer/nursery_icons_lblack.png',
    px = 49,
    py = 49
})

function PissDrawer.Shop.create_nursery_buttons(card)
    if card.highlighted then
        if card.children.hp_nursery_buttons then card.children.hp_nursery_buttons:remove() end
        local buttons
        local y = 0.84
        if card.area ~= G.nursery_father and card.area ~= G.nursery_mother and card.area ~= G.nursery_child then
            buttons = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR}, nodes ={
                {n=G.UIT.R, config = {align = 'cm', padding = 0.2}, nodes ={
                    {n=G.UIT.C, config = { ref_table = card, minw = 0.6, maxw = 0.6, padding = 0.1, align = 'bm', colour = lighten(G.C.BLUE, 0.2),
                    shadow = true, r = 0.08, minh = 1.2, func = 'nursery_father', button = 'nursery_father_button', hover = true }, nodes = {
                        {n=G.UIT.O, config = {object = Sprite(0, 0, 0.5, 0.5, G.ASSET_ATLAS['hpot_nursery_icons'], { x = 1, y = 0 })}},
                    }},
                    {n=G.UIT.C, config = { ref_table = card, minw = 0.6, maxw = 0.6, padding = 0.1, align = 'bm', colour = lighten(G.C.RED, 0.2),
                    shadow = true, r = 0.08, minh = 1.2, func = 'nursery_mother', button = 'nursery_mother_button', hover = true }, nodes = {
                        {n=G.UIT.O, config = {object = Sprite(0, 0, 0.5, 0.5, G.ASSET_ATLAS['hpot_nursery_icons'], { x = 0, y = 0 })}},
                    }}
                }}
            }}
        elseif not (card.area == G.nursery_mother and G.GAME.active_breeding) then
            buttons = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR}, nodes ={
                {n=G.UIT.R, config = {align = 'cm', padding = 0.2}, nodes ={
                    {n=G.UIT.C, config = { ref_table = card, minw = 1.2, maxw = 1.2, padding = 0.1, align = 'bm', colour = G.C.RED,
                    shadow = true, r = 0.08, minh = 0.94, button = 'nursery_remove', hover = true }, nodes = {
                        {n=G.UIT.T, config = { text = 'REMOVE', colour = G.C.WHITE, scale = 0.3 } }
                    }}
                }}
            }}
            y = 0.64 + (card.ability.is_nursery_smalled and 0.2 or 0)
        end
        if not buttons then return end

        card.children.hp_nursery_buttons = UIBox {
            definition = buttons,
            config = {
                align = "bmi",
                offset = { x = 0, y = y },
                parent = card
            }
        }
    elseif card.children.hp_nursery_buttons then
        card.children.hp_nursery_buttons:remove()
    end
end

function PissDrawer.Shop.create_delivery_order_button(card)
    if card.highlighted then
        if card.children.hp_jtem_price_side then card.children.hp_jtem_price_side:remove() end
        local t2 = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR}, nodes ={
            {n=G.UIT.C, config = { ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.GOLD,
                shadow = true, r = 0.08, minh = 0.94, func = 'hp_jtem_can_order', one_press = true, button = 'hp_jtem_order', hover = true }, nodes = {
                {n=G.UIT.T, config = { text = localize('hotpot_delivery_order'), colour = G.C.WHITE, scale = 0.5 } }
            }}
        }}

        card.children.hp_jtem_price_side = UIBox {
            definition = t2,
            config = {
                align = "bm",
                offset = { x = 0, y = -0.34 },
                parent = card
            }
        }
    elseif card.children.hp_jtem_price_side then
        card.children.hp_jtem_price_side:remove()
    end
end

function PissDrawer.Shop.create_delivery_refund_button(card)
    if card.highlighted then
        if card.children.hp_jtem_cancel_order then card.children.hp_jtem_cancel_order:remove() end
        local t2 = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR}, nodes ={
            {n=G.UIT.C, config = { ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.RED,
                shadow = true, r = 0.08, minh = 0.94, func = 'hp_jtem_can_cancel', one_press = true, button = 'hp_jtem_cancel', hover = true }, nodes = {
                {n=G.UIT.T, config = { text = localize('hotpot_delivery_order_cancel'), colour = G.C.WHITE, scale = 0.5 } }
            }}
        }}

        card.children.hp_jtem_cancel_order = UIBox {
            definition = t2,
            config = {
                align = "bm",
                offset = { x = 0, y = -0.34 },
                parent = card
            }
        }
    elseif card.children.hp_jtem_cancel_order then
        card.children.hp_jtem_cancel_order:remove()
    end
end

PissDrawer.Shop.delivery_post = function(keys)
    PissDrawer.Shop.reload_shop_areas(keys)
    hotpot_delivery_refresh_card()
    if not PissDrawer.Shop.delivery_spawn then PissDrawer.Shop.delivery_spawn = true end
end

PissDrawer.Shop.black_market_post = function(keys)
    PissDrawer.Shop.reload_shop_areas(keys)
    if not PissDrawer.Shop.market_spawn then hotpot_horsechicot_market_section_init_cards(); PissDrawer.Shop.market_spawn = true end
end


local pissdrawer_card_highlight = Card.highlight
function Card:highlight(highlighted)
    pissdrawer_card_highlight(self, highlighted)
    if self.area == G.hp_jtem_delivery_special_deals then
        PissDrawer.Shop.create_delivery_order_button(self)
    elseif self.area == G.hp_jtem_delivery_queue then
        PissDrawer.Shop.create_delivery_refund_button(self)
    end
    -- Clean up old buttons
    if self.children.hpot_reforge_button then
        self.children.hpot_reforge_button:remove()
        self.children.hpot_reforge_button = nil
    end
    if self.children.hp_nursery_buttons then
        self.children.hp_nursery_buttons:remove()
        self.children.hp_nursery_buttons = nil
    end
    if self.children.hpot_move_to_train then
        self.children.hpot_move_to_train:remove()
        self.children.hpot_move_to_train = nil
    end
    if self.ability.consumeable then
        G.hpot_training_consumable_highlighted = nil
    end
    if self.children.hpot_train_button then
        self.children.hpot_train_button:remove()
        self.children.hpot_train_button = nil
    end

    if self.highlighted and PissDrawer.Shop.active_tab == 'hotpot_nursery' and self.ability.set == 'Joker' then
        PissDrawer.Shop.create_nursery_buttons(self)
    end
    if self.highlighted and PissDrawer.Shop.active_tab == 'hotpot_shop_tab_hotpot_tname_toggle_reforge' and self.ability.set == 'Joker' then
        self.children.hpot_reforge_button = UIBox{
            definition = PissDrawer.Shop.reforge_emplace(self),
            config = {align = "bmi", offset ={x=0,y=0.5}, parent = self}
        }
    end
    if self.highlighted and PissDrawer.Shop.active_tab == 'hotpot_shop_tab_hotpot_pissdrawer_toggle_training' and self.ability.hp_jtem_mood and self.ability.set == 'Joker' then
        self.children.hpot_move_to_train = UIBox{
            definition = PissDrawer.Shop.training_emplace(self),
            config = {align = "bmi", offset ={x=0,y=0.5}, parent = self}
        }
    end
    if self.ability.hpot_train_increase and self.highlighted and self.ability.consumeable then
        -- set this as the highlighted consumeable
        G.hpot_training_consumable_highlighted = self
    end
    if self.ability.set == "Joker" and not self.ability.hp_jtem_mood and G.jokers and self.area == G.jokers and (PissDrawer.Shop.active_tab ~= 'hotpot_shop_tab_hotpot_tname_toggle_reforge' and PissDrawer.Shop.active_tab ~= 'hotpot_nursery') then
        self.children.hpot_train_button = UIBox{
            definition = hpot_joker_train_button_definition(self),
            config = {align = "bmi", offset ={x=0,y=0.7}, parent = self}
        }
    end
end

function PissDrawer.Shop.reforge_emplace(card)
	return
    {n = G.UIT.R, config = {ref_table = card, r = 0.08, padding = 0.1, align = "bm", minh = 0.4 * card.T.h,
        hover = true, shadow = true, colour = G.C.RED, button = 'reforge_place', func = 'place_return_reforge' }, nodes = {
        {n=G.UIT.R, config={align = 'cm'}, nodes = {{n = G.UIT.T, config = { text = localize('hotpot_go_reforge'), colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true }}}}
    }}
end

function PissDrawer.Shop.training_emplace(card)
	return
    {n = G.UIT.R, config = {ref_table = card, r = 0.08, padding = 0.1, align = "bm", minh = 0.4 * card.T.h,
        hover = true, shadow = true, colour = G.C.RED, button = 'training_emplace', func = 'can_emplace_training' }, nodes = {
        {n = G.UIT.T, config = { text = localize('hotpot_go_train'), colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true }}
    }}
end

G.FUNCS.training_emplace = function (e)
    if G.jokers and G.jokers.highlighted and #G.jokers.highlighted > 0 then
        local c = e.config.ref_table
        if c.children.hpot_move_to_train then
            c.children.hpot_move_to_train:remove()
            c.children.hpot_move_to_train = nil
        end
        HPTN.move_card(c, G.train_jokers)
    end
end

G.FUNCS.training_return = function ()
    if G.train_jokers and G.train_jokers.cards then
        if #G.train_jokers.cards > 0 and G.FUNCS.check_for_buy_space(G.train_jokers.cards[1]) then
            HotPotato.adding_from_storage = true
            if G.train_jokers.cards[1].children.hpot_move_to_train then
                G.train_jokers.cards[1].children.hpot_move_to_train:remove()
                G.train_jokers.cards[1].children.hpot_move_to_train = nil
            end
            HPTN.move_card(G.train_jokers.cards[1], G.jokers)
            HotPotato.adding_from_storage = nil
        end
    end
end

function G.FUNCS.can_emplace_training(e)
    if G.CONTROLLER.locks.hpot_training_grounds then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        if e.config.ref_table.area == G.jokers then
            e.children[1].config.text = localize('hotpot_go_train')
            e.children[1].config.scale = 0.4
            if G.train_jokers and G.train_jokers.cards and #G.train_jokers.cards > 0 then
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            else
                e.config.colour = G.C.BLUE
                e.config.button = 'training_emplace'
            end
        else
            e.children[1].config.text = localize('hotpot_leave_train')
            e.children[1].config.scale = 0.3
            e.config.colour = G.C.BLUE
            e.config.button = 'training_return'
        end
    end
end

function PissDrawer.Shop.black_market()
    G.harvest_cost = G.harvest_cost or 0
    return
    {n=G.UIT.C, config = {align = 'tm', minh = 8}, nodes = {
        PissDrawer.Shop.help_button('black_market_help'),
        {n = G.UIT.R, config = { align = "cm", padding = 0.05 }, nodes = {
            {n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = {
                {n = G.UIT.R, config = { align = "cm", minw = 2.5, minh = 1.4, r = 0.15, colour = SMODS.Gradients.hpot_advert, button = 'reroll_market', func = 'can_reroll_market', hover = true, shadow = true }, nodes = {
                    {n = G.UIT.R, config = { align = "cm", padding = 0.07, focus_args = { button = 'y', orientation = 'cr' }, func = 'set_button_pip' }, nodes = {
                        {n = G.UIT.R, config = { align = "cm", maxw = 1.3 }, nodes = {
                            {n = G.UIT.T, config = { text = localize('k_reroll'), scale = 0.4, colour = G.C.WHITE, shadow = true }},
                        }},
                        {n = G.UIT.R, config = { align = "cm", maxw = 1.3, minw = 1 }, nodes = {
                            {n = G.UIT.T, config = { text = "£", font = SMODS.Fonts['hpot_plincoin'], scale = 0.7, colour = G.C.WHITE, shadow = true }},
                            {n = G.UIT.T, config = { ref_table = G.GAME.current_round, ref_value = 'market_reroll_cost', scale = 0.75, colour = G.C.WHITE, shadow = true }},
                        }}
                    }}
                }},
                {n = G.UIT.R, config = { align = "cm", minw = 2.5, minh = 1.4, r = 0.15, colour = SMODS.Gradients.hpot_advert, button = 'harvest_market', func = 'can_harvest_market', hover = true, shadow = true }, nodes = {
                    {n = G.UIT.R, config = { align = "cm", padding = 0.07, focus_args = { button = 'x', orientation = 'cr' }, func = 'set_button_pip' }, nodes = {
                        {n = G.UIT.R, config = { align = "cm", maxw = 1.3 }, nodes = {
                            {n = G.UIT.T, config = { text = localize('k_harvest'), scale = 0.6, colour = G.C.WHITE, shadow = true }},
                        }},
                        {n = G.UIT.R, config = { align = "cm", maxw = 1.3, minw = 1 }, nodes = {
                            {n = G.UIT.T, config = { text = "£", font = SMODS.Fonts['hpot_plincoin'], scale = 0.7, colour = G.C.WHITE, shadow = true }},
                            {n = G.UIT.T, config = { ref_table = G, ref_value = 'harvest_cost', scale = 0.75, colour = G.C.WHITE, shadow = true }},
                        }}
                    }}
                }},
            }},
            {n = G.UIT.C, config = { align = "cm", padding = 0.1, r = 0.2, colour = G.C.L_BLACK, emboss = 0.05, minw = 8.2 }, nodes = {
                {n = G.UIT.O, config = { object = G.market_jokers }},
            }},
        }}
    }}
end

function PissDrawer.Shop.currency_exchange()
    return
    {n=G.UIT.C, config = {minh = 10, align = 'tm', padding = 0.1}, nodes = {
        {n=G.UIT.R, config = {align = 'cm'}, nodes = {
            {n=G.UIT.C, config = {align = 'cm'}, nodes = {
                {n=G.UIT.O, config = {object = DynaText({ string = {localize('hotpot_exchange_title')}, font = SMODS.Fonts.hpot_plincoin, scale = 0.65, float = true, colours = {G.C.BLUE}, shadow = true})}},
            }}
        }},
        {n=G.UIT.R, config = {align = 'cm', padding = 0.1, id = 'exchange_UI'}, nodes ={
            hp_jtem_buy_jx_row( "dollars" )
        }},
        {n=G.UIT.R, config = {align = "tm", padding = 0.1}, nodes = {
            {n=G.UIT.T, config = { text = localize("hotpot_exchange_note"), scale = 0.3, colour = G.C.GREY }}
        }},
        {n=G.UIT.R, config = {align = 'cm', padding = 0.2}, nodes = {
            PissDrawer.Shop.spark_exchange_button({currency = 'dollars', text_colour = G.C.GOLD}),
            PissDrawer.Shop.spark_exchange_button({currency = 'plincoins', font = SMODS.Fonts.hpot_plincoin,}),
            PissDrawer.Shop.spark_exchange_button({currency = 'cryptocurrency', font = SMODS.Fonts.hpot_plincoin,}),
            PissDrawer.Shop.spark_exchange_button({currency = 'credits', font = SMODS.Fonts.hpot_plincoin,}),
        }}
    }}
end

PissDrawer.Shop.spark_exchange_button = function(args)
    local internal = args.currency
    if args.currency == "credits" and G.GAME.seeded then
        args.currency = "budget"
        args.colour = G.C.ORANGE
    end
    return
    {n = G.UIT.C, config = {minw = 1.3, align = 'cm', r=0.1, padding = 0.1, emboss = 0.1, colour = args.colour or G.C.L_BLACK, currency = internal, button = 'switch_spark_exchange', func = 'can_switch_spark_exchange', text_colour = args.text_colour, hover = true, button_dist = 0.5}, nodes = {
        {n=G.UIT.O, config={id = 'spark_exchange_'..internal, object = DynaText({string = {localize('hotpot_reforge_'..args.currency)},
            maxw = 1, colours = {G.C.GREY}, font = args.font, shadow = true, spacing = 1, scale = 0.35})}}
    }}
end

G.FUNCS.switch_spark_exchange = function(e)
    local exchange_display = e.parent.UIBox:get_UIE_by_ID('exchange_UI')
    exchange_display:remove()
    exchange_display.UIBox:add_child(hp_jtem_buy_jx_row(e.config.currency), exchange_display)
end

G.FUNCS.can_switch_spark_exchange = function(e)
    local tab = {config = {}}
    local curr = e.config.currency
    if curr == 'cryptocurrency' then curr = 'b' end
    curr = string.sub(curr, 1, 1)
    G.FUNCS['hp_jtem_can_exchange_'..curr..'2j'](tab)
    e.children[1].config.object.colours = {tab.config.button and tab.config.colour or G.C.GREY}
    e.config.colour = tab.config.button and mix_colours(G.C.L_BLACK, G.C.BLUE, 0.8) or G.C.BLACK
    e.config.button = tab.config.button and 'switch_spark_exchange' or nil
end

function format_ui_value(value)
    if type(value) ~= "number" then
        return tostring(value)
    end
    local ret = number_format(value, 1000000)
    if value > 0 and value < 0.00001 then
        local tbl = {}
        for i, _ in string.gmatch(ret, '([^e]+)') do tbl[#tbl+1] = i end
        if tbl[1] then
            ret = tbl[1]:sub(1, 3).."e"..tbl[2]
        end
    end
    if value < 0 and value > -0.00001 then
        local tbl = {}
        for i, _ in string.gmatch(ret, '([^e]+)') do tbl[#tbl+1] = i end
        if tbl[1] then
            ret = tbl[1]:sub(1, 4).."e"..tbl[2]
        end
    end
    return ret
end

function PissDrawer.Shop.nursery()
    return 
    {n=G.UIT.C, config = { align = 'tm', minh = 8, colour = G.C.CLEAR }, nodes = {
        PissDrawer.Shop.help_button('hpot_nursery_tutorial'),
        {n=G.UIT.R, config={align='cm', colour = G.C.L_BLACK, padding = 0.1, r=0.1}, nodes = {

            {n=G.UIT.R, config={align = 'cm', colour = G.C.BLACK, r=0.1, padding = 0.2}, nodes = {
                {n=G.UIT.C, config = {align = 'tm', minh = 5, colour = G.C.BLACK, r=0.1}, nodes = {
                    {n=G.UIT.C, config = { align = "tm", colour = G.C.L_BLACK, padding = 0.2, maxh = 3, minw = 2.3, minh = 1.9, r = 0.2 }, nodes = {
                        {n=G.UIT.R, config = { align = "cm", minw = G.CARD_W }, nodes = {
                            {n=G.UIT.T, config = { text = localize('nursery_father'), scale = 1.3, colour = G.C.BLACK } },
                        }},
                        {n=G.UIT.R, config = { align = "cm", colour = G.C.BLACK, minh = G.CARD_H, r = 0.2}, nodes = {
                            {n=G.UIT.C, config = {minw = 0.1}},
                            {n=G.UIT.C, config = {align='cm', padding = -1 * G.CARD_W}, nodes = {
                                {n=G.UIT.O, config = {padding = -1, object = Sprite(0, 0, G.CARD_W, G.CARD_W, G.ASSET_ATLAS['hpot_nursery_icons_lblack'], { x = 1, y = 0 })}},
                                {n=G.UIT.O, config = {padding = -1, object = G.nursery_father, align = "cm", id = "shop_nursery_father" }},
                            }},
                            {n=G.UIT.C, config = {minw = 0.3}},
                        }}
                    }},
                }},
                {n=G.UIT.C, config = {align = 'bm', minh = 5, colour = G.C.BLACK, r=0.1}, nodes = {
                    {n=G.UIT.R, config = {align = 'cm', padding = -0.2}, nodes = {
                        {n=G.UIT.C, config = {align = 'cm'}, nodes = {
                            {n=G.UIT.R, config = {minh = 1.2, minw = 1, align = 'cm', padding = 0.1}, nodes = {
                                {n=G.UIT.R, config = {maxw = 2, minw = 2, minh = 0.8, maxh = 0.8, padding = 0.1, r = 0.1, emboss = 0.1, align = 'cm', button = 'nursery_breed', func = 'nursery_ready', colour = G.C.GREEN}, nodes = {
                                    {n=G.UIT.T, config = {ref_table = PissDrawer.Shop, ref_value = 'nursery_text', scale = 0.5, colour = G.C.WHITE}}
                                }}
                            }},
                            {n=G.UIT.R, config = {maxh = 0.05, minh = 0.05, minw = 2.9, colour = G.C.L_BLACK}},
                            {n=G.UIT.R, config = {minh = 1.2, maxh = 1.2, maxw = 0.05, minw = 0.05, align = 'cm'}, nodes = {
                                {n=G.UIT.C, config = {maxw = 0.05, minw = 0.05, minh = 1.4, colour = G.C.L_BLACK}}
                            }},
                        }},
                    }},
                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {                        
                        {n=G.UIT.C, config = { align = "bm", colour = G.C.L_BLACK, padding = 0.2, maxh = 3 * 0.85, minw = 2.3 * 0.85, maxw = 2.3 * 0.85, minh = 1.9 * 0.85, r = 0.2 }, nodes = {
                            {n=G.UIT.R, config = { align = "cm", }, nodes = {
                                {n=G.UIT.T, config = { text = localize('nursery_child'), scale = 0.4, colour = G.C.BLACK } },
                            }},
                            {n=G.UIT.R, config = { align = "cm", colour = G.C.BLACK, r = 0.2, minw = G.CARD_W * 0.85, minh = G.CARD_H * 0.85 }, nodes = {
                                {n=G.UIT.C, config = {align='cm', padding = -0.4}, nodes = {
                                    {n=G.UIT.O, config = {object = G.nursery_child, align = "cm", id = "shop_nursery_child" }},
                                }},
                                {n=G.UIT.C, config = {minw = 0.5}},
                            }}
                        }},
                    }}
                }},
                {n=G.UIT.C, config = {align = 'tm', minh = 5, colour = G.C.BLACK, r=0.1}, nodes = {
                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                        {n=G.UIT.C, config = { align = "tm", colour = G.C.L_BLACK, padding = 0.2, maxh = 3, minw = 2.3, minh = 1.9, r = 0.2 }, nodes = {
                            {n=G.UIT.R, config = { align = "cm", minw = G.CARD_W }, nodes = {
                                {n=G.UIT.T, config = { text = localize('nursery_mother'), scale = 1.3, colour = G.C.BLACK } },
                            }},
                            {n=G.UIT.R, config = { align = "cm", colour = G.C.BLACK, minh = G.CARD_H, r = 0.2}, nodes = {
                                {n=G.UIT.C, config = {minw = 0.1}},
                                {n=G.UIT.C, config = {align='cm', padding = -1 * G.CARD_W}, nodes = {
                                    {n=G.UIT.O, config = {padding = -1, object = Sprite(0, 0, G.CARD_W, G.CARD_W, G.ASSET_ATLAS['hpot_nursery_icons_lblack'], { x = 0, y = 0 })}},
                                    {n=G.UIT.O, config = {padding = -1, object = G.nursery_mother, align = "cm", id = "shop_nursery_mother" }},
                                }},
                                {n=G.UIT.C, config = {minw = 0.45}},
                            }},
                        }},
                    }},
                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                        {n=G.UIT.C, config = {align = 'cm', padding = -0.15, func = 'nursery_progress'}, nodes = {
                            {n=G.UIT.R, config = {padding = 0.1, colour = G.C.L_BLACK, r = 0.1, align = 'cm'}, nodes = {
                                {n=G.UIT.R, config = {minw = G.CARD_W * 0.85, maxw = G.CARD_W * 0.85, minh = 0.15, r = 0.025, colour = G.C.BLACK,
                                progress_bar = {
                                    max = G.GAME.quick_preggo and 2 or 3, ref_table = G.GAME, ref_value = 'breeding_rounds_passed', empty_col = G.C.BLACK, filled_col = adjust_alpha(G.C.HPOT_PINK, 0.5)
                                }}}
                            }}
                        }}
                    }}
                }}
            }}
        }}
    }}
end

G.FUNCS.nursery_progress = function(e)
    if G.GAME.active_breeding then
        e.children[1].children[1].config.progress_bar.empty_col = G.C.BLACK
        e.children[1].config.colour = G.C.L_BLACK
    else
        e.children[1].children[1].config.progress_bar.empty_col = G.C.CLEAR
        e.children[1].config.colour = G.C.CLEAR
    end
end

G.FUNCS.nursery_father = function(e)
    if #G.nursery_father.cards > 0 or not HotPotato.can_breed(e.config.ref_table, false) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = lighten(G.C.BLUE, 0.2)
        e.config.button = 'nursery_father_button'
    end
end

G.FUNCS.nursery_mother = function(e)
    if #G.nursery_mother.cards > 0 or not HotPotato.can_breed(e.config.ref_table, true) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = lighten(G.C.RED, 0.2)
        e.config.button = 'nursery_mother_button'
    end
end

G.FUNCS.nursery_father_button = function(e)
    if (not G.nursery_father.cards) or #G.nursery_father.cards > 0 or not HotPotato.can_breed(e.config.ref_table, false) then return end
    HPTN.move_card(e.config.ref_table, G.nursery_father)
end

G.FUNCS.nursery_mother_button = function(e)
    if (not G.nursery_father.cards) or #G.nursery_mother.cards > 0 or not HotPotato.can_breed(e.config.ref_table, true) then return end
    HPTN.move_card(e.config.ref_table, G.nursery_mother)
end

G.FUNCS.nursery_ready = function(e)
    if (#G.nursery_father.cards == 1 or G.GAME.parthenogenesis) and #G.nursery_mother.cards == 1 and #G.nursery_child.cards == 0 and not G.GAME.active_breeding and ((G.GAME.dollars-G.GAME.bankrupt_at) - to_big(5) >= to_big(0)) then
        e.config.colour = G.C.HPOT_PINK
        e.children[1].config.colour = G.C.WHITE
        PissDrawer.Shop.nursery_text = localize('nursery_breed')
        e.config.button = 'nursery_breed'
        e.config.hover = true
    else
        if G.GAME.active_breeding then
            e.config.colour = G.C.ETERNAL
            e.children[1].config.colour = G.C.WHITE
            PissDrawer.Shop.nursery_text = localize('nursery_abort')
            e.config.button = 'nursery_abort'          
            e.config.hover = false
        else
            e.config.colour = G.C.BLACK
            e.children[1].config.colour = G.C.L_BLACK
            PissDrawer.Shop.nursery_text = localize('nursery_breed')
            e.config.button = nil
            e.config.hover = false
        end
    end
end

G.FUNCS.nursery_remove = function(e)
    if G.FUNCS.check_for_buy_space(e.config.ref_table) then
        HotPotato.adding_from_storage = true
        HPTN.move_card(e.config.ref_table, G.jokers)
        HotPotato.adding_from_storage = nil
    end
end


G.FUNCS.training_emplace = function (e)
    if G.jokers and G.jokers.highlighted and #G.jokers.highlighted > 0 then
        local c = e.config.ref_table
        if c.children.hpot_move_to_train then
            c.children.hpot_move_to_train:remove()
            c.children.hpot_move_to_train = nil
        end
        HPTN.move_card(c, G.train_jokers)
    end
end

G.FUNCS.training_return = function ()
    if G.train_jokers and G.train_jokers.cards then
        if #G.train_jokers.cards > 0 and G.FUNCS.check_for_buy_space(G.train_jokers.cards[1]) then
            HotPotato.adding_from_storage = true
            if G.train_jokers.cards[1].children.hpot_move_to_train then
                G.train_jokers.cards[1].children.hpot_move_to_train:remove()
                G.train_jokers.cards[1].children.hpot_move_to_train = nil
            end
            HPTN.move_card(G.train_jokers.cards[1], G.jokers)
            HotPotato.adding_from_storage = nil
        end
    end
end

function G.FUNCS.can_emplace_training(e)
    if e.config.ref_table.area == G.jokers then
        e.children[1].config.text = localize('hotpot_go_train')
        e.children[1].config.scale = 0.4
        if G.train_jokers and G.train_jokers.cards and #G.train_jokers.cards > 0 then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.BLUE
            e.config.button = 'training_emplace'
        end
    else
        e.children[1].config.text = localize('hotpot_leave_train')
        e.children[1].config.scale = 0.3
        e.config.colour = G.C.BLUE
        e.config.button = 'training_return'
    end
end

function PissDrawer.Shop.plinko()
    local reward_scale=  0.7
    G.plinko_rewards = CardArea(
        G.hand.T.x+0,
        G.hand.T.y+9,
        7.8,
        PlinkoUI.s.reward_area_h/0.6*G.CARD_H,
        {card_limit = PlinkoLogic.rewards.total, type = 'shop', highlight_limit = 0, plinko_rewards = true}
    )

    local use_ante = G.GAME.current_round.plinko_cost_reset.ante_left > 0
    local play_dollars = not not G.GAME.plinko_dollars_cost
    local plinko_4ever = G.GAME.modifiers.hpot_plinko_4ever


    return
    {n=G.UIT.C, config = {align='tm', minh = 8}, nodes = {
        PissDrawer.Shop.help_button('plinko_help'),
        {n=G.UIT.R, config={align = "tm"}, nodes={
            {n=G.UIT.C, config={align = "tm"}, nodes={
                plinko_4ever and {n=G.UIT.R,config={id = 'next_round_button', align = "cm", minw = 1.8, minh = 1.3, r=0.15,colour = G.C.RED, one_press = true, button = 'toggle_shop', hover = true,shadow = true}, nodes = {
                    {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'y', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                        {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                            {n=G.UIT.T, config={text = localize('b_next_round_1'), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                        }},
                        {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                            {n=G.UIT.T, config={text = localize('b_next_round_2'), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                        }}
                    }},
                }},
                {n=G.UIT.R, config = {minh = 0.8}},
                {n=G.UIT.R, config={align = "cm", padding = -0.3}, nodes={
                    {n=G.UIT.C, config={minw = 0.6}},
                    {n=G.UIT.C, config={colour=G.C.L_BLACK, padding = 0.15, r=0.1}, nodes = {
                        {n=G.UIT.C, config={align='bm', minw = 2.6, r=0.1, colour = G.C.BLACK}, nodes = {
                            {n=G.UIT.R, config = {align = 'cm', minw = 1, colour = G.C.BLACK, r=0.2}, nodes = {
                                {n=G.UIT.C, config = {align = 'cm', padding = 0.1}, nodes = {
                                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                        {n=G.UIT.O, config={id = 'reset_plinko', object = DynaText({string = {{ref_table = G.GAME.current_round.plinko_cost_reset, ref_value = use_ante and 'ante_left' or 'rounds_left', prefix = 'Resets in ', suffix = use_ante and localize('hotpot_plinko_reset2_ante') or localize('hotpot_plinko_reset2_round')}},
                                            colours = {G.C.L_BLACK}, maxw = 2.3, scale = 0.5})}}
                                    }},
                                    -- {n=G.UIT.R, config = {minh = 0.1}},
                                    {n=G.UIT.R, config = {align='cm', minw = 1, r=0.1, padding = 0.1}, nodes = {
                                        {n=G.UIT.C, config = {align = 'cm'}, nodes = {
                                            G.GAME.plinko_dollars_cost and {n=G.UIT.R, config = {align='cm', padding = 0.2}, nodes = {
                                                {n=G.UIT.R, config = {align = 'cm', colour = G.C.L_BLACK, padding = 0.05, r = 0.05, minh=0.45, minw = 1.05}, nodes = {
                                                    {n=G.UIT.R, config = {align='cl', colour = G.C.BLACK, minw = 0.5, r = 0.05, hover = true, button_dist = 0, button = 'toggle_plinko_cost'}, nodes = {
                                                        {n=G.UIT.C, config = {align = 'cm', colour = SMODS.Gradients.hpot_plincoin, r=0.1, minw=0.3, minh = 0.3}, nodes = {
                                                            {n=G.UIT.T, config = {text = '$', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, font = SMODS.Fonts.hpot_plincoin}}
                                                        }},
                                                        {n=G.UIT.C, config = {align = 'cr', colour = G.C.CLEAR, r=0.1, minw=0.3, minh = 0.3}, nodes = {
                                                            {n=G.UIT.T, config = {text = '»', colour = G.C.UI.TEXT_INACTIVE, scale = 0.3, font = SMODS.Fonts.hpot_plincoin}}
                                                        }},
                                                        {n=G.UIT.C, config = {align = 'cm', colour = G.C.CLEAR, r=0.1, minw=0.3, minh = 0.3}, nodes = {
                                                            {n=G.UIT.T, config = {text = '$', colour = G.C.UI.TEXT_INACTIVE, scale = 0.3}}
                                                        }}
                                                    }}
                                                }},
                                            }} or {n=G.UIT.R, config = {minh = 0.7}},
                                            {n=G.UIT.R, config={align='cm', padding = -0.25, minw = 2.5}, nodes = {
                                                {n=G.UIT.C, config = {align='cm', padding = 0.05}, nodes = {
                                                    {n=G.UIT.R, config = {align = 'cm', colour = G.C.L_BLACK, r = 0.3, padding = 0.05}, nodes = {
                                                        {n=G.UIT.R, config = {colour = SMODS.Gradients.hpot_plincoin, cost_up = 3, func = 'handle_plinko_colour', r=0.1, minw=0.5, minh = 0.15}}
                                                    }},
                                                    {n=G.UIT.R, config = {align = 'cm', colour = G.C.L_BLACK, r = 0.3, padding = 0.05}, nodes = {
                                                        {n=G.UIT.R, config = {colour = G.C.UI.TEXT_DARK, cost_up = 2, func = 'handle_plinko_colour', r=0.1, minw=0.5, minh = 0.15}}
                                                    }},
                                                    {n=G.UIT.R, config = {align = 'cm', colour = G.C.L_BLACK, r = 0.3, padding = 0.05}, nodes = {
                                                        {n=G.UIT.R, config = {colour = G.C.UI.TEXT_DARK, cost_up = 1, func = 'handle_plinko_colour', r=0.1, minw=0.5, minh = 0.15}}
                                                    }}
                                                }},
                                                {n=G.UIT.C, config = {align = 'cm', padding = 0.1, r=0.1, colour = G.C.L_BLACK}, nodes = {
                                                    {n=G.UIT.C, config = {hover = true, button = 'start_plinko', button_dist = 0.1, func = 'can_plinko', align = 'cm', minw = 1.4, maxw = 1.4, colour = SMODS.Gradients.hpot_plincoin, emboss=-0.03, r=0.2, padding = 0.1}, nodes = {
                                                        {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
                                                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                                                {n=G.UIT.O, config={object = DynaText({string = {{string = 'Play'}},
                                                                colours = {G.C.WHITE}, maxw = 1.6, shadow = true, spacing = 2, scale = 0.5})}},
                                                            }},
                                                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                                                {n=G.UIT.O, config={id = 'plinko_cost', object = DynaText({string = {{ref_table = G.GAME.current_round, ref_value = 'plinko_roll_cost', prefix = '$', font = SMODS.Fonts.hpot_plincoin}},
                                                                colours = {G.C.WHITE}, maxw = 1.6, shadow = true, spacing = 2, scale = 0.5})}}
                                                            }}
                                                        }},
                                                        
                                                    }},
                                                }},
                                                {n=G.UIT.C, config = {align='cm', padding = 0.05}, nodes = {
                                                    {n=G.UIT.R, config = {align = 'cm', padding = 0.05}, nodes = {
                                                        {n=G.UIT.R, config = {minw=0.5}}
                                                    }}
                                                }},
                                            }},
                                        }}
                                    }},
                                    {n=G.UIT.R, config = {minh = 0.15}},
                                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                        {n=G.UIT.T, config={text = 'Increases after', scale = 0.35, colour = G.C.L_BLACK}},
                                    }},
                                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                        {n=G.UIT.T, config={text = '3 plays', scale = 0.35, colour = G.C.L_BLACK}},
                                    }}
                                }},
                            }},
                        }},
                    }},
                
                }},
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, emboss = 0.05, minw = 6.8}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = G.C.BLACK, r=0.2, minh = 4, maxh=5 }, nodes={
                    {n=G.UIT.R, config={id = "plinking_area", align = "tm", colour = G.C.BLACK, r=0.2,  padding = 0., minw = 7, maxw = 7, minh = 5, maxh=5}, nodes={
                    
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.O, config={object = G.plinko_rewards}}
                    }},
                }},
            }},
        }}
    }}
end

function G.FUNCS.toggle_plinko_cost(e)
    local container = e
    local cost = container.UIBox:get_UIE_by_ID('plinko_cost')
    if container.config.align == 'cl' then
        -- dollars
        container.config.align = 'cr'
        e.children[3].config.colour = G.C.GOLD
        e.children[1].config.colour = G.C.CLEAR
        e.children[1].children[1].config.colour = G.C.UI.TEXT_INACTIVE
        e.children[3].children[1].config.colour = G.C.UI.TEXT_LIGHT
        e.children[2].config.align = 'cm'
        e.children[2].children[1].config.text = '«'
        cost.config.object.config.string[1].ref_value = 'plinko_roll_cost_dollars'
        cost.config.object.config.string[1].font = nil
        cost.parent.parent.parent.config.colour = G.C.GOLD
        cost.parent.parent.parent.config.func = 'can_plinko_dollars'
        cost.parent.parent.parent.config.button = 'start_plinko_dollars'
        PissDrawer.Shop.plinko_dollars = true
    else
        -- plincoins
        container.config.align = 'cl'
        e.children[1].config.colour = SMODS.Gradients.hpot_plincoin
        e.children[3].config.colour = G.C.CLEAR
        e.children[1].children[1].config.colour = G.C.UI.TEXT_LIGHT
        e.children[3].children[1].config.colour = G.C.UI.TEXT_INACTIVE
        e.children[2].config.align = 'cr'
        e.children[2].children[1].config.text = '»'
        cost.config.object.config.string[1].ref_value = 'plinko_roll_cost'
        cost.config.object.config.string[1].font = SMODS.Fonts.hpot_plincoin
        cost.parent.parent.parent.config.colour = SMODS.Gradients.hpot_plincoin
        cost.parent.parent.parent.config.func = 'can_plinko'
        cost.parent.parent.parent.config.button = 'start_plinko'
        PissDrawer.Shop.plinko_dollars = nil
    end
    cost.config.object:update_text(true)
    container.UIBox:recalculate()
end

function G.FUNCS.handle_plinko_colour(e)
    e.config.active = not PissDrawer.Shop.reset_plinko_counter and (3 - (G.GAME.current_round.plinko_rolls % 3)) >= to_number(e.config.cost_up)
    e.config.colour = PissDrawer.Shop.plinko_dollars and G.C.GOLD or SMODS.Gradients.hpot_plincoin
    e.config.colour = e.config.active and e.config.colour or G.C.BLACK
end



function PissDrawer.Shop.wheel()
    local reward_scale=  0.7
    G.wheel_rewards = CardArea(
        G.hand.T.x+0,
        G.hand.T.y+9,
        6,
        6,
        {card_limit = 8, type = 'shop', highlight_limit = 0, wheel_rewards = true}
    )
    G.wheel_arrow = CardArea(
        0, 0, 0, 0,
        { card_limit = 1, type = "shop", highlight_limit = 0, hotpot_shop = true }
    )
    
  local use_ante = Wheel.ante_left > 0
  local play_dollars = not not G.GAME.plinko_dollars_cost
    return
    {n=G.UIT.C, config = {align='tm', minh = 8}, nodes = {
        PissDrawer.Shop.help_button('wheel_help'),
        {n=G.UIT.R, config={align = "tm"}, nodes={
            {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.R, config = {minh = 0.8}},
                {n=G.UIT.R, config={align = "cm", padding = -0.3}, nodes={
                    {n=G.UIT.C, config={minw = 0.6}},
                    {n=G.UIT.C, config={colour=G.C.L_BLACK, padding = 0.15, r=0.1}, nodes = {
                        {n=G.UIT.C, config={align='bm', minw = 2.6, r=0.1, colour = G.C.BLACK}, nodes = {
                            {n=G.UIT.R, config = {align = 'cm', minw = 1, colour = G.C.BLACK, r=0.2}, nodes = {
                                {n=G.UIT.C, config = {align = 'cm', padding = 0.1}, nodes = {
                                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                        {n=G.UIT.O, config={object = DynaText({string = { { ref_table = Wheel, ref_value = use_ante and 'ante_left' or 'rounds_left', prefix = 'Resets in ', suffix = use_ante and localize('hotpot_plinko_reset2_ante') or localize('hotpot_plinko_reset2_round') } },
                                            colours = {G.C.L_BLACK}, maxw = 2.3, scale = 0.5})}}
                                    }},
                                    -- {n=G.UIT.R, config = {minh = 0.1}},
                                    {n=G.UIT.R, config = {align='cm', minw = 1, r=0.1, padding = 0.1}, nodes = {
                                        {n=G.UIT.C, config = {align = 'cm'}, nodes = {
                                            {n=G.UIT.R, config = {minh = 0.7}},
                                            {n=G.UIT.R, config={align='cm', padding = -0.25, minw = 2.5}, nodes = {
                                                {n=G.UIT.C, config = {align='cm', padding = 0.05}, nodes = {
                                                    {n=G.UIT.R, config = {align = 'cm', colour = G.C.L_BLACK, r = 0.3, padding = 0.05}, nodes = {
                                                        {n=G.UIT.R, config = {colour = G.C.UI.TEXT_DARK, cost_up = 2, func = 'handle_wheel_colour', r=0.1, minw=0.5, minh = 0.15}}
                                                    }},
                                                    {n=G.UIT.R, config = {align = 'cm', colour = G.C.L_BLACK, r = 0.3, padding = 0.05}, nodes = {
                                                        {n=G.UIT.R, config = {colour = G.C.UI.TEXT_DARK, cost_up = 1, func = 'handle_wheel_colour', r=0.1, minw=0.5, minh = 0.15}}
                                                    }}
                                                }},
                                                {n=G.UIT.C, config = {align = 'cm', padding = 0.1, r=0.1, colour = G.C.L_BLACK}, nodes = {
                                                    {n=G.UIT.C, config = {hover = true, button = 'wheel_spin', button_dist = 0.1, func = 'can_wheel_spin', align = 'cm', minw = 1.4, maxw = 1.4, colour = G.C.PURPLE, emboss=-0.03, r=0.2, padding = 0.1}, nodes = {
                                                        {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
                                                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                                                {n=G.UIT.O, config={object = DynaText({string = {{string = localize("wheel_spin_button1")}},
                                                                colours = {G.C.WHITE}, maxw = 1.6, shadow = true, spacing = 2, scale = 0.5})}},
                                                            }},
                                                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                                                {n=G.UIT.O, config={object = DynaText({string = {{ref_table = Wheel, ref_value = 'Price', prefix = G.GAME.seeded and localize('hotpot_reforge_budget') or localize('hotpot_reforge_credits'), font = SMODS.Fonts.hpot_plincoin}},
                                                                colours = {G.C.WHITE}, maxw = 1.6, shadow = true, spacing = 2, scale = 0.5})}}
                                                            }}
                                                        }},
                                                    }},
                                                }},
                                                {n=G.UIT.C, config = {align='cm', padding = 0.05}, nodes = {
                                                    {n=G.UIT.R, config = {align = 'cm', padding = 0.05}, nodes = {
                                                        {n=G.UIT.R, config = {minw=0.5}}
                                                    }}
                                                }},
                                            }},
                                        }}
                                    }},
                                    {n=G.UIT.R, config = {minh = 0.15}},
                                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                        {n=G.UIT.T, config={text = 'Increases after', scale = 0.35, colour = G.C.L_BLACK}},
                                    }},
                                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                        {n=G.UIT.T, config={text = '2 plays', scale = 0.35, colour = G.C.L_BLACK}},
                                    }}
                                }},
                            }},
                        }},
                    }},
                
                }},
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, emboss = 0.05, minw = 6.8, minh = 6.8}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = G.C.BLACK, r=0.2, padding = 0.2 }, nodes={
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.O, config={object = G.wheel_rewards}}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.O, config={object = G.wheel_arrow}}
                    }},
                }},
            }},
        }}
    }}
end

function G.FUNCS.handle_wheel_colour(e)
    e.config.active = not PissDrawer.Shop.reset_wheel_counter and (2 - (Wheel.cost_up % 2)) >= to_number(e.config.cost_up)
    e.config.colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE
    e.config.colour = e.config.active and e.config.colour or G.C.BLACK
end

local old_can_sell = Card.can_sell_card
function Card:can_sell_card(...)
    if
        PlinkoLogic.STATE == PlinkoLogic.STATES.IN_PROGRESS
        or PlinkoLogic.STATE == PlinkoLogic.STATES.REWARD
        or Wheel.STATE.SPUN
    then
        return false
    end
    return old_can_sell(self, ...)
end

local old_can_use = Card.can_use_consumeable
function Card:can_use_consumeable(...)
    if
        PlinkoLogic.STATE == PlinkoLogic.STATES.IN_PROGRESS
        or PlinkoLogic.STATE == PlinkoLogic.STATES.REWARD
        or Wheel.STATE.SPUN
    then
        return false
    end
    return old_can_use(self, ...)
end