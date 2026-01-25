SMODS.Joker {
    key = 'box_of_frogs',
    rarity = 3,
    blueprint_compat = false,
    cost = 7,
    atlas = "oap_jokers",
    pos = { x = 9, y = 0 },
    hotpot_credits = {
        art = { 'th30ne' },
        code = { 'theAstra' },
        idea = { 'th30ne' },
        team = { 'O!AP' }
    }
}

local atp = SMODS.add_to_pool
function SMODS.add_to_pool(prototype_obj, args)
    local ret = atp(prototype_obj, args)

    if next(SMODS.find_card('j_hpot_box_of_frogs')) and prototype_obj.set == 'Joker' and not prototype_obj.original_mod and args.source and args.source == 'sho' then
        ret = false
    end

    return ret
end

local cc = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, extra)
    if forced_key then
        G.GAME.current_forced_key = forced_key
    end
    local ret = cc(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, extra)
    G.GAME.current_forced_key = nil
    return ret
end