SMODS.Atlas({key = "capatlas", path = "PerkeoCards/bottlecaps.png", px = 34, py = 34, atlas_table = "ASSET_ATLAS"}):register()

SMODS.ConsumableType {
    key = "bottlecap",
    primary_colour = HEX("EEEEEE"),
    secondary_colour = HEX("9ec961"),
    collection_row = {5, 5},
    shop_rate = 0,
    default = "c_hpot_cap_money",
}

SMODS.ObjectType { --dummy pools for bottlecaps per valid rarity 
    key = 'bottlecap_Common',
    default = "c_hpot_cap_money"
}
SMODS.ObjectType {
    key = 'bottlecap_Uncommon',
    default = "c_hpot_cap_money"
}
SMODS.ObjectType {
    key = 'bottlecap_Rare',
    default = "c_hpot_cap_money"
}
--added by horsechicot
SMODS.ObjectType {
    key = 'bottlecap_Legendary',
    default = "c_hpot_cap_money"
}
SMODS.ObjectType {
    key = 'bottlecap_Bad',
    default = "c_hpot_cap_money"
}

--[[
Wanna add your own bottlecaps to the plinko game? Here's what you need to know!

In the extra table, you should have a value for each of the valid rarities for that bottlecap, indexed by string
For example, a bottlecap that only has an Uncommon and a Rare effect will have:
['Uncommon'] = value1,
['Rare'] = value2

Importantly, make sure to have extra.chosen be a string that corresponds to one of the valid rarities for that bottlecap, such as:
chosen = 'Uncommon'

In the use function, do a check identical to the can_use function first, since card:use() is called manually by the plinko. You can put a Nope! in there for if the check fails.
Then, have your payout effect based on card.ability.extra[card.ability.extra.chosen], as the plinko will set chosen to the correct rarity when it's created

To get the bottlecap into the correct rarity pools, use the pools of the ObjectTypes above this. Notice how cap_money and cap_edition have different pools!

You can create a random bottlecap of a specific rarity using these pools as well, with SMODS.create_card{set = 'bottlecap_Common'} or whichever rarity.
However, note that you will have to manually set the chosen rarity once it's created, or else it'll stick to whatever chosen is defaulted to
]]

HotPotato.bottlecap_badges = function(self, card, badges)
    local color = G.C.BLUE
    if card.ability.extra.chosen == 'Uncommon' then
        color = G.C.GREEN
    elseif card.ability.extra.chosen == 'Rare' then
        color = G.C.RED
    elseif card.ability.extra.chosen == 'Legendary' then
        color = G.C.PURPLE
    elseif card.ability.extra.chosen == 'Bad' then
        color = G.C.BLACK
    end
    badges[#badges+1] = create_badge(localize("k_"..string.lower(card.ability.extra.chosen)), color, G.C.WHITE, 1 )
end

local function nope(card)
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
        attention_text({
            text = localize('k_nope_ex'),
            scale = 1.3, 
            hold = 1.4,
            major = card.cap_parent or card,
            backdrop_colour = G.C.SECONDARY_SET.Tarot,
            align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
            offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
            silent = true
            })
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                play_sound('tarot2', 0.76, 0.4);return true end}))
            play_sound('tarot2', 1, 0.4)
            card:juice_up(0.3, 0.5)
        return true end }))
end

SMODS.Consumable { --Money
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Money',
    key = 'cap_money',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 3, y = 0 },
    config = {
        extra = {
            ['Common'] = 5,
            ['Uncommon'] = 10,
            ['Rare'] = 20,
            ['Legendary'] = 40,
            ['Bad'] = -5,
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        ease_dollars(card.ability.extra[card.ability.extra.chosen])
    end
}

SMODS.Consumable { --Plincoin
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Plincoin',
    key = 'cap_plincoin',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 5, y = 1 },
    config = {
        extra = {
            ['Common'] = 2,
            ['Uncommon'] = 4,
            ['Rare'] = 6,
            ['Legendary'] = 15,
            ['Bad'] = -2,
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        ease_plincoins(card.ability.extra[card.ability.extra.chosen])
    end
}

SMODS.Consumable { --Edition
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Edition',
    key = 'cap_edition',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 2, y = 1 },
    config = {
        extra = {
            ['Common'] = {'e_foil', "Foil"},
            ['Uncommon'] = {'e_holo', "Holographic"},
            ['Rare'] = {'e_polychrome', "Polychrome"},
            ["Legendary"] = {"e_negative", "Negative"},
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen][2]}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        if G.jokers and G.jokers.cards then
            for k, v in ipairs(G.jokers.cards) do
                if not v.edition then return true end
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local can_use = false
        if G.jokers and G.jokers.cards then
            for k, v in ipairs(G.jokers.cards) do
                if not v.edition then can_use = true break end
            end
        end
        if can_use then
            local valid = {}
            for k, v in ipairs(G.jokers.cards) do
                if not v.edition then 
                    valid[#valid+1] = v
                end
            end
            pseudorandom_element(valid, pseudoseed("cap_edition")):set_edition(card.ability.extra[card.ability.extra.chosen][1])
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Perkeo
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Perkeo',
    key = 'cap_perkeo',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 2, y = 2 },
    config = {
        extra = {
            ['Uncommon'] = 1,
            chosen = 'Uncommon'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Uncommon'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,

    set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, G.C.GREEN, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        if G.consumeables and #G.consumeables.cards > 0 and not (#G.consumeables.cards == 1 and G.consumeables.cards[1] == card) then
            return true
        end
        return false
    end,

    use = function(self, card, area, copier)
        if G.consumeables and #G.consumeables.cards > 0 and not (#G.consumeables.cards == 1 and G.consumeables.cards[1] == card) then
            G.E_MANAGER:add_event(Event({
                func = function() 
                    local _card = copy_card(pseudorandom_element(G.consumeables.cards, pseudoseed('perkeo_cap')), nil)
                    _card:set_edition({negative = true}, true)
                    _card:add_to_deck()
                    G.consumeables:emplace(_card) 
                    return true
                end}))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Joker
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Joker',
    key = 'cap_joker',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            ['Common'] = 'Common',
            ['Uncommon'] = 'Uncommon',
            ['Rare'] = 'Rare',
            ['Legendary'] = 'Legendary',
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end,

    use = function(self, card, area, copier)
        if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
            SMODS.add_card({set = 'Joker', rarity = card.ability.extra[card.ability.extra.chosen], legendary = card.ability.extra[card.ability.extra.choden] == "Legendary", key_append = 'jokercap'}):juice_up(0.5,0.5)
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Wheel
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Wheel',
    key = 'cap_wheel',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 1, y = 0 },
    config = {
        extra = {
            ['Common'] = 8,
            ['Uncommon'] = 4,
            ['Rare'] = 2,
            ['Legendary'] = 1,
            ['Bad'] = 16,
            chosen = 'Common',
            dollars = 50
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        local new_numerator, new_denominator = SMODS.get_probability_vars(card, 1, card.ability.extra[card.ability.extra.chosen], 'cap_wheel')
        return {vars = {new_numerator, new_denominator, card.ability.extra.dollars}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        if SMODS.pseudorandom_probability(card, 'cap_wheel', 1, card.ability.extra[card.ability.extra.chosen], 'cap_wheel') then
            ease_dollars(card.ability.extra.dollars)
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Sticker
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Sticker',
    key = 'cap_sticker',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 1, y = 1 },
    config = {
        extra = {
            ['Bad'] = 'Nothing!!! #MyNothing',
            chosen = 'Bad'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,

    set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, G.C.BLACK, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        if G.jokers and #G.jokers.cards > 0 then
            for k, v in ipairs(G.jokers.cards) do
                if not (v.ability.rental) or (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) or (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) then
                    return true
                end
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local can_use = false
        if G.jokers and #G.jokers.cards > 0 then
            for k, v in ipairs(G.jokers.cards) do
                if not (v.ability.rental) or (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) or (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) then
                    can_use = true break
                end
            end
        end
        if can_use then
            local choices = {}
            for k, v in ipairs(G.jokers.cards) do
                if not (v.ability.rental) then
                    choices[1] = 'rental' 
                end
                if (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) then
                    choices[2] = 'eternal' 
                end
                if (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) then
                    choices[3] = 'perishable' 
                end
            end
            local stickertype = pseudorandom_element(choices, pseudoseed('stickercap'))
            if stickertype == 'rental' then
                local valid = {}
                for k, v in ipairs(G.jokers.cards) do
                    if not v.ability.rental then
                        valid[#valid+1] = v
                    end
                end
                pseudorandom_element(valid, pseudoseed('stickercap')):set_rental(true)
            elseif stickertype == 'eternal' then
                local valid = {}
                for k, v in ipairs(G.jokers.cards) do
                    if (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) then
                        valid[#valid+1] = v
                    end
                end
                pseudorandom_element(valid, pseudoseed('stickercap')):set_eternal(true)
            elseif stickertype == 'perishable' then
                local valid = {}
                for k, v in ipairs(G.jokers.cards) do
                    if (not v.ability.eternal and not v.ability.perishable and v.config.center.perishable_compat) then
                        valid[#valid+1] = v
                    end
                end
                pseudorandom_element(valid, pseudoseed('stickercap')):set_perishable(true)
            end
            
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            attention_text({
                text = localize('k_nope_ex'),
                scale = 1.3, 
                hold = 1.4,
                major = card,
                backdrop_colour = G.C.SECONDARY_SET.Tarot,
                align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                silent = true
                })
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                    play_sound('tarot2', 0.76, 0.4);return true end}))
                play_sound('tarot2', 1, 0.4)
                card:juice_up(0.3, 0.5)
            return true end }))
        end
    end
}

SMODS.Consumable { --Anti-Joker 
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Anti-Joker',
    key = 'cap_anti_joker',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 3, y = 2 },
    config = {
        extra = {
            ['Bad'] = 1,
            chosen = 'Bad'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, G.C.BLACK, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        if G.jokers and G.jokers.cards[1] then
            for k, v in ipairs(G.jokers.cards) do
                if not SMODS.is_eternal(v) then return true end
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        if G.jokers and G.jokers.cards[1] then
            local valid = {}
            if G.jokers and G.jokers.cards[1] then
            for k, v in ipairs(G.jokers.cards) do
                if not SMODS.is_eternal(v) then 
                    valid[#valid+1] = v
                end
            end
            local byebye = pseudorandom_element(valid, pseudoseed('antijokercap'))
            if byebye then
                byebye.getting_sliced = true
                G.E_MANAGER:add_event(Event({func = function()
                    card:juice_up(0.8, 0.8)
                    SMODS.destroy_cards({ byebye })
                return true end }))
            end
        end
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Tag
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Tag',
    key = 'cap_tag',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 4, y = 1 },
    config = {
        extra = {
            ['Common'] = 1,
            ['Uncommon'] = 2,
            ['Rare'] = 3,
            ['Legendary'] = 4,
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen == 'Common' and '' or 's'}}
    end,

    can_use = function(self, card)
        return true
    end,

    set_badges = HotPotato.bottlecap_badges,

    use = function(self, card, area, copier)
        for i=1, card.ability.extra[card.ability.extra.chosen] do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                local tagkey = get_next_tag_key('tagcap')
                local tag = Tag(tagkey)
                if tagkey == 'tag_orbital' then
                    local _poker_hands = {}
                    for k, v in pairs(G.GAME.hands) do
                        if v.visible then _poker_hands[#_poker_hands+1] = k end
                    end
                    
                    tag.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
                end
                if i==1 then
                    play_sound('timpani')
                    card:juice_up(0.3, 0.5)
                end
                add_tag(tag)
                return true
            end}))
        end
    end
}

SMODS.Consumable { --Hands
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Hands',
    key = 'cap_hands',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 0, y = 1 },
    config = {
        extra = {
            ['Common'] = 1,
            ['Uncommon'] = 2,
            ['Rare'] = 3,
            ['Legendary'] = 4,
            ['Bad'] = -1,
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen == 'Common' and '' or 's'}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        G.GAME.round_bonus.next_hands = G.GAME.round_bonus.next_hands + card.ability.extra[card.ability.extra.chosen]
        ease_hands_played(card.ability.extra[card.ability.extra.chosen])
        card:juice_up(0.5,0.5)
    end
}

SMODS.Consumable { --Discards
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Discards',
    key = 'cap_discards',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 5, y = 0 },
    config = {
        extra = {
            ['Common'] = 1,
            ['Uncommon'] = 2,
            ['Rare'] = 3,
            ['Legendary'] = 4,
            ['Bad'] = -1,
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen == 'Common' and '' or 's'}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        G.GAME.round_bonus.discards = G.GAME.round_bonus.discards + card.ability.extra[card.ability.extra.chosen]
        ease_discard(card.ability.extra[card.ability.extra.chosen])
        card:juice_up(0.5,0.5)
    end
}

SMODS.Consumable { --Pack
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Pack',
    key = 'cap_pack',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 1, y = 3 },
    config = {
        extra = {
            ['Common'] = {'Booster Pack','normal'},
            ['Uncommon'] = {'Jumbo Booster Pack', 'jumbo'},
            ['Rare'] = {'Mega Booster Pack','mega'},
            ['Legendary'] = {'Ultra Booster Pack', 'ultra'},
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen][1]}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return G.shop or G.GAME.modifiers.hpot_plinko_4ever
    end,

    use = function(self, card, area, copier)
        if G.shop or G.GAME.modifiers.hpot_plinko_4ever then
            local key = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == 'Booster' and string.find(k, string.lower(card.ability.extra[card.ability.extra.chosen][2])) ~= nil then
                        key[#key+1] = k
                    end
                end
            if key[1] then
                SMODS.add_booster_to_shop(pseudorandom_element(key, pseudoseed('packcap')))
            else
                SMODS.add_booster_to_shop()
            end
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Capitalism
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Capitalism',
    key = 'cap_italism',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 5, y = 2 },
    config = {
        extra = {
            ['Common'] = 2,
            ['Bad'] = 5,
            chosen = 'Bad'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = function(self, card, badges)
        local color = G.C.BLACK
        if card.ability.extra.chosen == 'Common' then
            color = G.C.BLUE
        end
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, color, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        create_ads(card.ability.extra[card.ability.extra.chosen])
    end
}

SMODS.Consumable { --Inflation
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Inflation',
    key = 'cap_inflation',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 1, y = 2 },
    config = {
        extra = {
            ['Bad'] = 2,
            chosen = 'Bad'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, G.C.BLACK, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        PlinkoLogic.f.change_roll_cost(G.GAME.current_round.plinko_roll_cost + card.ability.extra[card.ability.extra.chosen])
    end
}

SMODS.Consumable { --Emperor
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Emperor',
    key = 'cap_emperor',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 4, y = 2 },
    config = {
        extra = {
            ['Common'] = 2,
            ['Uncommon'] = 2,
            ['Rare'] = 2,
            ['Bad'] = 2,
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) or (card.area == G.consumeables)
    end,

    use = function(self, card, area, copier)
        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            for i=1, to_number(math.min(card.ability.extra[card.ability.extra.chosen],G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer))) do
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local _card = SMODS.create_card{set = 'bottlecap_'..card.ability.extra.chosen,area = G.consumeables, key_append = 'empercap'}
                            _card.ability.extra.chosen = card.ability.extra.chosen
                            if card.ability.extra.chosen == "Bad" then
                                _card.ability.eternal = true
                            end
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end}))                         
                    return true
                end)}))
            end
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Consumable
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Consumable',
    key = 'cap_consumable',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 3, y = 1 },
    config = {
        extra = {
            ['Common'] = 'Planet',
            ['Uncommon'] = 'Tarot',
            ['Rare'] = 'Spectral',
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) or (card.area == G.consumeables)
    end,

    use = function(self, card, area, copier)
        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            for i=1, G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer) do
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local _card = SMODS.create_card{set = card.ability.extra[card.ability.extra.chosen],area = G.consumeables, key_append = 'consumablecap'}
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end}))                         
                    return true
                end)}))
            end
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Voucher
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Voucher',
    key = 'cap_voucher',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 0, y = 2 },
    config = {
        extra = {
            ['Uncommon'] = 'Tier 1',
            ['Rare'] = 'Tier 1 and Tier 2',
            ['Legendary'] = 'Two Tier 2s',
            chosen = 'Uncommon'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    ignore_save = true,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Rare'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        local need_save = true
        local save = Event { func = function() save_run(); return true end}

        local vouchers = get_current_pool('Voucher')
        local valid1, valid2 = {}, {}
        for k, v in pairs(vouchers) do
            if v ~= 'UNAVAILABLE' then
                if G.P_CENTERS[v].requires then
                    valid2[#valid2+1] = v
                else
                    valid1[#valid1+1] = v
                end
            end
        end

        if card.ability.extra.chosen == 'Uncommon' then
            if valid1[1] then
                need_save = false

                local key = pseudorandom_element(valid1, pseudoseed('vouchercap'))
                local saveshopv = G.GAME.current_round.voucher
                local _card = SMODS.create_card{set = 'Voucher', key = key}
                G.play:emplace(_card)
                _card.cost = 0
                _card:redeem()
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 5, blockable = false, blocking = false, func = function()
                _card:start_dissolve()
                return true end}))
                if saveshopv ~= nil then
                    G.GAME.current_round.voucher = saveshopv
                end
            end

        elseif card.ability.extra.chosen == 'Rare' then
            if valid1[1] and valid2[1] then
                need_save = false

                local key1 = pseudorandom_element(valid1, pseudoseed('vouchercap'))
                local saveshopv = G.GAME.current_round.voucher
                for k, v in pairs(G.P_CENTERS) do
                    if string.sub(k, 1, 2) == "v_"  and v.requires then
                        local is_voucher_obtainable = true
                        for _, vv in ipairs(v.requires) do
                            if vv ~= key1 then
                                local is_voucher_matching = false
                                for kk, _ in pairs(G.GAME.used_vouchers) do
                                    if kk == vv then
                                        is_voucher_matching = true
                                        break
                                    end
                                end
                                if not is_voucher_matching then is_voucher_obtainable = false end
                            end
                        end
                        local is_voucher_duplicate = false
                        for kk, _ in pairs(G.GAME.used_vouchers) do
                            if kk == k then
                                is_voucher_duplicate = true
                                break
                            end
                        end
                        if is_voucher_obtainable and not is_voucher_duplicate then
                            valid2[#valid2 + 1] = k
                        end
                    end
                end
                local key2 = pseudorandom_element(valid2, pseudoseed('vouchercap'))
                local _card1 = SMODS.create_card{set = 'Voucher', key = key1}
                local _card2 = SMODS.create_card{set = 'Voucher', key = key2}
                G.play:emplace(_card1)
                G.play:emplace(_card2)
                _card1.cost = 0
                _card2.cost = 0
                _card1:redeem()
                _card2:redeem()

                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 5, blockable = false, blocking = false, func = function()
                _card1:start_dissolve()
                _card2:start_dissolve()
                return true end}))
                if saveshopv ~= nil then
                    G.GAME.current_round.voucher = saveshopv
                end
            
            elseif valid1[1] and not valid2[1] then
                need_save = false
                local _card2 = nil
                local key = pseudorandom_element(valid1, pseudoseed('vouchercap'))
                local saveshopv = G.GAME.current_round.voucher
                local _card1 = SMODS.create_card{set = 'Voucher', key = key}
                for k, v in pairs(G.P_CENTERS) do
                    if string.sub(k, 1, 2) == "v_"  and v.requires then
                        local is_voucher_obtainable = true
                        for _, vv in ipairs(v.requires) do
                            if vv ~= key then
                                local is_voucher_matching = false
                                for kk, _ in pairs(G.GAME.used_vouchers) do
                                    if kk == vv then
                                        is_voucher_matching = true
                                        break
                                    end
                                end
                                if not is_voucher_matching then is_voucher_obtainable = false end
                            end
                        end
                        local is_voucher_duplicate = false
                        for kk, _ in pairs(G.GAME.used_vouchers) do
                            if kk == k then
                                is_voucher_duplicate = true
                                break
                            end
                        end
                        if is_voucher_obtainable and not is_voucher_duplicate then
                            valid2[#valid2 + 1] = k
                        end
                    end
                end
                if next(valid2) then
                    _card2 = SMODS.create_card{set = 'Voucher', key = pseudorandom_element(valid2, pseudoseed('vouchercap'))}
                end
                G.play:emplace(_card1)
                if _card2 then G.play:emplace(_card2) end
                _card1.cost = 0
                if _card2 then _card2.cost = 0 end
                _card1:redeem()
                if _card2 then _card2:redeem() end
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 5, blockable = false, blocking = false, func = function()
                _card1:start_dissolve()
                if _card2 then _card2:start_dissolve() end
                return true end}))
                if saveshopv ~= nil then
                    G.GAME.current_round.voucher = saveshopv
                end

            elseif valid2[1] and not valid1[2] then
                need_save = false

                local key = pseudorandom_element(valid2, pseudoseed('vouchercap'))
                local saveshopv = G.GAME.current_round.voucher
                local _card = SMODS.create_card{set = 'Voucher', key = key}
                G.play:emplace(_card)
                _card.cost = 0
                _card:redeem()
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 5, blockable = false, blocking = false, func = function()
                _card:start_dissolve()
                return true end}))
                if saveshopv ~= nil then
                    G.GAME.current_round.voucher = saveshopv
                end
            end
        elseif card.ability.extra.chosen == 'Legendary' then
            if valid2[1] and valid2[2] then
                need_save = false

                local key1, key2 = pseudorandom_element(valid2, pseudoseed('vouchercap')), pseudorandom_element(valid2, pseudoseed('vouchercap'))
                local saveshopv = G.GAME.current_round.voucher
                local _card1 = SMODS.create_card{set = 'Voucher', key = key1}
                local _card2 = SMODS.create_card{set = 'Voucher', key = key2}
                G.play:emplace(_card1)
                G.play:emplace(_card2)
                _card1.cost = 0
                _card2.cost = 0
                _card1:redeem()
                _card2:redeem()

                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 5, blockable = false, blocking = false, func = function()
                _card1:start_dissolve()
                _card2:start_dissolve()
                return true end}))
                if saveshopv ~= nil then
                    G.GAME.current_round.voucher = saveshopv
                end
            elseif valid2[1] then
                need_save = false

                local key = pseudorandom_element(valid2, pseudoseed('vouchercap'))
                local saveshopv = G.GAME.current_round.voucher
                local _card = SMODS.create_card{set = 'Voucher', key = key}
                G.play:emplace(_card)
                _card.cost = 0
                _card:redeem()
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 5, blockable = false, blocking = false, func = function()
                _card:start_dissolve()
                return true end}))
                if saveshopv ~= nil then
                    G.GAME.current_round.voucher = saveshopv
                end
            end
        end
    end
}

SMODS.Consumable { --Perkeo Quip         <--- QUIPS IN HERE 
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Perkeo?',
    key = 'cap_perkeo_quip',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 4, y = 0 },
    config = {
        extra = {
            ['Bad'] = 1,
            chosen = 'Bad'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, G.C.BLACK, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        card.states.visible = false
        local real_perky = SMODS.create_card{key = 'j_perkeo', area = G.play}
	    real_perky.states.visible = false
        local perkolator = Card_Character({x = real_perky.T.x,y = real_perky.T.y,w = real_perky.T.w,h = real_perky.T.h,center = 'j_perkeo',})





        --                                               vvv HERE FOR QUIP POOL

        perkolator:add_speech_bubble("bc_"..math.random(1,16), nil, {quip = true})

        --                                               ^^^ THAT SECOND NUMBER RIGHT THERE THANK YOU





        perkolator:say_stuff(5 * G.SETTINGS.GAMESPEED)
        delay(2 * G.SETTINGS.GAMESPEED)
        G.E_MANAGER:add_event(Event({
		func = function()
			perkolator:remove_speech_bubble()
			perkolator.children.particles:fade(0.2, 1)
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.5 * G.SETTINGS.GAMESPEED,
				func = function()
                    real_perky:remove()
					perkolator:remove()
					return true
				end,
			}))
			return true
		end,
	    }))
        
    end
    
}

SMODS.Consumable { --Venture Capital
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Venture Capital',
    key = 'cap_venture',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 0, y = 3 },
    config = {
        extra = {
            ['Common'] = 4,
            ['Uncommon'] = 6,
            ['Rare'] = 10,
            ['Legendary'] = 20,
            chosen = 'Common'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Rare'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        if to_big(G.GAME.plincoins) > to_big(0) then
            ease_plincoins(math.min(card.ability.extra[card.ability.extra.chosen], G.GAME.plincoins))
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Duplicate
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Duplicate',
    key = 'cap_duplicate',
    set = 'bottlecap',
    atlas = 'capatlas',
    pos = { x = 2, y = 0 },
    config = {
        extra = {
            ['Rare'] = 'Rare',
            chosen = 'Rare'
        }
    },
    ppu_artist = {'dottykitty'},
    ppu_coder = {'CampfireCollective'},
    ppu_team = {'Perkeocoin'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Rare'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit and G.jokers.cards[1]
    end,

    use = function(self, card, area, copier)
        if G.jokers and #G.jokers.cards < G.jokers.config.card_limit and G.jokers.cards[1] then
            local choice = pseudorandom_element(G.jokers.cards, pseudoseed('dupecap'))
            card_eval_status_text(choice, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
            local _card = copy_card(choice, nil, nil, nil, choice.edition and choice.edition.negative)
            _card:add_to_deck()
            G.jokers:emplace(_card)
            _card:juice_up(0.5,0.5)
        else
            nope(card)
        end
    end
}


SMODS.Consumable { --Sticker Bomb (change this to use poll_sticker() )
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Sticker Bomb',
    key = 'cap_sticker_bomb',
    set = 'bottlecap',
    atlas = 'tname_caps',
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            ['Bad'] = 'Nothing!!! #MyNothing',
            chosen = 'Bad'
        }
    },
    ppu_artist = {'Revo'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,

    set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, G.C.BLACK, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        if G.jokers and #G.jokers.cards > 0 then
            for k, v in ipairs(G.jokers.cards) do
                if not (v.ability.rental) or (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) or (not v.ability.eternal and not v.ability.perishable and v.config.center.eternal_compat) then
                    return true
                end
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local can_use = false
        if G.jokers and #G.jokers.cards > 0 then
            can_use = true
        end
        if can_use then
            local choices = {}
            for k, v in pairs(SMODS.Stickers) do
                if k ~= "hpot_jtem_mood" then
                    choices[#choices+1] = k
                end
            end

            for i = 1, #G.jokers.cards do
                local stickertype = pseudorandom_element(choices, pseudoseed('stickercap'))
                SMODS.Stickers[stickertype]:apply(G.jokers.cards[i],true)
            end
            
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Modification
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Cap Modification',
    key = 'cap_modif',
    set = 'bottlecap',
    atlas = 'tname_caps',
    pos = { x = 2, y = 0 },
    config = {
        extra = {
            ['Bad'] = 'BAD',
            ['Common'] = "GOOD",
            chosen = 'Common'
        }
    },
    ppu_artist = {'Revo'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}}
    end,

    set_badges = function(self, card, badges)
        local color = G.C.BLUE
        if card.ability.extra.chosen == 'Bad' then
            color = G.C.BLACK
        end
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, color, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        if G.jokers and #G.jokers.cards > 0 then
            for k, v in ipairs(G.jokers.cards) do
                return true
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local can_use = false
        if G.jokers and #G.jokers.cards > 0 then
            can_use = true
        end
        if can_use then
            local random_joker = pseudorandom_element(G.jokers.cards)
            play_sound("hpot_tname_reforge")
            apply_modification(random_joker, random_modif(card.ability.extra[card.ability.extra.chosen], card).key)
        else
            nope(card)
        end
    end
}

SMODS.Consumable { --Credit
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Credits',
    key = 'cap_credits',
    set = 'bottlecap',
    atlas = 'tname_caps',
    pos = { x = 1, y = 0 },
    config = {
        extra = {
            ['Common'] = 10,
            ['Uncommon'] = 20,
            ['Rare'] = 50,
            ["Legendary"] = 75,
            ['Bad'] = -20,
            chosen = 'Common'
        }
    },
    ppu_artist = {'Revo'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
        ['bottlecap_Rare'] = true,
        ['bottlecap_Legendary'] = true,
        ['bottlecap_Bad'] = true
    },
    loc_vars = function(self, info_queue, card)
		local key
		local fucking = G.GAME.seeded and "_budget" or ""
		key = (self.key .. fucking)
        return {vars = {card.ability.extra[card.ability.extra.chosen]}, key = key}
    end,

    set_badges = HotPotato.bottlecap_badges,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        HPTN.ease_credits(card.ability.extra[card.ability.extra.chosen])
    end
}

SMODS.Consumable { -- Team Name Consumable
in_pool = function(self, args)
		return true, { allow_duplicates = false }
	end,
    name = 'Team Name Consumable',
    key = 'cap_tname_consumables',
    set = 'bottlecap',
    atlas = 'tname_caps',
    pos = { x = 3, y = 0 },
    config = {
        extra = {
            ['Common'] = 'Hanafuda',
            ['Uncommon'] = 'Aura',
            chosen = 'Common'
        }
    },
    ppu_artist = {'Revo'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'},
    display_size = { h = 34, w = 34},
    unlocked = true,
    discovered = true,
    cost = 3,
    pools = {
        ['bottlecap'] = true,
        ['bottlecap_Common'] = true,
        ['bottlecap_Uncommon'] = true,
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra[card.ability.extra.chosen], card.ability.extra.chosen}}
    end,

    set_badges = function(self, card, badges)
        local color = G.C.BLUE
        if card.ability.extra.chosen == 'Uncommon' then
            color = G.C.GREEN
        end
 		badges[#badges+1] = create_badge(card.ability.extra.chosen, color, G.C.WHITE, 1 )
 	end,

    can_use = function(self, card)
        return (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) or (card.area == G.consumeables)
    end,

    use = function(self, card, area, copier)
        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            for i=1, G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer) do
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local _card = SMODS.create_card{set = card.ability.extra[card.ability.extra.chosen],area = G.consumeables, key_append = 'consumablecap'}
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end}))                         
                    return true
                end)}))
            end
        else
            nope(card)
        end
    end
}