--- did i do this right? idk

---@class HPTN.Modification: SMODS.GameObject
---@field obj_buffer? Modifications|string[] Array of keys to all objects registered to this class.
---@field obj_table? table<Modifications|string, HPTN.Modifications|table> Table of objects registered to this class.
---@field super? SMODS.GameObject|table Parent class.
---@field atlas? string Key to the center's atlas.
---@field pos? table|{x: integer, y: integer} Position of the center's sprite.
---@field morality? string use to define if effect is good or bad.
---@field hide_badge? boolean Sets if the badge shows up on the card.
---@field badge_colour? table HEX color the badge uses.
---@field sets? string[] Array of keys to pools that this modification is allowed to be applied on.
---@field needs_enabled_flag? boolean Sets whether the modification requires `G.GAME.modifiers["enable_"..key]` to be `true` before it can be applied.
---@field check_duplicate_register? fun(self: HPTN.Modifications|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: HPTN.Modifications|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: HPTN.Modifications|table) Registers the object.
---@field inject? fun(self: HPTN.Modifications|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field loc_vars? fun(self: HPTN.Modifications|table, info_queue: table, card: Card|table): table? Provides control over displaying descriptions and tooltips of the modification's tooltip.
---@field calculate? fun(self: HPTN.Modifications|table, card: Card|table, context: CalcContext|table): table?, boolean?  Calculates effects based on parameters in `context`. See [SMODS calculation](https://github.com/Steamodded/smods/wiki/calculate_functions) docs for details.
---@field apply? fun(self: HPTN.Modifications|table, card: Card|table, val: any) Handles applying and removing the modification. By default, sets `card.ability[self.key] = val`.
---@field draw? fun(self: HPTN.Modifications|table, card: Card|table, layer: string) Draws the sprite and shader of the modification.
---@overload fun(self: SHPTN.Modifications): HPTN.Modifications

HPTN.Modifications = {}
HPTN.Modification = SMODS.GameObject:extend({
	required_params = { "key" },
	set = "Modification",
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	pos2 = { x = 0, y = 1 },
	obj_table = HPTN.Modifications,
	obj_buffer = {},
	sets = { Joker = true },
	unlocked = true,
	discovered = true,
	config = {},
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	class_prefix = "modif",
	hide_badge = false,
	needs_enable_flag = true,
	register = function(self)
		if self.registered then
			sendWarnMessage(("Detected duplicate register call on object %s"):format(self.key), self.set)
			return
		end
		HPTN.Modification.super.register(self)
		self.order = #self.obj_buffer
	end,
	inject = function(self)
		self.sticker_sprite = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[self.atlas], self.pos)
		G.shared_stickers[self.key] = self.sticker_sprite

		if not G.modif_corner then
			G.modif_corner = {}
		end

		self.sticker_sprite2 = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[self.atlas], self.pos2)
		G.modif_corner[self.key] = self.sticker_sprite2
		
	end,
	apply = function(self, card, val)
		if val then
			card.modif = self.key
		else
			card.modif = nil
		end
		card.ability[self.key] = val
		if val and self.config and next(self.config) then
			card.ability[self.key] = {}
			for k, v in pairs(self.config) do
				if type(v) == "table" then
					card.ability[self.key][k] = copy_table(v)
				else
					card.ability[self.key][k] = v
				end
			end
		end
		SMODS.calculate_context({ -- unused
			hpot_mod_apply = true,
			hpot_mod_applied = self,
			hpot_mod_applied_to = card,
		})
	end,
	loc_vars = function(self)
		return {}
	end,
	pre_inject_class = function(self)
		G.P_CENTER_POOLS[self.set] = {}
	end,
	applied = function(self, card) end,
})

-- i tried to get this to work with photograph and couldnt figure it out
-- so if someone else wants to try to fix it feel free - ruby

-- this could've been inside of 1 drawstep but i got lazy - revo
SMODS.DrawStep({ -- drawstep like stickers
	key = "modifications",
	order = 39,
	func = function(self, layer)
		if self.modif and G.shared_stickers[self.modif] then
			G.shared_stickers[self.modif].role.draw_major = self
			G.shared_stickers[self.modif]:draw_shader("dissolve", nil, nil, nil, self.children.center)
			G.shared_stickers[self.modif]:draw_shader(
				"voucher",
				nil,
				self.ARGS.send_to_shader,
				nil,
				self.children.center
			)
		end

		for k, v in pairs(HPTN.Modifications) do
			if self.ability[v.key] then
				if v and v.draw and type(v.draw) == "function" then
					v:draw(self, layer)
				else
					G.shared_stickers[v.key].role.draw_major = self
					G.shared_stickers[v.key]:draw_shader("dissolve", nil, nil, nil, self.children.center)
					G.shared_stickers[v.key]:draw_shader(
						"voucher",
						nil,
						self.ARGS.send_to_shader,
						nil,
						self.children.center
					)
				end
			end
		end
	end,
	conditions = { vortex = false, facing = "front" },
})

SMODS.DrawStep({ -- drawstep like stickers
	key = "modifications2",
	order = 39,
	func = function(self, layer)
	if (self.children.center.scale.y + 0) >= 95 and (self.children.center.scale.x + 0) >= 71 then
		if self.modif and G.modif_corner[self.modif] then
			G.modif_corner[self.modif].role.draw_major = self
			G.modif_corner[self.modif]:draw_shader("dissolve", nil, nil, nil, self.children.center)
			G.modif_corner[self.modif]:draw_shader(
				"voucher",
				nil,
				self.ARGS.send_to_shader,
				nil,
				self.children.center
			)
		end

		for k, v in pairs(HPTN.Modifications) do
			if self.ability[v.key] then
				if v and v.draw and type(v.draw) == "function" then
					v:draw(self, layer)
				else
					G.modif_corner[v.key].role.draw_major = self
					G.modif_corner[v.key]:draw_shader("dissolve", nil, nil, nil, self.children.center)
					G.modif_corner[v.key]:draw_shader(
						"voucher",
						nil,
						self.ARGS.send_to_shader,
						nil,
						self.children.center
					)
				end
			end
		end
	end
end,
	conditions = { vortex = false, facing = "front" },
})

-- check smods stickers stuff for more info on these
function HPTN.modif_apply(modif, card)
	local sticker = HPTN.Modifications[modif]
	sticker:apply(card, true)
	SMODS.enh_cache:write(card, nil)
end

function Card:remove_modification(modif)
	if self.ability[modif] then
		HPTN.Modifications[modif]:apply(self, false)
		SMODS.enh_cache:write(self, nil)
	end
end

function Card:calculate_modification(context, key)
	local modif = HPTN.Modifications[key]
	if self.ability[key] and type(modif.calculate) == "function" then
		local o = modif:calculate(self, context)
		if o then
			if not o.card then
				o.card = self
			end
			return o
		end
	end
end

-- the ui page

local function mod_ui()
	local mods = {}

	for k, v in pairs(HPTN.Modifications) do
		mods[k] = v
	end

	return SMODS.card_collection_UIBox(mods, { 5, 5 }, {
		snap_back = true,
		hide_single_page = true,
		collapse_single_page = true,
		center = "c_base",
		h_mod = 1.18,
		back_func = "your_collection_other_gameobjects",
		modify_card = function(card, center)
			center:apply(card, true)
		end,
	})
end

G.FUNCS.your_collection_hpot_modifications = function()
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu({
		definition = mod_ui(),
	})
end

-- Modifications

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	key = "ruthless",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ xmult = 1.5 }, card)
			card.trigger_modif = nil
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	key = "greedy",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and not context.other_context.mod_probability and not context.other_context.fix_probability then
			SMODS.calculate_effect({ dollars = 2 }, card)

		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	key = "jumpy",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ xmult = 1.3 }, card)
			card.trigger_modif = nil
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	key = "invested",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.end_of_round and not context.individual and not context.repetition then
			if card.set_cost then
				card.ability.extra_value = (card.ability.extra_value or 0) + 1
				card:set_cost()
			end
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },
--[[HPTN.Modification({  %150 Mult Chip output
	    atlas = "tname_modifs",
    pos = { x = 0, y = 0 },
    hpot_anim = {
        { xrange = { first = 0, last = 8 }, y = 2, t = 0.1 }
    },
	key = "magnified",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
        if context.post_trigger and context.other_card == card then
			for k, v in pairs(context.other_ret) do
				print(k, v)
			end
		end
	end,
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },]
	ppu_team = { "Team Name" },N.Modification({
	atlas = "tname_modifs",
	pos = { x = 2, y = 0 },
	pos2 = { x = 2, y = 1 },
	key = "damaged",
	morality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(card, 1, 5, "hpot_damaged")
		return {
			vars = { numerator, demonimator },
		}
	end,
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and not context.other_context.mod_probability and not context.other_context.fix_probability then
			if SMODS.pseudorandom_probability(card, "hpot_damaged", 1, 5) then
				SMODS.destroy_cards(card)
			end
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },  atlas = "tname_modifs",
    pos = { x = 0, y = 0 },
    hpot_anim = {
        { xrange = { first = 0, last = 8 }, y = 2, t = 0.1 }
    },
	key = "old",
	morality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	calculate = function(self, card, context)
        --brrr
	end,
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },]
	ppu_team = { "Team Name" },N.Modification({
	ppu_team = { "Team Name" },s = { x = 0, y = 0 },
	key = "supported",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ xmult = 1.1 }, card)
			card.trigger_modif = nil
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
})

	ppu_team = { "Team Name" },las = "tname_modifs",
	ppu_team = { "Team Name" },s2 = { x = 2, y = 1 },
	key = "dozing",
	morality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	loc_vars = function(self, info_queue, card)
		local numerator, demonimator = SMODS.get_probability_vars(card, 1, 3, "hpot_dozing")
		return {
			vars = { numerator, demonimator },
		}
	end,
	calculate = function(self, card, context)
		if
			context.setting_blind
			and not card.prevent_trigger
			and SMODS.pseudorandom_probability(card, "hpot_dozing", 1, 3)
		then
			card.prevent_trigger = true
			SMODS.calculate_effect({ message = localize("k_hotpot_trigger_disabled") }, card)
		end

		if context.ending_shop and card.prevent_trigger then
			card.prevent_trigger = nil
			SMODS.calculate_effect({ message = localize("k_hotpot_trigger_enabled") }, card)
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },

reset_hyper = function()
	ppu_team = { "Team Name" },f not v.ability.hpot_blunder then
	ppu_team = { "Team Name" },         if v.prevent_trigger then
                v.prevent_trigger = nil
				card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_hotpot_trigger_enabled") })
            else
                v.prevent_trigger = true
				card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_hotpot_trigger_disabled") })
            end
		else
			if v.prevent_trigger then
				v.prevent_trigger = nil
				card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_hotpot_trigger_enabled") })
			end
        end
    end
end
end

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 2, y = 0 },
	pos2 = { x = 2, y = 1 },
	key = "hyper",
	morality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	apply = function(self, card, val)
		card.ability[self.key] = val
		if val and self.config and next(self.config) then
			card.ability[self.key] = {}
			for k, v in pairs(self.config) do
				if type(v) == "table" then
					card.ability[self.key][k] = copy_table(v)
				else
					card.ability[self.key][k] = v
				end
			end
		end
		SMODS.calculate_context({
			hpot_mod_apply = true,
			hpot_mod_applied = self,
			hpot_mod_applied_to = card,
		})

		card.ability.hpot_trig = true


	end,
	calculate = function(self, card, context)
		local fucking_kys

		fucking_kys = fucking_kys


		if context.retrigger_joker_check and not context.retrigger_joker and not card.prevent_trigger and context.other_card == card then
			return {
				repetitions = 1,
			}
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },
HPTN.Modification({
	atlas = "tname_modifs",
	ppu_team = { "Team Name" },s2 = { x = 2, y = 1 },
	ppu_team = { "Team Name" },rality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ xmult = 0.9}, card)
			card.trigger_modif = nil
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },N.Modification({
	atlas = "tname_modifs",
	pos = { x = 2, y = 0 },
	ppu_team = { "Team Name" },y = "depreciating",
	ppu_team = { "Team Name" },dge_colour = G.C.DARK_EDITION,
	calculate = function(self, card, context)
		if context.end_of_round and not context.individual and not context.repetition then
			if card.set_cost then
				card.ability.extra_value = (card.ability.extra_value or 0) - 1
				card:set_cost()
			end
		end
	end,
	
	ppu_artist = { "Revo" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },
	ppu_team = { "Team Name" },
HPTN.Modification({
	atlas = "tname_modifs",
	ppu_team = { "Team Name" },y = "sharpened",
	ppu_team = { "Team Name" },dge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ mult = 10}, card)
		end
	end,
	
		idea = { "lord.ruby" },
	ppu_coder = { "lord.ruby" },
	ppu_team = { "Horsechicot" },
	},
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	key = "jagged",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ chips = 50}, card)
			card.trigger_modif = nil
		end
	end,
	
		idea = { "lord.ruby" },
	ppu_coder = { "lord.ruby" },
	ppu_team = { "Horsechicot" },
	},
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	key = "spiked",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ xchips = 1.2}, card)
			card.trigger_modif = nil
		end
	end,
	
		idea = { "lord.ruby" },
	ppu_coder = { "lord.ruby" },
	ppu_team = { "Horsechicot" },
	},
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 0, y = 0 },
	key = "menacing",
	morality = "GOOD",
	badge_colour = HEX("4bc292"),
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ xchips = 1.5 }, card)
			card.trigger_modif = nil
		end
	end,
	
		idea = { "lord.ruby" },
	ppu_coder = { "lord.ruby" },
	ppu_team = { "Horsechicot" },
	},
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 2, y = 0 },
	pos2 = { x = 2, y = 1 },
	key = "dull",
	morality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ mult = -5}, card)
			card.trigger_modif = nil
		end
	end,
	
		idea = { "lord.ruby" },
	ppu_coder = { "lord.ruby" },
	ppu_team = { "Horsechicot" },
	},
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 2, y = 0 },
	pos2 = { x = 2, y = 1 },
	key = "flawed",
	morality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ xchips = 0.8}, card)
			card.trigger_modif = nil
		end
	end,
	
		idea = { "lord.ruby" },
	ppu_coder = { "lord.ruby" },
	ppu_team = { "Horsechicot" },
	},
})

HPTN.Modification({
	atlas = "tname_modifs",
	pos = { x = 2, y = 0 },
	pos2 = { x = 2, y = 1 },
	key = "rusty",
	morality = "BAD",
	badge_colour = G.C.DARK_EDITION,
	calculate = function(self, card, context)
		if context.post_trigger and context.other_card == card and HPTN.during_scoring then
			card.trigger_modif = true
		end
		if context.final_scoring_step and card.trigger_modif then
			SMODS.calculate_effect({ chips = -25}, card)
			card.trigger_modif = nil
		end
	end,
	
		idea = { "lord.ruby" },
	ppu_coder = { "lord.ruby" },
	ppu_team = { "Horsechicot" },
	},
})


local localize_ref = localize
function localize(args, misc_cat)
	if type(args) == "table" then
		args.vars = args.vars or {}
	end
	return localize_ref(args, misc_cat)
end
