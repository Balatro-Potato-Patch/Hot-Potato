-- Reforge menu

--- Custom function to make buttons:tm:
---@param args {label:{}[],w:number,h:number,colour:table,text_scale:number,text_col:table,font:string,func:string,button:string,type:"R"|"C"}
---@return table node The button node
---`label = {{{"Word 1"},{"Word 2"}...},{"New line"}...}` - The button's label text. It is highly customizable, supporting raw text `strings`, `ref_table` + `ref_value` combinations, custom `font`, `colour` and `scale`.\
---`w = 2.7, h = 0.9` - Minimum **width** and **height** of the button.\
---`colour = G.C.RED` - Colour of the button.\
---`text_scale = 0.3` - Default text scale. Can be overwritten in each text component.\
---`text_col = G.C.WHITE` - Default text colour. Can be overwritten in each text component.\
---`font = nil` - Default font. Can be overwritten in each text component.\
---`type = C` - Defines how to align the buttons.\
---`func` - Function to run in `G.FUNCS[func]` every frame the button is present.\
---`button` - Function to run `G.FUNCS.[button]` when the button is pressed.
function UIBox_adv_button (args)
    args = args or {}
    args.label = args.label or { -- HORRID EXAMPLE ON HOW TO SET THESE UP !!!
        {
            {"ERROR"},{" NO TEXT"}
        }
    }
    args.w = args.w or 2.7
    args.h = args.h or 0.9
    args.colour = args.colour or G.C.RED
    args.text_scale = args.text_scale or 0.3
    args.text_col = args.text_col or G.C.WHITE
    args.font = args.font or nil
    if not args.type and (args.type ~= "R" or args.type ~= "C") then args.type = "R" end

    local texts = {}

    for _,v in ipairs(args.label) do
        local line = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR, minw = 0.2, minh = 0.2}, nodes = {}}
        for kk,vv in pairs(v) do
            local text = {n = G.UIT.T, config = {
                text = vv[1] or vv.string,
                ref_table = vv.ref_table,
                ref_value = vv.ref_value,
                colour = vv.colour or args.text_col or G.C.WHITE,
                scale = args.text_scale or vv.scale or 0.3,
                font = (vv.font and SMODS.Fonts[vv.font]) or (args.font and SMODS.Fonts[args.font])
            }}
            table.insert(line.nodes,text)
        end
        table.insert(texts,line)
    end

    return {n = G.UIT[args.type], config = {
        minw = args.w,
        minh = args.h,
        align = "cm",
        colour = args.colour,
        func = args.func, button =
        args.button,
        r = 0.1,
        hover = true},
        nodes = texts
    }
end

function HPTN.move_card(card, _area) -- Moving cards from one area to another easily
    local area = card.area
    if area == G.jokers and _area ~= G.jokers then
        card:remove_from_deck()
    elseif _area == G.jokers and area ~= G.jokers then
        card:add_to_deck()
    end
	if not card.getting_sliced then	
		area:remove_card(card)
		_area:emplace(card)
    end
end

function G.FUNCS.return_place_reforge(e)
if G.reforge_area and G.reforge_area.cards then
    if #G.reforge_area.cards <= 0 then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.RED
            e.config.button = 'reforge_return'
        end
    end
end

function G.FUNCS.place_return_reforge(e)
    if e.config.ref_table.area == G.jokers then
        e.children[1].children[1].config.text = localize('hotpot_go_reforge')
        if G.reforge_area and G.reforge_area.cards and #G.reforge_area.cards > 0 then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.RED
            e.config.button = 'reforge_place'
        end
    else
        e.children[1].children[1].config.text = localize('hotpot_leave_reforge')
            e.config.colour = G.C.RED
            e.config.button = 'reforge_return'
    end
end

G.FUNCS.reforge_place = function (e)
    if G.jokers and G.jokers.highlighted and #G.jokers.highlighted > 0 then
        local c = e.config.ref_table
        HPTN.move_card(c, G.reforge_area)
        G.GAME.ref_placed = true
        ready_to_reforge() -- give the card the dependencies 
        update_reforge_cost() -- update the reforge cost incase the card has already been reforged
    end
end

G.FUNCS.reforge_return = function ()
    if G.reforge_area and G.reforge_area.cards then
        if #G.reforge_area.cards > 0 and G.FUNCS.check_for_buy_space(G.reforge_area.cards[1])then
            final_ability_values() -- save the final table (not needed pobably)
            HPTN.move_card(G.reforge_area.cards[1], G.jokers)
            G.GAME.ref_placed = nil
            reset_reforge_cost() -- reset the cost to default
        end
    end
end

G.FUNCS.hotpot_tname_toggle_reforge = function () -- takn from deliveries
    if (G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0)) then return end
    stop_use()
    PissDrawer.Shop.change_shop_sign("hpot_tname_shop_sign", {percent = 1.3})
    PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.reforge_shop, PissDrawer.Shop.create_reforge_areas, PissDrawer.Shop.reload_shop_areas, PissDrawer.Shop.area_keys.reforge)
    ease_background_colour({new_colour = G.C.BLACK, special_colour = G.C.RED, tertiary_colour = darken(G.C.BLACK,0.4), contrast = 3})

end



-- self explanatory
function G.FUNCS.can_reforge(e)
    local currency = e.config.currency
    local result = {config = {button = 'true'}}
    G.FUNCS['can_reforge_with_'..currency](result)
    e.config.button = result.config.button
    e.config.colour = result.config.button and G.C.L_BLACK or G.C.BLACK
    e.config.hover = result.config.button and true or nil
    e.UIBox:get_UIE_by_ID('text_'..currency).config.object.colours = {result.config.colour}
end

function G.FUNCS.can_reforge_with_credits(e)
    if not HPTN.check_if_enough_credits(G.GAME.cost_credits) or not G.GAME.ref_placed then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE
            e.config.button = 'reforge_with_credits'
        end
    end

function G.FUNCS.can_reforge_with_dollars(e)
    if to_big(to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) < to_big(G.GAME.cost_dollars) or not G.GAME.ref_placed then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
    else
            e.config.colour = G.C.GOLD
            e.config.button = 'reforge_with_dollars'
        end
    end

function G.FUNCS.can_reforge_with_sparks(e)
    if to_big(G.GAME.spark_points) < to_big(G.GAME.cost_sparks) or not G.GAME.ref_placed then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.BLUE
            e.config.button = 'reforge_with_sparks'
        end
    end
    
function G.FUNCS.can_reforge_with_plincoins(e)
    if to_big(G.GAME.plincoins) < to_big(G.GAME.cost_plincoins) or not G.GAME.ref_placed then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = SMODS.Gradients["hpot_plincoin"]
            e.config.button = 'reforge_with_plincoins'
        end
    end

function G.FUNCS.can_reforge_with_cryptocurrency(e)
    if to_big(G.GAME.cryptocurrency) < to_big(G.GAME.cost_cryptocurrency) or not G.GAME.ref_placed then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = SMODS.Gradients['hpot_advert']
            e.config.button = 'reforge_with_cryptocurrency'
        end
    end
--

G.FUNCS.reforge_with_credits = function ()
    HPTN.ease_credits(-G.GAME.cost_credits)
    set_card_reforge() -- 
    update_reforge_cost()
    reforge_card(G.reforge_area.cards[1], false, "CREDIT")
    play_sound("hpot_tname_reforge")
	set_card_reforge()
    update_reforge_cost()
end

G.FUNCS.reforge_with_dollars = function ()
    ease_dollars(-G.GAME.cost_dollars)
    set_card_reforge()
    update_reforge_cost()
    reforge_card(G.reforge_area.cards[1], false, "DOLLAR")
    play_sound("hpot_tname_reforge")
	set_card_reforge()
    update_reforge_cost()
end

G.FUNCS.reforge_with_sparks = function ()
    ease_spark_points(-G.GAME.cost_sparks)
    set_card_reforge()
    update_reforge_cost()
    reforge_card(G.reforge_area.cards[1], false, "SPARKLE")
    play_sound("hpot_tname_reforge")
	set_card_reforge()
    update_reforge_cost()
end

G.FUNCS.reforge_with_plincoins = function ()
    ease_plincoins(-G.GAME.cost_plincoins)
    set_card_reforge()
    update_reforge_cost()
    reforge_card(G.reforge_area.cards[1], false, "PLINCOIN")
    play_sound("hpot_tname_reforge")
	set_card_reforge()
    update_reforge_cost()
end

G.FUNCS.reforge_with_cryptocurrency = function ()
    ease_cryptocurrency (-G.GAME.cost_cryptocurrency )
    set_card_reforge()
    update_reforge_cost()
    reforge_card(G.reforge_area.cards[1], false, "CRYPTOCURRENCY")
    play_sound("hpot_tname_reforge")
	set_card_reforge()
    update_reforge_cost()
end