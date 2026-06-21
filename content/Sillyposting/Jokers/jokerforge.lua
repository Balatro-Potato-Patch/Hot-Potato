
SMODS.Joker {
    key = "joker_forge",
    config = { extra = 1},
    blueprint_compat = true,
    rarity = 2,
    cost = 6,
    atlas = "SillypostingJokers",
    pos = { x = 1, y = 0 },
    discovered = true,

    --society if create_card had an options field
    -- there is probably a better way to do this but i just copied the joker code for expansion pack joker from more fluff
    calculate = function(self, card, context)
        if context.setting_blind and not card.getting_sliced and 
           #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            
            local jokers_to_create = math.min(card.ability.extra, 
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            
            local vanilla_jokers = {
                "j_joker", "j_jolly", "j_greedy_joker", "j_lusty_joker", "j_wrathful_joker", "j_gluttenous_joker",
                "j_zany", "j_mad", "j_crazy", "j_droll", "j_sly", "j_wily", "j_clever", "j_devious",
                "j_crafty", "j_half", "j_stencil", "j_four_fingers", "j_mime", "j_credit_card",
                "j_ceremonial", "j_banner", "j_mystic_summit", "j_marble", "j_loyalty_card", "j_8_ball",
                "j_misprint", "j_dusk", "j_raised_fist", "j_chaos", "j_fibonacci", "j_steel_joker",
                "j_scary_face", "j_abstract", "j_delayed_grat", "j_hack", "j_pareidolia", "j_gros_michel",
                "j_even_steven", "j_odd_todd", "j_scholar", "j_business", "j_supernova", "j_ride_the_bus",
                "j_space", "j_egg", "j_burglar", "j_blackboard", "j_runner", "j_ice_cream", "j_dna",
                "j_splash", "j_blue_joker", "j_sixth_sense", "j_constellation", "j_hiker", "j_faceless",
                "j_green_joker", "j_superposition", "j_todo_list", "j_cavendish", "j_card_sharp",
                "j_red_card", "j_madness", "j_square", "j_seance", "j_riff_raff", "j_vampire",
                "j_shortcut", "j_hologram", "j_vagabond", "j_baron", "j_cloud_9", "j_rocket",
                "j_obelisk", "j_midas_mask", "j_luchador", "j_photograph", "j_gift", "j_turtle_bean",
                "j_erosion", "j_reserved_parking", "j_mail", "j_to_the_moon", "j_hallucination",
                "j_fortune_teller", "j_juggler", "j_drunkard", "j_stone", "j_golden", "j_lucky_cat",
                "j_baseball", "j_bull", "j_diet_cola", "j_trading", "j_flash", "j_popcorn",
                "j_trousers", "j_ancient", "j_ramen", "j_walkie_talkie", "j_selzer", "j_castle",
                "j_smiley", "j_campfire", "j_ticket", "j_mr_bones", "j_acrobat", "j_sock_and_buskin",
                "j_swashbuckler", "j_troubadour", "j_certificate", "j_smeared", "j_throwback",
                "j_hanging_chad", "j_rough_gem", "j_bloodstone", "j_arrowhead", "j_onyx_agate",
                "j_glass", "j_ring_master", "j_flower_pot", "j_blueprint", "j_wee", "j_merry_andy",
                "j_oops", "j_idol", "j_seeing_double", "j_matador", "j_hit_the_road", "j_duo",
                "j_trio", "j_family", "j_order", "j_tribe", "j_stuntman", "j_invisible",
                "j_brainstorm", "j_satellite", "j_shoot_the_moon", "j_drivers_license",
                "j_cartomancer", "j_astronomer", "j_burnt", "j_bootstraps", "j_caino",
                "j_triboulet", "j_yorick", "j_chicot", "j_perkeo"
            }
            
            local function temp_ban_joker(key)
                if not G.GAME.banned_keys[key] then
                    G.GAME.banned_keys[key] = 214389
                elseif G.GAME.banned_keys[key] == true then
                    G.GAME.banned_keys[key] = 214389
                elseif G.GAME.banned_keys[key] % 214389 == 0 then
                    G.GAME.banned_keys[key] = G.GAME.banned_keys[key] + 214389
                end
            end
            
            local function temp_unban_joker(key)
                if G.GAME.banned_keys[key] == 214389 then
                    G.GAME.banned_keys[key] = nil
                elseif G.GAME.banned_keys[key] and G.GAME.banned_keys[key] % 214389 == 0 then
                    G.GAME.banned_keys[key] = G.GAME.banned_keys[key] - 214389
                end
            end
            
            for i = 1, #vanilla_jokers do
                temp_ban_joker(vanilla_jokers[i])
            end
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, jokers_to_create do
                        local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'expansion')
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                        new_card:start_materialize()
                    end
                    G.GAME.joker_buffer = 0
                    
                    for i = 1, #vanilla_jokers do
                        temp_unban_joker(vanilla_jokers[i])
                    end
                    return true
                end
            }))
            
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = localize('k_plus_joker'), 
                colour = G.C.BLUE
            })
        end
    end,

    ppu_artist = {"Jaydchw"},
    ppu_coder = {"Jaydchw"},
    ppu_team = {"Sillyposting"},

}