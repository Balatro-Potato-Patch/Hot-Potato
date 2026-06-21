Horsechicot = {}
PotatoPatchUtils.Team {
    name = 'Horsechicot',
    colour = HEX('5dc797')
}

SMODS.Atlas { key = "hc_jokers", path = "Horsechicot/hc_jokers.png", px = 71, py = 95 }
SMODS.Atlas { key = "hc_decks", path = "Horsechicot/hc_decks.png", px = 71, py = 95 }
SMODS.Atlas { key = "hc_boosters", path = "Horsechicot/hc_boosters.png", px = 71, py = 95 }
SMODS.Atlas { key = "hc_vouchers", path = "Horsechicot/hc_vouchers.png", px = 71, py = 95 }
SMODS.Atlas { key = "hc_placeholder", path = "Horsechicot/placeholders.png", px = 71, py = 95 }
SMODS.Atlas { key = "hc_consumables", path = "Horsechicot/hc_consumables.png", px = 71, py = 95 }


SMODS.Atlas {
    key = "horsechicot_market",
    path = "Horsechicot/shop_button.png",
    px = 34, py = 34,
}

SMODS.Atlas {
    key = "hc_tags",
    path = "Horsechicot/hc_tags.png",
    px = 34, py = 34,
}

SMODS.Sound {
    key = "music_market",
    path = "music_market.ogg",
    pitch = 0.9,
    select_music_track = function(self)
        if PissDrawer.Shop.active_tab == "hotpot_shop_tab_hotpot_horsechicot_toggle_market" or (G.hpot_event and G.HP_HC_MARKET_VISIBLE) then
            return 1325
        end
    end,
    hpot_title = "Black Market Theme",
    hpot_artist = "GoldenLeaf",
    hpot_purpose = {
        "Music that plays in",
        "the Black Market"
    },
    hotpot_credits = {
        team = 'Team Name'
    }
}


SMODS.Atlas {
    key = "hc_plinkos",
    path = "Horsechicot/plinkos.png",
    px = 40, py = 40,
}

function Horsechicot:calculate(context)
    if context.end_of_round then
        G.GAME.bm_bought_this_round = false
    end
end

local oldfunc = Game.main_menu
Game.main_menu = function(self, change_context)
    local ret = oldfunc(self, change_context)
    jokerOrder = {}
    for i, v in ipairs(G.P_CENTER_POOLS.Joker) do
        jokerOrder[v.key] = i
    end
    return ret
end

HotPotato.menu_cards = function()
    return {
        remove_original = true,
        {key = 'j_hpot_thetruehotpotato'},
        {key = 'j_hpot_birthdayboy'},
        func = function()
            for k, v in pairs(G.title_top.cards) do
                if v.config.center_key == 'j_hpot_birthdayboy' then
                    v.no_ui = false
                    break
                end
            end
        end
    }
end

function HotPotato.get_blind_font(blind)
    if blind and (blind.name == "bl_hpot_quartz" or (blind.config and blind.config.name == "bl_hpot_quartz")) then
        return SMODS.Fonts['hpot_plincoin']
    end
end

function Horsechicot.post_load()
    local cards = {
        c_death = true,
        c_hanged_man = true,
    }
    local cards_jokerless = {
        c_death = true,
        c_hanged_man = true,
    }
    local sets = {
        Spectral = true,
        Omen = true,
    }
    for i, v in pairs(G.P_CENTERS) do
        if (v.set == "Joker" and v.rarity == 3) then
            cards[i] = true
        elseif (sets[v.set]) then
            cards[i] = true
            cards_jokerless[i] = true
        end
    end

    for k, v in pairs(G.P_CENTERS) do
        if v.set == 'Booster' and (string.find(k, string.lower("ultra")) ~= nil or string.find(k, string.lower("mega")) ~= nil) then
            cards[k] = true
            cards_jokerless[k] = true
        end
    end

    SMODS.ObjectType {
        key = 'BlackMarket',
        default = "c_wraith",
        cards = cards
    }
    SMODS.ObjectTypes.BlackMarket:inject()
    SMODS.ObjectType {
        key = 'BlackMarketJokerless',
        default = "c_wraith",
        cards = cards_jokerless
    }
    SMODS.ObjectTypes.BlackMarketJokerless:inject()
    if Cryptid then
        HotPotato.manipulate = Cryptid.manipulate
        HotPotato.manipulate_table = Cryptid.manipulate_table
        HotPotato.manipulate_value = Cryptid.manipulate_value
    end
end

-- I have no idea why this lock is needed in a first place
-- Without it everything looks like working fine
-- With it - Lock In stuck, just winning a blind stuck, losing stuck, door stuck
-- So for now I remove check - SleepyG11
local old = end_round
function end_round()
    G.round_end_lock = true
    old()
    G.E_MANAGER:add_event(Event { func = function()
        G.round_end_lock = false
        return true
    end })
end

local loadmodsref = SMODS.injectItems
function SMODS.injectItems(...)
    loadmodsref(...)
    Horsechicot.post_load()
end

function HotPotato.reload_localization()
    SMODS.handle_loc_file(HotPotato.path)
    return init_localization()
end

SMODS.Atlas { key = "hcbananaad", path = "Ads/BananaAd.png", px = 169, py = 55 }
SMODS.Atlas { key = "hcnumberslop", path = "Ads/numberslop.png", px = 169, py = 55 }
SMODS.Atlas { key = "hcred", path = "Ads/red.png", px = 169, py = 55 }
SMODS.Atlas { key = "hcmustard", path = "Ads/mustard.png", px = 169, py = 55 }
SMODS.Atlas { key = "hcwindows", path = "Ads/WindowDeck.png", px = 154, py = 139 }
SMODS.Atlas { key = "hpot_hchorseyworseys", path = "Ads/Horseys.png", px = 200, py = 150 }
