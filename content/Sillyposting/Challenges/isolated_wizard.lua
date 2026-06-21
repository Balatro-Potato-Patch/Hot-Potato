SMODS.Challenge {
    key = 'isolated_wizard',
    rules = {
        custom = {
            { id = 'no_shop_jokers' }
        }
    },
    jokers = {
        { id = 'j_hpot_wizard_tower', eternal = true },
        { id = 'j_cartomancer',  eternal = true }
    },
    vouchers = {
        { id = 'v_crystal_ball' },
        { id = "v_tarot_merchant" }
    },
    restrictions = {
        banned_cards = {
            { id = 'c_judgement' },
            { id = 'c_wraith' },
            { id = 'c_soul' },
            { id = 'c_hpot_cod_account' },
            { id = 'c_hpot_sacrifice' },
            { id = 'c_hpot_cap_anti_joker' },
            { id = 'c_hpot_cap_joker' },
            { id = 'c_hpot_tenacity' },
            { id = 'p_buffoon_normal_1', ids = {
                'p_buffoon_normal_1', 'p_buffoon_normal_2', 'p_buffoon_jumbo_1', 'p_buffoon_mega_1', 'p_hpot_ultra_buffoon_1',
            }
            },
            { id = 'p_hpot_team_normal_1', ids = {
                'p_hpot_team_normal_1', 'p_hpot_team_jumbo_1', 'p_hpot_team_mega_1', 'p_hpot_team_ultra_1',
            }
            },
            { id = 'v_hpot_antibodies' },
            { id = 'v_hpot_vaccination' },
            { id = 'v_hpot_hc_underground_control' },
            { id = 'v_hpot_right_at_your_door' },
            { id = 'v_hpot_cargo_size_upgrade' },
            { id = 'v_hpot_delivery_fleet_upgrade' },
        },
        banned_tags = {
            { id = 'tag_uncommon' },
            { id = 'tag_rare' },
            { id = 'tag_negative' },
            { id = 'tag_foil' },
            { id = 'tag_holographic' },
            { id = 'tag_polychrome' },
            { id = 'tag_buffoon' },
            { id = 'tag_top_up' },
            { id = "tag_hpot_psychedelic_tag" },
            { id = "tag_hpot_phantasmic" }
        },
        banned_other = {
            { id = 'bl_final_heart', type = 'blind' },
            { id = 'bl_final_leaf',  type = 'blind' },
            { id = 'bl_final_acorn', type = 'blind' },
            { id = 'bl_hpot_holed', type = 'blind' },
        }
    }
}