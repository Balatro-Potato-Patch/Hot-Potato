PotatoPatchUtils.Team {
    name = 'Sillyposting',
    colour = HEX('77269b')
}

-- There wasn't a better spot for me to put this - Astra
SMODS.Atlas({ key = "SillypostingCredits", path = "Sillyposting/SillypostingCreditsCards.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }):register()

local update_consumable = function(card)
    if card.ability and type(card.ability) == "table" then
        if card.ability.consumeable and card.ability.consumeable.max_highlighted then
            card.ability.consumeable.og_max_highlighted = card.ability.consumeable.og_max_highlighted or card.ability.consumeable.max_highlighted
            card.ability.consumeable.max_highlighted = card.ability.consumeable.og_max_highlighted + G.GAME.max_highlighted_mod
            if card.ability.consumeable.max_highlighted < 1 then card.ability.consumeable.max_highlighted = 1 end
        end
        if card.ability.extra and type(card.ability.extra) == "table" then
            if card.ability.extra.max_highlighted then
                card.ability.extra.og_max_highlighted = card.ability.extra.og_max_highlighted or card.ability.extra.max_highlighted
                card.ability.extra.max_highlighted = card.ability.extra.og_max_highlighted + G.GAME.max_highlighted_mod
                if card.ability.extra.max_highlighted < 1 then card.ability.extra.max_highlighted = 1 end
            end
        end
        if card.ability.max_highlighted then
            card.ability.og_max_highlighted = card.ability.og_max_highlighted or card.ability.max_highlighted
            card.ability.max_highlighted = card.ability.og_max_highlighted + G.GAME.max_highlighted_mod
            if card.ability.max_highlighted < 1 then card.ability.max_highlighted = 1 end
        end
    end
    return card
end
create_card_ref = create_card
function create_card(...)
    local card = create_card_ref(...)
    return update_consumable(card)
end
function change_max_highlight(amount) --modifies the max_highlighted_mod variable and updates all existing consumables automatically
    if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit - G.GAME.max_highlighted_mod
    end
    G.GAME.max_highlighted_mod = (G.GAME.max_highlighted_mod or 0) + amount
    if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit + G.GAME.max_highlighted_mod
    end
    for _, card in pairs(G.I.CARD) do
        update_consumable(card)
    end
end
local update_ref = Game.update
function Game:update(dt)
    local ret = update_ref(self, dt)
    for _, card in pairs(G.I.CARD) do
        if G.GAME and G.GAME.max_highlighted_mod and type(card) == "table" and type(card.area) == "table" and type(card.area.config) == "table" and card.area.config.collection then update_consumable(card) end
    end
    return ret
end
function init_sillyposting(game)
  game.max_highlighted_mod = game.max_highlighted_mod or 0
  game.current_round.cryptocurrency = game.current_round.cryptocurrency or 0 -- this is horsechicots but fuck it
end
-- Below this line is a series of take_ownerships made to ensure every consumable works properly with Wizard Tower
--#region Take ownership maxhighlight stuff
local usage_check_consumable = function(self, card)
    return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
end
--#region Tarots
local enhancement_tarot_use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true
        end
    }))
    for i = 1, #G.hand.highlighted do
        local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.highlighted[i]:flip()
                play_sound('card1', percent)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    delay(0.2)
    for i = 1, #G.hand.highlighted do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                G.hand.highlighted[i]:set_ability(G.P_CENTERS[card.ability.mod_conv])
                return true
            end
        }))
    end
    for i = 1, #G.hand.highlighted do
        local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.highlighted[i]:flip()
                play_sound('tarot2', percent, 0.6)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            G.hand:unhighlight_all()
            return true
        end
    }))
    delay(0.5)
end
SMODS.Consumable:take_ownership('magician',
    {
    config = { max_highlighted = 2, mod_conv = 'm_lucky' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -1 then
            key = key .. "_s"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('empress',
    {
    config = { max_highlighted = 2, mod_conv = 'm_mult' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -1 then
            key = key .. "_s"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('heirophant',
    {
    config = { max_highlighted = 2, mod_conv = 'm_bonus' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -1 then
            key = key .. "_s"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('lovers',
    {
    config = { max_highlighted = 1, mod_conv = 'm_wild' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('chariot',
    {
    config = { max_highlighted = 1, mod_conv = 'm_steel' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('justice',
    {
    config = { max_highlighted = 1, mod_conv = 'm_glass' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('strength',
    {
    config = { max_highlighted = 2 },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -1 then
            key = key .. "_s"
        end
        return { key = key, vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    -- SMODS.modify_rank will increment/decrement a given card's rank by a given amount
                    assert(SMODS.modify_rank(G.hand.highlighted[i], 1))
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('hanged_man',
    {
    config = { max_highlighted = 2 },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -1 then
            key = key .. "_s"
        end
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                SMODS.destroy_cards(G.hand.highlighted)
                return true
            end
        }))
        delay(0.3)
    end,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('death',
    {
    config = { max_highlighted = 2 }, -- used as exact amount of cards to higlight
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        if card.ability.max_highlighted >= 3 then
            info_queue[#info_queue + 1] = { set = "Other", key = "hpot_death_clarification_plus"}
            if G.hand then
                if (#G.hand.cards >= 1) then
                    if math.floor(card.ability.max_highlighted) > #G.hand.cards then
                        info_queue[#info_queue + 1] = { set = "Other", key = "hpot_death_clarification_big"}
                    end
                elseif math.floor(card.ability.max_highlighted) > math.floor(G.hand.config.card_limit) then
                    info_queue[#info_queue + 1] = { set = "Other", key = "hpot_death_clarification_big"}
                end
            end
        elseif card.ability.max_highlighted <= 1 then
            key = key .. "_s"
            info_queue[#info_queue + 1] = { set = "Other", key = "hpot_death_clarification_minus"}
        end
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
   use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        local rightmost = G.hand.highlighted[1]
        for i = 1, #G.hand.highlighted do
            if G.hand.highlighted[i].T.x > rightmost.T.x then
                rightmost = G.hand.highlighted[i]
            end
        end
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if G.hand.highlighted[i] ~= rightmost then
                        copy_card(rightmost, G.hand.highlighted[i])
                    end
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and (#G.hand.highlighted == math.floor(card.ability.max_highlighted) or #G.hand.highlighted == #G.hand.cards)
    end
    }
, true)
SMODS.Consumable:take_ownership('devil',
    {
    config = { max_highlighted = 1, mod_conv = 'm_gold' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('tower',
    {
    config = { max_highlighted = 1, mod_conv = 'm_stone' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { key = key, vars = { card.ability.max_highlighted,
        localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = enhancement_tarot_use,
    can_use = usage_check_consumable
    }
, true)
local suit_tarot_use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true
        end
    }))
    for i = 1, #G.hand.highlighted do
        local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.highlighted[i]:flip()
                play_sound('card1', percent)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    delay(0.2)
    for i = 1, #G.hand.highlighted do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                SMODS.change_base(G.hand.highlighted[i], card.ability.suit_conv)
                return true
            end
        }))
    end
    for i = 1, #G.hand.highlighted do
        local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.highlighted[i]:flip()
                play_sound('tarot2', percent, 0.6)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            G.hand:unhighlight_all()
            return true
        end
    }))
    delay(0.5)
end
SMODS.Consumable:take_ownership('star',
    {
    config = { max_highlighted = 3, suit_conv = 'Diamonds' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -2 then
            key = key .. "_s"
        end
        return { key = key, vars = { card.ability.max_highlighted,
        localize(card.ability.suit_conv, 'suits_plural'),
        colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
    use = suit_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('moon',
    {
    config = { max_highlighted = 3, suit_conv = 'Clubs' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -2 then
            key = key .. "_s"
        end
        return { key = key, vars = { card.ability.max_highlighted,
        localize(card.ability.suit_conv, 'suits_plural'),
        colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
    use = suit_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('sun',
    {
    config = { max_highlighted = 3, suit_conv = 'Hearts' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -2 then
            key = key .. "_s"
        end
        return { key = key, vars = { card.ability.max_highlighted,
        localize(card.ability.suit_conv, 'suits_plural'),
        colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
    use = suit_tarot_use,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('world',
    {
    config = { max_highlighted = 3, suit_conv = 'Spades' },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if to_number(G.GAME.max_highlighted_mod or 0) <= -2 then
            key = key .. "_s"
        end
        return { key = key, vars = { card.ability.max_highlighted,
        localize(card.ability.suit_conv, 'suits_plural'),
        colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
    use = suit_tarot_use,
    can_use = usage_check_consumable
    }
, true)
--#endregion
--#endregion
--#region Spectrals
SMODS.Consumable:take_ownership('talisman',
    {
    config = { extra = { seal = 'Gold' }, max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { key = key, vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for _, v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                        v:set_seal(card.ability.extra.seal, nil, true)
                    return true
                end
            }))
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('aura',
    {
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
        return { key = key, vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        for _, v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                        local edition = poll_edition('aura', nil, true, true,
                            { 'e_polychrome', 'e_holo', 'e_foil' })
                        v:set_edition(edition, true)
                        card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('deja_vu',
    {
    config = { extra = { seal = 'Red' }, max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { key = key, vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for _, v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                        v:set_seal(card.ability.extra.seal, nil, true)
                    return true
                end
            }))
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('trance',
    {
    config = { extra = { seal = 'Blue' }, max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { key = key, vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for _, v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                        v:set_seal(card.ability.extra.seal, nil, true)
                    return true
                end
            }))
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('medium',
    {
    config = { extra = { seal = 'Purple' }, max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { key = key, vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for _, v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                        v:set_seal(card.ability.extra.seal, nil, true)
                    return true
                end
            }))
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
    can_use = usage_check_consumable
    }
, true)
SMODS.Consumable:take_ownership('cryptid',
    {
    config = { max_highlighted = 1, extra = { cards = 2 } },
    loc_vars = function(self, info_queue, card)
        local key = self.key .. "_v2"
        if G.GAME.max_highlighted_mod and to_number(G.GAME.max_highlighted_mod) > 0 then
            key = key .. "_p"
        end
        return { key = key, vars = { card.ability.extra.cards, card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                local _first_dissolve = nil
                local new_cards = {}
                for _, v in ipairs(G.hand.highlighted) do
                    for i = 1, card.ability.extra.cards do
                        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                        local _card = copy_card(v, nil, nil, G.playing_card)
                        _card:add_to_deck()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, _card)
                        G.hand:emplace(_card)
                        _card:start_materialize(nil, _first_dissolve)
                        _first_dissolve = true
                        new_cards[#new_cards + 1] = _card
                    end
                end
                SMODS.calculate_context({ playing_card_added = true, cards = new_cards })
                return true
            end
        }))
    end,
    can_use = usage_check_consumable
    }
, true)
--#endregion
--#endregion
