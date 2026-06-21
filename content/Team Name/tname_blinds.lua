
SMODS.Atlas({ key = "TeamNameBlinds", path = "Team Name/tname_blinds.png", px = 34, py = 34, atlas_table = "ANIMATION_ATLAS", frames = 21})
SMODS.Atlas({ key = "Fuck", path = "Team Name/tname_blinds2.png", px = 34, py = 34, atlas_table = "ANIMATION_ATLAS", frames = 21})
SMODS.Atlas({ key = "err", path = "Team Name/tname_blinds3.png", px = 34, py = 34, atlas_table = "ANIMATION_ATLAS", frames = 26})
SMODS.Blind {
    key = "holed",
    atlas = "TeamNameBlinds",
    pos = { x= 0, y = 0 },
    boss = { showdown = true },
    boss_colour = HEX("8a71e1"),
    recalc_debuff = function (self, card, from_blind)
        for k, _ in pairs(SMODS.Stickers) do
            if card.ability[k] == true then
                return false
            end
        end
        return card.area == G.jokers
    end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"},
    in_pool = function(self, blind)
        return G.GAME.tnamestickers
    end
}

SMODS.Blind {
    calculate = function(self, blind, context)
        if not blind.disabled and context.press_play then
            
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.4,
				func = function()
					for _, joker in pairs(G.jokers.cards) do
                        local jokero = G.P_CENTER_POOLS.Joker[pseudorandom("j",1,#G.P_CENTER_POOLS.Joker)].key
                        joker:set_ability(jokero)
					end
					return true
				end,
			}))
        end
    end,
    boss = {},
    key = "bluescreen",
    atlas = "err",
    pos = { x= 0, y = 0 },
    dollars = 8,
    mult = 1.5,
    in_pool = function (self)
        if G.GAME.round_resets.ante == 10 then
            return true
        end
        return false
    end,
    boss_colour = HEX("0049ff"),
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"}
}

SMODS.Blind {
    boss = { min = 3 },
    calculate = function(self, blind, context)
        if not blind.disabled and context.press_play then
            HPTN.ease_credits(-5)
        end
    end,
    key = "credential",
    loc_vars = function (self)
		local key
		local fucking = G.GAME.seeded and "_budget" or ""
		key = (self.key .. fucking)
        return {key = key}
    end,
    atlas = "Fuck",
    pos = { x= 0, y = 0 },
    dollars = 5,
    mult = 2,
    in_pool = function (self)
        if HPTN.check_if_enough_credits(0) then
            return true
        end
        return false
    end,
    boss_colour = HEX("b7a2fd"),
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"}
}