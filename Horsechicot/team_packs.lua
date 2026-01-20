local allowed_sets = {
    -- Vanilla
    ["Joker"] = true,
    ["Planet"] = true,
    ["Tarot"] = true,
    ["Spectral"] = true,
    ["Voucher"] = true,
    -- HotPot (some of them capitalized some of them not, so add all of them because fuck it)
    ["Hanafuda"] = true,
    ["hanafuda"] = true,
    ["Bottlecap"] = true,
    ["bottlecap"] = true,
    ["Imaginary"] = true,
    ["imaginary"] = true,
    ["Aura"] = true,
    ["Czech"] = true,
}

function get_team_card(team, seed)
    local cards = {}
    for i, v in pairs(G.P_CENTERS) do
        if v.set and allowed_sets[v.set] and not v.hidden and not G.GAME.banned_keys[v.key] and v.hotpot_credits and string.lower(v.hotpot_credits.team[1]) == string.lower(team) and v.rarity ~= 4 then
            cards[#cards+1] = v
        end
    end
    return pseudorandom_element(cards, pseudoseed(seed))
end

function get_teams()
    return {
        "Sillyposting",
        ":)",
        "Perkeocoin",
        "Pissdrawer",
        "Team Name",
        "O!AP",
        "Jtem",
        "Horsechicot"
    }
end

SMODS.Booster {
    name = 'Team Pack',
    key = 'team_normal_1',
    atlas = 'hc_boosters', pos = {x=0,y=0},
    config = { choose = 1, extra = 3, team = "[RANDOM TEAM]" },
    discovered = true,
    cost = 4,
    weight = 0.4,
    kind = 'hpot_team',
    group_key = 'k_hpot_team_pack',
    hotpot_credits = {
        art = {'lord.ruby'},
        code = {'lord.ruby'},
        team = {'Horsechicot'}
    },

    loc_vars = function(self, info_queue, card)
        return{vars={card.ability.choose, card.ability.extra, card.ability.team}, key = self.key:sub(1, -3)}
    end,
    create_card = function(self, card, i)
        local c = get_team_card(card.ability.team, "team_pack")
        if c then
            local newCard = SMODS.create_card{
                key = c.key,
                skip_materialize = true
            }
            return newCard
        end
        return {key = "j_hpot_vremade_joker"}
    end,
    ease_background_colour = function(self)
        ease_background_colour{new_colour = darken(G.C.ORANGE, 0.2), special_colour = G.C.ORANGE, contrast = 5}
    end,
    set_ability = function(self, card)
        card.ability.team = pseudorandom_element(get_teams(), pseudoseed("team_pack"))
    end,
    draw_hand = true,
}

SMODS.Booster {
    name = 'Team Pack',
    key = 'team_jumbo_1',
    atlas = 'hc_boosters', pos = {x=1,y=0},
    config = { choose = 1, extra = 5, team = "[RANDOM TEAM]" },
    discovered = true,
    cost = 6,
    weight = 0.3,
    kind = 'hpot_team',
    group_key = 'k_hpot_team_pack',
    hotpot_credits = {
        art = {'lord.ruby'},
        code = {'lord.ruby'},
        team = {'Horsechicot'}
    },

    loc_vars = function(self, info_queue, card)
        return{vars={card.ability.choose, card.ability.extra, card.ability.team}, key = self.key:sub(1, -3)}
    end,
    create_card = function(self, card, i)
        local c = get_team_card(card.ability.team, "team_pack")
        if c then
            local newCard = SMODS.create_card{
                key = c.key,
                skip_materialize = true
            }
            return newCard
        end
        return {key = "j_hpot_vremade_joker"}
    end,
    ease_background_colour = function(self)
        ease_background_colour{new_colour = darken(G.C.ORANGE, 0.2), special_colour = G.C.ORANGE, contrast = 5}
    end,
    set_ability = function(self, card)
        card.ability.team = pseudorandom_element(get_teams(), pseudoseed("team_pack"))
    end,
    draw_hand = true,
}

SMODS.Booster {
    name = 'Team Pack',
    key = 'team_mega_1',
    atlas = 'hc_boosters', pos = {x=2,y=0},
    config = { choose = 2, extra = 5, team = "[RANDOM TEAM]" },
    discovered = true,
    cost = 8,
    weight = 0.2,
    kind = 'hpot_team',
    group_key = 'k_hpot_team_pack',
    hotpot_credits = {
        art = {'lord.ruby'},
        code = {'lord.ruby'},
        team = {'Horsechicot'}
    },

    loc_vars = function(self, info_queue, card)
        return{vars={card.ability.choose, card.ability.extra, card.ability.team}, key = self.key:sub(1, -3)}
    end,
    create_card = function(self, card, i)
        local c = get_team_card(card.ability.team, "team_pack")
        if c then
            local newCard = SMODS.create_card{
                key = c.key,
                skip_materialize = true
            }
            return newCard
        end
        return {key = "j_hpot_vremade_joker"}
    end,
    ease_background_colour = function(self)
        ease_background_colour{new_colour = darken(G.C.ORANGE, 0.2), special_colour = G.C.ORANGE, contrast = 5}
    end,
    set_ability = function(self, card)
        card.ability.team = pseudorandom_element(get_teams(), pseudoseed("team_pack"))
    end,
    draw_hand = true,
}

SMODS.Booster {
    name = 'Team Pack',
    key = 'team_ultra_1',
    atlas = 'hc_boosters', pos = {x=3,y=0},
    config = { choose = 3, extra = 7, team = "[RANDOM TEAM]" },
    discovered = true,
    cost = 4,
    weight = 0.4,
    kind = 'hpot_team',
    group_key = 'k_hpot_team_pack',
    hotpot_credits = {
        art = {'lord.ruby'},
        code = {'lord.ruby'},
        team = {'Horsechicot'}
    },
    credits = 100,
    loc_vars = function(self, info_queue, card)
        return{vars={card.ability.choose, card.ability.extra, card.ability.team}, key = self.key:sub(1, -3)}
    end,
    create_card = function(self, card, i)
        local c = get_team_card(card.ability.team, "team_pack")
        if c then
            local newCard = SMODS.create_card{
                key = c.key,
                skip_materialize = true
            }
            return newCard
        end
        return {key = "j_hpot_vremade_joker"}
    end,
    ease_background_colour = function(self)
        ease_background_colour{new_colour = darken(G.C.ORANGE, 0.2), special_colour = G.C.ORANGE, contrast = 5}
    end,
    set_ability = function(self, card)
        card.ability.team = pseudorandom_element(get_teams(), pseudoseed("team_pack"))
    end,
    draw_hand = true,
}

--TODO add more team pack variations/sprites
--my original idea for this was to have 1 pack for every team but obviously we are 6th so we have to rely on the last team here