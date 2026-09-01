
SMODS.Voucher {
	key = 'digital_payment',
	atlas = "tname_vouchers",
	pos = { x = 0, y = 0 },
    loc_vars = function (self, info_queue, card)
		local key
		local fucking = G.GAME.seeded and "_budget" or ""
		key = (self.key .. fucking)
		return {
			vars = {
				(G.GAME.credits_cashout or 0)
			},
			key = key
		}
	end,
	redeem = function(self, voucher)
		G.GAME.modifiers.interest_to_credits = true
	end,
	
    ppu_artist = {'GhostSalt'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'}
}

SMODS.Voucher {
	key = 'digital_promotion', --i cant think of anything else
	atlas = "tname_vouchers",
	pos = { x = 1, y = 0 },
	loc_vars = function (self, info_queue, card)
		local key
		local fucking = G.GAME.seeded and "_budget" or ""
		key = (self.key .. fucking)
		return {
			vars = {
				(G.GAME.credits_cashout2 or 0)
			},
			key = key
		}
	end,
	redeem = function(self, voucher)
		G.GAME.modifiers.hands_to_credits = true
	end,
	requires = {
		'v_hpot_digital_payment'
	},
	
    ppu_artist = {'GhostSalt'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'}
}

SMODS.Voucher {
	key = 'ref_dollars',
	pos = { x = 0, y = 1 },
	atlas = "tname_vouchers",
	config = {
		extra = {
			discount_in_dollars = 2
		}
	},
    loc_vars = function (self, info_queue, card)
		return {
			vars = {
				card.ability.extra.discount_in_dollars
			}
		}
	end,
	redeem = function(self, card)
		G.GAME.reforge_discount = G.GAME.reforge_discount + card.ability.extra.discount_in_dollars
	end,
    ppu_artist = {'GhostSalt'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'}
}

SMODS.Voucher {
	key = 'ref_joker_exc',
	pos = { x = 1, y = 1 },
	atlas = "tname_vouchers",
	config = {
		extra = {
			discount_in_dollars = 3
		}
	},
	loc_vars = function (self, info_queue, card)
		return {
			vars = {
				card.ability.extra.discount_in_dollars
			}
		}
	end,
	requires = {
		'v_hpot_ref_dollars'
	},
	redeem = function(self, card)
		G.GAME.reforge_discount = G.GAME.reforge_discount + card.ability.extra.discount_in_dollars
	end,
    ppu_artist = {'GhostSalt'},
    ppu_coder = {'Revo'},
    ppu_team = {'Team Name'}
}


-- scrapped vouchers

--[[SMODS.Voucher {
	key = 'costcutting',
	pos = { x = 2, y = 0 },
	redeem = function(self, voucher)
		G.GAME.cost_credits_default = G.GAME.cost_credit_default - 2
		G.GAME.cost_dollars_default = G.GAME.cost_dollars_default - 2
		G.GAME.cost_sparks_default = G.GAME.cost_sparks_default - 2
		G.GAME.cost_plincoins_default = G.GAME.cost_plincoins_default - 2
	end,
    loc_vars = function (self, info_queue, card)
		return {
			vars = {
				(G.GAME.credits_cashout or 0)
			}
		}
	end,
	
        ppu_artist = {'No Art'},
        ppu_coder = {'Revo'},
        idea = {'Corobo'},
        ppu_team = {'Team Name'}
    }
}

SMODS.Voucher {
	key = 'intership',
	pos = { x = 3, y = 0 },
	requires = {
		'v_hpot_costcutting'
	},
	
        ppu_artist = {'No Art'},
        ppu_coder = {'Revo'},
        idea = {'Corobo'},
        ppu_team = {'Team Name'}
    }
}]]


--[[SMODS.Voucher {
	key = 'bachelor', --modifications are guaranteed
	pos = { x = 2, y = 0 },
    loc_vars = function (self, info_queue, card)
		return {
			vars = {
				(G.GAME.credits_cashout or 0)
			}
		}
	end,
	
        ppu_artist = {'No Art'},
        ppu_coder = {'Revo'},
        idea = {'Corobo'},
        ppu_team = {'Team Name'}
    }
}

SMODS.Voucher {
	key = 'intership',  -- cards cannot have a bad modifier
	pos = { x = 3, y = 0 },
	requires = {
		'v_hpot_costcutting'
	},
	
        ppu_artist = {'No Art'},
        ppu_coder = {'Revo'},
        idea = {'Corobo'},
        ppu_team = {'Team Name'}
    }
}]]