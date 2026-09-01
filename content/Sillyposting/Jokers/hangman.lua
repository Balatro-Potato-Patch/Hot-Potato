local generate_main_end_hangman = function(card)
    local add_node = function(nodes, text, colour)
        nodes[#nodes + 1] = {
            n = G.UIT.T,
            config = {
                text = text,
                colour = colour,
                scale = 0.3
            }
        }
    end
    if card.area and card.area == G.jokers then
        local nodes_ = {}
        add_node(nodes_, '(Seen:', G.C.UI.TEXT_INACTIVE)
        for _, rank in ipairs(card.ability.extra.secret) do
            if card.ability.extra.seen[rank] then
                add_node(nodes_, ' '..localize(rank, 'ranks'), G.C.FILTER)
            else
                add_node(nodes_, " ?", G.C.UI.TEXT_INACTIVE)
            end
        end
        add_node(nodes_, ')', G.C.UI.TEXT_INACTIVE)

        return {{
            n = G.UIT.C,
            config = {
                align = "bm",
                padding = 0.02
            },
            nodes = {{
                n = G.UIT.R,
                config = {
                    align = "cm"
                },
                nodes = nodes_
            }}
        }}
    end
end

SMODS.Joker { --Recycling
    name = "Hangman",
    key = "hangman",
    config = {
        extra = {
            secret = {
                'Ace',
                '2',
                '3',
                '4',
                '5',
            },
            seen = {},
            n_seen = 0,
            dollars = 2,
            dollars_extra = 4,
            n_ranks = 5,
        }
    },
    pos = { x = 3, y = 0 },
    cost = 3,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'SillypostingJokers',
    attributes = { 'rank', 'economy' },
    
    ppu_artist = { 'Jaydchw' },
    ppu_coder = { 'Victin' },
    ppu_team = { 'Sillyposting' },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.n_ranks, card.ability.extra.dollars, card.ability.extra.dollars_extra },
            main_end = generate_main_end_hangman(card)
        }
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            local candidate_ranks = {}
            for k, _ in pairs(SMODS.Ranks) do
                candidate_ranks[#candidate_ranks + 1] = k
            end
            pseudoshuffle(candidate_ranks, pseudoseed("hpot_hangman"))

            local selected_ranks = {}
            for i = 1, card.ability.extra.n_ranks do
                selected_ranks[i] = candidate_ranks[i]
                --sendDebugMessage(tprint(candidate_ranks[i]))
            end

            card.ability.extra.secret = selected_ranks
            card.ability.extra.seen = {}
            card.ability.extra.n_seen = 0
        elseif context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            for _, rank in ipairs(card.ability.extra.secret) do
                if id == SMODS.Ranks[rank].id and not card.ability.extra.seen[rank] then
                    card.ability.extra.seen[rank] = true
                    card.ability.extra.n_seen = card.ability.extra.n_seen + 1
                    return { dollars = card.ability.extra.dollars +
                    (((to_number(card.ability.extra.n_seen) >= #card.ability.extra.secret) and card.ability.extra.dollars_extra) or 0) }
                end
            end
        elseif context.end_of_round and context.cardarea == G.jokers then
        end
    end,

}
