local func_ref = Game.splash_screen
function Game:splash_screen()
if Galdur then
Galdur.run_setup.choices.budget = nil
Galdur.run_setup.choices.budget_temp = ""
function Galdur.start_run(_quick_start)
    if not Galdur.run_setup.choices.seed_select or Galdur.run_setup.choices.seed == '' then
        Galdur.run_setup.choices.seed = nil 
    else
        Galdur.run_setup.choices.budget = tonumber(Galdur.run_setup.choices.budget_temp)
        Galdur.run_setup.choices.seed = Galdur.run_setup.choices.seed_temp
    end
    if _quick_start then
        Galdur.run_setup.choices.deck = Galdur.quick_start.deck
        Galdur.run_setup.choices.stake = Galdur.quick_start.stake
    end
    G.PROFILES[G.SETTINGS.profile].MEMORY.deck = Galdur.run_setup.choices.deck.effect.center.name
    G.PROFILES[G.SETTINGS.profile].MEMORY.stake = Galdur.run_setup.choices.stake
    for _,page in ipairs(Galdur.run_setup.pages) do
        if page.pre_start and type(page.pre_start) == 'function' then
            page.pre_start(Galdur.run_setup.choices)
        end
    end

    G.FUNCS.start_run(nil, Galdur.run_setup.choices)

    for _,page in ipairs(Galdur.run_setup.pages) do
        if page.post_start and type(page.post_start) == 'function' then
            page.post_start(Galdur.run_setup.choices)
        end
    end
end

function G.FUNCS.toggle_seeded_run_galdur(bool, e)
    if not e then return end
    local current_selector_page = e.UIBox:get_UIE_by_ID('seed_input')
    local seed_unlocker_present = (SMODS.Mods['SeedUnlocker'] or {}).can_load
    if not current_selector_page then return end
    current_selector_page.config.object:remove()
    current_selector_page.config.object = bool and UIBox{
        definition = {n=G.UIT.ROOT, config={align = "cr", colour = G.C.CLEAR}, nodes={
          {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={
            {n=G.UIT.C, config={maxw = 3.1}, nodes = {
                (seed_unlocker_present and
                create_text_input({max_length = 2500, extended_corpus = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed_temp', prompt_text = localize('k_enter_seed')})
             or create_text_input({max_length = 8, all_caps = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed_temp', prompt_text = localize('k_enter_seed')})),
            }},
            {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
            UIBox_button({label = localize('ml_paste_seed'),minw = 1, minh = 0.6, button = 'paste_seed', colour = G.C.BLUE, scale = 0.3, col = true}),
            {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
            create_text_input({max_length = 8, all_caps = false, ref_table = Galdur.run_setup.choices, ref_value = 'budget_temp', prompt_text = localize('teamname_budget'), colour = copy_table(G.C.ORANGE), hooked_colour = darken(copy_table(G.C.ORANGE), 0.3), id = "galdur_budget"})
          }}
        }},
        config = {offset = {x=0,y=0}, parent = e, type = 'cm'}
    } or Moveable()
    if Galdur.run_setup.choices.seed_select then current_selector_page.UIBox:recalculate() end
end


function G.UIDEF.run_setup_option_new_model(type)
     for _, args in ipairs(Galdur.pages_to_add) do
        if not args.definition or localize(args.name) == "ERROR" then
            sendErrorMessage(localize('gald_new_page_error'), "Galdur")
        else
            table.insert(Galdur.run_setup.pages, args)
        end
    end
    Galdur.pages_to_add = {}
    
    if not G.SAVED_GAME then
        G.SAVED_GAME = get_compressed(G.SETTINGS.profile..'/'..'save.jkr')
        if G.SAVED_GAME ~= nil then G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME) end
    end
  
    Galdur.prepare_run_setup()
    G.SETTINGS.current_setup = type
    
    local seed_unlocker_present = (SMODS.Mods['SeedUnlocker'] or {}).can_load
    
    
    local deck_name = split_string_2(Galdur.run_setup.choices.deck.loc_name)
    Galdur.deck_preview_texts.deck_preview_1 = deck_name[1]
    Galdur.deck_preview_texts.deck_preview_2 = deck_name[2]
    
    generate_deck_card_areas()
    generate_stake_card_areas()
    
    Galdur.run_setup.current_page = 1
    Galdur.run_setup.pages.prev_button = ""
    Galdur.run_setup.pages.next_button = localize(Galdur.run_setup.pages[2].name) .. ' >'
    local quick_select_text = {}
    for _, func in ipairs(Galdur.quick_start_texts) do
        table.insert(quick_select_text, func())
    end
    local Taiko_pres = (SMODS.Mods['Taikomochi'] or {}).can_load
    local t =
    {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 6.6, minw = 6}, nodes={
        {n = G.UIT.C, nodes = {
            {n=G.UIT.R, config = {align = "cm", minw = 3}, nodes ={
                {n = G.UIT.O, config = {id = 'deck_select_pages', object = UIBox{
                    definition = Galdur.run_setup.pages[Galdur.run_setup.current_page].definition(),
                    config = {align = "cm", offset = {x=0,y=0}}
                }}},
            }},
            {n=G.UIT.R, config = {align = "cm", minw = 3, offset = {x=0, y=-5}}, nodes ={
                {n = G.UIT.C, config={align='cm'}, nodes = {
                    {n=G.UIT.C, config = {id = 'previous_selection', minw = 2.5, minh = 0.8, maxh = 0.8, r = 0.1,
                        hover = true, ref_value = -1, button = Galdur.run_setup.current_page > 1 and 'deck_select_next' or 'dead_button',
                        colour = Galdur.run_setup.current_page > 1 and G.C.BLUE or G.C.CLEAR, align = "cm",
                        emboss = Galdur.run_setup.current_page > 1 and 0.1 or 0},
                        nodes = {
                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.T, config={ref_table = Galdur.run_setup.pages, ref_value = 'prev_button', scale = 0.4, colour = G.C.WHITE}}}},
                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.C, config={func = 'set_button_pip_prev', focus_args = { button = 'triggerleft', set_button_pip = true, offset = {x=-0.2, y = 0.3} }}}}}
                    }}
                }},
                {n=G.UIT.C, config={align = "cm", padding = 0.05, minh = 0.9, minw = 6.6}, nodes={
                    {n=G.UIT.O, config={id = 'seed_input', align = "cm", object = Galdur.run_setup.choices.seed_select and UIBox{
                        definition = {n=G.UIT.ROOT, config={align = "cr", colour = G.C.CLEAR}, nodes={
                          {n=G.UIT.C, config={align = "cm", minw = 2.5, padding = 0.05}, nodes={
                          }},
                          {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={
                            {n=G.UIT.C, config={maxw = 3.1}, nodes = {
                                seed_unlocker_present and
                                create_text_input({max_length = 2500, extended_corpus = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed_temp', prompt_text = localize('k_enter_seed')})
                             or create_text_input({max_length = 8, all_caps = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed_temp', prompt_text = localize('k_enter_seed')}),
                            }},
                            {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
                            UIBox_button({label = localize('ml_paste_seed'),minw = 1, minh = 0.6, button = 'paste_seed', colour = G.C.BLUE, scale = 0.3, col = true}),
                            {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
             create_text_input({max_length = 8, all_caps = false, ref_table = Galdur.run_setup.choices, ref_value = 'budget_temp', prompt_text = localize('teamname_budget'), colour = copy_table(G.C.ORANGE), hooked_colour = darken(copy_table(G.C.ORANGE), 0.3), id = "galdur_budget"})
                          }}
                        }},
                        config = {offset = {x=0,y=0}, parent = e, type = 'cm'}
                    } or Moveable()}, nodes={}},
                }},
                {n=G.UIT.C, config={align = "cm", minw = 2.2, id = 'run_setup_seed'}, nodes={
                    {n=G.UIT.R, config={align='cr'}, nodes = {create_toggle{col = true, label = localize('k_seeded_run'), label_scale = 0.25, w = 0, scale = 0.7,
                        callback = G.FUNCS.toggle_seeded_run_galdur, ref_table = Galdur.run_setup.choices, ref_value = 'seed_select'}}},
                    {n=G.UIT.R, config={align='cr'}, nodes = {Taiko_pres and create_toggle{col = true, label = "Zen Mode", label_scale = 0.25, w = 0, scale = 0.7,
                        ref_table = G, ref_value = 'run_zen_mode', active_colour = G.C.BLUE} or nil}}
                }},
                {n = G.UIT.C, config={align='cm'}, nodes = {
                    {n=G.UIT.C, config = {id = 'next_selection', minw = 2.5, minh = 0.8, maxh = 0.8, r = 0.1, hover = true, ref_value = 1,
                        button = 'deck_select_next', colour = G.C.BLUE,
                        align = "cm", emboss = 0.1}, nodes = {
                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.T, config={ref_table = Galdur.run_setup.pages, ref_value = 'next_button', scale = 0.4, colour = G.C.WHITE}}}},
                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.C, config={func = 'set_button_pip', focus_args = { button = 'x', set_button_pip = true, offset = {x=-0.2, y = 0.3} }}}}}
                    }}
                }},
                {n=G.UIT.C, config={minw = 0.5}},
                {n = G.UIT.C, config={align='cm'}, nodes = {{n=G.UIT.R, config = {maxw = 2.5, minw = 2.5, minh = 0.8, r = 0.1, hover = true, ref_value = 1,
                    button = 'quick_start', colour = G.C.ORANGE, align = "cm", emboss = 0.1, tooltip = {text = quick_select_text} }, nodes = {
                        {n = G.UIT.C, config = {align = 'cm'} , nodes = {
                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.T, config={text = localize('gald_quick_start'), scale = 0.4, colour = G.C.WHITE}},}},
                            {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.C, config={func = 'set_button_pip', focus_args = { button = 'y', set_button_pip = true, offset = {x=-0.2, y = 0.3} }}}}}
                        }}
                }}}}
            }}
        }}
    }}
    return t
end
end
return func_ref(self)
end