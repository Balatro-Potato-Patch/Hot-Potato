--[[
Values:
G.GAME.dollars     DONE
G.GAME.plincoins     DONE
G.GAME.spark_points     DONE
G.PROFILES[G.SETTINGS.profile].TNameCredits     DONE

G.GAME.round_resets.ante     DONE
G.GAME.round_resets.hands     DONE
G.GAME.round_resets.discards     DONE
G.GAME.round_resets.free_rerolls     DONE

G.GAME.blind_mult == Blind Size Extra multiplier
G.GAME.payout_mult == Payout multiplier; rerolled for each new currency

All Shop Costs     DONE
All Market Costs     DONE
Reroll Cost when rerolling
Market Reroll cost when Market Rerolling     DONE

G.GAME.cost_dollar_default     DONE
G.GAME.cost_plincoins_default     DONE
G.GAME.cost_spark_default     DONE
G.GAME.cost_credit_default     DONE
G.GAME.cost_cryptocurrency_default     DONE

]]
Horsechicot.unstable = {
    GAME = {
        "dollars",
        "plincoins",
        "spark_points",
        "cryptocurrency",
        "cost_dollar_default",
        "cost_plincoins_default",
        "cost_spark_default",
        "cost_credit_default",
        "cost_cryptocurrency_default",
        "round"
    },
    round_resets = {
        "ante",
        "hands",
        "discards",
        "free_rerolls",
    },
}
function randomize_values()
    for i, v in pairs(Horsechicot.unstable.GAME) do
        local random_result = pseudorandom("unstable_deck_"..i) * 0.4 - 0.1675 + 1
        if G.GAME[v] then
            G.GAME[v] = G.GAME[v] * random_result
        end
    end
    for i, v in pairs(Horsechicot.unstable.round_resets) do
        local random_result = pseudorandom("unstable_deck_"..i) * 0.4 - 0.1675 + 1
        if G.GAME.round_resets[v] then
            G.GAME.round_resets[v] = G.GAME.round_resets[v] * random_result
            G.GAME.current_round[v] = G.GAME.round_resets[v]
        end
    end
    if not G.GAME.seeded then G.PROFILES[G.SETTINGS.profile].TNameCredits = G.PROFILES[G.SETTINGS.profile].TNameCredits * (pseudorandom("unstable_deck_credits") * 0.1 - 0.05 + 1) else
        G.GAME.budget = G.GAME.budget * (pseudorandom("unstable_deck_credits") * 0.1 - 0.05 + 1) end
    G.GAME.credits_text = G.GAME.seeded and G.GAME.budget or G.PROFILES[G.SETTINGS.profile].TNameCredits
    if G.HUD then
        local uie = G.HUD:get_UIE_by_ID('credits_UI_text')
        if uie and uie.config.object then
            uie.config.object:update()
        end
    end
    for i, v in pairs(G.GAME.hands) do
        for ind, value in pairs(v) do
            if type(value) == "number" and ind ~= "level" then
                G.GAME.hands[i][ind] = value * (pseudorandom("unstable_deck_"..ind..i..G.GAME.pseudorandom.seed) * 0.4 - 0.1675 + 1)
            end
        end
    end
    for i, v in pairs(G.I.CARD) do
        HotPotato.manipulate(v, {
            min = 0.8325,
            max = 1.225,
        })
    end
end

local card_set_abilityref = Card.set_ability
function Card:set_ability(...)
    card_set_abilityref(self, ...)
    if G.GAME.modifiers.unstable and not G.SETTINGS.paused then
        HotPotato.manipulate(self, {
            min = 0.8325,
            max = 1.225,
        })
    end
    if self.ability.consumeable and next(SMODS.find_card("j_hpot_apocalypse")) then
        for i, v in pairs(SMODS.find_card("j_hpot_apocalypse")) do
            if v.ability.horseman == "pangaea" then
                HotPotato.manipulate(self, {
                    value = 2
                })
            end
        end
    end
end

local card_ui = create_shop_card_ui
function create_shop_card_ui(card, ...)
    if G.GAME.modifiers.unstable then
        card.cost = card.cost * (pseudorandom("unstable_deck_cost") * 0.4 - 0.1675 + 1)
    end
    return card_ui(card, ...)
end

local reroll_shopref = G.FUNCS.reroll_shop
function G.FUNCS.reroll_shop(e)
    reroll_shopref(e)
    if G.GAME.modifiers.unstable then
        G.E_MANAGER:add_event(Event{
            trigger = "after",
            func = function()
                G.GAME.current_round.reroll_cost = G.GAME.current_round.reroll_cost * math.floor((pseudorandom("unstable_deck_reroll_cost") * 0.4 - 0.1675 + 1) * 100) / 100
                return true
            end
        })
    end
end

if not Entropy then
    local gba_ref = get_blind_amount
    function get_blind_amount(a, ...)
        if math.floor(a) == a then
            return gba_ref(math.floor(a), ...)
        end
        local p = math.abs(a - math.floor(a))
        return gba_ref(math.floor(a), ...) * (1 - p) + gba_ref(math.floor(a) + 1, ...) * p
    end
end

SMODS.Back {
    name = "Unstable Deck",
    key = "unstable",
    pos = { x = 1, y = 0 },
    atlas = "hc_decks",
    apply = function()
        G.GAME.payout_mult = G.GAME.payout_mult or 1
        randomize_values()
        G.GAME.modifiers.unstable = true
    end,
    calculate = function(self, card, context)
        if (context.end_of_round and not context.blueprint and not context.individual and G.GAME.blind_on_deck == "Boss" and not context.repetition) then
            randomize_values()
            return {
                message = get_err_message(),
                colour = G.C.RED
            }
        end
    end,
    loc_vars = function()
        return {
            vars = {
                "#1#"
            }
        }
    end
}

Horsechicot.errors = {
    "Index out of Bounds",
    "Attempt to compare Number with Table",
    "Well, this is awkward..",
    "Context failed succesfully!",
    "Something bad",
    "Click 'Play' to continue",
    "Your Deck ran :(",
    "HC_Alloc: no free edicts",
    "???",
    "#",
    "Server is not responding",
    "keylog.exe was terminated",
    "Unable to gain access to sys32",
    "Mods/Tangents is missing",
    "version.dll was altered",
    "Your steamID was blacklisted",
    "OUT_OF_MEMORY",
    "Stack overflow",
    "Discord Nitro expired"
}

function get_err_message()
    return pseudorandom_element(Horsechicot.errors, pseudoseed("unstable_error"))
end