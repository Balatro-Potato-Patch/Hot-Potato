-- SHOP Button for Delivery
-- this is patched into the code via jtem_delivery.toml

-- little reminder that unless absolutely needed, don't use "at" target for patches :3

-- Lil LSP definitions

--- Type of currency.
---@alias Jtem.CurrencyType
---| "dollars"          -- Traditional dollars
---| "plincoin"
---| "credits"
---| "joker_exchange"

--- Delivery object.
---@class Jtem.Delivery
---@field key string Key to the object to be delivered.
---@field price? number Price of the object.
---@field currency? Jtem.CurrencyType|string Currency type for the object.
---@field rounds_passed number Amount of rounds passed for delivery.
---@field rounds_total number Amount of rounds required until delivery.
---@field extras? table Additional fields to be added to the delivered card's ability table.
---@field create_card_args? CreateCard|table Arguments to be passed to `SMODS.create_card`.

function G.UIDEF.hotpot_jtem_delivery_section()
end

-- like in React, I made stuff I reuse into buttons
---<br>Patched to support custom non-hardcoded buttons.\
---`loc_txt` - String pointing towards `misc/dictionary` in the localization files.\
---`button` - String pointing towards a function in `G.FUNCS[button]`.\
---`atlas` - String pointing towards an atlas file in `G.ASSET_ATLAS[atlas].`\
---`pos = {x, y}` - Array of 2 numbers pointing towards the position of the sprite in the `atlas` provided.
---@param btntype? string|{loc_txt:string,button:string,atlas:string,pos:{x:integer,y:integer}}
---@return table
function G.UIDEF.hotpot_jtem_shop_delivery_btn_component(btntype)
    local btnx = 0
    local btny = 0
    local localized = "hotpot_delivery"
    local func = "hotpot_jtem_toggle_delivery"
    local has_sprite = not not (btntype and type(btntype) == "table" and btntype.atlas)
    local atlas = "hpot_jtem_pkg"
    -- Wrapper to prevent crashes due to use of the original function
    if type(btntype) == "string" or not btntype then
        if btntype == "to_delivery" or not btntype then
            localized = "hotpot_delivery"
            btnx = 0
        elseif btntype == "back_from_delivery" then
            localized = "hotpot_delivery_back"
            btnx = 1
        end
    elseif type(btntype) == "table" then
        localized = btntype.loc_txt or "hotpot_delivery"
        func = btntype.button or "hotpot_jtem_toggle_delivery"
        atlas = btntype.atlas or "hpot_jtem_pkg"
        btnx = btntype.pos and btntype.pos.x or 0
        btny = btntype.pos and btntype.pos.y or 0
    end
    return {
        n = G.UIT.R,
        config = { colour = G.C.RED, padding = 0.05, r = 0.02, w = 0.1, h = 0.1, shadow = true, button = func, hover = true },
        nodes = {
            has_sprite and {
                n = G.UIT.R,
                config = {},
                nodes = {
                    {
                        n = G.UIT.O,
                        config = {
                            object = Sprite(0, 0, 0.5, 0.5, G.ASSET_ATLAS[atlas], { x = btnx, y = btny })
                        }
                    },
                }
            } or nil,
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = { text = localize(localized), scale = 0.4, colour = G.C.WHITE, opposite_vert = true }
                    },
                }
            },
        }
    }
end

function get_stickers(center)
    local stickers = {}
    if center then
          for k, v in pairs(SMODS.Sticker.obj_table) do
            local success, should_apply = pcall(v.should_apply, v, nil, center, nil, true)
            if success then
                if k ~= "eternal" and k ~= "rental" and k ~= "perishable" and type(v.should_apply) == 'function' and v:should_apply(nil, center, nil, true) then
                    if pseudorandom("hpjtem_delivery_" .. k .. center_key) < v.rate then
                        local sticker_compatible = v.default_compat
                        if sticker_compatible == nil then sticker_compatible = true end
                        if center[k.."_compat"] ~= nil then sticker_compatible = center[k.."_compat"] end
                        if sticker_compatible then stickers[#stickers + 1] = k end
                    end
                end
            end
        end  
    end
    return stickers
end

function G.UIDEF.hotpot_jtem_shop_delivery_btn()
    if not G.GAME.modifiers.no_shop_jokers then
        return {
            n = G.UIT.C,
            config = { padding = 0.05, r = 0.05, w = 0.1, h = 0.1 },
            nodes = {
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component(),
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component {
                    loc_txt = "hotpot_go_reforge",
                    button = "hotpot_tname_toggle_reforge",
                    atlas = "hpot_tname_shop_reforge"
                },
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component {
                    loc_txt = "hotpot_go_market",
                    button = "hotpot_horsechicot_toggle_market",
                    atlas = "hpot_horsechicot_market"
                },
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component {
                    loc_txt = "hotpot_go_training",
                    button = "hotpot_pd_toggle_training",
                },
                {
                    n = G.UIT.R,
                    nodes = {
                        {
                            n = G.UIT.B,
                            config = {
                                h = 7,
                                w = 0.1
                            }
                        }
                    }
                },
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component("back_from_delivery"),
                {
                    n = G.UIT.R,
                    nodes = {
                        {
                            n = G.UIT.B,
                            config = {
                                h = 12.2,
                                w = 0.1
                            }
                        }
                    }
                },
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component {
                    loc_txt = "hotpot_delivery_back",
                    button = "hotpot_tname_toggle_reforge",
                    atlas = "hpot_tname_shop_reforge",
                    pos = { x = 1, y = 0 }
                },
                {
                    n = G.UIT.R,
                    nodes = {
                        {
                            n = G.UIT.B,
                            config = {
                                h = 10.5,
                                w = 0.1
                            }
                        }
                    }
                },
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component {
                    loc_txt = "hotpot_delivery_back",
                    button = "hotpot_horsechicot_toggle_market",
                    atlas = "hpot_tname_shop_reforge",
                    pos = { x = 1, y = 0 }
                },
                {
                    n = G.UIT.R,
                    nodes = {
                        {
                            n = G.UIT.B,
                            config = {
                                h = 10.5,
                                w = 0.1
                            }
                        }
                    }
                },
                G.UIDEF.hotpot_jtem_shop_delivery_btn_component {
                    loc_txt = "hotpot_delivery_back",
                    button = "hotpot_pd_toggle_training",
                    atlas = "hpot_tname_shop_reforge",
                    pos = { x = 1, y = 0 }
                },
            },
        }
    end
end

G.FUNCS.hp_jtem_can_exchange_d2j = function(e)
    if (to_big(0) > to_big(G.GAME.dollars - G.GAME.bankrupt_at)) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.GOLD
        e.config.button = 'hp_jtem_exchange_d2j'
    end
end
G.FUNCS.hp_jtem_can_exchange_p2j = function(e)
    if (to_big(0) > to_big(G.GAME.plincoins)) or not G.GAME.hp_jtem_should_allow_buying_jx_from_plincoin then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = SMODS.Gradients["hpot_plincoin"]
        e.config.button = 'hp_jtem_exchange_p2j'
    end
end
G.FUNCS.hp_jtem_can_exchange_c2j = function(e)
    if (to_big(0) > to_big(G.GAME.seeded and G.GAME.budget or G.PROFILES[G.SETTINGS.profile].TNameCredits)) or not G.GAME.hp_jtem_should_allow_buying_jx_from_credits then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE
        e.config.button = 'hp_jtem_exchange_c2j'
    end
end
G.FUNCS.hp_jtem_can_exchange_b2j = function(e)
    if (to_big(0) > to_big(G.GAME.cryptocurrency)) or not G.GAME.hp_jtem_should_allow_buying_jx_from_crypto then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = SMODS.Gradients["hpot_advert"]
        e.config.button = 'hp_jtem_exchange_b2j'
    end
end
G.FUNCS.hp_jtem_can_order = function(e)
    local _c = e.config.ref_table
    if (to_big(_c.ability.hp_jtem_currency_bought_value) > to_big(get_currency_amount(_c.ability.hp_jtem_currency_bought) - (_c.ability.hp_jtem_currency_bought == "dollars" and G.GAME.bankrupt_at or 0))) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.ORANGE
        e.config.button = 'hp_jtem_order'
    end
end
G.FUNCS.hp_jtem_can_request_joker = function(e)
    local _c = e.config.ref_table
    if (not G.GAME.hp_jtem_should_allow_custom_order) or G.GAME.hp_jtem_already_requested_this_ante then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.RED
        e.config.button = 'hotpot_jtem_delivery_request_item'
    end
end

function hpot_jtem_create_request_menu()
    G.HP_REQUEST = {
        text = "",
        extended_corpus = true
    }
    local butan = UIBox_button {
        button = 'hp_jtem_search_jokers',
        minh = 0.7,
        minw = 3,
        align = "cm",
        colour = G.C.RED,
        label = { localize("hotpot_search") },
        scale = 0.6
    }
    -- i am going to kill myself
    butan.n = G.UIT.C
    return SMODS.card_collection_UIBox({}, { 5 }, {
        no_materialize = true,
        hide_single_page = true,
        h_mod = 1.18,
        hp_misc_elements = function()
            return {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.2 },
                nodes = {
                    create_text_input({
                        ref_table = G.HP_REQUEST,
                        ref_value = "text",
                        w = 8,
                        max_length = 32,
                        callback = function()
                            G.FUNCS.hp_jtem_search_jokers()
                        end
                    }),
                    butan
                }
            }
        end,
        back_func = 'exit_overlay_menu'
    })
end

function G.FUNCS.hotpot_jtem_delivery_request_item(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = hpot_jtem_create_request_menu()
    }
end

local currencies = { "dollars", "joker_exchange", "plincoin", "credits", "cryptocurrency" }
local function hpot_create_joker_from_amazon(card, center)
    -- factors are more fucked when requesting
    local should_spawn_with_rental = pseudorandom("hpjtem_amazon_delivery_rental") < 0.3 and true
    local should_spawn_with_eternal = center.eternal_compat and pseudorandom("hpjtem_amazon_delivery_eternal") < 0.3 and true
    local should_spawn_with_perishable = center.perishable_compat and
        pseudorandom("hpjtem_amazon_delivery_perishable") < 0.3 and not should_spawn_with_eternal
    local currency = pseudorandom_element(currencies, pseudoseed("hpjtem_amazon_delivery_currency"))
    local price_factor = 0.5
    if currency == "joker_exchange" then
        price_factor = 12942
    elseif currency == "plincoin" then
        price_factor = 0.75
    elseif currency == "credits" then
        price_factor = 20
    end
    local credits = currency == "credits"
    local plincoin = currency == "plincoin"
    local jx = currency == "joker_exchange"
    local stickers = get_stickers(center)
    stickers[#stickers + 1] = should_spawn_with_rental and "rental" or nil
    stickers[#stickers + 1] = should_spawn_with_eternal and "eternal" or nil
    stickers[#stickers + 1] = should_spawn_with_perishable and "perishable" or nil
    local create_card_args = {
        hp_jtem_silent_edition = plincoin and poll_edition("hpjtem_amazon_delivery_edition", nil, nil, true) or
            (not jx and poll_edition("hpjtem_amazon_delivery_edition")),
        no_edition = jx or credits,
        bypass_discovery_ui = true,
        bypass_discovery_center = true,
        stickers = stickers,
        no_stickers = true
    }
    if create_card_args.hp_jtem_silent_edition == nil then create_card_args.hp_jtem_silent_edition = "e_base" end
    -- TODO: Needs tweaking. This isn't free joker simulator :V
    local random_price_factor = pseudorandom("hpjtem_amazon_delivery_price_factor") * 0.52 + 0.84
    price_factor = price_factor * (should_spawn_with_eternal and 0.9 or 1) * (should_spawn_with_rental and 0.6 or 1) *
        (should_spawn_with_perishable and 0.6 or 1) * 1.5
    for _, v in ipairs(stickers) do
        if v ~= "eternal" and v ~= "rental" and v ~= "perishable" then
            price_factor = price_factor * (SMODS.Sticker.obj_table[v].hpot_amazon_price or SMODS.Sticker.obj_table[v].hpot_delivery_price or 0.95)
        end
    end
    if center.credits then
        hotpot_jtem_add_to_offers(center.key, {
            price = { currency = currency, value = math.ceil(center.credits / 7 * price_factor * random_price_factor) },
            rounds_total_factor = 0.4 * (should_spawn_with_perishable and 0.6 or 1) *
                (should_spawn_with_eternal and 0.6 or 1) * (should_spawn_with_rental and 0.5 or 1) *
                (plincoin and 2 or 1) * 1.5,
            extras = {
                rental = should_spawn_with_rental,
                eternal = should_spawn_with_eternal,
                perishable = should_spawn_with_perishable,
                perish_tally = should_spawn_with_perishable and G.GAME.perishable_rounds,
            },
            create_card_args = create_card_args
        })
    else
        hotpot_jtem_add_to_offers(center.key, {
            price = { currency = currency, value = math.ceil(center.cost * price_factor * random_price_factor) },
            rounds_total_factor = 0.4 * (should_spawn_with_perishable and 0.6 or 1) *
                (should_spawn_with_eternal and 0.6 or 1) * (should_spawn_with_rental and 0.5 or 1) *
                (plincoin and 2 or 1) * 1.5,
            extras = {
                rental = should_spawn_with_rental,
                eternal = should_spawn_with_eternal,
                perishable = should_spawn_with_perishable,
                perish_tally = should_spawn_with_perishable and G.GAME.perishable_rounds,
            },
            create_card_args = {
                hp_jtem_silent_edition = plincoin and poll_edition("hpjtem_amazon_delivery_edition", nil, nil, true) or
                    (not jx and poll_edition("hpjtem_amazon_delivery_edition")),
                no_edition = jx or credits,
                bypass_discovery_ui = true,
                bypass_discovery_center = true,
                stickers = {
                    rental = should_spawn_with_rental,
                    eternal = should_spawn_with_eternal,
                    perishable = should_spawn_with_perishable,
                    unpack(stickers)
                },
                no_stickers = true
            }
        })
    end
    -- cannot order again until the end of this ante
    G.GAME.hp_jtem_already_requested_this_ante = true
    hotpot_delivery_refresh_card()
end

function G.FUNCS.hp_jtem_search_jokers(e)
    -- you FUCKING idiot
    if G.HP_REQUEST and G.HP_REQUEST.text == "" then return end
    if G.your_collection and G.your_collection[1] then
        hotpot_jtem_destroy_all_card_in_an_area(G.your_collection[1])
        local count = 0
        for _, joker in pairs(G.P_CENTER_POOLS.Joker) do
            local name = localize { key = joker.key, set = "Joker", vars = {}, type = 'name_text' }
            if not name then goto continue end
            if not string.find(string.lower(name), string.lower(G.HP_REQUEST.text)) then goto continue end
            local card = SMODS.add_card { key = joker.key, area = G.your_collection[1] }
            local old_click = card.click
            local center = card.config.center or {}
            card.click = function(self)
                old_click(self)
                hpot_create_joker_from_amazon(card, center)
                G.FUNCS.exit_overlay_menu()
            end
            count = count + 1
            if count >= 5 then break end
            ::continue::
        end
    end
end

G.FUNCS.hp_jtem_can_cancel = function(e)
    return false
end
G.FUNCS.hp_jtem_exchange_d2j = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = G.UIDEF.hp_jtem_buy_jx("dollars")
    }
end
G.FUNCS.hp_jtem_exchange_p2j = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = G.UIDEF.hp_jtem_buy_jx("plincoin")
    }
end
G.FUNCS.hp_jtem_exchange_c2j = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = G.UIDEF.hp_jtem_buy_jx("credits")
    }
end
G.FUNCS.hp_jtem_exchange_b2j = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = G.UIDEF.hp_jtem_buy_jx("crypto")
    }
end
G.FUNCS.hp_jtem_order = function(e)
    G.GAME.hp_jtem_queue_max_size = G.GAME.hp_jtem_queue_max_size or 2
    local card = e.config.ref_table
    if #G.GAME.hp_jtem_delivery_queue >= to_number(G.GAME.hp_jtem_queue_max_size) then
        alert_no_space(card, G.hp_jtem_delivery_queue)
        e.disable_button = nil
        return
    end
    local object = card.ability.hp_delivery_obj
    ease_currency(object.currency, -object.price)
    table.insert(G.GAME.hp_jtem_delivery_queue, object)
    remove_element_from_list(G.GAME.round_resets.hp_jtem_special_offer, object)
    draw_card(G.hp_jtem_delivery_special_deals, G.hp_jtem_delivery_queue, nil, 'up', false, card)
    if card.children.price then
        card.children.price:remove()
        card.children.price = nil
    end
    if card.children.hp_jtem_price_side then
        card.children.hp_jtem_price_side:remove()
        card.children.hp_jtem_price_side = nil
    end
    if card.children.hp_jtem_cancel_order then
        card.children.hp_jtem_cancel_order:remove()
        card.children.hp_jtem_cancel_order = nil
    end
    local args = generate_currency_string_args(card.ability.hp_jtem_currency_bought)
    local temp_str = { str = (object.rounds_passed .. "/" .. object.rounds_total) }
    hpot_jtem_create_delivery_boxes(card, { { ref_table = temp_str, ref_value = 'str', object = object } }, args)
    --hotpot_delivery_refresh_card()
end
G.FUNCS.hp_jtem_cancel = function(e)
    local card = e.config.ref_table
    local object = card.ability.hp_delivery_obj
    local returncost = math.ceil(object.price * 0.5)
    ease_currency(object.currency, returncost)
    remove_element_from_list(G.GAME.hp_jtem_delivery_queue, object)
    card:start_dissolve()
    --hotpot_delivery_refresh_card()
end

-- literally copied from price boxes
function hpot_jtem_create_delivery_boxes(card, rounds_text, args)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.43,
        blocking = false,
        blockable = false,
        func = (function()
            if card.opening then return true end
            if card.children.price then
                card.children.price:remove()
            end
            if card.children.hp_jtem_price_side then
                card.children.hp_jtem_price_side:remove()
            end
            local t1 = {
                n = G.UIT.ROOT,
                config = { minw = 0.6, align = 'tm', colour = darken(G.C.BLACK, 0.2), shadow = true, r = 0.05, padding = 0.05, minh = 1 },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", colour = lighten(G.C.BLACK, 0.1), r = 0.1, minw = 1, minh = 0.55, emboss = 0.05, padding = 0.03 },
                        nodes = {
                            { n = G.UIT.O, config = { object = DynaText({ string = { unpack(rounds_text) }, colours = { G.C.GREEN }, shadow = true, silent = true, bump = true, pop_in = 0, scale = 0.5 }) } },
                        }
                    }
                }
            }
            local t2 = {
                n = G.UIT.ROOT,
                config = { ref_table = card, minw = 1.5, maxw = 2.8, padding = 0.1, align = 'mc', colour = args.colour, shadow = true, r = 0.08, minh = 0.94 },
                nodes = {
                    {
                        n = G.UIT.R,
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = {},
                                nodes = {
                                    { n = G.UIT.T, config = { font = SMODS.Fonts["hpot_plincoin"], text = localize("hotpot_cashback") .. " ", colour = G.C.WHITE, scale = 0.4, shadow = true, } }
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = {},
                                nodes = {
                                    { n = G.UIT.T, config = { font = args.font, text = ((args.symbol) .. number_format(math.ceil(card.ability.hp_jtem_currency_bought_value * 0.5))), colour = G.C.WHITE, scale = 0.4, shadow = true } }
                                }
                            },
                        }
                    },
                    { n = G.UIT.R, nodes = { { n = G.UIT.B, config = { h = 1, w = 0.1 } } } },
                }
            }
            card.children.price = UIBox {
                definition = t1,
                config = {
                    align = "tm",
                    offset = { x = 0, y = 1.5 },
                    major = card,
                    bond = 'Weak',
                    parent = card

                } }
            card.children.hp_jtem_price_side = UIBox {
                definition = t2,
                config = {
                    align = "tm",
                    offset = { x = 0, y = 0.5 },
                    major = card,
                    bond = 'Weak',
                    parent = card

                } }
            card.children.price.alignment.offset.y = card.ability.set == 'Booster' and 0.5 or 0.38
            local _obj = card.ability.hp_delivery_obj or rounds_text.object
            if _obj and _obj.rounds_passed == _obj.rounds_total then
                card.children.hp_jtem_delivery_alert = UIBox{
                    definition = hp_jtem_create_UIBox_card_alert({ bg_col = G.C.RED }), 
                    config = { align="tri", offset = {x = 0.1, y = 0.1}, parent = card}
                }
                card.children.hp_jtem_delivery_alert.states.collide.can = false
            end
            return true
        end)
    }))
end

function hpot_jtem_create_special_deal_boxes(card, price_text, args)
    if card.REMOVED then return end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.43,
        blocking = false,
        blockable = false,
        func = (function()
            if card.opening or card.REMOVED then return true end

            if not card.children.price then
                local t1 = {
                    n = G.UIT.ROOT,
                    config = { minw = 0.6, align = 'tm', colour = darken(G.C.BLACK, 0.2), shadow = true, r = 0.05, padding = 0.05, minh = 1 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm", colour = lighten(G.C.BLACK, 0.1), r = 0.1, minw = 1, minh = 0.55, emboss = 0.05, padding = 0.03 },
                            nodes = {
                                { n = G.UIT.O, config = { object = DynaText({ string = { unpack(price_text) }, colours = { args.colour or G.C.MONEY }, shadow = true, silent = true, bump = true, pop_in = 0, scale = 0.5, font = args.font or SMODS.Fonts["hpot_plincoin"] }) } },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", r = 0.1, minw = 1, minh = 0.2, emboss = 0.05, padding = 0.01 },
                            nodes = {
                                { n = G.UIT.T, config = { text = localize { key = "hotpot_round_total_eta", type = "variable", vars = { card.ability.hp_delivery_obj.rounds_total } }, colour = G.C.WHITE, scale = 0.4, font = SMODS.Fonts["hpot_plincoin"] } },
                            }
                        },
                        { n = G.UIT.R, nodes = { { n = G.UIT.B, config = { h = 0.2, w = 0.1 } } } },

                    }
                }

                card.children.price = UIBox {
                    definition = t1,
                    config = {
                        align = "tm",
                        offset = { x = 0, y = 1.5 },
                        major = card,
                        bond = 'Weak',
                        parent = card

                    }
                }
            end
            
            card.children.price.alignment.offset.y = card.ability.set == 'Booster' and 0.5 or 0.425
            G.GAME.hp_jtem_d2j_rate = G.GAME.hp_jtem_d2j_rate or { from = 1, to = 5000 }
            G.GAME.hp_jtem_p2j_rate = G.GAME.hp_jtem_p2j_rate or { from = 1, to = 32000 }
            G.GAME.hp_jtem_b2j_rate = G.GAME.hp_jtem_b2j_rate or { from = 1, to = 117000 }
            G.GAME.hp_jtem_c2j_rate = G.GAME.hp_jtem_c2j_rate or { from = 1, to = 833 }


            return true
        end)
    }))
end

function hotpot_jtem_init_extra_shops_area()
    -- i just copied this from the shop definition lol
    if G.hp_jtem_delivery_special_deals then
        G.hp_jtem_delivery_special_deals:remove()
    end
    if G.hp_jtem_delivery_queue then
        G.hp_jtem_delivery_queue:remove()
    end
    G.hp_jtem_delivery_special_deals = CardArea(
        G.hand.T.x + 0,
        G.hand.T.y + G.ROOM.T.y + 9,
        2.95 * G.CARD_W,
        1.15 * G.CARD_H * PissDrawer.shop_scale,
        { card_limit = 4, type = 'shop', highlight_limit = 1, lr_padding = 0.1, hotpot_shop = true })
    G.hp_jtem_delivery_queue = CardArea(
        G.hand.T.x + 0,
        G.hand.T.y + G.ROOM.T.y + 9,
        1.82 * G.CARD_W,
        1.05 * G.CARD_H * PissDrawer.shop_scale,
        { card_limit = 2, type = 'shop', highlight_limit = 1, hotpot_shop = true })
    G.hp_jtem_delivery_queue.cards = G.hp_jtem_delivery_queue.cards or {}
    G.hp_jtem_delivery_special_deals.cards = G.hp_jtem_delivery_special_deals.cards or {}
    G.hp_jtem_y_queue = G.hp_jtem_y_queue or {}
    G.hp_jtem_y_queue.children = G.hp_jtem_delivery_queue.children or {}
    G.hp_jtem_delivery_special_deals.children = G.hp_jtem_delivery_special_deals.children or {}
end

-- destroy all cards in an area, I am too lazy to make a god damn loop damn it
-- I do! - SleepyG11
function hotpot_jtem_destroy_all_card_in_an_area(area, nofx)
    if not area or not area.cards then return end
    local cards_to_remove = {}
    for _, card in pairs(area.cards) do
        table.insert(cards_to_remove, card)
    end

    for i, _c in ipairs(cards_to_remove) do
        area:remove_card(_c)
        if nofx then
            _c:remove()
        else
            _c:start_dissolve({ G.C.RED }, G.SPEEDFACTOR * 1.2)
        end
    end
    area.cards = {}
end

local skip_align_card_if_no_card = CardArea.align_cards
function CardArea:align_cards()
    if not self.cards then return end
    return skip_align_card_if_no_card(self)
end

local init_game_object_for_delivery = Game.init_game_object
function Game:init_game_object()
    local r = init_game_object_for_delivery(self)
    ---@type Jtem.Delivery[]
    r.hp_jtem_delivery_queue = {}
    --[[
        okay so before i get murdered for not documenting my code here's the rundown on the format
        the queue consist of
            key - the key of the card that was queue in delivery
            rounds_passed - rounds waited for delivery
            rounds_total - rounds that you would have to wait in total
            price - cost in case of refunds (is a table now lol)
                price.value and price.currency - should be self explanatory (ok so currency at the moment has 4,
                    dollars, plincoin, credits, and joker exchange (internally spark_points) )
            extras - other attributes that should apply to card ability directly, for example eternal, rental
    ]]
    ---@type Jtem.Delivery[]
    r.round_resets.hp_jtem_special_offer = {}
    --[[
        the offer should reset EVERY round with the following format which is basically the same as above (there should be 5 of them at most)
            key - the center key thing (lol)
            extras - shit like rental and eternal and stuff like that
            price - same as above really
            rounds_passed, rounds_total should be lower than normally ordering jokers to incentivise doing this
                instead of ordering everything and so should the price
    ]]
    -- from 1 dollar to 500 jx
    r.hp_jtem_queue_max_size = 2
    -- d2j is dollars to joker exchange
    r.hp_jtem_d2j_rate = { from = 1, to = 5000 }
    -- p2j is plincoin to joker exchange
    r.hp_jtem_p2j_rate = { from = 1, to = 32000 }
    -- c2j is credits to joker exchange
    r.hp_jtem_pcj_rate = { from = 1, to = 833 }
    r.hp_jtem_special_offer_count = 3
    r.hp_jtem_should_allow_custom_order = false
    r.hp_jtem_should_allow_buying_jx_from_plincoin = false
    r.jp_jtem_has_ever_bought_jx = false
    return r
end

local r_g_ref = SMODS.current_mod.reset_game_globals or function() end
SMODS.current_mod.reset_game_globals = function(run_start)
    r_g_ref(run_start)
    if not run_start then
        G.GAME.round_resets.hp_jtem_special_offer = {}
        hotpot_jtem_generate_special_deals()
    end
end

function hotpot_jtem_center_to_round_wait(center) -- accept ONLY center object
    local rounds = 2
    if center.set == "Joker" then
        rounds = 24
        if center.rarity == 1 then
            rounds = 3
        elseif center.rarity == 2 then
            rounds = 5
        elseif center.rarity == 3 then
            rounds = 10
        elseif center.rarity == 4 then
            rounds = 24
        end
    elseif center.set == "Spectral" then
        rounds = 6
    end
    -- target: for custom rounds :3
    return rounds
end

-- very useful for multiple currencies like this
function get_currency_amount(currency)
    currency = currency or "dollars"
    value = value or 0
    if currency == "credits" then return G.GAME.seeded and G.GAME.budget or G.PROFILES[G.SETTINGS.profile].TNameCredits end
    if currency == "dollars" then return G.GAME.dollars end
    if currency == "plincoin" then return G.GAME.plincoins end
    if currency == "joker_exchange" then return G.GAME.spark_points end
    if currency == "cryptocurrency" or currency == "crypto" then return G.GAME.cryptocurrency end
end

function ease_currency(currency, value, instant)
    currency = currency or "dollars"
    value = value or 0
    if currency == "credits" or currency == 'all' then HPTN.ease_credits(value, instant) end
    if currency == "dollars" or currency == 'all' then ease_dollars(value, instant) end
    if currency == "plincoin" or currency == 'all' then ease_plincoins(value, instant) end
    if currency == "joker_exchange" or currency == 'all' then ease_spark_points(value, instant) end
    if currency == "cryptocurrency" or currency == "crypto" or currency == 'all' then ease_cryptocurrency(value, instant) end
    -- patches for other currencies ease
end

function generate_currency_string_args(currency)
    currency = currency or "dollars"
    if currency == "credits" then return { colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE, symbol = G.GAME.seeded and "e." or "c.", font = G.LANG.font } end
    if currency == "dollars" then return { colour = G.C.MONEY, symbol = "$", font = G.LANG.font } end
    if currency == "plincoin" then
        return {
            colour = SMODS.Gradients["hpot_plincoin"],
            symbol = "$",
            font = SMODS.Fonts
                ["hpot_plincoin"]
        }
    end
    if currency == "joker_exchange" then return { colour = G.C.BLUE, symbol = "͸", font = SMODS.Fonts["hpot_plincoin"] } end
    if currency == "cryptocurrency" or currency == "crypto" then
        return {
            colour = G.C.ORANGE,
            symbol = "£",
            font = SMODS
                .Fonts["hpot_plincoin"]
        }
    end
    -- patches for other currencies strings
end

function hotpot_jtem_add_card_to_delivery_queue(key, price)
    -- price accepts the following value
    -- number - defaults to dollars
    -- table with key currency and value for
    price = price or 0
    local value = type(price) == "table" and price.value or price
    local currency = type(price) == "table" and price.currency or "dollars"
    if not G.P_CENTERS[key] then return end
    local ct = G.P_CENTERS[key]
    local delivery_table = {
        key = key,
        rounds_passed = 0,
        rounds_total = hotpot_jtem_center_to_round_wait(ct),
        price = value,
        currency = currency,
        extras = {},
        create_card_args = {},
    }
    -- target patch for custom delivery queue
    ---@type Jtem.Delivery[]
    G.GAME.hp_jtem_delivery_queue = G.GAME.hp_jtem_delivery_queue or {}
    table.insert(G.GAME.hp_jtem_delivery_queue, delivery_table)
    if G.hp_jtem_delivery_queue then
        hotpot_delivery_refresh_card()
    end
end

function hotpot_jtem_add_to_offers(key, args)
    -- args accepts like weird shit you can probably just understand it by looking at it
    if not G.P_CENTERS[key] then return end

    local price = args.price or 0
    local value = type(price) == "table" and price.value or price
    local currency = type(price) == "table" and price.currency or "dollars"
    local ct = G.P_CENTERS[key]
    ---@type Jtem.Delivery
    local delivery_table = {
        key = key,
        rounds_passed = args.rounds_passed or 0,
        rounds_total = args.rounds_total or
            math.ceil(hotpot_jtem_center_to_round_wait(ct) * (args.rounds_total_factor or 0)),
        price = value,
        currency = currency,
        extras = args.extras or {},
        create_card_args = args.create_card_args or {}
    }
    -- target patch for custom special deals
    G.GAME.round_resets.hp_jtem_special_offer = G.GAME.round_resets.hp_jtem_special_offer or {}
    table.insert(G.GAME.round_resets.hp_jtem_special_offer, delivery_table)
    if G.hp_jtem_delivery_special_deals then
        hotpot_delivery_refresh_card()
    end
end

function hotpot_jtem_generate_special_deals(deals)
    -- generate 5 deals
    -- to other people who see this
    -- feel free to tweak the balanced
    ---@type Jtem.Delivery[]
    G.GAME.round_resets.hp_jtem_special_offer = {}
    PissDrawer.Shop.delivery_spawn = false
    G.GAME.hp_jtem_special_offer_count = G.GAME.hp_jtem_special_offer_count or 3
    for i = 1, to_number(deals or G.GAME.hp_jtem_special_offer_count) do
        local _pool, _pool_key = get_current_pool("Joker")
        -- _pool = remove_unavailable(_pool)
	local center_key = pseudorandom_element(_pool, pseudoseed(_pool_key.."_hpjtem_delivery"))
	while center_key == "UNAVAILABLE" do
            center_key = pseudorandom_element(_pool, pseudoseed(_pool_key.."_hpjtem_delivery"))
        end
        local center = G.P_CENTERS[center_key]
        local should_spawn_with_rental = pseudorandom("hpjtem_delivery_rental"..center_key) < 0.1 and true
        local should_spawn_with_eternal = center.eternal_compat and pseudorandom("hpjtem_delivery_eternal"..center_key) < 0.1 and
            true
        local should_spawn_with_perishable = center.perishable_compat and
            pseudorandom("hpjtem_delivery_perishable"..center_key) < 0.1 and not should_spawn_with_eternal
        local stickers = get_stickers(center)
        stickers[#stickers + 1] = should_spawn_with_rental and "rental" or nil
        stickers[#stickers + 1] = should_spawn_with_eternal and "eternal" or nil
        stickers[#stickers + 1] = should_spawn_with_perishable and "perishable" or nil
        local currency = pseudorandom_element(currencies, pseudoseed("hpjtem_delivery_currency"..center_key))
        local price_factor = 0.8
        if currency == "joker_exchange" then
            price_factor = 7331
        elseif currency == "plincoin" then
            price_factor = 0.3
        elseif currency == "credits" then
            price_factor = 10
        elseif currency == "cryptocurrency" then
            price_factor = 0.1
        end
        local credits = currency == "credits"
        local plincoin = currency == "plincoin"
        local jx = currency == "joker_exchange"
        local bc = currency == "cryptocurrency"
        -- add factor of 0.87 to 1.15
        local random_price_factor = pseudorandom("hpjtem_delivery_price_factor"..center_key) * 0.28 + 0.87
        price_factor = price_factor * (should_spawn_with_eternal and 0.8 or 1) * (should_spawn_with_rental and 0.5 or 1) *
            (should_spawn_with_perishable and 0.3 or 1)
        for _, v in ipairs(stickers) do
            if v ~= "eternal" and v ~= "rental" and v ~= "perishable" then
                price_factor = price_factor * (SMODS.Sticker.obj_table[v].hpot_delivery_price or SMODS.Sticker.obj_table[v].hpot_amazon_price or 0.85)
            end
        end
        local create_card_args = {
            hp_jtem_silent_edition = plincoin and poll_edition("hpjtem_delivery_edition"..center_key, nil, nil, true) or
                (not jx and poll_edition("hpjtem_delivery_edition"..center_key)),
            no_edition = jx or credits,
            bypass_discovery_ui = true,
            bypass_discovery_center = true,
            stickers = stickers,
            no_stickers = true
        }
    if create_card_args.hp_jtem_silent_edition == nil then create_card_args.hp_jtem_silent_edition = "e_base" end
        if center and center.credits then
            hotpot_jtem_add_to_offers(center.key, {
                price = { currency = currency, value = math.ceil(center.credits / 7 * price_factor * random_price_factor) },
                rounds_total_factor = 0.4 * (should_spawn_with_perishable and 0.2 or 1) *
                    (should_spawn_with_eternal and 0.5 or 1) * (should_spawn_with_rental and 0.3 or 1) *
                    (plincoin and 2 or 1),
                extras = {
                    rental = should_spawn_with_rental,
                    eternal = should_spawn_with_eternal,
                    perishable = should_spawn_with_perishable,
                    perish_tally = should_spawn_with_perishable and G.GAME.perishable_rounds,
                },
                create_card_args = create_card_args
            })
        else
            hotpot_jtem_add_to_offers(center.key, {
                price = { currency = currency, value = math.ceil(center.cost * price_factor * random_price_factor) },
                rounds_total_factor = 0.4 * (should_spawn_with_perishable and 0.2 or 1) *
                    (should_spawn_with_eternal and 0.5 or 1) * (should_spawn_with_rental and 0.3 or 1) *
                    (plincoin and 2 or 1),
                extras = {
                    rental = should_spawn_with_rental,
                    eternal = should_spawn_with_eternal,
                    perishable = should_spawn_with_perishable,
                    perish_tally = should_spawn_with_perishable and G.GAME.perishable_rounds,
                },
                create_card_args = create_card_args
            })
        end
    end
end

function hotpot_delivery_refresh_card()
    if not G.hp_jtem_delivery_queue.cards then return end
    hotpot_jtem_destroy_all_card_in_an_area(G.hp_jtem_delivery_special_deals, true)
    hotpot_jtem_destroy_all_card_in_an_area(G.hp_jtem_delivery_queue, true)
    for _, _obj in ipairs(G.GAME.hp_jtem_delivery_queue) do
        local temp_str = { str = (_obj.rounds_passed .. "/" .. _obj.rounds_total) }
        local cct = { area = G.hp_jtem_delivery_queue, key = _obj.key, skip_materialize = true, no_edition = true, no_stickers = true, force_stickers = true }
        for k, v in pairs(_obj.create_card_args) do
            cct[k] = v
        end
        local _c = SMODS.create_card(cct)
        _c.ability.hp_jtem_currency_bought = _obj.currency
        _c.ability.hp_jtem_currency_bought_value = _obj.price
        _c.ability.hp_delivery_obj = _obj
        local args = generate_currency_string_args(_c.ability.hp_jtem_currency_bought)
        if _obj.rounds_passed == _obj.rounds_total then
            hp_jtem_juice_card_until(_c, function (card)
                local will_overflow = #G.jokers.cards >= G.jokers.config.card_limit
                return card, will_overflow and 0.15 or 0.1, will_overflow and 0.2 or 0.05, will_overflow and 0.4 or 0.8
            end, true, 0, 0.2, 0.2, 0.5)
        end
        hpot_jtem_create_delivery_boxes(_c, { { ref_table = temp_str, ref_value = 'str', object = _obj } }, args)
        --[[if _obj.extras then
            for k, v in pairs(_obj.extras) do
                _c.ability[k] = v
            end
        end]]--
        G.hp_jtem_delivery_queue:emplace(_c)
    end
    for _, _obj in ipairs(G.GAME.round_resets.hp_jtem_special_offer) do
        local cct = { area = G.hp_jtem_delivery_special_deals, key = _obj.key, skip_materialize = true, no_edition = true, no_stickers = true, force_stickers = true }
        for k, v in pairs(_obj.create_card_args) do
            cct[k] = v
        end
        local _c = SMODS.create_card(cct)
        _c.ability.hp_jtem_currency_bought = _obj.currency
        _c.ability.hp_jtem_currency_bought_value = _obj.price
        _c.ability.hp_delivery_obj = _obj
        local args = generate_currency_string_args(_c.ability.hp_jtem_currency_bought)
        hpot_jtem_create_special_deal_boxes(_c,
            { { prefix = args.symbol, ref_table = _c.ability, ref_value = "hp_jtem_currency_bought_value" } }, args)
        --[[if _obj.extras then
            for k, v in pairs(_obj.extras) do
                _c.ability[k] = v
            end
        end]]--
        G.hp_jtem_delivery_special_deals:emplace(_c)
    end
end

-- this part is for saving card value
local card_init_val = Card.init
function Card:init(x, y, w, h, _card, _center, _params)
    local _c = card_init_val(self, x, y, w, h, _card, _center, _params)
    self.ability.hp_jtem_currency_bought = self.ability.hp_jtem_currency_bought or "dollars"
    self.ability.hp_jtem_currency_bought_value = self.ability.hp_jtem_currency_bought_value or 0
    return _c
end

local card_save_additional_props = Card.save
function Card:save()
    local st = card_save_additional_props(self)
    st.ability.hp_jtem_currency_bought = self.ability.hp_jtem_currency_bought or "dollars"
    st.ability.hp_jtem_currency_bought_value = self.ability.hp_jtem_currency_bought_value or 0
    return st
end

local card_load_additional_props = Card.load
function Card:load(ct, oc)
    local st = card_load_additional_props(self, ct, oc)
    self.ability.hp_jtem_currency_bought = ct.ability.hp_jtem_currency_bought or "dollars"
    self.ability.hp_jtem_currency_bought_value = ct.ability.hp_jtem_currency_bought_value or 0
    return st
end

local update_shop_hook_to_create_cards = Game.update_shop
function Game:update_shop()
			if not G.GAME.hpot_currencies_have_been_shown then
				open_hotpot_info("hotpot_wallet_explain")
			end
			G.GAME.hpot_currencies_have_been_shown = true
    if not self.HP_SHOP_CREATED_CARDS then
        self.HP_SHOP_CREATED_CARDS = true
        hotpot_jtem_init_extra_shops_area()
        simple_add_event(function()
            simple_add_event(function()
                hotpot_delivery_refresh_card()
                return true
            end)
            return true
        end)
    end
    return update_shop_hook_to_create_cards(self)
end

local cash_out_hook_for_refresh_card = G.FUNCS.cash_out
function G.FUNCS.cash_out(e)
    local x = cash_out_hook_for_refresh_card(e)
    hotpot_jtem_init_extra_shops_area()
    simple_add_event(function()
        hotpot_delivery_refresh_card()
        return true
    end)
    return x
end

local update_new_round_to_reset_card = Game.update_new_round
function Game:update_new_round()
    -- this one is for creating delivery cards
    if not self.HP_SHOP_CREATED_CARDS then
        self.HP_SHOP_CREATED_CARDS = nil
    end
    return update_new_round_to_reset_card(self)
end

-- calculate delivery which is calculated at the start of the round along with giving out cards
function hotpot_jtem_calculate_deliveries()
    G.GAME.hp_jtem_delivery_queue = G.GAME.hp_jtem_delivery_queue or {}
    local refunded = 0
    for _, delivery in pairs(G.GAME.hp_jtem_delivery_queue) do
        delivery.rounds_total = delivery.rounds_total or 999 -- just in case an order was badly made
        if delivery.key == "j_hpot_smods" then
            delivery.rounds_total = delivery.rounds_total + 1
        end
        delivery.rounds_passed = (delivery.rounds_passed or 0) + 1
        if to_number(delivery.rounds_passed) > to_number(delivery.rounds_total) then
            local area = G.P_CENTERS[delivery.key].consumeable and G.consumeables or
                G.P_CENTERS[delivery.key].set == 'Joker' and G.jokers
            if 
                (delivery.create_card_args.hp_jtem_silent_edition and delivery.create_card_args.hp_jtem_silent_edition == "e_negative")
                or (area and area.cards and #area.cards < area.config.card_limit)
            then
                local cct = { key = delivery.key, skip_materialize = true, no_stickers = true, force_stickers = true }
                for k, v in pairs(delivery.create_card_args) do
                    cct[k] = v
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local c = SMODS.add_card(cct)
                        c.ability.ordered = true
                        card_eval_status_text(c, 'extra', nil, nil, nil, {message = localize('k_hotpot_delivery'), colour = G.C.CHIPS})
                        return true
                    end,
                }))
                --[[if delivery.extras then
                    for k, v in pairs(delivery.extras) do
                        c.ability[k] = v
                    end
                end]]--
            else
                ease_currency(delivery.currency, delivery.price)
                refunded = refunded + 1
                --ease_dollars(delivery.price)
            end
        end
    end

    for i = #G.GAME.hp_jtem_delivery_queue, 1, -1 do
        local delivery = G.GAME.hp_jtem_delivery_queue[i]
        if to_number(delivery.rounds_passed) > to_number(delivery.rounds_total) then
            remove_element_from_list(G.GAME.hp_jtem_delivery_queue, delivery)
        end
    end

    if refunded > 0 then
        local text = localize({
			type = "variable",
			key = "hotpot_deliveries_refunded",
			vars = { refunded },
		})
        play_sound('tarot1', 1.5)
        attention_text({
            scale = 0.75, text = text, hold = 3, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
        })
    end
end

local start_run_to_init_areas = Game.start_run
function Game:start_run(args)
    local x = { start_run_to_init_areas(self, args) }

    local saveTable = args.savetext or nil
    if not saveTable or (saveTable and not saveTable.GAME) then
        G.HP_SHOP_CREATED_CARDS = nil
    end

    if G.STATE == G.STATES.SHOP then
        hotpot_jtem_init_extra_shops_area()
        simple_add_event(function()
            hotpot_delivery_refresh_card()
            return true
        end)
    end
    return unpack(x)
end

local card_creator = SMODS.create_card
function SMODS.create_card(t)
    local ret = card_creator(t)
    if t.no_stickers then
		for k, v in pairs(SMODS.Stickers) do
			if (ret.ability[k] or ret[k]) then v:apply(ret, false) end
		end
        if t.stickers then
            for i, v in ipairs(t.stickers) do
                ret:add_sticker(v, t.force_stickers)
            end
        end
    end
    return ret
end

-- destroy cards below
local next_round_button_for_delivery_area_destruction = G.FUNCS.toggle_shop
function G.FUNCS.toggle_shop(e)
    G.HP_SHOP_CREATED_CARDS = nil
    G.HP_JTEM_DELIVERY_VISIBLE = false
    G.HP_TNAME_REFORGE_VISIBLE = false
    hotpot_jtem_destroy_all_card_in_an_area(G.hp_jtem_delivery_special_deals, true)
    hotpot_jtem_destroy_all_card_in_an_area(G.hp_jtem_delivery_queue, true)
    hotpot_jtem_destroy_all_card_in_an_area(G.market_jokers, true)
    return next_round_button_for_delivery_area_destruction(e)
end

-- this moves the shop up and down along with slide whistle sound :joy::ok_hand:
function G.FUNCS.hotpot_jtem_toggle_delivery()
    if (G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0)) then return end
    stop_use()
    PissDrawer.Shop.change_shop_sign("hpot_jtem_postlatro")
    PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.delivery_shop, hotpot_jtem_init_extra_shops_area, PissDrawer.Shop.delivery_post, PissDrawer.Shop.area_keys.delivery)
    ease_background_colour({new_colour = G.C.BLUE, special_colour = G.C.RED, tertiary_colour = darken(G.C.BLACK,0.4), contrast = 3})
end