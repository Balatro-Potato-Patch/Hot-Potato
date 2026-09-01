local currencies = { "dollars", "joker_exchange", "plincoin", "credits", "cryptocurrency" }

SMODS.Joker {
    ppu_artist = { 'lord.ruby' },
    ppu_coder = { 'lord.ruby' },
    ppu_team = { 'Horsechicot' },
    key = "lotus",
    rarity = 3,
    cost = 5,
    atlas = "hc_jokers",
    pos = { x = 2, y = 3 },
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    attributes = { 'generation', 'joker', 'economy', 'jicks', 'plincoin', 'credits', 'bitcoin' },
    can_use = function(self, card)
        for i, v in pairs(G.jokers.highlighted) do
            if v ~= card and v.ability.quantum_1 then
                return false
            end
        end
        return G.jokers and (#G.jokers.highlighted == 2 or G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker)
    end,
    use = function(self, card)
        if G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker then
            G.GAME.banned_keys[G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker] = false
            SMODS.add_card{
                area = G.jokers,
                key = G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker
            }
            card:start_dissolve()
            G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker = nil
        else
            local currency = pseudorandom_element(currencies, pseudoseed("hpot_lotus"))
            local value = get_currency_amount(currency)
            ease_currency(currency, -value * 0.5)
            local j
            for i, v in pairs(G.jokers.highlighted) do
                if v ~= card then j = v end
            end
            check_for_unlock({ type = "lotus_banish", key = j.config.center_key })
            G.GAME.banned_keys[j.config.center_key] = true
            j:start_dissolve()
            card:start_dissolve()
            G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker = j.config.center_key
        end
    end,
    loc_vars = function(self, q, card)
        if G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker then
            q[#q+1] = G.P_CENTERS[G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker]
        end
        return {
            key = G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker and "j_hpot_lotus_filled" or "j_hpot_lotus",
            vars = G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker and {
                localize { type = 'name_text', key = G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker, set = "Joker", vars = {} }
            } or nil
        }
    end,
    set_sprites = function(self, card, front)
        if G.PROFILES[G.SETTINGS.profile].hpot_lotus_joker then
            card.children.center:set_sprite_pos({x = 3, y = 3})
        end
    end
}