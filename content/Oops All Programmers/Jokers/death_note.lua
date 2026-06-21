SMODS.Joker {
    key = 'death_note',
    rarity = 1,
    blueprint_compat = false,
    cost = 4,
    atlas = "oap_jokers",
    pos = { x = 1, y = 1 },
    config = {
        extra = {
            rank = 'Ace',
            suit = 'Spades',
            id = 14
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.rank, 'ranks'), localize(card.ability.extra.suit, 'suits_plural'), colours = { G.C.SUITS[card.ability.extra.suit] } } }
    end,
    set_ability = function(self, card, initial, delay_sprites)
        reset_death_note(card)
    end,
    calculate = function(self, card, context)
        if context.post_draw_individual and context.card and context.card:get_id() == card.ability.extra.id and context.card:is_suit(card.ability.extra.suit) and not context.blueprint then
            reset_death_note(card)
            if not context.card.hpot_deathnote_removed then
                context.card.hpot_deathnote_removed = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 1,
                    func = function()
                        card:juice_up(0.8, 0.8)
                        SMODS.destroy_cards({ context.card })
                        return true;
                    end
                }))
            end
        end
        if context.end_of_round and not context.blueprint then
            reset_death_note(card)
        end
    end,
    ppu_artist = { 'th30ne' },
    ppu_coder = { 'theAstra' },
    ppu_team = { 'OAP' }
}

function reset_death_note(card)
    card.ability.extra.rank = 'Ace'
    card.ability.extra.suit = 'Spades'
    card.ability.extra.id = 14

    if G.playing_cards then
        local valid_note_cards = {}
        for k, v in ipairs(G.playing_cards) do
            if v.ability.effect ~= 'Stone Card' then
                if not SMODS.has_no_suit(v) and not SMODS.has_no_rank(v) then
                    valid_note_cards[#valid_note_cards + 1] = v
                end
            end
        end

        if next(valid_note_cards) then
            local note_card = pseudorandom_element(valid_note_cards, pseudoseed('note' .. G.GAME.round_resets.ante))
            card.ability.extra.rank = note_card.base.value
            card.ability.extra.suit = note_card.base.suit
            card.ability.extra.id = note_card.base.id
        end
    end
end
