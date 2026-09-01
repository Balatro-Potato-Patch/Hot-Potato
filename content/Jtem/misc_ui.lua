local index_to_jx_mult = {
-- from_multiplier, to multiplier, first_time_bonus_multiplier
    { 1 , 1, 1.1 },
    { 5 , 5.3, 1.35 },
    { 11 , 12, 1.65 },
    { 20 , 24, 2.1 },
    { 35 , 43, 3.2 },
}
local function hp_jtem_buy_jx_individual( b_type, index )
    local am
    if b_type == "plincoins" then
        b_type = 'plincoin'
        am = "p2j"
    elseif b_type == "credits" then
        am = "c2j"
    elseif b_type == "cryptocurrency" then
        b_type = 'crypto'
        am = "b2j"
    else
        am = "d2j"
    end
    local st = G.GAME["hp_jtem_".. am .."_rate"] or G.GAME.hp_jtem_d2j_rate
    local price_mult = index_to_jx_mult[index]
    local price = st.from * price_mult[1]
    local price_display = st.from * price_mult[1] - 0.01
    local gives_out = st.to * price_mult[2]
    local first_time_bonus = 0
    if not G.GAME.jp_jtem_has_ever_bought_jx then
        first_time_bonus = gives_out * price_mult[3]
    end
    local args = generate_currency_string_args(b_type)
    local _y = b_type == "plincoin" and 1 or 0
    if b_type == 'credits' then _y = 2 end
    if b_type == "crypto" then _y = 3 end
    gives_out = {gives_out}
    local numbertext = {
        {n = G.UIT.C, config = { align = "cm" }, nodes = {
            {n=G.UIT.R, config = {align='cm', maxw = 1.8}, nodes ={
                -- {n = G.UIT.T, config = { text = "͸"..(number_format(gives_out, 1e10)), colour = G.C.BLUE, scale = 0.35, font = SMODS.Fonts.hpot_plincoin }}
                {n=G.UIT.O, config={object = DynaText({string = {{ref_table = gives_out, ref_value = 1, prefix = "͸"}},
                        maxw = 1.8, colours = {G.C.BLUE}, font = SMODS.Fonts.hpot_plincoin, shadow = true, scale = 0.35})}}
            }}
        }}
    }

    if not G.GAME.jp_jtem_has_ever_bought_jx then
        table.insert(numbertext[1].nodes, {n=G.UIT.R, config = {align='cm', maxw = 1.8}, nodes={
            -- {n=G.UIT.T, config = { text = localize{type = "variable", vars = {number_format(first_time_bonus, 1e10)}, key = "hotpot_exchange_bonus"}, colour = G.C.RED, scale = 0.23, font = SMODS.Fonts.hpot_plincoin }}
            {n=G.UIT.O, config={object = DynaText({string = {localize{type = "variable", vars = {number_format(first_time_bonus, 1e10)}, key = "hotpot_exchange_bonus"}},
                        maxw = 1.8, colours = {G.C.RED}, font = args.font, shadow = true, scale = 0.23})}}
        }})
    end
        return 
        {n=G.UIT.C, config = { minw = 1.8, minh = 2.7, maxw = 1.8, maxh = 2.7, align = "bm", padding = 0.1, colour = G.C.UI.TRANSPARENT_DARK, r = 0.1}, nodes = {
            {n=G.UIT.R, config = { align = "cm" }, nodes = {
                {n = G.UIT.O, config = {object = Sprite(0,0,1.3,1.3,G.ASSET_ATLAS['hpot_jtem_jx_bundle'],{ x = index - 1, y = _y})}},
            }},
            {n=G.UIT.R, config = { align = "bm", maxw = 1.8, minh = 0.4, maxh = 0.4 }, nodes = {
                {n=G.UIT.O, config={object = DynaText({string = {localize("hotpot_exchange_option_"..(b_type == "plincoin" and "plin_" or b_type == "credits" and "cred_" or b_type == "crypto" and "crypto_" or "")..index)},
                    maxw = 1.8, colours = {G.C.WHITE}, font = SMODS.Fonts.hpot_plincoin, shadow = true, scale = 0.3})}}
            }},
            {n=G.UIT.R, config = { align = "cm", maxw = 1.8 }, nodes = numbertext},
            {n=G.UIT.R, config = {maxh = 0.75, minh = 0.55, maxw = 1.8, align = "cm", func = "hpot_can_buy_jx_screen", button = 'hpot_buy_jx_screen', shadow = true, ref_table = {currency = b_type, take = price, gives = gives_out[1] + first_time_bonus, args = args, first_time_bonus = first_time_bonus > 0}, hover = true, colour = args.colour, font = args.font, padding = 0.05, r = 0.05,minw = 1.8}, nodes = {
                -- {n=G.UIT.T, config = { text = args.symbol..price_display, colour = G.C.WHITE, scale = 0.3, font = args.font }}
                {n=G.UIT.O, config={object = DynaText({string = {args.symbol..price_display},
                        maxw = 1.8, colours = {G.C.WHITE}, font = args.font, shadow = true, scale = 0.35})}}
            }}
        }}
    
end

G.FUNCS.hpot_can_buy_jx_screen = function (e)
    local buy_table = e.config.ref_table
    
    if (to_big(buy_table.take) > to_big(get_currency_amount(buy_table.currency) - (buy_table.currency == "dollars" and G.GAME.bankrupt_at or 0))) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = buy_table.args.colour
        e.config.button = 'hpot_buy_jx_screen'
    end
    
end

G.FUNCS.hpot_buy_jx_screen = function (e)
    local buy_table = e.config.ref_table
    G.GAME.jp_jtem_has_ever_bought_jx = true
    ease_currency(buy_table.currency,-buy_table.take)
    ease_spark_points(buy_table.gives)
    if buy_table.first_time_bonus and G.shop then
        PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.currency_exchange)
    end
    -- Wtf is this?
    --[[local disp = e.parent.UIBox:get_UIE_by_ID('exchange_UI')
    if disp then
        disp:remove()
        disp.UIBox:add_child(hp_jtem_buy_jx_row(e.config.currency), disp)
    end]]--
end

function hp_jtem_buy_jx_row( type )
    local ch = {}
    for i = 1, 5 do 
        table.insert(ch, hp_jtem_buy_jx_individual(type, i))
    end
    return {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.1, colour = G.C.UI.TRANSPARENT_DARK, r = 0.1 },
        nodes = ch
    }
end
G.UIDEF.hp_jtem_buy_jx = function (mode)
    local nds = {}
    if mode == "dollars" or (mode == "both") then
        table.insert(nds, hp_jtem_buy_jx_row( "dollars" ))
    end
    if (mode == "plincoin" or (mode == "both")) and G.GAME.hp_jtem_should_allow_buying_jx_from_plincoin then
        table.insert(nds, hp_jtem_buy_jx_row( "plincoin" ))
    end
    if (mode == "credits" or mode == "both_2") and G.GAME.hp_jtem_should_allow_buying_jx_from_credits then
        table.insert(nds, hp_jtem_buy_jx_row( "credits" ))
    end

    if (mode == "crypto" or mode == "both_2") and G.GAME.hp_jtem_should_allow_buying_jx_from_crypto then
        table.insert(nds, hp_jtem_buy_jx_row( "crypto" ))
    end
    local ret
if G.GAME.used_vouchers["v_hpot_exchange_rate"] then
    if mode == "both" then
     ret = {
        n = G.UIT.C,
        config = { colour = G.C.UI.TRANSPARENT_DARK , minw = 6.5, minh = 3.5, r = 0.15, padding = 0.1, align = "tm" },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    { n = G.UIT.O, config = { 
                        object = 
                            DynaText({ string = {localize('hotpot_exchange_title')}, font = SMODS.Fonts.hpot_plincoin, float = true, colours = {G.C.BLUE}, shadow = true}) 
                        }
                    },
                }
            },
            {
                n = G.UIT.R,
                nodes = nds
            },
           {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = { text = localize("hotpot_exchange_note"), scale = 0.4, colour = G.C.GREY }
                    }
                }
            },
            UIBox_adv_button{
                    label = {{{"Go to Page 2"}}},
                    text_scale = 0.7,
                    button = 'change_page_or_do_somethng_idk',
                    colour = G.C.UI.TRANSPARENT_DARK
                },
            
        },
    }
    elseif mode == "both_2" then
            ret = {
        n = G.UIT.C,
        config = { colour = G.C.UI.TRANSPARENT_DARK , minw = 6.5, minh = 3.5, r = 0.15, padding = 0.1, align = "tm" },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    { n = G.UIT.O, config = { 
                        object = 
                            DynaText({ string = {localize('hotpot_exchange_title')}, font = SMODS.Fonts.hpot_plincoin, float = true, colours = {G.C.BLUE}, shadow = true}) 
                        }
                    },
                }
            },
            {
                n = G.UIT.R,
                nodes = nds
            },
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = { text = localize("hotpot_exchange_note"), scale = 0.4, colour = G.C.GREY }
                    }
                }
            },
            UIBox_adv_button{
                    label = {{{"Go to Page 1"}}},
                    text_scale = 0.7,
                    button = 'change_page_or_do_somethng_idk',
                    colour = G.C.UI.TRANSPARENT_DARK
                },
            
        },
    }
else
        ret = {
        n = G.UIT.C,
        config = { colour = G.C.UI.TRANSPARENT_DARK , minw = 6.5, minh = 3.5, r = 0.15, padding = 0.1, align = "tm" },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    { n = G.UIT.O, config = { 
                        object = 
                            DynaText({ string = {localize('hotpot_exchange_title')}, font = SMODS.Fonts.hpot_plincoin, float = true, colours = {G.C.BLUE}, shadow = true}) 
                        }
                    },
                }
            },
            {
                n = G.UIT.R,
                nodes = nds
            },
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = { text = localize("hotpot_exchange_note"), scale = 0.4, colour = G.C.GREY }
                    }
                }
            },
            
        },
    }
end
else
        ret = {
        n = G.UIT.C,
        config = { colour = G.C.UI.TRANSPARENT_DARK , minw = 6.5, minh = 3.5, r = 0.15, padding = 0.1, align = "tm" },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    { n = G.UIT.O, config = { 
                        object = 
                            DynaText({ string = {localize('hotpot_exchange_title')}, font = SMODS.Fonts.hpot_plincoin, float = true, colours = {G.C.BLUE}, shadow = true}) 
                        }
                    },
                }
            },
            {
                n = G.UIT.R,
                nodes = nds
            },
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.2},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = { text = localize("hotpot_exchange_note"), scale = 0.4, colour = G.C.GREY }
                    }
                }
            },
            
        },
    }
end
    return create_UIBox_generic_options({ contents = {ret}})
end

--[[
    ease_dollars(-G.GAME.hp_jtem_d2j_rate.from)
    ease_spark_points(G.GAME.hp_jtem_d2j_rate.to)

    ease_plincoins(-G.GAME.hp_jtem_p2j_rate.from)
    ease_spark_points(G.GAME.hp_jtem_p2j_rate.to)
]]

G.FUNCS.hp_can_open_full_jx_top_up = function(e)
    if not (G.STATE == G.STATES.SHOP) then
        e.config.button = nil
        e.config.hover = false
    else
        e.config.button = 'hp_open_full_jx_top_up'
        e.config.hover = true
    end
end
G.FUNCS.hp_open_full_jx_top_up = function(e)
    G.SETTINGS.paused = true
    G.GAME.second_first_ig = nil
        G.FUNCS.overlay_menu {
            definition = G.UIDEF.hp_jtem_buy_jx("both")
        }
end 

G.FUNCS.change_page_or_do_somethng_idk = function(e)
    G.SETTINGS.paused = true
    if G.GAME.second_first_ig then
        G.GAME.second_first_ig = nil
         G.FUNCS.hp_open_full_jx_top_up(e)
    else
        G.GAME.second_first_ig = true
        G.FUNCS.overlay_menu {
            definition = G.UIDEF.hp_jtem_buy_jx("both_2")
        }
       
    end
end