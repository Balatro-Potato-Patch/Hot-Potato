SMODS.Joker {
    key = 'charlie',
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    config = {
        extra = {
            mult = 8
        }
    },
    atlas = "oap_jokers",
    pos = { x = 0, y = 0 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.active = true
        end
        if context.after then
            card.ability.extra.active = false
        end
        if card.ability.extra.active and context.post_trigger and context.other_card and context.other_card.config and context.other_card.config.center_key ~= "j_hpot_melvin" and not context.blueprint_card then
            if context.other_ret and context.other_ret.jokers and
                (type(context.other_ret.jokers) == "table" and context.other_ret.jokers.chips and context.other_ret.jokers.chips ~= 0)
                or (type(context.other_ret.jokers) == "table" and context.other_ret.jokers.chip_mod and context.other_ret.jokers.chip_mod ~= 0) then
                return {
                    func = function()
                        SMODS.calculate_effect {
                            card = card,
                            mult = card.ability.extra.mult
                        }
                        return true
                    end
                }
            end
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'trif' },
    ppu_team = { 'OAP' }
}


SMODS.Joker {
    key = 'melvin',
    rarity = 1,
    cost = 5,
    config = {
        extra = {
            chips = 30,
        }
    },
    atlas = "oap_jokers",
    pos = { x = 1, y = 0 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.active = true
        end
        if context.after then
            card.ability.extra.active = false
        end
        if card.ability.extra.active and context.post_trigger and context.other_card and context.other_card.config and context.other_card.config.center_key ~= "j_hpot_charlie" and not context.blueprint_card then
            if context.other_ret and context.other_ret.jokers and (type(context.other_ret.jokers) == "table" and context.other_ret.jokers.mult and context.other_ret.jokers.mult ~= 0)
                or (type(context.other_ret.jokers) == "table" and context.other_ret.jokers.mult_mod and context.other_ret.jokers.mult_mod ~= 0) then
                return {
                    func = function()
                        SMODS.calculate_effect {
                            card = card,
                            chips = card.ability.extra.chips
                        }
                        return true
                    end
                }
            end
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'trif' },
    ppu_team = { 'OAP' }
}
