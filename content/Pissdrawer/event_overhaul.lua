-- TODO: maybe make these an SMODS object.
HotPotato.EventDomainPool = {
    { key = "combat",      weight = 1,    colour = G.C.RED,                        reward_text_amount = 1 },
    { key = "occurence",   weight = 1,    colour = G.C.PURPLE,                     reward_text_amount = 1 },
    { key = "encounter",   weight = 0.7,  colour = darken(G.C.RED, 0.2),           reward_text_amount = 2 },
    { key = "transaction", weight = 0.5,  colour = G.C.GREEN,                      reward_text_amount = 2 },
    { key = "reward",      weight = 0.4,  colour = G.C.HPOT_PINK or HEX("fe89d0"), rare = true,           reward_text_amount = 3 },
    { key = "adventure",   weight = 0.2,  colour = G.C.ORANGE,                     rare = true,           reward_text_amount = 4 },
    { key = "wealth",      weight = 0.2,  colour = G.C.MONEY,                      rare = true,           reward_text_amount = 4 },
    { key = "escapade",    weight = 0.01, colour = HEX("A17CFF"),                  rare = true,           once_per_run = true,   reward_text_amount = 5 },
    {
        key = "respite",
        weight = 0,
        colour = G.C.GREEN,
        reward_text_amount = 2
    },
    --toma reformats her event tables because she's a rebellious bitch and everyone loves her
    {
        key = "aroombetween",
        weight = 0.0666666666666666666666666666666,
        colour = HEX("DE2041"),
        rare = true,
        once_per_run = true,
        no_collection = true
    },
    {
        key = "swoon",
        weight = 0.05,
        colour = G.C.RED,
        rare = true,
        once_per_run = true,
        no_collection = true
    },
}

HotPotato.EventDomains = {}
G.C.HPOT_EVENTS = {}

-- TODO: do this on initialization instead for crossmod stuff
for _, domain in ipairs(HotPotato.EventDomainPool) do
    HotPotato.EventDomains[domain.key] = domain
    G.C.HPOT_EVENTS[domain.key] = domain.colour
    G.ARGS.LOC_COLOURS["hpot_event_" .. domain.key] = domain.colour
end

function hpot_event_domain_add_to_pool(domain, args)
    local args = args or {}
    local domain = type(domain) == "string" and HotPotato.EventDomains[domain] or domain

    if type(domain) ~= "table" then
        return false
    end

    local add, pool_opts = true, {}

    if type(domain.in_pool) == "function" then
        add, pool_opts = domain:in_pool(args)
        pool_opts = pool_opts or {}
    end

    local allow_duplicates = args.allow_duplicates or pool_opts.allow_duplicates

    if domain.once_per_run and not args.ignore_once_per_run
        and G.GAME.hpot_event_domains_this_run and G.GAME.hpot_event_domains_this_run[domain.key] then
        return false
    end

    return add and
        (allow_duplicates or not (G.GAME.hpot_event_domain_choices_used or {})[domain.key])
end

function hpot_event_get_domain_pool(args)
    local args = args or {}
    local options = args.options or HotPotato.EventDomainPool
    local pool = {}

    for _, domain in ipairs(options) do
        if hpot_event_domain_add_to_pool(domain, args) then
            pool[#pool + 1] = type(domain) == "string" and HotPotato.EventDomains[domain] or domain
        end
    end

    if #pool == 0 then
        pool[#pool + 1] = HotPotato.EventDomains.occurence
    end

    return pool
end

function hpot_event_get_domain_weight(domain, args)
    local args = args or {}
    local domain = type(domain) == "string" and HotPotato.EventDomains[domain] or domain

    local weight = type(domain.get_weight) == "function" and domain:get_weight(args) or domain.weight or 1

    if domain.rare and next(SMODS.find_card("j_hpot_ruan_mei")) then
        weight = weight * 2
    end

    return weight
end

function hpot_event_get_event_domain(args)
    local args = args or {}

    if not args.ignore_respite and (G.GAME.round_resets.ante) % G.GAME.win_ante == 0
        and G.GAME.round_resets.blind.key == "bl_big" then
        return "respite"
    end

    local options = hpot_event_get_domain_pool(args)

    local total_weight = 0

    for _, domain in ipairs(options) do
        local weight = type(domain.get_weight) == "function" and domain:get_weight(args) or domain.weight or 1
        total_weight = total_weight + weight
    end

    local domain_poll = pseudorandom(args.key or 'hpot_domain_generic')
    local weight_i = 0
    for _, domain in ipairs(options) do
        local weight = type(domain.get_weight) == "function" and domain:get_weight(args) or domain.weight or 1
        weight_i = weight_i + weight
        if domain_poll > 1 - (weight_i / total_weight) then
            return domain.key
        end
    end
end

function hpot_event_get_event_count(args)
    local args = args or {}
    if not args.ignore_respite and (G.GAME.round_resets.ante) % G.GAME.win_ante == 0
        and G.GAME.round_resets.blind.key == "bl_big" then
        return 1
    end
    if next(SMODS.find_card("j_hpot_local_newspaper")) then
        return 3
    end
    return 2
end

-- TODO: test any weird blind choice cases or, better yet, PR SMODS a better blind tracker
function hpot_event_can_appear(blind_prototype)
    if G.GAME.hpot_event_enable_all_blinds or type(blind_prototype) ~= "table" then return true end
    if (G.GAME.round_resets.ante) % G.GAME.win_ante == 0 and blind_prototype.key == "bl_big" then
        return true
    end
    if blind_prototype.key == "bl_big" and G.GAME.hpot_event_enable_big_blind then
        return true
    end
    if blind_prototype.key == "bl_small" and G.GAME.hpot_event_enable_small_blind then
        return true
    end
    return not not blind_prototype.boss
end

--- Event Cards

-- Local Newspaper
SMODS.Joker {
    key = 'local_newspaper',
    rarity = 2,
    cost = 6,
    atlas = "pdr_joker",
    pos = { x = 1, y = 0 },
    ppu_artist = { 'Tacashumi' },
    ppu_coder = { "N'" },
    ppu_team = { 'Pissdrawer' }
}

-- Ruan Mei
SMODS.Joker {
    key = 'ruan_mei',
    rarity = 3,
    cost = 8,
    atlas = "pdr_joker",
    pos = { x = 3, y = 1 },
    ppu_artist = { 'BepisFever' },
    ppu_coder = { "N'" },
    ppu_team = { 'Pissdrawer' }
}

-- Domain Extrapolation
SMODS.Voucher {
    key = 'domain_extrapolation',
    pos = { x = 0, y = 0 },
    atlas = 'pdr_vouchers',
    ppu_artist = { 'SDM_0' },
    ppu_coder = { "N'" },
    ppu_team = { 'Pissdrawer' },
    redeem = function(self, voucher)
        G.GAME.hpot_event_enable_big_blind = true
    end
}

-- Domain Expansion
SMODS.Voucher {
    key = 'domain_expansion',
    requires = { "v_hpot_domain_extrapolation" },
    pos = { x = 0, y = 1 },
    atlas = 'pdr_vouchers',
    ppu_artist = { 'SDM_0' },
    ppu_coder = { "N'" },
    ppu_team = { 'Pissdrawer' },
    redeem = function(self, voucher)
        G.GAME.hpot_event_enable_all_blinds = true
    end
}

--#region Combat

-- based on Bonus Blinds <3
function hpot_event_bonus_new_round(blind_key, extra_config)
    G.RESET_JIGGLES = nil
    delay(0.4)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
            G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
            G.GAME.current_round.hands_played = 0
            G.GAME.current_round.discards_used = 0
            G.GAME.current_round.reroll_cost_increase = 0
            G.GAME.current_round.used_packs = {}

            for k, v in pairs(G.GAME.hands) do
                v.played_this_round = 0
            end

            for k, v in pairs(G.playing_cards) do
                v.ability.wheel_flipped = nil
            end

            G.GAME.round_bonus.next_hands = 0
            G.GAME.round_bonus.discards = 0

            local blhash = 'S'
            G.GAME.subhash = (G.GAME.round_resets.ante) .. (blhash)

            G.GAME.blind_on_deck = 'Combat'
            G.GAME.blind:set_blind(G.P_BLINDS[blind_key])
            G.GAME.blind.effect.hpot_combat_bonus = extra_config or {}
            for _, v in ipairs(G.playing_cards) do
                SMODS.recalc_debuff(v)
            end
            for _, v in ipairs(G.jokers.cards) do
                SMODS.recalc_debuff(v)
            end
            G.GAME.last_blind.boss = nil
            G.HUD_blind.alignment.offset.y = -10
            G.HUD_blind:recalculate(false)

            SMODS.calculate_context({ setting_blind = true, blind = G.P_BLINDS[blind_key] })
            delay(0.4)

            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.STATE = G.STATES.DRAW_TO_HAND
                    G.deck:shuffle('hpot_nr' .. G.GAME.round_resets.ante)
                    G.deck:hard_set_T()
                    G.STATE_COMPLETE = false
                    return true
                end
            }))
            return true
        end
    }))
end

function hpot_event_start_combat(key, override_blind, extra_config)
    if HotPotato.CombatEvents[key] then
        hpot_event_end_scenario(true)
        G.GAME.hpot_combat_event = key
        hpot_event_bonus_new_round(override_blind or HotPotato.CombatEvents[key].blind_key, extra_config)
    else
        hpot_event_end_scenario()
    end
end

local blind_defeat_ref = Blind.defeat
function Blind:defeat(silent)
    blind_defeat_ref(self, silent)
    if G.GAME.hpot_combat_event then
        if type(HotPotato.CombatEvents[G.GAME.hpot_combat_event].defeat) == "function" then
            HotPotato.CombatEvents[G.GAME.hpot_combat_event]:defeat()
            if MP and MP.GAME then       
                MP.GAME.round_ended = true
            end
        end
    end
end

--#endregion

--#region UI

function event_collection_domains_ui()
    local custom_gameobject_tabs = { {} }
    local curr_height = 0
    local curr_col = 1
    local object_tabs = {}
    for _, domain in ipairs(HotPotato.EventDomainPool) do
        if not domain.no_collection then
            local loc_name = localize({
                type = "name_text",
                key = "hpot_event_encounter" ..
                    (domain.key and ("_" .. domain.key) or ""),
                set = "Other"
            })

            local chosen = { key = domain.key or "occurence" }

            object_tabs[#object_tabs + 1] = UIBox_button({
                button = 'your_collection_hpot_events_domain',
                label = { loc_name },
                minw = 3,
                colour = domain.colour,
                ref_table = chosen
            })
        end
    end
    local custom_gameobject_rows = {}
    if #object_tabs > 0 then
        for _, gameobject_tabs in ipairs(object_tabs) do
            table.insert(custom_gameobject_tabs[curr_col], gameobject_tabs)
            curr_height = curr_height + gameobject_tabs.nodes[1].config.minh
            if curr_height > 2 then
                curr_height = 0
                curr_col = curr_col + 1
                custom_gameobject_tabs[curr_col] = {}
            end
        end
        for _, v in ipairs(custom_gameobject_tabs) do
            table.insert(custom_gameobject_rows, { n = G.UIT.C, config = { align = "cm", padding = 0.15 }, nodes = v })
        end

        local t = {
            n = G.UIT.C,
            config = { align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05, minw = 7 },
            nodes = {
                { n = G.UIT.R, config = { align = "cm", padding = 0.15 }, nodes = custom_gameobject_rows }
            }
        }

        return create_UIBox_generic_options({
            colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_colour or
                (G.ACTIVE_MOD_UI.ui_config or {}).colour),
            bg_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_bg_colour or
                (G.ACTIVE_MOD_UI.ui_config or {}).bg_colour),
            back_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_back_colour or
                (G.ACTIVE_MOD_UI.ui_config or {}).back_colour),
            outline_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_outline_colour or
                (G.ACTIVE_MOD_UI.ui_config or {}).outline_colour),
            back_func = 'your_collection_other_gameobjects',
            contents = { t }
        })
    end
end

local old_update = Game.update
function Game:update(...)
    if MP and MP.GAME and G.GAME and G.GAME.hpot_combat_event then
        MP.GAME.round_ended = false
        MP.GAME.prevent_eval = false
    end
    return old_update(self, ...)
end

--#endregion
