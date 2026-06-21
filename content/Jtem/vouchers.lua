SMODS.Voucher {
	key = 'exchange_rate',
	atlas = "jtem_vouchers",
	pos = { x = 0, y = 0 },
	loc_vars = function (self, info_queue, card)
		local key
		local fucking = G.GAME.seeded and "_budget" or ""
		key = (self.key .. fucking)
		return {key = key}
	end,
	redeem = function(self, voucher)
		G.GAME.hp_jtem_should_allow_buying_jx_from_plincoin = true
		G.GAME.hp_jtem_should_allow_buying_jx_from_credits = true
		G.GAME.hp_jtem_should_allow_buying_jx_from_crypto = true
	end,
    ppu_artist = {'MissingNumber'},
    ppu_coder = {'Haya'},
    ppu_team = {'Jtem'}
}

SMODS.Voucher {
	key = 'right_at_your_door',
	atlas = "jtem_vouchers",
	pos = { x = 0, y = 1 },
    requires = {
		'v_hpot_exchange_rate'
	},
	redeem = function(self, voucher)
		G.GAME.hp_jtem_should_allow_custom_order = true
	end,
    ppu_artist = {'MissingNumber'},
    ppu_coder = {'Haya'},
    ppu_team = {'Jtem'}
}

SMODS.Voucher {
	key = 'cargo_size_upgrade',
	atlas = "jtem_delivery_vouchers",
	pos = { x = 0, y = 0 },
	config = {
		extras = {
			add = 1
		}
	},
	redeem = function(self, voucher)
		G.GAME.hp_jtem_special_offer_count = (G.GAME.hp_jtem_special_offer_count or 3) + voucher.ability.extras.add
        hotpot_jtem_init_extra_shops_area()
		simple_add_event(
			function ()
				hotpot_jtem_generate_special_deals()
				return true
			end
		)
	end,
	loc_vars = function (self, info_queue, card)
		return {
			vars = {
				card.ability.extras.add,
				(G.GAME.hp_jtem_special_offer_count or 3)
			}
		}
	end,
    ppu_artist = {'Aikoyori'},
    ppu_coder = {'Aikoyori'},
    ppu_team = {'Jtem'}
}

SMODS.Voucher {
	key = 'delivery_fleet_upgrade',
	atlas = "jtem_delivery_vouchers",
	pos = { x = 1, y = 0 },
	config = {
		extras = {
			add = 1
		}
	},
	loc_vars = function (self, info_queue, card)
		return {
			vars = {
				card.ability.extras.add,
				(G.GAME.hp_jtem_queue_max_size or 2)
			}
		}
	end,
	redeem = function(self, voucher)
		G.GAME.hp_jtem_queue_max_size = (G.GAME.hp_jtem_queue_max_size or 2) + voucher.ability.extras.add
	end,
	requires = {
		'v_hpot_cargo_size_upgrade'
	},
    ppu_artist = {'Aikoyori'},
    ppu_coder = {'Aikoyori'},
    ppu_team = {'Jtem'}
}