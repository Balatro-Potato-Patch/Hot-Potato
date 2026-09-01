G.dynamic_train_messages = {
    speed = "",
    stamina = "",
    power = "",
    guts = "",
    wits = "",

    speed_subrank = "",
    stamina_subrank = "",
    power_subrank = "",
    guts_subrank = "",
    wits_subrank = "",

    stats_speed = "",
    stats_stamina = "",
    stats_power = "",
    stats_guts = "",
    stats_wits = "",

    stat_multiplier_speed = "+?%",
    stat_multiplier_stamina = "+?%",
    stat_multiplier_power = "+?%",
    stat_multiplier_guts = "+?%",
    stat_multiplier_wits = "+?%",

    energy = 0,
    dummy_energy_cost = 0,

    speed_level = "Level 1",
    stamina_level = "Level 1",
    power_level = "Level 1",
    guts_level = "Level 1",
    wits_level = "Level 1",

    failure_rate_speed = "0%",
    failure_rate_stamina = "0%",
    failure_rate_power = "0%",
    failure_rate_guts = "0%",
    failure_rate_wits = "0%",

    spark_per_turn = 45000,
}
G.training_boost = {
    level_1 = {
        speed = {
            speed = 10,
            power = 5
        },
        stamina = {
            stamina = 9,
            guts = 4
        },
        power = {
            power = 8,
            stamina = 5,
        },
        guts = {
            guts = 8,
            speed = 4,
            power = 4,
        },
        wits = {
            wits = 9,
            speed = 2
        },
    },
    level_2 = {
        speed = {
            speed = 11,
            power = 5
        },
        stamina = {
            stamina = 10,
            guts = 4
        },
        power = {
            power = 9,
            stamina = 7,
        },
        guts = {
            guts = 9,
            speed = 4,
            power = 4,
        },
        wits = {
            wits = 10,
            speed = 2
        },
    },
    level_3 = {
        speed = {
            speed = 12,
            power = 5
        },
        stamina = {
            stamina = 11,
            guts = 4
        },
        power = {
            power = 10,
            stamina = 5,
        },
        guts = {
            guts = 10,
            speed = 4,
            power = 4,
        },
        wits = {
            wits = 11,
            speed = 2
        },
    },
    level_4 = {
        speed = {
            speed = 13,
            power = 6
        },
        stamina = {
            stamina = 12,
            guts = 5
        },
        power = {
            power = 11,
            stamina = 5,
        },
        guts = {
            guts = 11,
            speed = 5,
            power = 4,
        },
        wits = {
            wits = 12,
            speed = 3
        },
    },
    level_5 = {
        speed = {
            speed = 14,
            power = 7
        },
        stamina = {
            stamina = 13,
            guts = 6
        },
        power = {
            power = 12,
            stamina = 5,
        },
        guts = {
            guts = 12,
            speed = 5,
            power = 5,
        },
        wits = {
            wits = 13,
            speed = 4
        },
    },
}

function acc_hp_calc_failure_rate(energy, train)
    if next(SMODS.find_card("j_hpot_jtem_special_week")) then return 0 end
    local energy = to_number(math.max(energy, 0))
    local energy_start_calc = 0
    local max_failure_rate = 0
    if train == "speed" then
        energy_start_calc = 40
        max_failure_rate = 0.99
    elseif train == "stamina" then
        energy_start_calc = 42
        max_failure_rate = 0.99
    elseif train == "power" then
        energy_start_calc = 38
        max_failure_rate = 0.99
    elseif train == "guts" then
        energy_start_calc = 35
        max_failure_rate = 0.99
    elseif train == "wits" then
        energy_start_calc = 50
        max_failure_rate = 0.4
    end

    if energy > energy_start_calc then
        return 0
    end
    local failureRate = max_failure_rate * (1 - energy / energy_start_calc)

    return math.max(0, math.min(max_failure_rate, failureRate)) 
end

function calc_energy_cost(joker_stats, energy)
    if not joker_stats then return energy or 0 end
    energy = to_number(energy)
    return to_number((energy or 0) >= 0 and math.ceil(energy * (1 - math.min(joker_stats.stamina / 800, 0.9)))) or (math.ceil((energy or 0) * (1 + (joker_stats.stamina / 1200))))
end

function Card:mod_training_stat(stat, num)
    if self.ability.hp_jtem_stats then
        if stat ~= "energy" then
            local old_stats = copy_table(self.ability.hp_jtem_stats)
            self.ability.hp_jtem_stats[stat] = (self.ability.hp_jtem_stats[stat] or 0) + num
            -- Change value modification related stats
            local stats = self.ability.hp_jtem_stats
            -- Guts
            hpot_jtem_with_deck_effects(self, function(c)
                if to_number(stats.guts) > 200 then
                    hpot_jtem_misprintize({ val = c.ability, amt = 1/(1+((((math.max(200,old_stats.guts)-200)/500)*100)/100)) })
                    hpot_jtem_misprintize({ val = c.ability, amt = 1+((((stats.guts-200)/500)*100)/100) })
                end
            end)
            self:set_cost()
        else
            -- energy isnt a traditional stat like everything else
            self.ability.hp_jtem_energy = math.min(math.max(0, (self.ability.hp_jtem_energy or 0) + num), 100)
        end
        self:create_train_popup(stat, num)
    end
end

local update_ref = Game.update
function Game:update(...)
    local ret = update_ref(self,...)
    local stats = {"speed", "stamina", "power", "guts", "wits"}
    local joker_stats = G.train_jokers and G.train_jokers.cards and next(G.train_jokers.cards) and G.train_jokers.cards[1].ability.hp_jtem_stats
    if G.GAME then
        G.dynamic_train_messages.spark_per_turn = G.GAME.spark_per_turn or 45000
        if G.GAME.hovered_train and joker_stats then
            local dummy_cost = calc_energy_cost(joker_stats, G.GAME.training_cost[G.GAME.hovered_train])
            if dummy_cost < 0 then
                dummy_cost = math.ceil(dummy_cost * (1 - math.min(joker_stats.stamina / 800, 0.9)))
            else
                dummy_cost = math.ceil(dummy_cost * (1 + (joker_stats.stamina / 1200)))
            end
            G.dynamic_train_messages.dummy_energy_cost = dummy_cost
        else
            G.dynamic_train_messages.dummy_energy_cost = 0
        end
        if joker_stats then
            local card = G.train_jokers.cards[1]
            G.dynamic_train_messages.energy = math.min(card.ability.hp_jtem_energy - G.dynamic_train_messages.dummy_energy_cost, 100)
        else
            G.dynamic_train_messages.energy = 0
        end
        if G.GAME.training_level then
            for i,v in pairs(G.GAME.training_level) do
                G.dynamic_train_messages[i.."_level"] = localize("hotpot_training_level")..v
            end
        end
        for _,v in ipairs(stats) do
            if joker_stats then
                local card = G.train_jokers.cards[1]    
                local stats = card.ability.hp_jtem_stats
                local multipliers = card.ability.hp_jtem_train_mult
                local specific_stat = stats[v]

                G.dynamic_train_messages[v] = hpot_get_rank_and_colour(specific_stat)
                if G.dynamic_train_messages[v]:sub(1,1) == "U" then
                    G.dynamic_train_messages[v.."_subrank"] = G.dynamic_train_messages[v]:sub(2,2)
                    G.dynamic_train_messages[v] = G.dynamic_train_messages[v]:sub(1,1)
                end
                G.dynamic_train_messages["stats_"..v] = specific_stat
                G.dynamic_train_messages["stat_multiplier_"..v] = "+"..((multipliers[v] - 1) * 100).."%"

                local energy = G.train_jokers.cards[1].ability.hp_jtem_energy
                if energy then
                    G.dynamic_train_messages["failure_rate_"..v] = math.ceil((acc_hp_calc_failure_rate(energy, v) * 100)).."%"
                end
            else
                G.dynamic_train_messages[v] = "?"
                G.dynamic_train_messages[v.."_subrank"] = ""
                G.dynamic_train_messages["stats_"..v] = "?"
                G.dynamic_train_messages["stat_multiplier_"..v] = "+?%"
                G.dynamic_train_messages["failure_rate_"..v] = "??%"
            end
        end 
    end
    return ret
end

-- this moves the shop up and down along with slide whistle sound :joy::ok_hand:
function G.FUNCS.hotpot_pd_toggle_training()
    if (G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0)) then return end
    stop_use()
    if not G.HP_TRAINING_VISIBLE then
        ease_background_colour({ new_colour = G.C.BLUE, special_colour = G.C.RED, tertiary_colour = darken(G.C.BLACK, 0.4), contrast = 3 })
        G.shop.alignment.offset.y = -60
        G.HP_TRAINING_VISIBLE = true
        play_sound("hpot_sfx_whistleup", nil, 0.25)
    else
        if G.train_jokers and #(G.train_jokers.cards or {}) > 0 then
            for _,v in ipairs(G.train_jokers.cards) do
                HotPotato.draw_card(G.train_jokers, G.jokers, 1, 'up', nil, v, 0)
            end
        end
        ease_background_colour_blind(G.STATES.SHOP)
        G.shop.alignment.offset.y = -5.3
        G.HP_TRAINING_VISIBLE = false
        play_sound("hpot_sfx_whistledown", nil, 0.25)
    end
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    G.HP_TRAINING_VISIBLE = nil
    local ret = start_run_ref(self, args)
    local saveTable = args.savetext or nil
    if saveTable and saveTable.cardAreas then
        G.GAME.train_table = saveTable.cardAreas.train_jokers
    end
    G.jokers.states.collide.can = true

    G.GAME.training_level = G.GAME.training_level or {
        speed = 1,
        stamina = 1,
        power = 1,
        guts = 1,
        wits = 1
    }
    G.GAME.training_count = G.GAME.training_count or {
        speed = 0,
        stamina = 0,
        power = 0,
        guts = 0,
        wits = 0
    }
    G.GAME.training_boost = G.GAME.training_boost or copy_table(G.training_boost.level_1)
    G.GAME.training_cost = G.GAME.training_cost or {
        speed = 20,
        stamina = 18,
        power = 18,
        guts = 22,
        wits = -5
    }
    G.GAME.spark_per_turn = G.GAME.spark_per_turn or 45000
    
    for _,train in ipairs(HP_JTEM_STATS) do
        G.C.training_colors[train] = copy_table(G.C.level_colors["level_"..G.GAME.training_level[train]])
    end
    return ret
end

function G.FUNCS.hotpot_training_grounds_train(e)
    local config = e.config
    local train = config.train
    local card = G.train_jokers and G.train_jokers.cards and next(G.train_jokers.cards) and G.train_jokers.cards[1]
    if G.CONTROLLER.locks.hpot_training_grounds then return end
    if card and G.GAME and G.GAME.spark_points and to_big(G.GAME.spark_points) >= to_big(G.GAME.spark_per_turn) then
        G.CONTROLLER.locks.hpot_training_grounds = true
        ease_currency("joker_exchange", -G.GAME.spark_per_turn)
        local joker_stats = card.ability.hp_jtem_stats
        local energy = card.ability.hp_jtem_energy
        local buff = G.GAME.training_boost[train]
        local failure_rate = acc_hp_calc_failure_rate(energy, train)
        G.GAME.training_count[train] = G.GAME.training_count[train] + 1
        if G.GAME.training_level[train] < 5 and G.GAME.training_count[train]%5 == 0 and math.floor(G.GAME.training_count[train]/5) >= G.GAME.training_level[train] then
            G.GAME.training_level[train] = G.GAME.training_level[train] + 1
            G.GAME.training_boost[train] = copy_table(G.training_boost["level_"..G.GAME.training_level[train]][train])
            ease_colour(G.C.training_colors[train], G.C.level_colors["level_"..G.GAME.training_level[train]])
        end
        if failure_rate then
            if pseudorandom("hpot_fail_train") >= failure_rate and not card.ability.hpot_skip_fail_check then
                local cost = calc_energy_cost(joker_stats,G.GAME.training_cost[train])
                card.ability.hp_jtem_energy = math.max(math.min(card.ability.hp_jtem_energy - cost,100),0)
                for i,v in pairs(buff) do
                    local multiplier = hpot_calc_stat_multiplier(card, i)
                    card:mod_training_stat(i,math.ceil(v*multiplier))
                end
                if pseudorandom('hpot_success_train_mood', 1, 10) == 10 then
                    hot_mod_mood(card, 1)
                end
            else
                if train == "wits" then
                    card.ability.hp_jtem_energy = math.min(card.ability.hp_jtem_energy - calc_energy_cost(joker_stats,-5),100)
                    play_sound("hpot_sfx_stat_down", nil, 0.7)
                else
                    local reduc = buff[train]
                    if reduc then
                        card:mod_training_stat(train,-reduc)
                    end
                end
                if pseudorandom('hpot_fail_train_mood', 1, 2) == 2 then
                    hot_mod_mood(card, -1)
                end
            end
        end
        G.E_MANAGER:add_event(Event{
            func = function()
                G.E_MANAGER:add_event(Event{
                    func = function()
                        G.CONTROLLER.locks.hpot_training_grounds = nil
                        return true
                    end
                })
                return true
            end
        })
    end
end

---@param e table|UIElement
function G.FUNCS.hotpot_training_grounds_train_button(e)
    local config = e.config

    if G.CONTROLLER.locks.hpot_training_grounds or to_big(G.GAME.spark_points) < to_big(G.GAME.spark_per_turn) or not (G.train_jokers and G.train_jokers.cards and next(G.train_jokers.cards)) then
        config.colour = G.C.UI.BACKGROUND_INACTIVE
        config.button = nil
        if e.states.hover.is then
            hpot_unhover_train_button(e)
        end
        e.states.hover.can = false
        config.is_train_button = false
    else
        config.colour = G.C.training_colors[config.train]
        config.button = "hotpot_training_grounds_train"
        config.is_train_button = true
        e.states.hover.can = true
    end
end

function G.FUNCS.hotpot_training_grounds_stats_func(e)
    local config = e.config
    local train = config.stat
    local joker_stats = G.train_jokers and G.train_jokers.cards and next(G.train_jokers.cards) and G.train_jokers.cards[1].ability.hp_jtem_stats

    if joker_stats and train then
        local _,colour = hpot_get_rank_and_colour(joker_stats[train])
        config.colour = colour or G.C.UI.TEXT_DARK
    else
        config.colour = G.C.UI.TEXT_DARK
    end
end

function G.FUNCS.hotpot_training_grounds_sub_stats_func(e)
    local config = e.config
    local train = config.stat
    local joker_stats = G.train_jokers and G.train_jokers.cards and next(G.train_jokers.cards) and G.train_jokers.cards[1].ability.hp_jtem_stats

    if joker_stats and train then
        local rank, colour = hpot_get_rank_and_colour(joker_stats[train])
        if rank:sub(1,1) == "U" then
            local subrank = rank:sub(2,2)
            colour = G.C.HP_JTEM.RANKS[subrank == "S" and "SS" or subrank] or G.C.UI.TEXT_DARK
        else
            colour = G.C.UI.TEXT_DARK
        end
        config.colour = colour or G.C.UI.TEXT_DARK
    else
        config.colour = G.C.UI.TEXT_DARK
    end
end

function hpot_hover_train_button_arrow(colour)
	return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.C, config = {align = "cm", padding = 0, colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {shadow = true, text = "v", colour = colour or G.C.FILTER, scale = 1}},
            }},
        }}
    }}
end

function hpot_hover_train_button_failure_rate(colours, train)
	return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.C, config = {align = "cm", padding = 0.05, colour = (colours or {})[1] or G.C.BLUE, minw = 2, minh = 0.6, r = 0.3}, nodes = {
            {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {shadow = true, ref_table = G.dynamic_train_messages, ref_value = "failure_rate_"..train, colour = (colours or {})[2] or G.C.UI.TEXT_LIGHT, scale = 0.4}},
                {n = G.UIT.T, config = {shadow = true, text = localize('hpot_training_failure'), colour = (colours or {})[2] or G.C.UI.TEXT_LIGHT, scale = 0.4}},
            }}
        }}
    }}
end

function hpot_hover_train_button_stat(colour, num)
    return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.C, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {shadow = true, text = ((to_number(num or 0) >= 0 and "+") or nil)..num, colour = colour or G.C.FILTER, scale = 0.6}},
            }},
        }}
    }}
end

function hpot_hover_train_button(self)
    local pos = { x = 0, y = -0.15 }
    local destination = { x = 0, y = 0 }
    if not self.config.original_offset then
        self.config.original_offset = copy_table(self.role.offset)
    end
    for i, _ in pairs(destination) do
        destination[i] = pos[i] + (self.config.original_offset[i] - self.role.offset[i])
    end
    G.E_MANAGER.queues[self.config.id] = G.E_MANAGER.queues[self.config.id] or {}
    G.E_MANAGER:clear_queue(self.config.id)
    self:ease_move(destination, 6, self.config.id, true, true, nil, nil, nil, "inexpo")
    self.hpot_hovered = true

    --[[G.GAME.arrow_popup = (G.GAME.arrow_popup or 0) + 1
        local popup = G.GAME.arrow_popup
        repeat
            if G.C["train_button_arrow"..popup] then
                popup = popup + 1
            end
        until not G.C["train_button_arrow"..popup]
        G.E_MANAGER.queues["train_button_arrow"..popup] = G.E_MANAGER.queues["train_button_arrow"..popup] or {}
        G.E_MANAGER:clear_queue("train_button_arrow"..popup)
        G.C["train_button_arrow"..popup] = copy_table(G.C.FILTER)
        G.C["train_button_arrow"..popup][4] = 0
        ease_colour_queue(G.C["train_button_arrow"..popup], G.C.FILTER, nil, "train_button_arrow"..popup)
        self.children["train_button_arrow"..popup] = UIBox{
            definition = hpot_hover_train_button_arrow(G.C["train_button_arrow"..popup]),
            config = {
                align = "tmi",
                offset = {x = 0, y = -0.6},
                parent = self
            }
        }
        local text_node = self.children["train_button_arrow"..popup].UIRoot.children[1].children[1].children[1]
        text_node.states.hover.can = false
        text_node:ease_move{x = 0, y = -0.25}]]

    G.GAME.failure_popup = (G.GAME.failure_popup or 0) + 1
    local f_popup = G.GAME.failure_popup
    repeat
        if G.C["train_button_failure" .. f_popup] or G.C["text_" .. "train_button_failure" .. f_popup] then
            f_popup = f_popup + 1
        end
    until not G.C["train_button_failure" .. f_popup] and not G.C["text_" .. "train_button_failure" .. f_popup]
    G.E_MANAGER.queues["train_button_failure" .. f_popup] = G.E_MANAGER.queues["train_button_failure" .. f_popup] or {}
    G.E_MANAGER:clear_queue("train_button_failure" .. f_popup)
    G.C["train_button_failure" .. f_popup] = copy_table(G.C.BLUE)
    G.C["train_button_failure" .. f_popup][4] = 0
    ease_colour_queue(G.C["train_button_failure" .. f_popup], G.C.BLUE, nil, "train_button_failure" .. f_popup)

    G.E_MANAGER.queues["text_" .. "train_button_failure" .. f_popup] = G.E_MANAGER.queues
    ["text_" .. "train_button_failure" .. f_popup] or {}
    G.E_MANAGER:clear_queue("text_" .. "train_button_failure" .. f_popup)
    G.C["text_" .. "train_button_failure" .. f_popup] = copy_table(G.C.UI.TEXT_LIGHT)
    G.C["text_" .. "train_button_failure" .. f_popup][4] = 0
    ease_colour_queue(G.C["text_" .. "train_button_failure" .. f_popup], G.C.UI.TEXT_LIGHT, nil,
        "text_" .. "train_button_failure" .. f_popup)
    self.children["train_button_failure" .. f_popup] = UIBox {
        definition = hpot_hover_train_button_failure_rate({ G.C["train_button_failure" .. f_popup], G.C["text_" .. "train_button_failure" .. f_popup] }, self.config.train),
        config = {
            align = "tmi",
            offset = { x = 0, y = -0.5 },
            parent = self,
        }
    }
    local node = self.children["train_button_failure" .. f_popup].UIRoot.children[1]
    node.states.hover.can = false
    node:ease_move { x = 0, y = -0.25 }

    local stat_gains = G.GAME.training_boost[self.config.train]
    if stat_gains and G.shop then
        for i, v in pairs(stat_gains) do
            local stat_container = G.shop:get_UIE_by_ID("stat_train_" .. i)
            if stat_container then
                G.GAME.stat_popup = (G.GAME.stat_popup or 0) + 1
                local popup = G.GAME.stat_popup
                repeat
                    if stat_container.children["stat_gains" .. popup] then
                        popup = popup + 1
                    end
                until not stat_container.children["stat_gains" .. popup]
                for i, v in pairs(stat_container.children) do
                    if string.find(i, "stat_gains") then
                        v:remove()
                        stat_container.children[i] = nil
                        G.GAME.stat_popup = (G.GAME.stat_popup or 1) - 1
                    end
                end
                G.GAME["stop_removing_children_" .. "stat_gains" .. popup] = true
                G.GAME.hovered_train = self.config.train
                local multiplier = 1
                if G.train_jokers and G.train_jokers.cards and next(G.train_jokers.cards) then
                    local card = G.train_jokers.cards[1]
                    multiplier = hpot_calc_stat_multiplier(card, i)
                end
                stat_container.children["stat_gains" .. popup] = UIBox {
                    definition = hpot_hover_train_button_stat(G.C.FILTER, v * multiplier),
                    config = {
                        align = "tmi",
                        offset = { x = 0, y = -0.45 },
                        parent = stat_container,
                        train = i
                    }
                }
                stat_container.stat_gains = { "stat_gains" .. popup }
                local node = stat_container.children["stat_gains" .. popup].UIRoot.children[1]
                node:ease_move { x = 0, y = -0.2 }
            end
        end
    end
end

function hpot_unhover_train_button(self)
    local pos = { x = 0, y = 0.25 }
    local destination = { x = 0, y = 0 }
    if not self.config.original_offset then
        self.config.original_offset = copy_table(self.role.offset)
    end
    G.E_MANAGER.queues[self.config.id] = G.E_MANAGER.queues[self.config.id] or {}
    G.E_MANAGER:clear_queue(self.config.id)
    for i, _ in pairs(destination) do
        destination[i] = pos[i] + (self.config.original_offset[i] - pos[i] - self.role.offset[i])
    end
    self:ease_move(destination, 6, self.config.id, true, true)
    self.hpot_hovered = nil
    for i, v in pairs(self.children) do
        if string.find(i, "train_button_arrow") then
            --[[local node = v.UIRoot.children[1].children[1].children[1]
                ease_colour_queue(G.C[i], {G.C.FILTER[1], G.C.FILTER[2], G.C.FILTER[3], 0}, nil, i)
                node:ease_move({x = 0, y = 0.5}, nil, nil, nil, nil, nil, nil, {after_func = function(node)
                    G.GAME.arrow_popup = (G.GAME.arrow_popup or 1) - 1
                    G.E_MANAGER.queues[i] = G.E_MANAGER.queues[i] or {}
                    G.E_MANAGER:clear_queue(i)
                    G.C[i] = nil
                    v:remove()
                    self.children[i] = nil
                end})]]
        elseif string.find(i, "train_button_failure") then
            local node = v.UIRoot.children[1]
            ease_colour_queue(G.C[i], { G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], 0 }, nil, i)
            ease_colour_queue(G.C["text_" .. i], { G.C.UI.TEXT_LIGHT[1], G.C.UI.TEXT_LIGHT[2], G.C.UI.TEXT_LIGHT[3], 0 },
                nil, "text_" .. i)
            node:ease_move({ x = 0, y = -0.4 }, nil, nil, nil, nil, nil, nil, {
                after_func = function(node)
                    G.GAME.failure_popup = (G.GAME.failure_popup or 1) - 1
                    G.E_MANAGER.queues[i] = G.E_MANAGER.queues[i] or {}
                    G.E_MANAGER:clear_queue(i)
                    G.C[i] = nil

                    G.E_MANAGER.queues["text_" .. i] = G.E_MANAGER.queues["text_" .. i] or {}
                    G.E_MANAGER:clear_queue("text_" .. i)
                    G.C["text_" .. i] = nil

                    v:remove()
                    self.children[i] = nil
                end
            })
        end
    end

    local stat_gains = G.GAME.training_boost[self.config.train]
    if stat_gains and G.shop then
        for i, _ in pairs(stat_gains) do
            local stat_container = G.shop:get_UIE_by_ID("stat_train_" .. i)
            if stat_container and G.GAME.hovered_train == self.config.train then
                for ii, vv in pairs(stat_container.children) do
                    if string.find(ii, "stat_gains") then
                        vv:remove()
                        stat_container.children[ii] = nil
                        G.GAME.stat_popup = (G.GAME.stat_popup or 1) - 1
                    end
                end
            elseif stat_container and G.GAME.hovered_train ~= self.config.train then
                local to_delete = copy_table(G.GAME.training_boost[self.config.train] or {})
                for ii, _ in pairs(G.GAME.training_boost[G.GAME.hovered_train] or {}) do
                    if to_delete[ii] then
                        to_delete[ii] = nil
                    end
                end
                for ii, vv in pairs(stat_container.children) do
                    if vv.config and vv.config.train and to_delete[vv.config.train] then
                        vv:remove()
                        stat_container.children[ii] = nil
                        G.GAME.stat_popup = (G.GAME.stat_popup or 1) - 1
                    end
                end
            end
        end
    end
    if G.GAME.hovered_train == self.config.train then G.GAME.hovered_train = nil end
end

local ui_hover_ref = UIElement.hover
function UIElement:hover(...)
    local ret = ui_hover_ref(self,...)
    if self.config and self.config.is_train_button then
        hpot_hover_train_button(self)
    end
    return ret
end

local ui_stop_hover_ref = UIElement.stop_hover
function UIElement:stop_hover(...)
    local ret = ui_stop_hover_ref(self,...)
    if self.config and self.config.is_train_button then
        hpot_unhover_train_button(self)
    end
    return ret
end

function G.UIDEF.hotpot_pd_training_section()
    if G.GAME.train_table then
        G.train_jokers:load(G.GAME.train_table)
        G.GAME.train_table = nil
    end
    local training_level = {
        speed = 1,
        stamina = 1,
        power = 1,
        guts = 1,
        wits = 1
    }

    local button_minsize = 1.3
    local function create_train_button(train)
        return {n = G.UIT.C, config = {align = "cm", padding = 0.05, r = 0.2, colour = G.C.training_colors[train], minw = button_minsize, minh = button_minsize, outline_colour = G.C.WHITE, outline = 1, button = "hotpot_training_grounds_train", func = "hotpot_training_grounds_train_button", train = train, hover = true, shadow = true, id = "button_train_"..train, is_train_button = true, button_dist = 0}, nodes = {
            {n = G.UIT.R, config = {align = "cm"}, nodes = {
                {n = G.UIT.T, config = {text = localize("hotpot_"..train), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
            {n = G.UIT.R, config = {align = "cm"}, nodes = {
                {n = G.UIT.T, config = {ref_table = G.dynamic_train_messages, ref_value = train.."_level", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
        }}
    end
    local function create_stat_display(stat)
        return {n = G.UIT.C, config = {align = "tm", id = "stat_train_"..stat, minw = 1.4}, nodes = {
            {n = G.UIT.R, config = {align = "cm", colour = G.C.hotpot_default_stat_color, minh = 0.4, minw = 1.4, padding = 0.05}, nodes = {
                {n = G.UIT.T, config = {text = localize("hotpot_"..stat), scale = 0.35, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.02}, nodes = {
                    {n = G.UIT.R, config = {align = "cm"}, nodes = {
                        {n = G.UIT.C, config = { align = "bm" }, nodes = {
                            { n = G.UIT.T, config = { ref_table = G.dynamic_train_messages, ref_value = stat, scale = 0.6, colour = G.C.UI.TEXT_DARK, func = "hotpot_training_grounds_stats_func", stat = stat, shadow = true } },
                        }},
                        {n = G.UIT.C, config = { align = "bm" }, nodes = {
                            { n = G.UIT.T, config = { ref_table = G.dynamic_train_messages, ref_value = stat.."_subrank", scale = 0.4, colour = G.C.UI.TEXT_DARK, func = "hotpot_training_grounds_sub_stats_func", stat = stat, shadow = true } },
                        }},
                    }},
                }},
                {n = G.UIT.C, config = {align = "cm", padding = 0.02}, nodes = {
                    {n = G.UIT.R, config = {align = "cm"}, nodes = {
                        {n = G.UIT.T, config = {ref_table = G.dynamic_train_messages, ref_value = "stats_"..stat, scale = 0.425, colour = G.C.UI.TEXT_DARK, shadow = true}},
                    }},
                    {n = G.UIT.R, config = {align = "cm"}, nodes = {
                        {n = G.UIT.T, config = {text = "/1200", scale = 0.3, colour = G.C.UI.TEXT_DARK, shadow = true}},
                    }},
                    {n = G.UIT.R, config = { align = "cm" }, nodes = {
                        { n = G.UIT.T, config = { ref_table = G.dynamic_train_messages, ref_value = "stat_multiplier_"..stat, scale = 0.235, colour = G.C.UI.TEXT_INACTIVE } },
                    }},
                }},
            }},
        }}
    end
    local function create_stat_display_gap(minw, padding, r)
        return {n = G.UIT.C, config = {align = "tm", padding = padding or nil}, nodes = {
            {n = G.UIT.R, config = {align = "cm", colour = G.C.hotpot_default_stat_color, minh = 0.4, minw = minw or 0.5, r = r or nil}},
        }}
    end

    return 
    {n=G.UIT.C, config = {align = 'tm', minh = 8}, nodes={
        PissDrawer.Shop.help_button('training_help'),
        {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                    {n = G.UIT.C, config = {align = "tm", padding = 0.1}, nodes = {
                        {n=G.UIT.R, nodes = {
                            {n=G.UIT.C, nodes = {
                                {n=G.UIT.R, config = {colour = G.C.CLEAR, minh = 0.2}},
                                {n = G.UIT.R, config = {align = "cm", colour = G.C.WHITE, r = 0.15, outline_colour = G.C.hotpot_default_stat_color, outline = 1}, nodes = {
                                    create_stat_display("speed"),
                                    create_stat_display_gap(),
                                    create_stat_display("stamina"),
                                    create_stat_display_gap(),
                                    create_stat_display("power"),
                                }},
                                {n=G.UIT.R, config = {colour = G.C.CLEAR, minh = 0.1}},
                                {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                                    {n=G.UIT.C, config = {align = 'cm'}, nodes = {
                                        {n = G.UIT.R, config = {align = "cm", colour = G.C.WHITE, r = 0.15, outline_colour = G.C.hotpot_default_stat_color, outline = 1}, nodes = {
                                            create_stat_display("guts"),
                                            create_stat_display_gap(),
                                            create_stat_display("wits"),
                                        }},
                                    }},
                                }}
                            }}
                        }},
                        {n=G.UIT.R, config = {minh = 0.2}},
                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                            {n = G.UIT.C, config = {align = "cm", minh = 0.65, minw = 1.5, r = 0.2, colour = G.C.L_BLACK}, nodes = {
                                {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                                    {n = G.UIT.C, config = {align = "cl"}, nodes = {
                                        {n = G.UIT.T, config = {text = "Energy", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
                                    }},
                                    {n = G.UIT.C, config = {align = "cm", colour = G.C.BLUE, minw = 3.5, minh = 0.4, r = 0.2, ease_progress_bar = {max = 100, ref_table = G.dynamic_train_messages, ref_value = "energy", empty_col = darken(G.C.BLUE, 0.5), filled_col = G.C.BLUE, ease = "quad"}}},
                                }},
                            }}
                        }},
                    }},
                    {n=G.UIT.C, config = {minw = 1}},
                    {n = G.UIT.C, config = {align = "cm", padding = 0.125, r = 0.2, emboss = 0.05, colour = G.C.L_BLACK}, nodes = {
                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                            {n = G.UIT.T, config = {text = localize("hotpot_training_joker"), scale = 0.4, colour = G.C.BLACK}},
                        }},
                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                            {n = G.UIT.C, config = {align = "cm", r = 0.2, colour = G.C.BLACK}, nodes = {
                                {n = G.UIT.C, nodes = {
                                    {n = G.UIT.O, config = {object = G.train_jokers}},
                                }},
                                {n = G.UIT.C, config = { minw = 0.5 }},
                            }},
                        }},
                        {n = G.UIT.R, config = {align = "cm", minh = 0.05}},
                    }},
                }},
                {n = G.UIT.R, config = {align = "cm", minh = 0.35}},
                {n = G.UIT.R, config = {align = "cm", padding = 0.2}, nodes = {
                    {n = G.UIT.C, config = {align = "tm", r = 0.2, colour = G.C.WHITE, outline_colour = G.C.BLUE, outline = 1}, nodes = {
                        {n = G.UIT.R, config = {align = "cm", colour = G.C.BLUE, padding = 0.1, minh = 0.7}, nodes = {
                            {n = G.UIT.T, config = {text = localize("k_spark_per_turn"), scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
                        }},
                        {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                            {n = G.UIT.C, config = {align = "cm", padding = 0.025}, nodes = {
                                {n = G.UIT.T, config = {text = localize('hotpot_reforge_sparks'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.BLUE, scale = 0.5, shadow = true}},
                            }},
                            {n = G.UIT.C, config = {align = "cm", padding = 0.025}, nodes = {
                                {n = G.UIT.T, config = {ref_table = G.dynamic_train_messages, ref_value = "spark_per_turn", scale = 0.5, colour = G.C.BLUE, shadow = true}},
                            }},
                        }},
                    }},
                    create_train_button("speed"),
                    create_train_button("stamina"),
                    create_train_button("power"),
                    create_train_button("guts"),
                    create_train_button("wits"),
                }},
            }}
end

G.C = G.C or {}
G.C.level_colors = {
    level_1 = HEX("61c963"),
    level_2 = copy_table(G.C.BLUE),
    level_3 = copy_table(G.C.FILTER),
    level_4 = HEX("cf3853"),
    level_5 = HEX("6156a6"),
}
G.C.hotpot_default_stat_color = HEX("61c963")
G.C.training_colors = {
    speed = copy_table(G.C.level_colors["level_1"]),
    stamina = copy_table(G.C.level_colors["level_1"]),
    power = copy_table(G.C.level_colors["level_1"]),
    guts = copy_table(G.C.level_colors["level_1"]),
    wits = copy_table(G.C.level_colors["level_1"])
}

local loc_colour_ref = loc_colour
function loc_colour(_c, _default)
    if not G.ARGS.LOC_COLOURS then
        loc_colour_ref()
    end

    for i,v in pairs(G.C.level_colors) do
        G.ARGS.LOC_COLOURS["train_"..i] = v
        G.C["train_"..i] = v
    end

    return loc_colour_ref(_c, _default)
end

--Code to drag card between areas, adapted from Aikoyori Shenanigans' code (check it out btw)
function HotPotato.draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only, forced_facing)
    percent = percent or 50
    delay = delay or 0.1 
    if dir == 'down' then 
        percent = 1-percent
    end
    sort = sort or false
    local drawn = nil

    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = delay,
        blocking = not (G.SETTINGS.GAMESPEED >= 999 and ((to == G.hand and from == G.deck) or (to == G.deck and from == G.hand))), -- Has to be these specific draws only, otherwise it's buggy
        
        func = function()
            if card then 
                if from then card = from:remove_card(card) end
                if card then drawn = true end
                if card and to == G.hand and not card.states.visible then
                    card.states.visible = true
                end
                local stay_flipped = G.GAME and G.GAME.blind and G.GAME.blind:stay_flipped(to, card, from)
                if to then
                    to:emplace(card, nil, stay_flipped)
                else
                    
                end
                if card and forced_facing then 
                    card.sprite_facing = forced_facing
                    card.facing = forced_facing
                end
            else
                card = to:draw_card_from(from, stay_flipped, discarded_only)
                if card then drawn = true end
                if card and to == G.hand and not card.states.visible then
                    card.states.visible = true
                end
                if card and forced_facing then 
                    card.sprite_facing = forced_facing
                    card.facing = forced_facing
                end
            end
            if not mute and drawn then
                if from == G.deck or from == G.hand or from == G.play or from == G.jokers or from == G.consumeables or from == G.discard then
                    G.VIBRATION = G.VIBRATION + 0.6
                end
                play_sound('card1', 0.85 + percent*0.2/100, 0.6*(vol or 1))
            end
            if sort then
                to:sort()
            end
            SMODS.drawn_cards = SMODS.drawn_cards or {}
            if card and card.playing_card then SMODS.drawn_cards[#SMODS.drawn_cards+1] = card end
            
            if card and forced_facing then 
                card.facing = forced_facing
                card.sprite_facing = forced_facing
            end
            return true
        end
      }))
end

local toHook = Card.stop_drag
function Card:stop_drag()
    if G.jokers and G.jokers.cards and G.train_jokers then
        local area = self.area
        self.hp_oldarea = self.area or self.hp_oldarea
        for i, k in ipairs(G.CONTROLLER.collision_list) do
            if (k:is(CardArea)) then
                area = k
                break
            end
            
            if (k:is(Card)) and false then
                area = k.area
                break
            end
        end
        if self.hp_oldarea ~= area and (area == G.train_jokers and G.train_jokers.cards and #(G.train_jokers.cards or {}) <= 0) or (area == G.jokers and self.hp_oldarea == G.train_jokers) then
            HotPotato.draw_card(self.hp_oldarea, area, 1, 'up', nil, self ,0)
            G.E_MANAGER:add_event(Event({
                func = function()
                    self.hp_oldarea = nil
                    return true 
                end
            }))
            area:align_cards()
        end
    end
    local c = toHook(self)
    return c
end 