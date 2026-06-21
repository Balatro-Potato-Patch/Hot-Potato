SMODS.Joker {
    key = "emoticon",
    config = {
        extra = {
            x_mult = 1.4
        }
    },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.x_mult } }
    end,
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    atlas = "smiley_jokers",
    pos = {x=1,y=0},
    ppu_artist = {"RGBeet"},
    ppu_coder = {"PokéRen"},
    ppu_team = {":)"},
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face(false,{ignore_emoticon = true}) then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    x_mult = card.ability.extra.x_mult
                }
            end
        end
    end
}

local original_isface = Card.is_face
function Card:is_face(from_boss,options)
    if self.debuff and not from_boss then return end
    if next(find_joker("j_hpot_faceblindness")) then
        --print(find_joker("j_hpot_faceblindness"))
        local faceblindness = find_joker("j_hpot_faceblindness")[1]
        if SMODS.pseudorandom_probability(faceblindness, 'faceblindness', faceblindness.ability.extra.numerator, faceblindness.ability.extra.denominator, 'faceblindness') then
            if next(find_joker("j_hpot_emoticon")) and not (options and options.ignore_emoticon) then
                -- Face cards will not be considered face cardss if you have Emoticon. if you want to ignore this, do is_face(false,{ignore_emoticon = true})
                return false --Face Blindness hit and emoticon owned
            else
                return true --Face Blindness hit and emoticon not owned (or ignore_emoticon is true)
            end
        else
            return false --Face Blindness didn't hit
        end
    end -- Face Blindness not owned, all below
    if next(find_joker("j_hpot_emoticon")) and not (options and options.ignore_emoticon) then
        -- Face cards will not be considered face cardss if you have Emoticon. if you want to ignore this, do is_face(false,{ignore_emoticon = true})
        return false
    end
    return original_isface(self,from_boss)
end