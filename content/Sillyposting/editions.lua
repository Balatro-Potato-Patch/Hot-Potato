SMODS.Shader {
    key = "psychedelic",
    path = "psychedelic.fs"
}

SMODS.Edition { --doesnt have unique sound yet!
    key = "psychedelic",
    shader = "psychedelic",
    config = { odds = 3 },
    weight = 3,
    extra_cost = 5,
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, (card.edition or self.config).odds, "hpot_psych")
        return { vars = { numerator, denominator } }
    end,
    calculate = function (self, card, context)
        if context.before and context.main_eval and SMODS.pseudorandom_probability(card, "hpot_psych", 1, (card.edition or self.config).odds ) then
            return {
                level_up = true,
                message = localize("k_upgrade_ex"),
                colour = G.C.DARK_EDITION
            }
        end
    end,
    ppu_artist = {"Supernova"},
    ppu_coder = {"Eris"},
    ppu_team = {"Sillyposting"}
}
