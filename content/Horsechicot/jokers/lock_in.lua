SMODS.Joker {
    ppu_coder = { "cg223" },
    ppu_artist = { "pangaea47" },
    ppu_team = { "Horsechicot" },
    key = "lockin",
    cost = 4,
    rarity = 2,
    config = { was_clicked = false, start_time = 0, leniency = 1, can_save = false },
    atlas = "hc_jokers",
    pos = { x = 6, y = 0 },
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
}

HotPotato.find_lock_in = function()
    for _, v in ipairs(G.jokers.cards) do
        if v.config.center.key == "j_hpot_lockin" or (v.ability.quantum_1 and v.ability.quantum_1.key == "j_hpot_lockin") or (v.ability.quantum_2 and v.ability.quantum_2.key == "j_hpot_lockin") then
            if not v.debuff then return v end
        end
    end
end

local old = G.draw
function G:draw()
    local card = G.lock_in_card
    local focused = G.CONTROLLER.focused.target
    G.CONTROLLER.focused.target = card
    old(self)
    G.CONTROLLER.focused.target = focused
end

local old = end_round
function end_round()
    local cardparent = HotPotato.find_lock_in()
    local cardquantum = SMODS.find_card("j_hpot_lockin", false)[1]
    if cardparent and to_big(G.GAME.chips / G.GAME.blind.chips) < to_big(1) then
        cardquantum.ability.can_save = false
        cardparent.ability.was_clicked = false
        cardparent.ability.start_time = love.timer.getTime()
        G.draw_lockin_background = true
        SMODS.calculate_effect({ message = localize("k_hotpot_lock_in") }, cardparent)
        local time_given = (G.GAME.chips / G.GAME.blind.chips) * cardquantum.ability.leniency
        local last_juice_time = love.timer.getTime()
        G.jokers:remove_card(cardparent)
        G.lock_in_card = cardparent
        cardparent.T.x = pseudorandom("hc_lockinpos", 0, G.ROOM.T.w - G.CARD_W)
        cardparent.T.y = pseudorandom("hc_lockinpos", 0, G.ROOM.T.h - G.CARD_H)
        G.E_MANAGER:add_event(Event({
            func = function()
                if (love.timer.getTime() - time_given) > cardquantum.ability.start_time or cardquantum.ability.was_clicked then
                    return true
                else
                    if love.timer.getTime() - 0.3 > last_juice_time then
                        last_juice_time = love.timer.getTime()
                        cardparent:juice_up(0.1, 0.08)
                    end
                end
            end
        }))
        G.E_MANAGER:add_event(Event {
            func = function()
                G.draw_lockin_background = false
                if cardparent.ability.was_clicked then
                    cardquantum.ability.can_save = true
                else
                    cardquantum.ability.can_save = false
                end
                return true
            end
        })
    end
    G.GAME.current_round.market_reroll_cost = 0.5
    if G.GAME.modifiers.windows and G.GAME.current_round.current_hand.scores then
        for i, v in pairs(G.GAME.current_round.current_hand.scores) do
            G.GAME.current_round.current_hand.scores[i] = 0
        end
    end
    if G.GAME.spawning_blocked then
        if G.GAME.spawning_reset == "ante" and G.GAME.blind_on_deck == "Boss" then
            G.GAME.spawning_blocked = {}
        end
        if G.GAME.spawning_reset == "round" then
            G.GAME.spawning_blocked = {}
        end
    end
    if G.GAME.blind_on_deck == "Boss" then
        G.GAME.dollars_ante = 0
        G.GAME.ante_banned = nil
    end
    G.GAME.current_round.harvested = nil
    return old()
end

local old = Card.click
function Card:click()
    old(self)
    if (self.config.center.key == "j_hpot_lockin" or self.ability.quantum_1 and (self.ability.quantum_1.key == "j_hpot_lockin" or self.ability.quantum_2.key == "j_hpot_lockin")) and self.ability.start_time and self.ability.start_time + 0.05 < love.timer.getTime()  then
        self.ability.was_clicked = true
    end
end

local old = SMODS.calculate_context
function SMODS.calculate_context(context, ...)
    if context.game_over then
        if G.lock_in_card then
            if G.lock_in_card.ability.was_clicked then
                SMODS.calculate_effect({message = localize("k_saved_ex")}, G.lock_in_card)
                SMODS.destroy_cards(G.lock_in_card)
                G.lock_in_card = nil
                SMODS.saved = true
                G.saved_by_lock_in = true
            else
                G.lock_in_card:remove()
                G.lock_in_card = nil
            end
        end
    end
    return old(context, ...)
end

local old = localize
function localize(key, ...)
    if key == "ph_mr_bones" and G.saved_by_lock_in then
        G.saved_by_lock_in = false
        return "Saved by Lock In"
    else
        return old(key, ...)
    end
end