--#region UBlock Deck
SMODS.Back {
    key = 'ublockdeck',
    atlas = 'pdr_decks',
    pos = { x = 1, y = 0 },
    discovered = true,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                G.GAME.ad_blocker = 1
                return true
            end
        }))
    end,
}
local _win = win_game
function win_game()
    ret = _win()
    if G.GAME.selected_back.name == 'b_hpot_ublockdeck' then
        check_for_unlock({type = 'clippy'})
    end
    return ret
end
--[[ 
eval ease_ante(7)
eval G.GAME.chips = G.GAME.blind.chips
]]
SMODS.ObjectType {
    key = 'ad_cards',
    cards = {
        j_hpot_adspace = true,
        j_hpot_kitchen_gun = true,
        j_hpot_tv_dinner = true,
        j_hpot_free_to_use = true,
        j_hpot_skimming = true,
        j_hpot_dont_touch_that_dial = true,
        j_hpot_slop = true,
    },
}

local atp = SMODS.add_to_pool
function SMODS.add_to_pool(prototype_obj, args)
    local ret = atp(prototype_obj, args)

    if prototype_obj.pools and prototype_obj.pools.ad_cards and G.GAME.ad_blocker and G.GAME.ad_blocker >= 1 then
        ret = false
    end

    return ret
end

local ref = create_ads
function create_ads(e)
    if (not G.GAME.ad_blocker) or to_number(G.GAME.ad_blocker) <= 0 then
        return ref(e)
    end
end

local start_run_old = Game.start_run
function Game:start_run(args)
    start_run_old(self, args)
    if args and args.savetext and args.savetext.ad_blocker then
        self.GAME.ad_blocker = args.savetext.ad_blocker
    elseif not args.savetext then
        self.GAME.ad_blocker = 0
    end
end

--#endregion

--#region Poop Deck
SMODS.Back {
    key = 'poopdeck',
    atlas = 'pdr_decks',
    pos = { x = 0, y = 0 },
    discovered = true,
    skip_materialize = true,
    config = { stones = 30, voucher = 'v_hpot_poop1' },
    ppu_artist = { "LocalThunk", "John Rackham" },
    ppu_coder = { "deadbeet" },
    ppu_team = { "Pissdrawer" },
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                for _ = 1, self.config.stones do
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local c = pseudorandom_element(G.deck.cards, pseudoseed('shoutouts to gay foxgirls'))
                            if c then
                                c:set_ability(G.P_CENTERS.m_stone, true, true)
                                c:set_edition('e_polychrome', true, true)
                            end
                            return true
                        end
                    }))
                end
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if (context.end_of_round or context.ending_booster) and context.main_eval then
            local cards = #G.playing_cards
            local scurved = pseudorandom('scurvy', 1, cards)
            if not SMODS.has_enhancement(G.playing_cards[scurved], 'm_stone') then
                SMODS.destroy_cards(G.playing_cards[scurved], true, true)
                return {
                    message = localize("k_hotpot_scurvy"),
                    colour = G.C.RED
                }
            else
                local stone_card = SMODS.create_card {
                    set = "Base",
                    enhancement = "m_stone",
                    area = G.discard,
                    edition = 'e_polychrome',
                    rank = '2',
                    suit = 'Clubs'
                }
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                stone_card.playing_card = G.playing_card
                table.insert(G.playing_cards, stone_card)

                G.E_MANAGER:add_event(Event({
                    func = function()
                        stone_card:start_materialize({
                            G.C.SECONDARY_SET.Enhanced })
                        G.play:emplace(stone_card)
                        return true
                    end
                }))
                return {
                    message = localize('k_hotpot_rocks'),
                    colour = G.C.SECONDARY_SET.Enhanced,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.deck.config.card_limit =
                                    G.deck.config.card_limit + 1
                                return true
                            end
                        }))
                        draw_card(G.play, G.deck, 90, 'up')
                        SMODS.calculate_context({
                            playing_card_added = true,
                            cards = { stone_card }
                        })
                    end
                }
            end
        end
        if context.individual and not context.end_of_round then
            local stones = 0
            context.other_card.ability.perma_h_mult = context.other_card.ability.perma_h_mult or 0
            context.other_card.ability.perma_h_chips = context.other_card.ability.perma_h_chips or 0
            for _, _2 in pairs(G.playing_cards) do
                if SMODS.has_enhancement(_2, 'm_stone') then stones = stones + 1 end
            end
            local xmystery = pseudorandom('xmystery', 1, stones)
            if SMODS.has_enhancement(context.other_card, 'm_stone') then
                if context.other_card.edition and context.other_card.edition.key == 'e_polychrome' then
                    if context.cardarea == G.play then
                        context.other_card.ability.perma_h_mult = context.other_card.ability.perma_h_mult +
                            (xmystery / 10)
                    end
                else
                    if context.cardarea == G.hand then
                        context.other_card.ability.perma_h_chips = context.other_card.ability.perma_h_chips +
                            (xmystery / 10)
                    end
                end
            end
        end
    end
}
--i dont wanna talk about it
SMODS.Voucher {
    key = 'poop1',
    pos = { x = 0, y = 2 },
    atlas = 'pdr_vouchers',
    no_collection = true,
    in_pool = function(self, args)
        return false
    end
}
--#endregion
