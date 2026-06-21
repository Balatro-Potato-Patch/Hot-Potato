
SMODS.Joker {
    key = "golden_apple",
    config = { extra = { uses_left = 5, bonus_highlight = 1} },
    loc_vars = function (self, info_queue, card)
        local key = self.key
        local append = (card.ability.extra.bonus_highlight == math.floor(card.ability.extra.bonus_highlight)) and "" or "_rounded"
        return { vars = { card.ability.extra.uses_left, card.ability.extra.bonus_highlight }, key = key..append }
    end,
    rarity = 2,
    cost = 5,
    pos = { x = 0, y = 0 },
    hpot_anim = {
        { xrange = { first = 0, last = 11 }, y = 0, t = 0.1 },
        { xrange = { first = 0, last = 3 }, y = 1, t = 0.1 }
    },
    pos_extra = { x = 4, y = 1 },
    hpot_anim_extra = {
        { xrange = { first = 4, last = 11 }, y = 1, t = 0.15 }
    },
    pools = { Food = true },
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'TeamNameAnims1',
    calculate = function (self, card, context)
        if context.using_consumeable and context.consumeable.ability.max_highlighted and not context.blueprint then
            if to_number(card.ability.extra.uses_left - 1) <= 0 then 
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_eaten_ex'),
                    colour = G.C.GOLD
                }
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "uses_left",
                    scalar_table = {mod = 1},
                    scalar_value = "mod",
                    operation = "-",
                    scaling_message = {
                        message = card.ability.uses_left,
                        colour = G.C.GOLD
                    }
                })
            end
        end
    end,
    add_to_deck = function (self, card, from_debuff)
        change_max_highlight(card.ability.extra.bonus_highlight)
    end,
    remove_from_deck = function (self, card, from_debuff)
        change_max_highlight(-card.ability.extra.bonus_highlight)
    end,
    ppu_artist = {"MissingNumber"},
    ppu_coder = {"UnusedParadox"},
    ppu_team = {"Sillyposting"}
}