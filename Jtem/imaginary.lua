-- Main idea is use this type of cards for events specifically

SMODS.Atlas {
    key = "jtem_imagine",
    path = "Jtem/imagine.png",
    px = 71, py = 95
}

SMODS.ConsumableType {
    key = "imaginary",
    primary_colour = HEX("9ec7cf"),
    secondary_colour = HEX("feff5b"),
    collection_row = { 2, 1 },
    shop_rate = 0.5,
    default = "c_hpot_imag_stars",
    text_colour = HEX("333333"),
    select_card = 'consumeables'
}

SMODS.Consumable {
    key = "imag_stars",
    set = "imaginary",
    atlas = "jtem_imagine",
    pos = { x = 1, y = 0 },
    hotpot_credits = {
        art = { 'Squidguset' },
        code = { 'Squidguset' },
        idea = { 'Squidguset' },
        team = { 'Jtem' }
    }
}

SMODS.Consumable {
    key = "imag_curi",
    set = "imaginary",
    atlas = "jtem_imagine",
    pos = { x = 2, y = 0 },
    hotpot_credits = {
        art = { 'Squidguset' },
        code = { 'Squidguset' },
        idea = { 'Squidguset' },
        team = { 'Jtem' }
    }
}

SMODS.Consumable {
    key = "imag_duck",
    set = "imaginary",
    atlas = "jtem_imagine",
    pos = { x = 3, y = 0 },
    hotpot_credits = {
        art = { 'Squidguset' },
        code = { 'Squidguset' },
        idea = { 'Squidguset' },
        team = { 'Jtem' }
    }
}

SMODS.Consumable {
    key = "imag_drop",
    set = "imaginary",
    atlas = "jtem_imagine",
    pos = { x = 4, y = 0 },
    hotpot_credits = {
        art = { 'Squidguset' },
        code = { 'Squidguset' },
        idea = { 'Squidguset' },
        team = { 'Jtem' }
    }
}
