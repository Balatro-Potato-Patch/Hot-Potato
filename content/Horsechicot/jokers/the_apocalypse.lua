local horsemen = {
    "ruby",
    "lily",
    "nxkoo",
    "cg",
    "pangaea",
    "baccon"
}

local pos_map = {
    ruby = {x = 1, y = 0},
    lily = {x = 2, y = 0},
    nxkoo = {x = 3, y = 0},
    cg = {x = 0, y = 1},
    pangaea = {x = 1, y = 1},
    baccon = {x = 2, y = 1}
}
local function randomize_horseman(card)
    if card.quantum then
        card = card.quantum
    end
    card:flip()
    card.ability.horseman = pseudorandom_element(horsemen, pseudoseed("hpot_apocalypse"))
    card.children.center:set_sprite_pos(pos_map[card.ability.horseman])
    card:flip()
end

function get_currency_mult()
    local pm = 0.2
    local bm = 0.4
    local dm = 0.05
    local cm = 0.01
    local jm = 0.000005
    local c_softcap = 100 --prevent metaprogression farming too hard
    local extra = to_big(G.PROFILES[G.SETTINGS.profile].TNameCredits) > to_big(c_softcap) and math.log(G.PROFILES[G.SETTINGS.profile].TNameCredits - c_softcap) or 0
    local xmult = 
    G.GAME.dollars * dm + G.GAME.plincoins + pm + G.GAME.cryptocurrency * bm + G.GAME.spark_points * jm
    + (math.min(G.PROFILES[G.SETTINGS.profile].TNameCredits, c_softcap) + extra) * cm
    return xmult
end

SMODS.Atlas{key = "hc_apocalypse", path = "Horsechicot/hc_apocalypse.png", px = 71, py = 95}

SMODS.Joker {
    key = "apocalypse",
    cost = 10,
    rarity = 3,
    config = {
        horseman = "",
        extra = {
            chips_mod = 1,
            odds = 2,
            cards_needed = 4,
            xmult = 4,

            axmult = 1.5,
            hxmult = 2
        }
    },
    atlas = "hc_apocalypse",
    pos = { x = 0, y = 0 },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_vars = function(self, q, card)
        if card.ability.horseman == "" then return end
        local vars
        if card.ability.horseman == "ruby" then
            q[#q+1] = {set = "Other", key = "hc_ruby_apocalypse"}
            vars = {
                get_currency_mult()
            }
        end
        if card.ability.horseman == "cg" then
            q[#q + 1] = { key = 'hc_cg_apocalypse', set = 'Other' }
            vars = {
                card.ability.extra.chips_mod,
                card.ability.extra.chips_mod * Horsechicot.num_jokers()
            }
        end
        if card.ability.horseman == "lily" then
            q[#q+1] = {set = "Other", key = "hc_lily_apocalypse"}
            local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hpot_apocalypse_lily')
            vars = {
                numerator,
                denominator
            }
        end
        if card.ability.horseman == "baccon" then
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.cards_needed
            }
        end
        if card.ability.horseman == "nxkoo" then
            vars = {
                card.ability.extra.hxmult,
                card.ability.extra.axmult
            }
        end
        return {
            vars = vars,
            key = "j_hpot_apocalypse_"..card.ability.horseman
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.horseman == "ruby" then
                return {
                    xmult = get_currency_mult()
                }
            elseif card.ability.horseman == "cg" then
                local chips = card.ability.extra.chips_mod * Horsechicot.num_jokers()
                return {
                    chips = chips
                }
            elseif card.ability.horseman == "baccon" and #G.play.cards == card.ability.extra.cards_needed then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if card.ability.horseman == "lily" and SMODS.pseudorandom_probability(card, 'hpot_apocalypse_lily', 1, card.ability.extra.odds) then
                local type = pseudorandom_element({"rank", "suit"}, pseudoseed("hpot_apocalypse_choice"))
                context.other_card:flip()
                if type == "rank" then
                    SMODS.change_base(context.other_card, nil, "9")
                else
                    SMODS.change_base(context.other_card, "Spades")
                end
                context.other_card:flip()
            elseif card.ability.horseman == "nxkoo" then
                if context.other_card:get_id() == 14 then
                    if context.other_card:is_suit("Hearts") then
                        return {xmult = card.ability.extra.hxmult}
                    else    
                        return {xmult = card.ability.extra.axmult}
                    end
                end
            end
        end
        if context.after then
            G.E_MANAGER:add_event(Event{
                func = function()
                    randomize_horseman(card)
                    return true
                end
            })
        end
        if context.using_consumeable and card.ability.horseman == "pangaea" then
            G.GAME.ante_banned = G.GAME.ante_banned or {}
            G.GAME.ante_banned[context.consumeable.config.center_key] = true
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if not card.ability.first then
            randomize_horseman(card)
            card.ability.first = true
        end
    end,
    set_sprites = function(self, card, front)
        if card.ability and card.ability.horseman then
            card.children.center:set_sprite_pos(pos_map[card.ability.horseman])
        end
    end,
    ppu_coder = { "lord.ruby" },
    ppu_artist = { "pangaea47", "lord.ruby" },
    ppu_team = { "Horsechicot" },
}