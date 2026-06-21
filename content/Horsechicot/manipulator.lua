--Using this system is basically a sin but its only used in Unstable Deck currently and i hope to keep it that way
--Stolen from Cryptlib because i wrote it all - ruby

if Cryptid then
    return
end

HotPotato.base_values = {}

HotPotato.misprintize_value_blacklist = {
	perish_tally = false,
	id = false,
	suit_nominal = false,
	base_nominal = false,
	face_nominal = false,
	qty = false,
	h_x_chips = false,
	d_size = false,
	h_size = false,
	selected_d6_face = false,
	cry_hook_id = false,
	colour = false,
	suit_nominal_original = false,
	times_played = false,
	extra_slots_used = false
	-- TARGET: Misprintize Value Blacklist (format: key = false, )
}
HotPotato.misprintize_bignum_blacklist = {
	odds = false,
	cry_prob = false,
	--nominal = false,
}

function HotPotato.log_random(seed, min, max)
	math.randomseed(seed)
	local lmin = math.log(min, 2.718281828459045)
	local lmax = math.log(max, 2.718281828459045)
	local poll = math.random() * (lmax - lmin) + lmin
	return math.exp(poll)
end
function hot_format(number, str)
	if math.abs((number)) >= (1e300) then
		return number
	end
	return tonumber(str:format((Big and ((number)) or number)))
end
--use ID to work with glitched/misprint
function Card:get_nominal(mod)
	local mult = 1
	local rank_mult = 1
	if mod == "suit" then
		mult = 1000000
	end
	if self.ability.effect == "Stone Card" or (self.config.center.no_suit and self.config.center.no_rank) then
		mult = -10000
	elseif self.config.center.no_suit then
		mult = 0
	elseif self.config.center.no_rank then
		rank_mult = 0
	end
	return 10 * (self.base.id or 0.1) * rank_mult
		+ self.base.suit_nominal * mult
		+ (self.base.suit_nominal_original or 0) * 0.0001 * mult
		+ 10 * self.base.face_nominal * rank_mult
		+ 0.000001 * self.unique_val
end

function HotPotato.manipulate(card, args)
    if not card or not card.config or not card.config.center then return end
	if not card.config.center.immutable or (args and args.bypass_checks) then
		if not args then
			return HotPotato.manipulate(card, {
				min = (G.GAME.modifiers.cry_misprint_min or 1),
				max = (G.GAME.modifiers.cry_misprint_max or 1),
				type = "X",
				dont_stack = true,
				no_deck_effects = true,
			})
		else
			local func = function(card)
				if not args.type then
					args.type = "X"
				end
				--hardcoded whatever
				if card.config.center.set == "Booster" then
					args.big = false
				end
				local caps = card.config.center.misprintize_caps or {}
				if card.infinifusion then
					if card.config.center == card.infinifusion_center or card.config.center.key == "j_infus_fused" then
						calculate_infinifusion(card, nil, function(i)
							HotPotato.manipulate(card, args)
						end)
					end
				end
				HotPotato.manipulate_table(card, card, "ability", args)
				if card.base then
					HotPotato.manipulate_table(card, card, "base", args)
				end
				if G.GAME.modifiers.cry_misprint_min then
					--card.cost = hot_format(card.cost / HotPotato.log_random(pseudoseed('cry_misprint'..G.GAME.round_resets.ante),override and override.min or G.GAME.modifiers.cry_misprint_min,override and override.max or G.GAME.modifiers.cry_misprint_max),"%.2f")
					card.misprint_cost_fac = 1
						/ HotPotato.log_random(
							pseudoseed("cry_misprint" .. G.GAME.round_resets.ante),
							override and override.min or G.GAME.modifiers.cry_misprint_min,
							override and override.max or G.GAME.modifiers.cry_misprint_max
						)
					card:set_cost()
				end
				if caps then
					for i, v in pairs(caps) do
						if type(v) == "table" and not v.tetrate then
							for i2, v2 in pairs(v) do
								if (card.ability[i][i2]) > (v2) then
									card.ability[i][i2] = HotPotato.sanity_check(v2, false)
								end
							end
						elseif (type(v) == "table" and v.tetrate) or type(v) == "number" then
							if (card.ability[i]) > (v) then
								card.ability[i] = HotPotato.sanity_check(v, false)
							end
						end
					end
				end
			end
			local config = copy_table(card.config.center.config)
			if not HotPotato.base_values[card.config.center.key] then
				HotPotato.base_values[card.config.center.key] = {}
				for i, v in pairs(config) do
					if (type(v) == "table" and v.tetrate) or type(v) == "number" and (v) ~= (0) then
						HotPotato.base_values[card.config.center.key][i .. "ability"] = v
					elseif type(v) == "table" then
						for i2, v2 in pairs(v) do
							HotPotato.base_values[card.config.center.key][i2 .. i] = v2
						end
					end
				end
			end
			if not args.bypass_checks and not args.no_deck_effects then
				HotPotato.with_deck_effects(card, func)
			else
				func(card)
			end
			if card.ability.consumeable then
				for k, v in pairs(card.ability.consumeable) do
					card.ability.consumeable[k] = HotPotato.deep_copy(card.ability[k])
				end
			end
			--ew ew ew ew
			G.P_CENTERS[card.config.center.key].config = config
		end
		return true
	end
end

function HotPotato.manipulate_table(card, ref_table, ref_value, args, tblkey)
	if ref_value == "consumeable" then
		return
	end
	for i, v in pairs(ref_table[ref_value]) do
		if
			(type(v) == "number" or (type(v) == "table" and v.tetrate))
			and HotPotato.misprintize_value_blacklist[i] ~= false
		then
			local num = v
			if args.dont_stack then
				if
					HotPotato.base_values[card.config.center.key]
					and (
						HotPotato.base_values[card.config.center.key][i .. ref_value]
						or (ref_value == "ability" and HotPotato.base_values[card.config.center.key][i .. "consumeable"])
					)
				then
					num = HotPotato.base_values[card.config.center.key][i .. ref_value]
						or HotPotato.base_values[card.config.center.key][i .. "consumeable"]
				end
			end
			if args.big ~= nil then
				ref_table[ref_value][i] = HotPotato.manipulate_value(num, args, args.big, i)
			else
				ref_table[ref_value][i] = HotPotato.manipulate_value(num, args, false, i)
			end
		elseif i ~= "immutable" and type(v) == "table" and HotPotato.misprintize_value_blacklist[i] ~= false then
			HotPotato.manipulate_table(card, ref_table[ref_value], i, args)
		end
	end
end

function HotPotato.manipulate_value(num, args, is_big, name)
	if args.func then
		num = args.func(num, args, is_big, name)
	else
		if args.min and args.max then
			local big_min = (args.min)
			local big_max = (args.max)
			local new_value = HotPotato.log_random(
				pseudoseed(args.seed or ("cry_misprint" .. G.GAME.round_resets.ante)),
				big_min,
				big_max
			)
			if args.type == "+" then
				if (num) ~= (0) and (num) ~= (1) then
					num = num + new_value
				end
			elseif args.type == "X" then
				if
					(num) ~= (0) and ((num) ~= (1) or (name ~= "x_chips" and name ~= "x_mult"))
				then
					num = num * new_value
				end
			elseif args.type == "^" then
				num = (num) ^ new_value
			elseif args.type == "hyper" and SMODS.Mods.Talisman and SMODS.Mods.Talisman.can_load then
				if (num) ~= (0) and (num) ~= (1) then
					num = (num):arrow(args.value.arrows, (new_value))
				end
			end
		elseif args.value then
			if args.type == "+" then
				if (num) ~= (0) and (num) ~= (1) then
					num = num + (args.value)
				end
			elseif args.type == "X" then
				if
					(num) ~= (0) and ((num) ~= (1) or (name ~= "x_chips" and name ~= "x_mult"))
				then
					num = num * args.value
				end
			elseif args.type == "^" then
				num = (num) ^ args.value
			elseif args.type == "hyper" and SMODS.Mods.Talisman and SMODS.Mods.Talisman.can_load then
				num = (num):arrow(args.value.arrows, (args.value.height))
			end
		end
	end
	if HotPotato.misprintize_bignum_blacklist[name] == false then
		num = (num)
		return (HotPotato.sanity_check(num, false))
	end
	local val = HotPotato.sanity_check(num, is_big)
	if to_big(val) > to_big(-1e100) and to_big(val) < to_big(1e100) then
		return (val)
	end
	return val
end

local get_nominalref = Card.get_nominal
function Card:get_nominal(...)
	return (get_nominalref(self, ...))
end

local gsr = Game.start_run
function Game:start_run(args)
	gsr(self, args)
	HotPotato.base_values = {}
end

function HotPotato.sanity_check(val, is_big)
	if not Talisman then return val end
	if is_big then
		if not val or type(val) == "number" and (val ~= val or val > 1e300 or val < -1e300) then
			val = 1e300
		end
		if type(val) == "table" then
			return val
		end
		if val > 1e100 or val < -1e100 then
			return (val)
		end
	end
	if not val or type(val) == "number" and (val ~= val or val > 1e300 or val < -1e300) then
		return 1e300
	end
	if type(val) == "table" then
		if val > to_big(1e300) then
			return 1e300
		end
		if val < to_big(-1e300) then
			return -1e300
		end
		return (val)
	end
	return val
end

function HotPotato.with_deck_effects(card, func)
	if not card.added_to_deck then
		return func(card)
	else
		card.from_quantum = true
		card:remove_from_deck(true)
		local ret = func(card)
		card:add_to_deck(true)
		card.from_quantum = nil
		return ret
	end
end

function HotPotato.deep_copy(obj, seen)
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do
		res[HotPotato.deep_copy(k, s)] = HotPotato.deep_copy(v, s)
	end
	return res
end
