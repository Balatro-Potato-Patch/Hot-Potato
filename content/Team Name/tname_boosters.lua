SMODS.Booster({
	key = "hanafuda_normal_1",
	atlas = "tname_boosters",
	pos = { x = 0, y = 0 },
	config = { extra = 3, choose = 1 },
	group_key = "k_hpot_hanafuda_packs",
	cost = 4,
	weight = 0.6,
	draw_hand = true,
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Hanafuda",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "hanafuda_normal_2",
	atlas = "tname_boosters",
	pos = { x = 1, y = 0 },
	config = { extra = 3, choose = 1 },
	group_key = "k_hpot_hanafuda_packs",
	cost = 4,
	weight = 0.6,
	draw_hand = true,
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Hanafuda",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "hanafuda_jumbo_1",
	atlas = "tname_boosters",
	pos = { x = 2, y = 0 },
	config = { extra = 5, choose = 1 },
	group_key = "k_hpot_hanafuda_packs",
	cost = 6,
	weight = 0.3,
	draw_hand = true,
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Hanafuda",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "hanafuda_mega_1",
	atlas = "tname_boosters",
	pos = { x = 3, y = 0 },
	config = { extra = 5, choose = 2 },
	group_key = "k_hpot_hanafuda_packs",
	cost = 7,
	weight = 0.11,
	draw_hand = true,
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Hanafuda",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "hanafuda_ultra_1",
	cost = 0,
	credits = 100,
	atlas = "tname_boosters",
	pos = { x = 4, y = 0 },
	config = { extra = 7, choose = 3 },
	group_key = "k_hpot_hanafuda_packs",
	draw_hand = true,
	create_card = function(self, card)
		return
			SMODS.create_card({
				set = "Hanafuda",
				skip_materialize = true,
			})
	end,
	
	ppu_artist = { "GoldenLeaf" },
		idea = { "Revo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

-- aura

SMODS.Booster({
	key = "auras_normal_1",
	atlas = "tname_boosters",
	pos = { x = 0, y = 1 },
	config = { extra = 3, choose = 1 },
	group_key = "k_hpot_auras_packs",
	cost = 4,
	weight = 0.6,
	kind = "hpot_aura",
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Aura",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "auras_normal_2",
	atlas = "tname_boosters",
	pos = { x = 1, y = 1 },
	config = { extra = 3, choose = 1 },
	group_key = "k_hpot_auras_packs",
	cost = 4,
	weight = 0.6,
	kind = "hpot_aura",
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Aura",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" }
})

SMODS.Booster({
	key = "auras_jumbo_1",
	atlas = "tname_boosters",
	pos = { x = 2, y = 1 },
	config = { extra = 5, choose = 1 },
	group_key = "k_hpot_auras_packs",
	cost = 6,
	weight = 0.3,
	kind = "hpot_aura",
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Aura",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "auras_mega_1",
	atlas = "tname_boosters",
	pos = { x = 3, y = 1 },
	config = { extra = 5, choose = 2 },
	group_key = "k_hpot_auras_packs",
	cost = 7,
	weight = 0.11,
	kind = "hpot_aura",
	create_card = function(self, card, i)
		return SMODS.create_card({
			set = "Aura",
			skip_materialize = true,
		})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "auras_ultra_1",
	weight = 0.025,
	cost = 0,
	credits = 100,
	atlas = "tname_boosters",
	pos = { x = 4, y = 1 },
	config = { extra = 7, choose = 3 },
	group_key = "k_hpot_auras_packs",
	kind = "hpot_aura",
	create_card = function(self, card)
		return
			SMODS.create_card({
				set = "Aura",
				skip_materialize = true,
			})
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "ultra_arcana",
	weight = 0.025,
	kind = "Arcana",
	name = "Ultra Arcana Pack",
	cost = 0,
	credits = 100,
	atlas = "tname_boosters",
	pos = { x = 3, y = 2 },
	config = { extra = 7, choose = 3 },
	group_key = "k_arcana_pack",
	draw_hand = true,
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.choose,
				card.ability.extra,
			},
		}
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Violet" }, -- <- this is the one to blame for the awful code
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "ultra_celestial",
	kind = "Celestial",
    name = "Ultra Celestial Pack",
	cost = 0,
	credits = 100,
	atlas = "tname_boosters",
	pos = { x = 4, y = 2 },
	config = { extra = 7, choose = 3 },
	group_key = "k_celestial_pack",
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.choose,
				card.ability.extra,
			},
		}
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Violet" }, -- <- this is the one to blame for the awful code
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "ultra_standard",
	weight = 0.025,
	kind = 'Standard',
	name = "Ultra Standard Pack",
	cost = 0,
	credits = 100,
	atlas = "tname_boosters",
	pos = { x = 0, y = 3 },
	config = { extra = 7, choose = 3 },
	group_key = "k_standard_pack",
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.choose,
				card.ability.extra,
			},
		}
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Violet" }, -- <- this is the one to blame for the awful code
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "ultra_spectral",
	weight = 0.025,
	kind = "Spectral",
	name = "Ultra Spectral Pack",
	cost = 0,
	credits = 100,
	atlas = "tname_boosters",
	pos = { x = 2, y = 2 },
	config = { extra = 7, choose = 3 },
	group_key = "k_spectral_pack",
	draw_hand = true,
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.choose,
				card.ability.extra,
			},
		}
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Violet" }, -- <- this is the one to blame for the awful code
	ppu_team = { "Team Name" },
})

SMODS.Booster({
	key = "ultra_buffoon",
	weight = 0.025,
	kind = "Buffoon",
	name = "Ultra Buffoon Pack",
	cost = 0,
	credits = 100,
	atlas = "tname_boosters",
	pos = { x = 1, y = 2 },
	config = { extra = 7, choose = 3 },
	group_key = "k_buffoon_pack",
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.choose,
				card.ability.extra,
			},
		}
	end,
	
	ppu_artist = { "GoldenLeaf" },
	ppu_coder = { "Violet" }, -- <- this is the one to blame for the awful code
	ppu_team = { "Team Name" },
})
