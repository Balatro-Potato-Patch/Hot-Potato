
SMODS.Joker({
	key = "kris_joker",
	rarity = 1,
	pos = {x=0,y=1},
	atlas = "tname_jokers2",
    cost = 3,
	add_to_deck = function (self, card, from_debuff)
		local a = HPTN.krisfactor
		HPTN.krisfactor = HPTN.cheapkrisfactor
		HPTN.cheapkrisfactor = a
	end,
	remove_from_deck = function (self, card, from_debuff)
		local a = HPTN.krisfactor
		HPTN.krisfactor = HPTN.cheapkrisfactor
		HPTN.cheapkrisfactor = a
	end,
    
    ppu_artist = {"GoldenLeaf"},
    ppu_coder = {"GoldenLeaf"},
    ppu_team = {"Team Name"}
})