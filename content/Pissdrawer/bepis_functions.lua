function HotPotato.round(number, digit_position) 
    digit_position = digit_position or 0
    if not number then return end
    local precision = 10 ^ -digit_position
    number = number + (precision / 2)
    return math.floor(number / precision) * precision
end

HotPotato.ease = {
    linear = function (x)
        return x
    end,
    quad = function (x)
        return x < 0.5 and 2 * x * x or 1 - math.pow(-2 * x + 2, 2) / 2
    end,
    inquad = function (x)
        return x * x
    end,
    outquad = function (x)
        return 1 - (1 - x) * (1 - x)
    end,
    expo = function (x)
        return x == 0
                and 0
                or x == 1
                and 1
                or x < 0.5 and math.pow(2, 20 * x - 10) / 2
                or (2 - math.pow(2, -20 * x + 10)) / 2
    end,
    inexpo = function (x)
        return x == 0 and 0 or math.pow(2, 10 * x - 10)
    end,
    outexpo = function (x)
        return x == 1 and 1 or 1 - math.pow(2, -10 * x)
    end
}

function HotPotato.lerp(b, a, t)
    return a * (1-t) + b * t
end

function UIElement:ease_move(T, speed, queue, blocking, blockable, save_pos, toggle, funcs, ease_type)
    -- Might as well put defaults here to reduce a lot of 'or's
    speed = speed or 10
    queue = queue or "ease_move"
    T = T or {}
    T.x = T.x or 0
    T.y = T.y or 0
    -- New: ease type
    ease_type = ease_type or "inquad"
    if not HotPotato.ease[ease_type] then ease_type = "inquad" end

    self.T_destination = {x = self.role.offset.x + T.x, y = self.role.offset.y + T.y}
    local T_starttime = {x = G.TIMERS.REAL, y = G.TIMERS.REAL} -- time in seconds
    local T_endtime = {x = G.TIMERS.REAL + ((math.abs(T.x)*speed) / math.abs(speed)), y = G.TIMERS.REAL + ((math.abs(T.y)*speed) / math.abs(speed))}
    self.T_ease = {x = self.role.offset.x, y = self.role.offset.y}
    self.T_origin = copy_table(self.T_ease)
    self.T_percent = {x = 0, y = 0}

    G.E_MANAGER.queues[queue] = G.E_MANAGER.queues[queue] or {}
    if save_pos then
        save_pos.ref_table[save_pos.ref_value] = {x = 0, y = 0}
    end
    if toggle then
        toggle.ref_table[toggle.ref_value] = true
    end

    G.E_MANAGER:add_event(Event({
        blocking = blocking or false,
        blockable = blockable or false,
        func = function() 
            if not self or not self.T_destination then return true end
            for i,v in pairs(self.T_destination) do
                -- lerp ease position to new time
                local percent =  T_endtime[i] >= G.TIMERS.REAL and (math.abs((T_endtime[i] - G.TIMERS.REAL) / (T_endtime[i] - T_starttime[i]))) or 0
                -- prevent nan values
                -- there is no reason for this to be nan
                if percent ~= percent then percent = 0 end
                -- ease types
                percent = HotPotato.ease[ease_type](percent)
                --print("percent "..i..": "..percent)
                self.T_ease[i] = HotPotato.lerp(self.T_origin[i], self.T_destination[i], percent)
                self.T_percent[i] = percent
                --self.T_ease[i] = v/(speed or 10)
                if save_pos then
                    local target = save_pos.ref_table[save_pos.ref_value]
                    target = target or {x = 0, y = 0}
                    target[i] = HotPotato.lerp(0, self.T_destination[i] - self.T_origin[i], percent)
                end
            end
            if funcs and type(funcs) == "table" then
                if funcs.ease_func and type(funcs.ease_func) == "function" then
                    funcs.ease_func(self)
                end
            end
            self:align(self.T_ease.x - self.role.offset.x, self.T_ease.y - self.role.offset.y)
            local all_low = true
            for _,v in pairs(self.T_percent) do
                if math.abs(v) > 0.01 then all_low = false; break end
            end
            if all_low then
                self:align(self.T_destination.x - self.role.offset.x, self.T_destination.y - self.role.offset.y)
                if save_pos then
                    local target = save_pos.ref_table[save_pos.ref_value]
                    target = target or {x = 0, y = 0}
                    target.x = T.x
                    target.y = T.y
                end
                if toggle then
                    toggle.ref_table[toggle.ref_value] = false
                end
                if funcs and type(funcs) == "table" then
                    if funcs.after_func and type(funcs.after_func) == "function" then
                        funcs.after_func(self)
                    end
                end
                self.T_destination = nil
                self.T_ease = nil
                self.T_percent = nil
                self.T_origin = nil
                return true
            end
        end
    }), queue or "ease_move")
end

function hotpot_add_event(args)
    G.E_MANAGER:add_event(Event(args))
end

function Card:hotpot_resize(mod)
    -- This uses VT.x and VT.y to prevent card teleporting on resize!
    -- CardArea:align_cards will set T properly on the next frame.
    self:hard_set_T(self.VT.x, self.VT.y, self.T.w * mod, self.T.h * mod)
    remove_all(self.children)
    self.children = {}
    self.children.shadow = Moveable(0, 0, 0, 0)
    self:set_sprites(self.ability and self.ability.quantum_1 and self.ability.quantum_1.config.center or self.config.center, self.base.id and self.config.card)
    self.CT.w = self.T.w
    self.CT.h = self.T.h
end

function HotPotato.create_fake_card(c_key, area)
    local area = area or {T = {x = 0, y = 0, w = 0, h = 0}}
    local card = Card(area.T.x + area.T.w / 2, area.T.y,
    G.CARD_W, G.CARD_H, G.P_CARDS.empty,
    G.P_CENTERS[c_key])
    card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[(G.P_CENTERS[c_key] and G.P_CENTERS[c_key].atlas) or "Joker"], (G.P_CENTERS[c_key] and G.P_CENTERS[c_key].pos) or {x = 0, y = 0})
    card.children.back.states.hover = card.states.hover
    card.children.back.states.click = card.states.click
    card.children.back.states.drag = card.states.drag
    card.children.back.states.collide.can = false
    card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})

    return card
end

function HotPotato.manual_parse(text, args)
    if not text then return end
    if type(text) ~= "table" then text = {text} end
    local args = args or {}
    local dir = G.localization
    if args.loc_dir then
        for _,v in ipairs(args.loc_dir) do
            dir[v] = dir[v] or {}
            dir = dir[v]
        end
    else
        dir = G.localization.misc.v_text_parsed
    end
    local key = args.loc_key or "SMODS_stylize_text"
    local function deep_find(t, index)
        if type(index) ~= "table" then index = {index} end
        for _,idv_index in ipairs(index) do
            if t[idv_index] then return true end
            for i,v in pairs(t) do
                if i == idv_index then return true end
                if type(v) == "table" then
                    return deep_find(v, idv_index)
                end
            end
        end
        return false
    end
    if deep_find(text, "control") and not args.refresh then
        if not args.no_loc_save then dir = text end
        return text
    end

    local a = {"text", "name", "unlock"}
    if not args.no_loc_save then
        local loc = dir
        loc[key] = {}
        if deep_find(text, a) then
            for _,v in ipairs(a) do
                text[v] = text[v] or {}
                text[v.."_parsed"] = (args.refresh and {}) or text[v.."_parsed"] or {}
            end
            if text.text then
                for _,v in ipairs(text.text) do
                    if type(v) == "table" then
                        text.text_parsed[#text.text_parsed+1] = {}
                        for _, vv in ipairs(v) do
                            text.text_parsed[#text.text_parsed][#text.text_parsed[#text.text_parsed]+1] = loc_parse_string(vv)
                        end
                    else
                        text.text_parsed[#text.text_parsed+1] = loc_parse_string(v)
                    end
                end
            end
            if text.name then
                for _,v in ipairs((type(text.name) == "string" and {text.name}) or text.name) do
                    text.name_parsed[#text.name_parsed+1] = loc_parse_string(v)
                end
            end
            if text.unlock then
                for _,v in ipairs(text.unlock) do
                    text.unlock_parsed[#text.unlock_parsed+1] = loc_parse_string(v)
                end
            end
            loc[key] = text
        else
            for i,v in ipairs(text) do
                loc[key][i] = loc_parse_string(v)
            end
        end

        return loc[key]
    else
        local loc = {}
        if deep_find(text, a) then
            for _,v in ipairs(a) do
                text[v] = text[v] or {}
                text[v.."_parsed"] = (args.refresh and {}) or text[v.."_parsed"] or {}
            end
            if text.text then
                for _,v in ipairs(text.text) do
                    if type(v) == "table" then
                        text.text_parsed[#text.text_parsed+1] = {}
                        for _, vv in ipairs(v) do
                            text.text_parsed[#text.text_parsed][#text.text_parsed[#text.text_parsed]+1] = loc_parse_string(vv)
                        end
                    else
                        text.text_parsed[#text.text_parsed+1] = loc_parse_string(v)
                    end
                end
            end
            if text.name then
                for _,v in ipairs((type(text.name) == "string" and {text.name}) or text.name) do
                    text.name_parsed[#text.name_parsed+1] = loc_parse_string(v)
                end
            end
            if text.unlock then
                for _,v in ipairs(text.unlock) do
                    text.unlock_parsed[#text.unlock_parsed+1] = loc_parse_string(v)
                end
            end
            loc = text
        else
            for i,v in ipairs(text) do
                loc[i] = loc_parse_string(v)
            end
        end

        return loc
    end
end

function HotPotato.localize(args, misc_cat)
    if args and not (type(args) == 'table') then
        if misc_cat and G.localization.misc[misc_cat] then return G.localization.misc[misc_cat][args] or 'ERROR' end
        return G.localization.misc.dictionary[args] or 'ERROR'
    end
    args = args or {}
    args.nodes = args.nodes or {}

    local loc_target = args.loc_target and copy_table(args.loc_target) or nil
    if args.stylize then loc_target = HotPotato.manual_parse(loc_target) end
    local ret_string = nil
    if args.type == 'other' then
        if not loc_target then loc_target = G.localization.descriptions.Other[args.key] end
    elseif args.type == 'descriptions' or args.type == 'unlocks' then
        if not loc_target then loc_target = G.localization.descriptions[args.set][args.key] end
    elseif args.type == 'tutorial' then
        if not loc_target then loc_target = G.localization.tutorial_parsed[args.key] end
    elseif args.type == 'quips' then
        if not loc_target then loc_target = G.localization.quips_parsed[args.key] end
    elseif args.type == 'raw_descriptions' then
        if not loc_target then loc_target = G.localization.descriptions[args.set][args.key] end
        local multi_line = {}
        if loc_target then
            for _, lines in ipairs(args.type == 'unlocks' and loc_target.unlock_parsed or args.type == 'name' and loc_target.name_parsed or args.type == 'text' and loc_target or loc_target.text_parsed) do
                local final_line = ''
                for _, part in ipairs(lines) do
                    local assembled_string = ''
                    for _, subpart in ipairs(part.strings) do
                        assembled_string = assembled_string..(type(subpart) == 'string' and subpart or format_ui_value(args.vars[tonumber(subpart[1])]) or 'ERROR')
                    end
                    final_line = final_line..assembled_string
                end
                multi_line[#multi_line+1] = final_line
            end
        end
        return multi_line
    elseif args.type == 'text' then
        if not loc_target then loc_target = G.localization.misc.v_text_parsed[args.key] end
    elseif args.type == 'variable' then
        if not loc_target then loc_target = G.localization.misc.v_dictionary_parsed[args.key] end
        if not loc_target then return 'ERROR' end
        if loc_target.multi_line then
            local assembled_strings = {}
            for k, v in ipairs(loc_target) do
                local assembled_string = ''
                for _, subpart in ipairs(v[1].strings) do
                    assembled_string = assembled_string..(type(subpart) == 'string' and subpart or format_ui_value(args.vars[tonumber(subpart[1])]))
                end
                assembled_strings[k] = assembled_string
            end
            return assembled_strings or {'ERROR'}
        else
            local assembled_string = ''
            for _, subpart in ipairs(loc_target[1].strings) do
                assembled_string = assembled_string..(type(subpart) == 'string' and subpart or format_ui_value(args.vars[tonumber(subpart[1])]))
            end
            ret_string = assembled_string or 'ERROR'
        end
    elseif args.type == 'name_text' then
        if pcall(function()
            local name_text = (loc_target and loc_target.name) or G.localization.descriptions[(args.set or args.node.config.center.set)][args.key or args.node.config.center.key].name
            if type(name_text) == "table" then
                ret_string = ""
                for i, line in ipairs(name_text) do
                    ret_string = ret_string.. (i ~= 1 and " " or "")..line
                end
            else
                ret_string = name_text
            end
        end) then
        else ret_string = "ERROR" end
    elseif args.type == 'name' then
        loc_target = loc_target or {}
        if pcall(function()
            local name = loc_target or G.localization.descriptions[(args.set or args.node.config.center.set)][args.key or args.node.config.center.key]
            loc_target.name_parsed = name.name_parsed or {loc_parse_string(name.name)}
        end) then
        else loc_target.name_parsed = {} end
    end

    if ret_string and type(ret_string) == 'string' then ret_string = string.gsub(ret_string, "{.-}", "") end
    if ret_string then return ret_string end

    if loc_target then
        args.AUT = args.AUT or {}
        args.AUT.info = args.AUT.info or {}
        args.AUT.box_colours = {}
        if (args.type == 'descriptions' or args.type == 'other') and type(loc_target.text) == 'table' and type(loc_target.text[1]) == 'table' then
            args.AUT.multi_box = {}
            for i, box in ipairs(loc_target.text_parsed) do
                for j, line in ipairs(box) do
                    local final_line = SMODS.localize_box(line, args)
                    if i == 1 or next(args.AUT.info) then
                        args.nodes[#args.nodes+1] = final_line -- Sends main box to AUT.main
                        if not next(args.AUT.info) then args.nodes.main_box_flag = true end
                    elseif not next(args.AUT.info) then
                        args.AUT.multi_box[i-1] = args.AUT.multi_box[i-1] or {}
                        args.AUT.multi_box[i-1][#args.AUT.multi_box[i-1]+1] = final_line
                    end
                    if not next(args.AUT.info) then args.AUT.box_colours[i] = args.vars.box_colours and args.vars.box_colours[i] or G.C.UI.BACKGROUND_WHITE end
                end
            end
            return
        end
        for _, lines in ipairs(args.type == 'unlocks' and loc_target.unlock_parsed or args.type == 'name' and loc_target.name_parsed or (args.type == 'text' or args.type == 'tutorial' or args.type == 'quips') and loc_target or loc_target.text_parsed) do
            local final_line = {}
            local final_name_assembled_string = ''
            if args.type == 'name' and loc_target.name_parsed then
                for _, part in ipairs(lines) do
                    local assembled_string_part = ''
                    for _, subpart in ipairs(part.strings) do
                        assembled_string_part = assembled_string_part..(type(subpart) == 'string' and subpart or format_ui_value(format_ui_value(args.vars[tonumber(subpart[1])])) or 'ERROR')
                    end
                    final_name_assembled_string = final_name_assembled_string..assembled_string_part
                end
            end
            for _, part in ipairs(lines) do
                local assembled_string = ''
                for _, subpart in ipairs(part.strings) do
                    assembled_string = assembled_string..(type(subpart) == 'string' and subpart or format_ui_value(args.vars[tonumber(subpart[1])]) or 'ERROR')
                end
                local desc_scale = (SMODS.Fonts[part.control.f] or G.FONTS[tonumber(part.control.f)] or G.LANG.font).DESCSCALE
                if G.F_MOBILE_UI then desc_scale = desc_scale*1.5 end
                if args.type == 'name' then
                    final_line[#final_line+1] = {n=G.UIT.C, config={align = "m", colour = part.control.B and args.vars.colours[tonumber(part.control.B)] or part.control.X and loc_colour(part.control.X) or nil, r = 0.05, padding = 0.03, res = 0.15}, nodes={}}
                    final_line[#final_line].nodes[1] = {n=G.UIT.O, config={
                        object = DynaText({string = {assembled_string},
                            colours = {(part.control.V and args.vars.colours[tonumber(part.control.V)]) or (part.control.C and loc_colour(part.control.C)) or args.text_colour or G.C.UI.TEXT_LIGHT},
                            bump = not args.no_bump,
                            silent = not args.no_silent,
                            pop_in = (not args.no_pop_in and (args.pop_in or 0)) or nil,
                            pop_in_rate = (not args.no_pop_in and (args.pop_in_rate or 4)) or nil,
                            maxw = args.maxw or 5,
                            shadow = not args.no_shadow,
                            y_offset = args.y_offset or -0.6,
                            text_effect = SMODS.DynaTextEffects and SMODS.DynaTextEffects[part.control.E] and part.control.E,
                            spacing = (not args.no_spacing and (args.spacing or 1) * math.max(0, 0.32*(17 - #(final_name_assembled_string or assembled_string)))) or nil,
                            font = SMODS.Fonts[part.control.f] or G.FONTS[tonumber(part.control.f)] or (SMODS.Fonts[args.font] or G.FONTS[args.font]),
                            scale = (0.55 - 0.004*#(final_name_assembled_string or assembled_string))*(part.control.s and tonumber(part.control.s) or args.scale or 1)*(args.fixed_scale or 1)
                        })
                    }}
                -- image code here
                -- pls dont abuse this kthxbai
                elseif part.control.A then
                    -- {A:atlas_name,P:x|y,S:scale}
                    local scale = tonumber(part.control.S or 1)
                    local pos = {}
                    for p in string.gmatch(part.control.P or "0|0", '([^|]+)') do
                        pos[#pos+1] = tonumber(p)
                    end
                    local atlas = G.ASSET_ATLAS[part.control.A]
                    final_line[#final_line+1] = {n=G.UIT.C, config={align = "m", colour = part.control.B and args.vars.colours[tonumber(part.control.B)] or part.control.X and loc_colour(part.control.X) or nil, r = 0.05, padding = 0.03, res = 0.15}, nodes={}}
                    final_line[#final_line].nodes[1] = {n=G.UIT.O, config={
                        object = Sprite(0, 0, (atlas.px / G.TILESIZE) * scale, (atlas.py / G.TILESIZE) * scale, atlas, { x = pos[1] or 0, y = pos[2] or 0 })
                    }}
                elseif part.control.E then
                    local _float, _silent, _pop_in, _bump, _spacing = nil, true, nil, nil, 1
                    local text_effects
                    if part.control.E == '1' then
                        _float = true; _silent = true; _pop_in = 0; _spacing = 1
                    elseif part.control.E == '2' then
                        _bump = true; _spacing = 1
                    elseif SMODS.DynaTextEffects and SMODS.DynaTextEffects[part.control.E] then
                        text_effects = part.control.E; _spacing = 1
                    end
                    final_line[#final_line+1] = {n=G.UIT.C, config={align = "m", colour = part.control.B and args.vars.colours[tonumber(part.control.B)] or part.control.X and loc_colour(part.control.X) or nil, r = 0.05, padding = 0.03, res = 0.15}, nodes={}}
                    final_line[#final_line].nodes[1] = {n=G.UIT.O, config={
                        object = DynaText({string = {assembled_string}, colours = {part.control.V and args.vars.colours[tonumber(part.control.V)] or loc_colour(part.control.C or nil)},
                            float = _float,
                            silent = _silent,
                            pop_in = _pop_in,
                            bump = _bump,
                            spacing = (args.spacing or 1) * _spacing,
                            font = SMODS.Fonts[part.control.f] or G.FONTS[tonumber(part.control.f)] or (SMODS.Fonts[args.font] or G.FONTS[args.font]),
                            text_effect = text_effects,
                            scale = 0.32*(part.control.s and tonumber(part.control.s) or args.scale or 1)*desc_scale*(args.fixed_scale or 1)
                        })
                    }}
                elseif part.control.X or part.control.B then
                    final_line[#final_line+1] = {n=G.UIT.C, config={align = "m", colour = part.control.B and args.vars.colours[tonumber(part.control.B)] or loc_colour(part.control.X), r = 0.05, padding = 0.03, res = 0.15}, nodes={
                        {n=G.UIT.T, config={
                            text = assembled_string,
                            font = SMODS.Fonts[part.control.f] or G.FONTS[tonumber(part.control.f)] or (SMODS.Fonts[args.font] or G.FONTS[args.font]),
                            colour = part.control.V and args.vars.colours[tonumber(part.control.V)] or loc_colour(part.control.C or nil),
                            scale = 0.32*(part.control.s and tonumber(part.control.s) or args.scale or 1)*desc_scale*(args.fixed_scale or 1)
                        }},
                    }}
                else
                    final_line[#final_line+1] = {n=G.UIT.T, config={
                        detailed_tooltip = part.control.T and (G.P_CENTERS[part.control.T] or G.P_TAGS[part.control.T] or G.DetailedTooltips[part.control.T]) or nil,
                        text = assembled_string,
                        font = SMODS.Fonts[part.control.f] or G.FONTS[tonumber(part.control.f)] or (SMODS.Fonts[args.font] or G.FONTS[args.font]),
                        shadow = not args.no_shadow or args.shadow,
                        colour = part.control.V and args.vars.colours[tonumber(part.control.V)] or not part.control.C and args.text_colour or loc_colour(part.control.C or nil, args.default_col),
                        scale = 0.32*(part.control.s and tonumber(part.control.s) or args.scale or 1)*desc_scale*(args.fixed_scale or 1)
                    }}
                end
            end
            if args.type == 'text' then return final_line end
            if not args.nodes and args.type == 'name' then args.nodes = {} end
            args.nodes[#args.nodes+1] = final_line
        end
        if args.type == 'name' then
            local final_name = {}

            for _, line in ipairs(args.nodes or {}) do
                final_name[#final_name+1] = {n=G.UIT.R, config={align = "m"}, nodes=line}
            end

            return final_name
        end
    end

    return args.nodes
end

local max_depth = 10
function HotPotato.recursive_check(t,func,depth)
    local depth = depth or 1
    if depth >= max_depth then return end
    for i,v in pairs(t) do
        if type(v) == "table" then
            HotPotato.recursive_check(v,func,depth+1)
        else
            func(v,i,t)
        end
    end
end

function ease_colour_queue(old_colour, new_colour, delay, queue)
    ease_value_queue(old_colour, 1, new_colour[1] - old_colour[1], false, 'REAL', nil, delay, nil, queue)
    ease_value_queue(old_colour, 2, new_colour[2] - old_colour[2], false, 'REAL', nil, delay, nil, queue)
    ease_value_queue(old_colour, 3, new_colour[3] - old_colour[3], false, 'REAL', nil, delay, nil, queue)
    ease_value_queue(old_colour, 4, new_colour[4] - old_colour[4], false, 'REAL', nil, delay, nil, queue)
end

function ease_value_queue(ref_table, ref_value, mod, floored, timer_type, not_blockable, delay, ease_type, queue)
    mod = mod or 0

    if queue then
        G.E_MANAGER.queues[queue] = G.E_MANAGER.queues[queue] or {}
    end

    --Ease from current chips to the new number of chips
    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        blockable = (not_blockable == false),
        blocking = false,
        ref_table = ref_table,
        ref_value = ref_value,
        ease_to = ref_table[ref_value] + mod,
        timer = timer_type,
        delay =  delay or 0.3,
        type = ease_type or nil,
        func = (function(t) if floored then return math.floor(t) else return t end end)
    }), queue)
end