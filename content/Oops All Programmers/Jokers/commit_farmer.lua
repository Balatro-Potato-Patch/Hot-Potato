SMODS.Joker {
    key = "commit_farmer",
    rarity = 3,
    blueprint_compat = true,
    cost = 8,
    config = {
        extra = {
            commits = {
                perkeocoin = 275,
                sillyposting = 97,
                jtem = 255,
                ["team name"] = 307,
                ["team :)"] = 16,
                horsechicot = 540,
                ["oops! all programmers"] = 145,
                pissdrawer = 208
            },
            xmult_base = 1,
            xmult_inc = 0.01
        }
    },
    atlas = "oap_jokers",
    pos = { x = 4, y = 0 },
    attributes = { 'xmult' },
    loc_vars = function(self, info_queue, card)
        local team = G.GAME.current_round.hpot_commit_farmer_team or "Sillyposting"
        local commits = card.ability.extra.commits[team:lower()] or 0
        local xmult = card.ability.extra.xmult_inc * commits + card.ability.extra.xmult_base
        return { vars = { card.ability.extra.xmult_inc, team, xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult_inc *
                    (card.ability.extra.commits[G.GAME.current_round.hpot_commit_farmer_team:lower()] or 0) +
                    card.ability.extra.xmult_base
            }
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'trif' },
    ppu_team = { 'OAP' }
}
function reset_commit_farmer()
    G.GAME.current_round.hpot_commit_farmer_ppu_team = G.GAME.current_round.hpot_commit_farmer_team or "Sillyposting"
    local teams = {}
    for k, v in ipairs({ "Perkeocoin", "Sillyposting", "Jtem", "Team Name", "Team :)", "Horsechicot", "Oops! All Programmers", "PissDrawer" }) do
        if v ~= G.GAME.current_round.hpot_commit_farmer_team then
            teams[#teams + 1] = v
        end
    end
    local team = pseudorandom_element(teams, "commit_farmer_" .. G.GAME.round_resets.ante)
    G.GAME.current_round.hpot_commit_farmer_ppu_team = team
end
