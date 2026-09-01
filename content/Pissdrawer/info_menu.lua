function hp_desc_from_rows(desc_nodes, empty, align, maxw, minh)
    local t = {}
    for k, v in ipairs(desc_nodes) do
        t[#t+1] = {n=G.UIT.R, config={align = align or "cm", maxw = maxw}, nodes=v}
    end
    return {n=G.UIT.R, config={align = "cm", colour = empty and G.C.CLEAR or G.C.UI.BACKGROUND_WHITE, r = 0.1, padding = 0.04, minw = 2, minh = minh or 0.8, emboss = not empty and 0.05 or nil, filler = true}, nodes={
        {n=G.UIT.R, config={align = align or "cm", padding = 0.03}, nodes=t}
    }}
end

function G.FUNCS.hotpot_previous_info_page(e)
    local config = e.config
    local max_page = config.max_page
    local page = config.page
    local menu_type = config.menu_type
    local back_func = config.back_func
    local no_first_time = config.no_first_time
    
    if page <= 1 then
        page = max_page
    else
        page = math.max(page - 1, 1)
    end

    G.FUNCS.hotpot_info{menu_type = menu_type, page = page, back_func = back_func, no_first_time = no_first_time, is_page_switch = true}
end

function G.FUNCS.hotpot_next_info_page(e)
    local config = e.config
    local max_page = config.max_page
    local page = config.page
    local menu_type = config.menu_type
    local back_func = config.back_func
    local no_first_time = config.no_first_time
    
    if page >= max_page then
        page = 1
    else
        page = math.min(page + 1, max_page)
    end

    G.FUNCS.hotpot_info{menu_type = menu_type, page = page, back_func = back_func, no_first_time = no_first_time, is_page_switch = true}

end

function hotpot_create_info_UI(args)
    local args = args or {}
    local back_func = args.back_func or "exit_overlay_menu"
    local no_first_time = args.no_first_time
    local menu_type = args.menu_type
    local page = args.page or 1
    local loc = G.localization.InfoMenu[menu_type]

    local function create_text_box(args)
        local desc_node = {}
        local loc_target = args.loc_target and copy_table(args.loc_target)
        HotPotato.localize{type = 'descriptions', loc_target = {text = loc_target}, nodes = desc_node, scale = 1, text_colour = G.C.UI.TEXT_LIGHT, vars = args.vars or {}, stylize = true, no_shadow = true} 
        desc_node = hp_desc_from_rows(desc_node,true,"cm")
        desc_node.config.align = "cm"

        return {n = G.UIT.R, config = {align = "cm", colour = G.C.BLACK, r = 0.2, shadow = true}, nodes = {
            {n = G.UIT.C, config = {align = "cm", padding = 0.05}, nodes = {
                desc_node
            }},
        }}
    end

    local name_nodes = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.C, config = {align = "cm"}, nodes = {}},
    }}
    local subname_nodes = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR, padding = -0.15}, nodes = {
        {n = G.UIT.C, config = {align = "cm"}, nodes = {}},
    }}
    local info_nodes = {}
    if loc then
        local temp_name_node = {}
        HotPotato.localize{type = 'name', loc_target = {name = loc.name}, nodes = temp_name_node, scale = 1.5, text_colour = G.C.UI.TEXT_LIGHT, vars = args.vars or {}, stylize = true} 
        temp_name_node = hp_desc_from_rows(temp_name_node,true,"cm",nil,0)
        temp_name_node.config.align = "cm"
        name_nodes.nodes[1].nodes[#name_nodes.nodes[1].nodes+1] = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.C, config = {align = "cm"}, nodes = {
                temp_name_node
            }},
        }}

        local target = loc.text[page]
        if target then
            local temp_subname_node = {}
            HotPotato.localize{type = 'name', loc_target = {name = target.name}, nodes = temp_subname_node, scale = 0.8, text_colour = G.C.UI.TEXT_LIGHT, vars = args.vars or {}, stylize = true, no_shadow = true, no_pop_in = true, no_bump = true, no_silent = true, no_spacing = true} 
            temp_subname_node = hp_desc_from_rows(temp_subname_node,true,"cm",nil,0)
            temp_subname_node.config.align = "cm"
            subname_nodes.nodes[1].nodes[#subname_nodes.nodes[1].nodes+1] = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.C, config = {align = "cm"}, nodes = {
                    temp_subname_node
                }},
            }}
            info_nodes = 
            {n = G.UIT.R, config = {align = "cm", padding = 0, colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.2}, nodes = {}},
            }}
            for _,v in ipairs(target.text) do
                info_nodes.nodes[1].nodes[#info_nodes.nodes[1].nodes+1] = create_text_box({loc_target = v})
            end
        end
    end

    G.PROFILES[G.SETTINGS.profile].first_time_disable = G.PROFILES[G.SETTINGS.profile].first_time_disable or {}

    local ret = {n=G.UIT.ROOT, config = {align = "cm", minw = G.ROOM.T.w*5, minh = G.ROOM.T.h*5,padding = 0.1, r = 0.1, colour = args.bg_colour or {G.C.GREY[1], G.C.GREY[2], G.C.GREY[3],0.7}}, nodes={
        {n=G.UIT.R, config={align = "cm", minh = 1, r = 0.3, padding = 0.07, minw = 1, colour = args.outline_colour or G.C.JOKER_GREY, emboss = 0.1}, nodes={
            {n=G.UIT.C, config={align = "cm", minh = 1, r = 0.2, padding = 0.1, minw = 1, colour = args.colour or G.C.L_BLACK}, nodes={
                {n=G.UIT.R, config={align = "cm", r = 0.2, padding = 0.15, minw = 1, colour = G.C.BLACK}, nodes={
                    {n=G.UIT.C, config={align = "cm", r = 0.2, padding = 0.05, minw = 1, colour = G.C.L_BLACK}, nodes={
                        --i gotta insert here
                        name_nodes,
                        subname_nodes,
                        info_nodes,
                       {n = G.UIT.R, config = {align = "cm", padding = 0.02}, nodes = {
                            {n = G.UIT.C, config = {align = "cr", colour = G.C.CLEAR}, nodes = {
                                not no_first_time and create_toggle({label = localize("hotpot_first_time_disable"), ref_table = G.PROFILES[G.SETTINGS.profile].first_time_disable, ref_value = menu_type, callback = function() end }) or nil,
                            }},
                        }},
                        {n = G.UIT.R, config = {align = "cm", minh = not no_first_time and 0.1 or 0.03}}
                    }},
                }},
                {n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
                    not args.no_back and 
                    {n=G.UIT.C, config={id = args.back_id or 'overlay_menu_back_button', align = "cm", minw = 4, button_delay = args.back_delay, padding =0.1, r = 0.1, hover = true, colour = args.back_colour or G.C.ORANGE, button = back_func, shadow = true, focus_args = {nav = 'wide', button = 'b', snap_to = args.snap_back}}, nodes={
                        {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
                            {n=G.UIT.T, config={id = args.back_id or nil, text = args.back_label or localize('b_back'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true, func = not args.no_pip and 'set_button_pip' or nil, focus_args =  not args.no_pip and {button = args.back_button or 'b'} or nil}}
                        }}
                    }} or nil
                }},
            }},
        }},
    }}
    if loc and loc.text and #loc.text > 1 then
        local pages = {
            {n = G.UIT.C, config = {align = "cm", minw = 0.5, minh = 0.5, maxh = 0.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLACK, shadow = true, button = "hotpot_previous_info_page", menu_type = menu_type, page = page, max_page = (#(loc.text or {}) or 1), back_func = back_func, no_first_time = no_first_time}, nodes = {
                {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                    {n = G.UIT.T, config = {text = "<", scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
                }}
            }},
            {n = G.UIT.C, config = {align = "cm", minw = 0.5, minh = 0.5, maxh = 0.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLACK, shadow = true}, nodes = {
                {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                    {n = G.UIT.T, config = {text = localize("k_page").." "..page.."/"..(#(loc.text or {}) or 1), scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
                }}
            }}, 
            {n = G.UIT.C, config = {align = "cm", minw = 0.5, minh = 0.5, maxh = 0.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLACK, shadow = true, button = "hotpot_next_info_page", menu_type = menu_type, page = page, max_page = (#(loc.text or {}) or 1), back_func = back_func, no_first_time = no_first_time}, nodes = {
                {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                    {n = G.UIT.T, config = {text = ">", scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
                }}
            }},
        }
        for _,v in ipairs(pages) do
            ret.nodes[1].nodes[1].nodes[1].nodes[1].nodes[4].nodes[#ret.nodes[1].nodes[1].nodes[1].nodes[1].nodes[4].nodes+1] = v
        end
    end

    return ret
end

function hotpot_create_info(args)   
    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = function()
            G.REFRESH_ALERTS = true
            return true
        end
    }))
    
    local t = hotpot_create_info_UI(args or {})
    return t
end

G.FUNCS.hotpot_info = function(args)   
    if not args or not args.menu_type or not G.localization.InfoMenu[args.menu_type] then return end
    local config = {}
    if args.is_page_switch then
        config.offset = { x = 0, y = 0 }
    end
    G.FUNCS.overlay_menu{
        definition = hotpot_create_info(args),
        config = config
    }
end

function open_hotpot_info(menu_type)
    G.PROFILES[G.SETTINGS.profile].first_time_disable = G.PROFILES[G.SETTINGS.profile].first_time_disable or {}
    if not G.PROFILES[G.SETTINGS.profile].first_time_disable[menu_type] then
        G.FUNCS.hotpot_info{menu_type = menu_type}
    end
end

--eval G.FUNCS.hotpot_info{menu_type = "hotpot_training"}