-- Thank you for this notmario you have saved so much time
HotPotato.key_has_attribute = function (card_key, key)
    if type(card_key) ~= 'string' then return false end
    local pool = SMODS.get_attribute_pool(key)
    for _, c in pairs(pool) do
        if c == card_key then return true end
    end
    return false
end

SMODS.Attribute {
    key = 'plincoin'
}

SMODS.Attribute {
    key = 'jicks'
}

SMODS.Attribute {
    key = 'credits'
}

SMODS.Attribute {
    key = 'bitcoin'
}

SMODS.Attribute {
    key = 'delivery'
}

SMODS.Attribute {
    key = 'ads'
}

SMODS.Attribute {
    key = 'training'
}

SMODS.Attribute {
    key = 'rotating_effect'
}

SMODS.Attribute {
    key = 'bottlecaps'
}

SMODS.Attribute {
    key = 'breeding'
}

SMODS.Attribute {
    key = 'czechs'
}

SMODS.Attribute {
    key = 'level_up'
}

SMODS.Attribute {
    key = 'hanafuda'
}

SMODS.Attribute {
    key = 'plinko'
}