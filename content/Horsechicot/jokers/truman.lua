SMODS.Joker {
    key = "truman",
    atlas = "hc_jokers",
    pos = { x = 4, y = 3 },
    soul_pos = {x = 4, y = 4},
    rarity = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 20,
    config = {
        extra = { base_mult = 5 },
    },
    ppu_artist = {"pangaea47"},
    ppu_coder = {"Nxkoo"},
    ppu_team = {"Horsechicot"},
    loc_vars = function(self, info_queue, card)
        if not G.jokers or G.SETTINGS.paused then
            return self:collection_loc_vars(info_queue, card)
        end
        local teams = {}
        if not G.jokers then return end
        for i, jkr in pairs(G.jokers.cards) do
            local ppu_team = jkr.config.center.hotpot_credits and jkr.config.center.hotpot_credits.team
            if team then
                for _, real_team in pairs(team) do
                    teams[real_team] = (teams[real_team] or 0) + 1
                end
            end
        end
        local highest_num = -1
        local highest_name
        for team_name, team_count in pairs(teams) do
            if team_count > highest_num then
                highest_num = team_count
                highest_name = team_name
            end
        end
        return {
            vars = {
                card.ability.extra.base_mult,
                highest_num,
                highest_num * card.ability.extra.base_mult,
                highest_name
            }
        }
    end,
    collection_loc_vars = function()
        return {
            vars = {
                5,
                0,
                1,
                "[TEAM]"
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local teams = {}
            for i, jkr in pairs(G.jokers.cards) do
                local ppu_team = jkr.config.center.hotpot_credits and jkr.config.center.hotpot_credits.team
                if team then
                    for _, real_team in pairs(team) do
                        teams[real_team] = (teams[real_team] or 0) + 1
                    end
                end
            end
            local highest_num = -1
            local highest_name
            for team_name, team_count in pairs(teams) do
                if team_count > highest_num then
                    highest_num = team_count
                    highest_name = team_name
                end
            end
            if highest_name == "Horsechicot" and not context.blueprint then
                if pseudorandom('hpot_truman', 1, 2) == 1 then
                    SMODS.destroy_cards({ card })
                end
            end
            if highest_name then
                return {
                    xmult = card.ability.extra.base_mult * highest_num
                }
            end
        end
    end
}
