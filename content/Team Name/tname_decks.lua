SMODS.Atlas {
    key = "TeamNameDecks",
    path = "Team Name/TeamNameBacks.png",
    px = 71,
    py = 95
}

SMODS.Back {
    key = 'lime',
    atlas = 'TeamNameDecks',
    pos = { x = 0, y = 0 },
    config = { plincoins = 5 },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.plincoins } }
    end,
    apply = function(self, back)
        G.GAME.plincoins = (G.GAME.plincoins or 0) + self.config.plincoins
    end,
}

SMODS.Back {
    key = 'minimal',
    atlas = 'TeamNameDecks',
    pos = { x = 1, y = 0 },
    apply = function (self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                local s = pseudorandom("mila",1,4)
                for _,v in ipairs(G.playing_cards) do
                    SMODS.destroy_cards(v,true,true,true)
                end
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "Ace", suit = ((s == 1 and "Spades") or (s == 2 and "Hearts") or (s == 3 and "Clubs") or (s == 4 and "Diamonds") or "Spades")}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "King", suit = "Diamonds"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "Queen", suit = "Diamonds"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "Jack", suit = "Diamonds"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "10", suit = "Hearts"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "9", suit = "Hearts"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "8", suit = "Hearts"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "7", suit = "Spades"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "6", suit = "Spades"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "5", suit = "Spades"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "4", suit = "Clubs"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "3", suit = "Clubs"}
                SMODS.add_card{set = "Base", area = G.deck, no_edition = true, rank = "2", suit = "Clubs"}
            return true
            end
        }))
    end
}






