Quantum = Card:extend()

for key, func in pairs(Card) do
    if type(func) == 'function' then
        Quantum[key] = function(self, ...)
            return Card[key](self.quantum, ...)
        end
    end
end


function Quantum:init(args, source)
    --ty eremel <3
    -- NOTE: this should probably be reworked to use metatables to access base card properties rather than pretend ones, but I do not have the motivation to do that right now -eremel
    self.base_cost = args.base_cost or 0
    self.extra_cost = args.extra_cost or 0
    self.cost = args.cost or 0
    self.sell_cost = args.sell_cost or 0
    self.sell_cost_label = args.sell_cost_label or 0
    self.base = {}

    self.key = args.key
    self.fake_card = true
    self.ability = args.ability
    self.ability.mother = false
    self.ability.father = false
    self.config = args.config
    self.quantum = source
    self.children = setmetatable({quantum = source}, {
        __index = function(t, key)
            return rawget(t.quantum.children, key)
        end,
        __newindex = function(t, key, value)
            rawset(t.quantum.children, key, value)
        end
    })
end

function Quantum:save()
    local cardTable = {
        base_cost = self.base_cost,
        extra_cost = self.extra_cost,
        cost = self.cost,
        sell_cost = self.sell_cost,
        ability = self.ability,
        key = self.key,
        fake_card = true,
        config = {
            center = self.config.center
        },
    }
    return cardTable
end

local cs = Card.save
function Card:save()
    local cardTable = cs(self)
    if self.ability and self.ability.quantum_1 and type(self.ability.quantum_1) ~= 'string' then
        for i = 1, 2 do
            cardTable['quantum_' .. i] = Quantum.save(self.ability['quantum_' .. i])
        end
    end
    return cardTable
end

local cest = card_eval_status_text
function card_eval_status_text(card, eval_type, amt, percent, dir, extra)
    if card and card.quantum then card = card.quantum end
    cest(card, eval_type, amt, percent, dir, extra)
end

local smods_find_card = SMODS.find_card
function SMODS.find_card(key, count_debuffed)
    local results = smods_find_card(key, count_debuffed)
    if not G.jokers or not G.jokers.cards then return {} end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        if area.cards then
            for _, v in pairs(area.cards) do
                if v and type(v) == 'table' and v.ability and v.ability.quantum_1 then
                    if (v.ability.quantum_1.key == key) and (count_debuffed or not v.debuff) then
                        table.insert(results, v.ability.quantum_1)
                    end
                    if (v.ability.quantum_2.key == key) and (count_debuffed or not v.debuff) then
                        table.insert(results, v.ability.quantum_2)
                    end
                end
            end
        end
    end
    return results
end

local discover_jonkler = find_joker
function find_joker(name, non_debuff)
    local results = discover_jonkler(name, non_debuff)
    if not G.jokers or not G.jokers.cards then return {} end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        if area.cards then
            for _, v in pairs(area.cards) do
                if v and type(v) == 'table' and v.ability and v.ability.quantum_1 then
                    if (v.ability.quantum_1.ability.name == name) and (non_debuff or not v.debuff) then
                        table.insert(results, v.ability.quantum_1)
                    end
                    if (v.ability.quantum_2.ability.name == name) and (non_debuff or not v.debuff) then
                        table.insert(results, v.ability.quantum_2)
                    end
                end
            end
        end
    end
    return results
end

local smods_destroy_cards = SMODS.destroy_cards
function SMODS.destroy_cards(cards, ...)
    if not cards[1] then
        if Object.is(cards, Card) then
            cards = { cards }
        else
            return
        end
    end
    local new_cards = {}
    for _, card in pairs(cards) do
        if card.quantum then
            new_cards[#new_cards + 1] = card.quantum
        else
            new_cards[#new_cards + 1] = card
        end
    end

    return smods_destroy_cards(new_cards, ...)
end

-- is rarity
local is_rarity = Card.is_rarity
function Card:is_rarity(rarity)
    if self.ability.quantum_1 then
        local rarities = { "Common", "Uncommon", "Rare", "Legendary" }
        rarity = rarities[rarity] or rarity
        local own_rarity_1 = rarities[self.ability.quantum_1.config.center.rarity] or
            self.ability.quantum_1.config.center.rarity
        local own_rarity_2 = rarities[self.ability.quantum_2.config.center.rarity] or
            self.ability.quantum_2.config.center.rarity
        return own_rarity_1 == rarity or SMODS.Rarities[own_rarity_1] == rarity or own_rarity_2 == rarity or
            SMODS.Rarities[own_rarity_2] == rarity
    end
    return is_rarity(self, rarity)
end

SMODS.Rarity {
    key = "child",
    loc_txt = { name = "Child" },
    badge_colour = G.C.HPOT_PINK,
}

function PissDrawer.quantum_calc_currency_bonus(bonus, card)
    if not (card.ability.quantum_1 or card.ability.quantum_2) then return 0 end

    bonus = bonus or "dollar"
    local f = Card["calculate_"..bonus.."_bonus"]

    if not f then return 0 end

    local ret1 = f(card.ability.quantum_1)
    local ret2 = f(card.ability.quantum_2)
    if ret1 and ret2 and type(ret1) == 'number' and type(ret2) == 'number' then
        ret1 = ret1 + ret2
    end

    return ret1 or ret2
end

SMODS.Joker {
    key = 'child',
    rarity = 'hpot_child',
    hotpot_credits = {
        idea = { "fey <3" },
        code = { "fey <3" },
        team = { "Pissdrawer" }
    },
    no_collection = true,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        if card then
            local q1, q2 = card.ability.quantum_1, card.ability.quantum_2
            local func = (q1.config.center.generate_ui or SMODS.Joker.generate_ui)
            if type(func) == "function" then
                func(q1.config.center, info_queue, q1, desc_nodes, Card.generate_UIBox_ability_table(q1, true),
                    full_UI_table)
            end
        end
    end,
    calculate = function(self, card, context)
        if card.ability.quantum_1 and card.ability.quantum_2 then
            local ret, trig = Card.calculate_joker(card.ability.quantum_1, context)
            if ret then SMODS.update_context_flags(context, ret) end

            local ret2, trig2 = Card.calculate_joker(card.ability.quantum_2, context)

            if ret then PissDrawer.replace_quantum(ret, card.ability.quantum_1, card) end
            if ret2 then PissDrawer.replace_quantum(ret2, card.ability.quantum_2, card) end
            return SMODS.merge_effects { ret or {}, ret2 or {} }, trig or trig2
        end
    end,
    calc_dollar_bonus = function(self, card)
        return PissDrawer.quantum_calc_currency_bonus("dollar", card)
    end,
    calc_plincoin_bonus = function(self, card)
        return PissDrawer.quantum_calc_currency_bonus("plincoin", card)
    end,
    calc_crypto_bonus = function(self, card)
        return PissDrawer.quantum_calc_currency_bonus("crypto", card)
    end,
    calc_spark_point_bonus = function(self, card)
        return PissDrawer.quantum_calc_currency_bonus("spark_point", card)
    end,
    calc_credits_point_bonus = function(self, card)
        return PissDrawer.quantum_calc_currency_bonus("credits", card)
    end,
    calc_scaling = function(self, card, other_card, scaling_value, scalar_value, args)
        if other_card.ability.quantum_1 and other_card.ability.quantum_2 then
            local center1 = other_card.ability.quantum_1.config.center
            local center2 = other_card.ability.quantum_2.config.center
            local ret, ret2 = {}, {}

            if center1.calc_scaling and type(center1.calc_scaling) == "function" then
                ret = center1:calc_scaling(card, other_card.ability.quantum_1, scaling_value, scalar_value, args)
            end
            if center2.calc_scaling and type(center2.calc_scaling) == "function" then
                ret2 = center2:calc_scaling(card, other_card.ability.quantum_2, scaling_value, scalar_value, args)
            end

            if ret then PissDrawer.replace_quantum(ret, other_card.ability.quantum_1, other_card) end
            if ret2 then PissDrawer.replace_quantum(ret2, other_card.ability.quantum_2, other_card) end

            return SMODS.merge_effects { ret or {}, ret2 or {} }
        end
    end,
    add_to_deck = function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                if card.ability.quantum_1 and card.ability.quantum_2 then
                    Card.add_to_deck(card.ability.quantum_1)
                    Card.add_to_deck(card.ability.quantum_2)
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                if card.ability.quantum_1 and card.ability.quantum_2 then
                    Card.remove_from_deck(card.ability.quantum_1)
                    Card.remove_from_deck(card.ability.quantum_2)
                end
                return true
            end
        }))
    end,
    in_pool = function(self, args)
        return false
    end,
    load = function(self, card, table, other)
        if table.ability and table.ability.quantum_1 then
            local args = table.quantum_1
            args.config.center = G.P_CENTERS[args.key]
            table.ability.quantum_1 = Quantum(args, card)
            args = table.quantum_2
            args.config.center = G.P_CENTERS[args.key]
            table.ability.quantum_2 = Quantum(args, card)
            update_child_atlas(card, G.ASSET_ATLAS[G.P_CENTERS[table.ability.quantum_1.key].atlas or 'Joker'],
                G.P_CENTERS[table.ability.quantum_1.key].pos)
            card.loaded = true
        end
    end,
    set_sprites = function(self, card)
        if card.ability and card.ability.quantum_1 then
            update_child_atlas(card, G.ASSET_ATLAS[G.P_CENTERS[card.ability.quantum_1.key].atlas or 'Joker'], G.P_CENTERS[card.ability.quantum_1.key].pos)
        end
    end,
    update = function(self, card, dt)
        if card.loaded and card.ability and card.ability.quantum_1 then
            Card.update(card.ability.quantum_1, dt)
            Card.update(card.ability.quantum_2, dt)
        end
    end,
    hpot_unbreedable = true
}

local bpe = SMODS.blueprint_effect
function SMODS.blueprint_effect(copier, copied_card, context)
    if copier.quantum and copier.quantum == copied_card then return end
    return bpe(copier, copied_card, context)
end

function PissDrawer.replace_quantum(effects, quantum, host)
    if type(effects) == 'table' then
        local new_eff = {}
        for k, v in pairs(effects) do
            if type(v) == 'table' then
                if v.quantum then
                    new_eff[k] = v.quantum
                elseif k == 'extra' then
                    new_eff[k] = PissDrawer.replace_quantum(v)
                else
                    new_eff[k] = v
                end
            else
                new_eff[k] = v
            end
        end
        return new_eff
    end
    return effects
end

local calc_effect = SMODS.calculate_effect
function SMODS.calculate_effect(effect, card, ...)
    effect = PissDrawer.replace_quantum(effect)
    if card and card.quantum then card = card.quantum end
    return calc_effect(effect, card, ...)
end

-- Tooltips use multibox
local gen_card_ui = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    local ui = gen_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    if card and card.ability.quantum_1 then
        local quantum_nodes = {}
        local info_queue = {}
        local vars = card.ability.quantum_2.config.center.loc_vars and
            card.ability.quantum_2.config.center.loc_vars(card.ability.quantum_2.config.center, info_queue,
                card.ability.quantum_2)
        vars = vars and vars.vars -- custom loc_vars functions
            or
            Card.generate_UIBox_ability_table(
                { ability = card.ability.quantum_2.ability, config = card.ability.quantum_2.config, bypass_lock = true },
                true)
        localize { type = 'descriptions', set = 'Joker', key = card.ability.quantum_2.key, nodes = quantum_nodes, vars = vars or {}, AUT = { info = { "yes" } } } -- some jank here to allow the second quantum object to have a multi box, currently combines them into one box like info_queues
        ui.quantum = quantum_nodes

        -- Can't get this working for vanilla jokers rn, this code lets custom jokers in slot 2 add to info queue
        -- if next(info_queue) then
        --     for _, v in ipairs(info_queue) do
        --         generate_card_ui(v, full_UI_table, {is_info_queue = true})
        --     end
        -- end
    end
    return ui
end

local card_h_popup = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
    local ret_val = card_h_popup(card)
    local AUT = card.ability_UIBox_table
    if AUT.quantum then
        table.insert(ret_val.nodes[1].nodes[1].nodes[1].nodes,
            #ret_val.nodes[1].nodes[1].nodes[1].nodes + (card.config.center.discovered and 0 or 1),
            desc_from_rows(AUT.quantum))
    end
    return ret_val
end

-- soul sprites
SMODS.DrawStep {
    key = 'floating_sprite',
    order = 60,
    func = function(self)
        if self.ability.quantum_1 and self.ability.quantum_1.config.center.soul_pos then
            local scale_mod = 0.07 + 0.02 * math.sin(1.8 * G.TIMERS.REAL) +
                0.00 * math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL)) * math.pi * 14) *
                (1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL))) ^ 3
            local rotate_mod = 0.05 * math.sin(1.219 * G.TIMERS.REAL) +
                0.00 * math.sin((G.TIMERS.REAL) * math.pi * 5) * (1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL))) ^ 2

            if type(self.ability.quantum_1.config.center.soul_pos.draw) == 'function' then
                self.ability.quantum_1.config.center.soul_pos.draw(self, scale_mod, rotate_mod)
            elseif self.children.floating_sprite then
                if self.ability.quantum_1.key == 'j_hologram' then
                    self.hover_tilt = self.hover_tilt * 1.5
                    self.children.floating_sprite:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil,
                        self.children.center, 2 * scale_mod, 2 * rotate_mod)
                    self.hover_tilt = self.hover_tilt / 1.5
                else
                    self.children.floating_sprite:draw_shader('dissolve', 0, nil, nil, self.children.center, scale_mod,
                        rotate_mod, nil, 0.1 + 0.03 * math.sin(1.8 * G.TIMERS.REAL), nil, 0.6)
                    self.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod,
                        rotate_mod)
                end
            end
            if self.edition then
                local edition = G.P_CENTERS[self.edition.key]
                if edition.apply_to_float and self.children.floating_sprite then
                    self.children.floating_sprite:draw_shader(edition.shader, nil, nil, nil, self.children.center,
                        scale_mod, rotate_mod)
                end
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

local old = copy_card
function copy_card(card, new_card, card_scale, playing_card, strip_edition)
    card = card.quantum or card
    if card.ability.quantum_1 then
        local q1, q2 = card.ability.quantum_1, card.ability.quantum_2
        card.ability.quantum_1, card.ability.quantum_2 = nil, nil
        local ret = old(card, new_card, card_scale, playing_card, strip_edition)
        card.ability.quantum_1, card.ability.quantum_2 = q1, q2
        ret.ability.quantum_1 =
            Quantum({
                fake_card = true,
                key = q1.config.center.key,
                ability = copy_table(q1.ability),
                config = {
                    center = q1.config.center,
                    center_key = q1.config.center.key
                },
            }, ret)
        ret.ability.quantum_2 =
            Quantum({
                fake_card = true,
                key = q2.config.center.key,
                ability = copy_table(q2.ability),
                config = {
                    center = q2.config.center,
                    center_key = q2.config.center.key
                },
            }, ret)

        update_child_atlas(ret, G.ASSET_ATLAS[ret.ability.quantum_1.config.center.atlas or 'Joker'],
            ret.ability.quantum_1.config.center.pos)
        ret.loaded = true
        --make children smaller
        ret.T.h = ret.T.h * 0.75
        ret.T.w = ret.T.w * 0.75

        ret.children.center.scale_mag = math.min(
            ret.children.center.atlas.px / ret.T.w,
            ret.children.center.atlas.py / ret.T.h
        )

        ret.ability.is_nursery_smalled = true
        return ret
    else
        return old(card, new_card, card_scale, playing_card, strip_edition)
    end
end
