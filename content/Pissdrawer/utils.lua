PotatoPatchUtils.Team {
    name = 'Pissdrawer',
    colour = HEX('b8860b')
}

G.FUNCS.your_collection_teams = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = create_UIBox_teams(),
    }
end

function create_UIBox_teams()
    local leftside_nodes = {
        UIBox_button({ button = 'collection_pdr', label = { 'Piss Drawer' }, minw = 5, colour = HEX('b8860b') }),
        UIBox_button({ button = 'your_collection_teams', label = { 'O!AP' }, minw = 5, colour = HEX('80f1c3') }),
        UIBox_button({ button = 'your_collection_teams', label = { 'Team Name' }, minw = 5, colour = HEX('fdd48e') }),
        UIBox_button({ button = 'your_collection_teams', label = { 'Horse Chicot' }, minw = 5, colour = HEX('fd5f55') }),
    }
    local rightside_nodes = {
        UIBox_button({ button = 'your_collection_teams', label = { 'Team :)' }, minw = 5, colour = HEX('ffd71d') }),
        UIBox_button({ button = 'your_collection_teams', label = { 'Jtem' }, minw = 5, colour = HEX('ebc8dd') }),
        UIBox_button({ button = 'your_collection_teams', label = { 'Silly Posting' }, minw = 5, colour = HEX('77269b') }),
        UIBox_button({ button = 'your_collection_teams', label = { 'PerkeoCoin' }, minw = 5, colour = HEX('17b117') }),
    }

    local t = create_UIBox_generic_options({
        back_func = 'your_collection_other_gameobjects',
        contents = {
            { n = G.UIT.C, config = { align = "cm", padding = 0.15 }, nodes = leftside_nodes },
            { n = G.UIT.C, config = { align = "cm", padding = 0.15 }, nodes = rightside_nodes }
        }
    })
    return t
end

--[[function buildAdditionsTabTeam(team)
    local consumable_nodes = {}
    for _, key in ipairs(SMODS.ConsumableType.visible_buffer) do
        local tally = {}
        for i,v in pairs(G.P_CENTERS) do
            if v.hotpot_credits and v.hotpot_credits.team == team then
                tally.of = (tally.of or 0) + 1
                if v.discovered then tally.has = (tally.has or 0) + 1
            end
        end
        if tally.of > 0 then
            consumable_nodes[#consumable_nodes+1] = UIBox_button({button = team..'_'..key, label = {v.key}, count = tally, minw = 4, colour = G.C.SECONDARY_SET[key], text_colour = G.C.UI[key]})
        end
    end
    if #consumable_nodes > 3 then
        consumable_nodes = { UIBox_button({ button = 'your_collection_consumables', label = {localize('b_stat_consumables'), localize{ type = 'variable', key = 'c_types', vars = {#consumable_nodes} } }, count = modsCollectionTally(G.P_CENTER_POOLS.Consumeables), minw = 4, minh = 4, id = 'your_collection_consumables', colour = G.C.FILTER }) }
    end

    local leftside_nodes = {}
    for _, v in ipairs { { k = 'Joker', minh = 1.7, scale = 0.6 }, { k = 'Back', b = 'decks' }, { k = 'Voucher' } } do
        v.b = v.b or v.k:lower()..'s'
        v.l = v.l or v.b
        local tally = modsCollectionTally(G.P_CENTER_POOLS[v.k])
        if tally.of > 0 then
            leftside_nodes[#leftside_nodes+1] = UIBox_button({button = 'your_collection_'..v.b, label = {localize('b_'..v.l)}, count = modsCollectionTally(G.P_CENTER_POOLS[v.k]),  minw = 5, minh = v.minh, scale = v.scale, id = 'your_collection_'..v.b})
        end
    end
    if #consumable_nodes > 0 then
        leftside_nodes[#leftside_nodes + 1] = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.1, r = 0.2, colour = G.C.BLACK },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cm", maxh = 2.9 },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize('k_cap_consumables'), scale = 0.45, colour = G.C.L_BLACK, vert = true, maxh = 2.2 } },
                    }
                },
                { n = G.UIT.C, config = { align = "cm", padding = 0.15 }, nodes = consumable_nodes }
            }
        }
    end

    local rightside_nodes = {}
    for _, v in ipairs { { k = 'Enhanced', b = 'enhancements', l = 'enhanced_cards'}, { k = 'Seal' }, { k = 'Edition' }, { k = 'Booster', l = 'booster_packs' }, { b = 'tags', p = G.P_TAGS }, { b = 'blinds', p = G.P_BLINDS, minh = 2.0 }, } do
        v.b = v.b or v.k:lower()..'s'
        v.l = v.l or v.b
        v.p = v.p or G.P_CENTER_POOLS[v.k]
        local tally = modsCollectionTally(v.p)
        if tally.of > 0 then
            rightside_nodes[#rightside_nodes+1] = UIBox_button({button = 'your_collection_'..v.b, label = {localize('b_'..v.l)}, count = modsCollectionTally(v.p),  minw = 5, minh = v.minh, id = 'your_collection_'..v.b})
        end
    end
    local has_other_gameobjects = create_UIBox_Other_GameObjects()
    if has_other_gameobjects then
        rightside_nodes[#rightside_nodes+1] = UIBox_button({button = 'your_collection_other_gameobjects', label = {localize('k_other')}, minw = 5, id = 'your_collection_other_gameobjects', focus_args = {snap_to = true}})
    end
    if G.ACTIVE_MOD_UI.id == 'HotPotato' then
        leftside_nodes[#leftside_nodes + 1] = UIBox_button({button = 'your_collection_teams', label = {localize('k_teams')}, minw = 5})
    end

    local t = {n=G.UIT.R, config={align = "cm",padding = 0.2, minw = 7}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes = leftside_nodes },
      {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes = rightside_nodes }
    }}

    local modNodes = {}
    table.insert(modNodes, t)
    return (#leftside_nodes > 0 or #rightside_nodes > 0 ) and {
        label = localize("b_additions"),
        chosen = SMODS.LAST_SELECTED_MOD_TAB == "additions" or false,
        tab_definition_function = function()
            SMODS.LAST_SELECTED_MOD_TAB = "additions"
            return {
                n = G.UIT.ROOT,
                config = {
                    emboss = 0.05,
                    minh = 6,
                    r = 0.1,
                    minw = 6,
                    align = "tm",
                    padding = 0.2,
                    colour = G.C.BLACK
                },
                nodes = modNodes
            }
        end
    } or nil
end]]

function G.FUNCS.collection_pdr(e)

end

function rotate_image(self)
    local scale_mod = 0.07 + 0.02 * math.sin(1.8 * G.TIMERS.REAL) +
        0.00 * math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL)) * math.pi * 14) *
        (1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL))) ^ 3
    local rotate_mod = 2 * math.sin(G.TIMERS.REAL * math.pi * 0.5)



    self:draw_shader('dissolve', 0, nil, nil, self, scale_mod, rotate_mod, nil,
        0.1 + 0.03 * math.sin(1.8 * G.TIMERS.REAL), nil, 0.6)
    --self:draw_shader('dissolve', nil, nil, nil, self, scale_mod, rotate_mod)
end

--- @param area table only use if you want to search a specific area, e.g. G.jokers.cards
--- @return index number position in table of card
--- @return area table the area of the card, returns `area` if passed in
function find_self(card, area)
    if not area then
        local areas = SMODS.get_card_areas('jokers')
        for _,a in pairs(areas) do
            for i,v in pairs(a.cards) do
                if v == card then
                    return i, a
                end
                if v.ability.quantum_1 and v.ability.quantum_2 then
                    for p = 1,2 do local str = 'quantum_'..p
                        if v.ability[str] == card then return i, a end
                    end
                end
            end
        end
    else
        for i,v in pairs(area) do
            if v == card then
                return i, area
            end
        end
    end
end