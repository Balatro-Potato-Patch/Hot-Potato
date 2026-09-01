--feel free to rewrite anything in this file causing issues (like UI stuff)
--i (cg) hacked it together from the wheel and plinko stuff

-- Takes in the card and if it's being checked to be a mother (true) or father (false)
HotPotato.can_breed = function(card, is_mother)
    if card.ability.hpot_unbreedable ~= nil then
        if type(card.ability.hpot_unbreedable) == "table" then
            if is_mother then return not card.ability.hpot_unbreedable.mother else return not card.ability.hpot_unbreedable.father end
        end
        return not card.ability.hpot_unbreedable
    end
    if card.config.center.hpot_unbreedable then
        if type(card.config.center.hpot_unbreedable) == "table" then
            if is_mother then return not card.config.center.hpot_unbreedable.mother else return not card.config.center.hpot_unbreedable.father end
        end
        return not card.config.center.hpot_unbreedable
    end
    return true
end

SMODS.Atlas {
    key = "nursery_sign",
    path = "Horsechicot/nursery_sign.png",
    px = 113, py = 57,
    frames = 4, atlas_table = 'ANIMATION_ATLAS'
}

G.STATES.NURSERY = 6942022367
function G.FUNCS.show_nursery(e)
    stop_use()
    hide_shop()
    G.STATE = G.STATES.NURSERY
    G.STATE_COMPLETE = false
end

--for watch lua
if Nursery then
    if G.nursery then
        G.FUNCS.hide_nursery()
        G.nursery:remove()
        G.nursery = nil
        G.nursery_mother:remove()
        G.nursery_father:remove()
    end
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    local ret = start_run_ref(self, args)
    local saveTable = args.savetext or nil
    G.GAME.breeding_rounds_passed = saveTable and saveTable.GAME.breeding_rounds_passed or 0
    return ret
end

function update_nursery(dt) -- talen from plinko so idk
    if not G.STATE_COMPLETE then
        stop_use()
        ease_background_colour_blind(G.STATES.NURSERY)


        G.STATE_COMPLETE = true
    end
    if G.GAME.breeding_finished then
        G.GAME.breeding_finished = false
        for i, v in pairs(G.I.CARD) do
            if v.ability and v.ability.father then
                dad = v
                v.ability.father = nil
            end
        end
        SMODS.calculate_context {
            baby_made = true,
            father = dad,
            mother = mom
        }
    end
end

function G.FUNCS.can_hide_nursery(e)
    return true
end

function G.FUNCS.hide_nursery(e)
    stop_use()

    G.STATE = G.STATES.SHOP
    G.STATE_COMPLETE = false
    ease_background_colour_blind(G.STATE)
    show_shop()

    G.nursery.alignment.offset.y = G.ROOM.T.y + 29

    G.E_MANAGER:add_event(Event({
        func = function()
            if G.shop then G.CONTROLLER:snap_to({ node = G.shop:get_UIE_by_ID('next_round_button') }) end
            return true
        end
    }))

    PissDrawer.Shop.change_shop_sign("shop_sign")
end

--maybe should make this only usable once a round
function G.FUNCS.nursery_abort(e)
    G.nursery_mother.cards[1].ability.mother = nil
    for i, v in pairs(G.I.CARD) do
        if v.ability and v.ability.father then
            v.ability.father = nil
        end
    end
    if G.nursery_child.cards[1] then
        G.nursery_child.cards[1]:remove()
    end
    G.GAME.active_breeding = false
    SMODS.calculate_effect { card = G.nursery_mother.cards[1], message = localize("k_hotpot_aborted") }
end

function G.FUNCS.can_nursery_abort(e)
    if not G.GAME.active_breeding then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.RED
        e.config.button = "nursery_abort"
    end
end

function G.FUNCS.nursery_breed(e)
    local mom = G.nursery_mother.cards[1]
    local dad = G.nursery_father.cards[1]
    if not dad and G.GAME.parthenogenesis then
        dad = mom
    end
    ease_dollars(-5)
    if not SMODS.pseudorandom_probability(mom, "nursery_breeding", 2, 3) then
        SMODS.calculate_effect({
            message = localize("k_nope_ex"),
            colour = G.C.RARITY[4],
        }, mom)
        return
    end

    -- Prevents removing Mother on successful breed
    G.nursery_mother:unhighlight_all()

    mom.ability.mother = true
    dad.ability.father = true
    Horsechicot.breed(mom, dad)
    if not G.SILENT_NURSERY then
        mom:juice_up()
        SMODS.calculate_effect {
            card = mom,
            message = localize("k_hotpot_impregnated"),
        }
    end
end

--dont draw G.hand during nursery
local ca_dref = CardArea.draw
function CardArea:draw(...)
    if self == G.hand and (G.STATE == G.STATES.NURSERY) then
        return
    end
    return ca_dref(self, ...)
end

--properly cleanup when menuing
local old = G.FUNCS.go_to_menu
function G.FUNCS.go_to_menu(e)
    old(e)
    if G.nursery then
        G.nursery:remove()
        G.nursery = nil
    end
end

--properly cleanup when new running
local old = Game.start_run
function Game.start_run(...)
    if G.nursery then
        G.nursery:remove()
        G.nursery = nil
    end
    old(...)
    for i, v in pairs(G.I.CARD) do
        if v.ability and v.ability.is_nursery_smalled then
            v.T.scale = v.T.scale * 0.75
        end
    end
end

--end ui, start mechanics
--this is used for "Nursery" and female nursery icon
G.C.HPOT_PINK = HEX("fe89d0")
G.ARGS.LOC_COLOURS.hpot_pink = G.C.HPOT_PINK
function Horsechicot.breed(mother, father)
    local poll = pseudorandom("hc_breed_result")
    --we choose which parent to make a new joker of || not anymore, quantum time
    if poll > 0.5 then
        G.GAME.child_colour = G.C.HPOT_PINK
        G.GAME.child_prio = mother.config.center.key
        G.GAME.child_sec = father.config.center.key
        G.GAME.child_prio_ability = copy_table(mother.ability)
        G.GAME.child_sec_ability = copy_table(father.ability)
    else
        G.GAME.child_colour = G.C.BLUE
        G.GAME.child_prio = father.config.center.key
        G.GAME.child_sec = mother.config.center.key
        G.GAME.child_prio_ability = copy_table(father.ability)
        G.GAME.child_sec_ability = copy_table(mother.ability)
    end
    G.GAME.active_breeding = true
    G.GAME.breeding_rounds_passed = 0
end

local old = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    if card and card.ability.mother then
        local ret = old(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        generate_card_ui({
            set = "Other",
            key = "hp_hc_mother"
        }, ret, {
            (G.GAME.quick_preggo and 2 or 3) - G.GAME.breeding_rounds_passed
        })
        return ret
    else
        return old(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    end
end

function update_child_atlas(self, new_atlas, new_pos)
    self.children.center.sprite_pos = new_pos
    self.children.center.atlas.name = new_atlas and new_atlas.key or 'Joker'
    self.children.center:reset()
    if self.ability.quantum_1 and self.ability.quantum_1.config.center.soul_pos and not self.children.floating_sprite then
        self.children.floating_sprite = Sprite(self.T.x, self.T.y, self.T.w * 0.75, self.T.h * 0.75,
            G.ASSET_ATLAS[self.ability.quantum_1.config.center.atlas or "Joker"],
            self.ability.quantum_1.config.center.soul_pos)
        self.children.floating_sprite.role.draw_major = self
        self.children.floating_sprite.states.hover.can = false
        self.children.floating_sprite.states.click.can = false
    elseif self.ability.quantum_1 and not self.ability.quantum_1.config.center.soul_pos and self.children.floating_sprite then
        self.children.floating_sprite:remove()
    end
end

--pregnancy checks
local old = end_round
function end_round()
    old()
    G.E_MANAGER:add_event(Event {
        func = function()
            nursery()
            return true
        end
    })
end

function nursery()
    if G.GAME.active_breeding then
        G.GAME.breeding_rounds_passed = G.GAME.breeding_rounds_passed + 1
        if to_number(G.GAME.breeding_rounds_passed) >= (G.GAME.quick_preggo and 2 or 3) then
            G.GAME.active_breeding = false
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                blocking = false,
                func = function()
                    if G.nursery_child and G.nursery_child.cards then
                        G.GAME.breeding_finished = true
                        for _, v in pairs(G.I.CARD) do
                            if v.ability and v.ability.father then
                                v:calculate_joker({ fathered_child = true })
                                v.ability.father = false
                            end
                        end
                        SMODS.calculate_context {
                            baby_made = true,
                            father = dad,
                            mother = mom
                        }
                        G.GAME.breeding_rounds_passed = 0
                        local child_prio = G.P_CENTERS[G.GAME.child_prio]
                        local child_sec = G.P_CENTERS[G.GAME.child_sec]
                        local card = SMODS.create_card { key = G.P_CENTERS.j_hpot_child.key, skip_materialize = true }
                        G.nursery_child:emplace(card)
                        local loc = localize { type = 'name', set = 'Joker', key = child_prio.key, vars = {} }
                        if not loc[1] then
                            loc = localize { type = 'name', set = 'Joker', key = "j_hpot_fallback", vars = {} }
                            --error("Joker ".. child_prio.key .." didnt localize")
                        end
                        --setting child abilities
                        card.ability.name = 'Baby ' ..
                            loc[1].nodes
                            [1]
                            .nodes[1].config.object.config.string[1]
                        loc[1].nodes
                            [1]
                            .nodes[1].config.object:remove()
                        card.ability.extra_value = ((child_prio.cost + child_sec.cost) / 2) - 1
                        card:set_cost()

                        card.ability.quantum_1 = Quantum({
                            fake_card = true,
                            key = child_prio.key,
                            ability = copy_table(G.GAME.child_prio_ability),
                            config = {
                                center = child_prio,
                                center_key = child_prio.key
                            },
                        }, card)
                        card.ability.quantum_2 = Quantum({
                            fake_card = true,
                            key = child_sec.key,
                            ability = copy_table(G.GAME.child_sec_ability),
                            config = {
                                center = child_sec,
                                center_key = child_sec.key
                            },
                        }, card)

                        card.ability.is_primary_mother = G.GAME.child_colour == G.C.HPOT_PINK
                        card:hotpot_resize(0.75)

                        card.ability.is_nursery_smalled = true

                        G.E_MANAGER:add_event(Event {
                            func = function()
                                card.loaded = true
                                update_child_atlas(card, G.ASSET_ATLAS[child_prio.atlas or 'Joker'], child_prio.pos)
                                if G.nursery_mother and G.nursery_mother.cards and G.nursery_mother.cards[1] then
                                    G.nursery_mother.cards[1].ability.mother = nil
                                    if child_prio.key == child_sec.key then check_for_unlock({ type = 'selfcest' }) end
                                    G.GAME.child_prio, G.GAME.child_sec = nil, nil
                                    return true
                                end
                            end,
                            blocking = false
                        })
                        return true
                    end
                    return false
                end
            }))
        end
    end
end

function random_nursery()
    local c1 = pseudorandom_element(G.P_CENTER_POOLS.Joker, tostring(os.time()))
    local c2 = pseudorandom_element(G.P_CENTER_POOLS.Joker, tostring(os.time()))
    test_nursery(c1.key, c2.key)
end

function test_nursery(key1, key2)
    G.SILENT_NURSERY = true
    G.nursery_father:emplace(SMODS.create_card { key = key1, skip_materialize = true })
    G.nursery_mother:emplace(SMODS.create_card { key = key2, skip_materialize = true })
    G.FUNCS.nursery_breed()
    nursery()
    nursery()
    nursery()
    local card = G.nursery_child.cards[1]
    G.nursery_child:remove_card(card)
    G.nursery_mother.cards[1]:remove()
    G.nursery_father.cards[1]:remove()
    G.jokers:emplace(card)
    G.SILENT_NURSERY = false
end

G.FUNCS.hpot_nursery_tutorial = function(e)
    G.FUNCS.hotpot_info { menu_type = "hotpot_nursery" }
end

G.P_CENTERS.j_wee.hpot_unbreedable = true
G.P_CENTERS.j_invisible.hpot_unbreedable = true