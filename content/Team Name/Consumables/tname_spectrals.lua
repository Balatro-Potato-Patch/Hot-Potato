SMODS.Consumable {
    key = 'blossom',
    set = 'Spectral',
    pos = { x = 0, y = 0 },
    atlas = 'tname_spectrals',
    config = { extra = { seal = 'hpot_hanafuda' }, max_highlighted = 1 },
    discovered = true,
    loc_vars = function(self, info_queue, card)
        -- commenting this because they didnt add a plural key and i need the field :p -N'
        -- I'm bringing back the plural part and just putting it at the end. -UnusedParadox
        local key = self.key
        -- if (G.GAME.max_highlighted_mod or 0) > 0 then
        --     key = key .. "_p"
        -- end
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        local numerator, denominator
        if JoyousSpring or PTASaka then
            numerator, denominator = SMODS.get_probability_vars(card, 1, 100, "hpot_blossom")
            if JoyousSpring then
                info_queue[#info_queue + 1] = G.P_CENTERS.m_joy_hanafuda
            end
            key = key .. (JoyousSpring and "_joy" or "") .. (PTASaka and "_pta" or "")
        end
        if to_number(G.GAME.max_highlighted_mod or 0) > 0 then
            key = key .. "_p"
        end
        return { key = key, vars = { card.ability.max_highlighted, numerator, denominator, colours = { HEX('800058') } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for _, i in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if JoyousSpring then
                        i:set_ability("m_joy_hanafuda")
                    end
                    i:set_seal(card.ability.extra.seal, nil, true)
                    return true
                end
            }))
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))

        if (JoyousSpring or PTASaka) and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit
            and SMODS.pseudorandom_probability(card, "hpot_blossom", 100, 100) then
            local choices = {}
            if JoyousSpring then choices[#choices + 1] = "j_joy_yokai_ash" end
            if PTASaka then choices[#choices + 1] = "j_payasaka_joyousspring" end
            local choice = pseudorandom_element(choices, "hpot_blossom_create")

            if choice then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.add_card({ key = choice })
                        G.GAME.joker_buffer = 0
                        return true;
                    end
                }))
            end
        end
    end,

    ppu_artist = { 'GoldenLeaf' },
    ppu_coder = { 'Goldenleaf' },
    ppu_team = { 'Team Name' }

}
