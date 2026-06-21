-- Hey, you, from another team!
-- Here's an Event's, an special round where player should make choices to gain buffs/debuffs/rewards/get silly dialog etc.
-- If you played games like Slay the Spire or Monster Train, this is (?) node event.
-- They appear guaranteed after leaving shop after Small Blind.
--
-- While it's fully functional, unfortunately it's not developed well enough (in terms of content).
-- I just don't have enough good ideas in my head to implement. But maybe YOU have!
-- So, if you want' you can make some own events.

G.STATES.HOTPOT_EVENT_SELECT = 198275827
G.STATES.HOTPOT_EVENT = 198275828

SMODS.Atlas({
	key = "hpot_event_default",
	px = 34,
	py = 34,
	path = "Events/default.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local event_colour = HEX("A17CFF")

---@class EventData
---@field scenario HotPotato.EventScenario|table Current scenario
---@field previous_step? HotPotato.EventStep|table Previous step
---@field current_step HotPotato.EventStep|table Current step
---@field next_step? HotPotato.EventStep|table Next step
---@field ability table Table similar to `card.ability`, can be used for sroting data between steps
---@field ui UIBox|table Main event ui
---@field image_area UIBox|table Black box on left side of event ui, mainly for displaying cutscenes or images
---@field text_area UIBox|table Container for all event text
---@field choices_area UIBox|table Container for all event choices
---@field display_lines fun(amount?: number, instant?: boolean) Display fixed amount of text lines (and place it in event queue)
---@field get_image_center fun(w?: number, h?: number): x: number, y: number Center position of image area (including card wight and height)
---@field start_step fun(key: string) Move to another step
---@field finish_scenario fun() End event

---@class EventChoice
---@field key? string The key for the event.
---@field loc_vars? table List of variables for setting the choice's text.
---@field text? table Choice text. Uses localization from `key` if unspecified and vice versa.
---@field button? function Function to run when selecting this choice.
---@field func? fun(): boolean Determines if the choice is selectable.
---@field no_prefix? boolean Determines if `key` does not take the prefix of the current event scenario.

HotPotato.EventSteps = {}
---@class HotPotato.EventStep: SMODS.GameObject
---@field get_choices fun(self: HotPotato.EventStep|table, event: EventData): EventChoice[] Function that returns a table of choices.
---@field hide_hand? boolean Should hide hand card area during this step
---@field hide_deck? boolean Should hide deck during this step
---@field start? fun(self: HotPotato.EventStep|table, event: EventData) Function that runs when this step is started.
---@field finish? fun(self: HotPotato.EventStep|table, event: EventData) Function that runs when this step is finished.
---@field loc_vars? fun(self: HotPotato.EventStep|table, event: EventData): table? Provides control over displaying descriptions for this event step.
---@overload fun(o: HotPotato.EventStep): HotPotato.EventStep
HotPotato.EventStep = SMODS.GameObject:extend({
	obj_table = HotPotato.EventSteps,
	set = "EventSteps",
	obj_buffer = {},
	required_params = {
		"key",
	},
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.descriptions.EventSteps, self.key:lower(), self.loc_txt)
		if self.loc_txt and self.loc_txt.choices then
			for k, _ in pairs(self.loc_txt.choices) do
				SMODS.process_loc_text(
					G.localization.misc.EventChoices,
					self.key:lower() .. "_" .. k,
					self.loc_txt.choices[k]
				)
			end
		end
	end,

	config = {
		extra = {},
	},

	hide_hand = true,
	hide_deck = false,

	get_choices = function(self, scenario)
		return {
			{
				key = "leave",
				loc_vars = {},
				text = "Leave",
				button = function()
					hpot_event_end_scenario()
				end,
				func = function()
					return true
				end,
			},
		}
	end,

	stppu_artist = function(self, scenario, previous_step, is_load) end,
	finish = function(self, scenario, next_step) end,

	loc_vars = function(self)
		return {}
	end,

	inject = function() end,
})

---@alias EventDomain
---| 'combat'
---| 'occurence'
---| 'encounter'
---| 'transaction'
---| 'reward'
---| 'adventure'
---| 'wealth'
---| 'escapade'
---| 'respite'

HotPotato.EventScenarios = {}
---@class HotPotato.EventScenario: SMODS.GameObject
---@field domains? table<EventDomain|string, true> Domain pool the scenario belongs to.
---@field can_repeat? boolean If the event can repeat even if all the other events weren't exhausted.
---@field hide_image_area? boolean Hides image area for this event.
---@field in_pool? fun(self: HotPotato.EventScenario|table): boolean Determines if this scenario can be chosen.
---@field get_weight? fun(self: HotPotato.EventScenario|table): number Determines the weight of the scenario being chosen.
---@field weight? number Used if `get_weight` isn't specified.
---@field starting_step_key string The key to the desired step to start with for this scenario.
---@field loc_vars? fun(self: HotPotato.EventScenario|table): table? Provides control over displaying descriptions for this event scenario. `text` is only used for the collection.
---@field collection_loc_vars? fun(self: HotPotato.EventScenario|table, info_queue: table): table?
---@overload fun(o: HotPotato.EventScenario): HotPotato.EventScenario
HotPotato.EventScenario = SMODS.GameObject:extend({
	obj_table = HotPotato.EventScenarios,
	set = "EventScenarios",
	obj_buffer = {},
	required_params = {
		"key",
		"starting_step_key",
	},
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.descriptions.EventScenarios, self.key:lower(), self.loc_txt)
	end,
	domains = { occurence = true },
	can_repeat = false,
	weight = 5,
	hide_image_area = false,
	in_pool = function(self)
		return true
	end,
	get_weight = function(self)
		return self.weight
	end,

	loc_vars = function(self)
		return {}
	end,
	collection_loc_vars = function(self, info_queue)
		return {}
	end,

	inject = function(self)
		SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
	end,
	pre_inject_class = function(self)
		G.P_CENTER_POOLS[self.set] = {}
	end,

	atlas = "hpot_event_default",
	pos = { x = 0, y = 0, },

	-- Events basically added by me so..
	-- Haya my goat <3
	ppu_coder = { "SleepyG11", "Haya" },
	ppu_team = { "Jtem" },
})

local your_collection_tabs = HotPotato.custom_collection_tabs
HotPotato.custom_collection_tabs = function()
	return {
		your_collection_tabs and next(your_collection_tabs()) and unpack(your_collection_tabs()) or nil,
		UIBox_button({
			button = 'your_collection_hpot_events',
			id = 'your_collection_hpot_events',
			label = { localize('k_events') },
			minw = 5,
			minh = 1
		}),
		UIBox_button({
			button = 'your_collection_hpot_modifications',
			id = 'your_collection_hpot_modifications',
			label = { "Modifications" },
			minw = 5,
			minh = 1
		}),
	}
end

local function event_collection_ui(e)
	local chosen = (e.config.ref_table or {}).key or "occurence"
	local pool = {}

	for _, event in ipairs(G.P_CENTER_POOLS.EventScenarios) do
		if event.domains and event.domains[chosen] then
			pool[#pool + 1] = event
		end
	end

	return SMODS.card_collection_UIBox(pool, { 5, 5 }, {
		snap_back = true,
		hide_single_page = true,
		collapse_single_page = true,
		center = 'c_base',
		h_mod = 1.18,
		back_func = 'your_collection_hpot_events',
		infotip = {
			"Events are encountered after the Boss Blind shop"
		},
		modify_card = function(card, center)
			local temp_blind = AnimatedSprite(card.children.center.T.x, card.children.center.T.y, 1.3, 1.3,
				G.ANIMATION_ATLAS[center.atlas], center.pos)
			temp_blind.states.click.can = false
			temp_blind.states.drag.can = false
			temp_blind.states.hover.can = true
			card.children.center = temp_blind
			temp_blind:set_role({ major = card, role_type = 'Glued', draw_major = card })
			card.set_sprites = function(...)
				local args = { ... }
				if not args[1].animation then return end -- fix for debug unlock
				local c = card.children.center
				Card.set_sprites(...)
				card.children.center = c
			end
			card.T.w = 1.3
			card.T.h = 1.3
			temp_blind:define_draw_steps({
				{ shader = 'dissolve', shadow_height = 0.05 },
				{ shader = 'dissolve' }
			})
			temp_blind.float = true
			card.hpot_event_key = center.key
		end,
	})
end

G.FUNCS.your_collection_hpot_events = function()
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu {
		definition = event_collection_domains_ui()
	}
end

G.FUNCS.your_collection_hpot_events_domain = function(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu {
		definition = event_collection_ui(e)
	}
end

SMODS.Gradient {
	key = 'event',
	colours = {
		G.C.RED,
		G.C.ORANGE,
		G.C.YELLOW,
		G.C.GREEN,
		G.C.BLUE,
		G.C.PURPLE,
	},
	cycle = 6,
	interpolation = 'linear'
}

-----------------

function Game:update_hpot_event_select(dt)
	if self.buttons then
		self.buttons:remove()
		self.buttons = nil
	end
	if self.shop then
		self.shop:remove()
		self.shop = nil
	end

	if not G.STATE_COMPLETE then
		stop_use()
		ease_background_colour_blind(G.STATES.BLIND_SELECT)
		G.E_MANAGER:add_event(Event({
			func = function()
				save_run()
				return true
			end,
		}))
		G.STATE_COMPLETE = true
		G.CONTROLLER.interrupt.focus = true
		G.E_MANAGER:add_event(Event({
			func = function()
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						play_sound("cancel")
						G.hpot_event_select = UIBox({
							definition = create_UIBox_hpot_event_select(),
							config = {
								align = "bmi",
								offset = { x = 0, y = G.ROOM.T.y + 29 },
								major = G.hand,
								bond = "Weak",
							},
						})
						G.hpot_event_select.alignment.offset.y = 0.8
							- (G.hand.T.y - G.jokers.T.y)
							+ G.hpot_event_select.T.h
						G.ROOM.jiggle = G.ROOM.jiggle + 3
						G.hpot_event_select.alignment.offset.x = 0
						G.CONTROLLER.lock_input = false
						if not G.GAME.hpot_event_first_time then
							open_hotpot_info("hotpot_events")
							G.GAME.hpot_event_first_time = true
						end
						return true
					end,
				}))
				return true
			end,
		}))
	end
end

function create_UIBox_hpot_event_choice(domain_key, index, total)
	local disabled = false
	local run_info = false

	local blind_choice = {
		config = G.P_BLINDS[G.GAME.round_resets.blind_choices["Big"]],
	}

	blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS['hpot_event_default'], {
		x = 0,
		y = 0,
	})
	blind_choice.animation:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
	})

	local loc_target = localize({
		type = "raw_descriptions",
		key = "hpot_event_encounter" .. (domain_key and ("_" .. domain_key) or ""),
		set = "Other",
		vars = { "" },
	})
	local loc_name = localize({
		type = "name_text",
		key = "hpot_event_encounter" ..
			(domain_key and ("_" .. domain_key) or ""),
		set = "Other"
	})
	local text_table = loc_target
	local blind_col = HotPotato.EventDomains[domain_key].colour or event_colour
	local loc_reward = ""
	if HotPotato.EventDomains[domain_key].reward_text_amount then
		for i = 1, HotPotato.EventDomains[domain_key].reward_text_amount do
			loc_reward = loc_reward .. "$"
		end
	else
		loc_reward = "???"
	end

	local t = {
		n = G.UIT.R,
		config = {
			align = "tm",
			minh = not run_info and 10 or nil,
			ref_table = { deck = nil, run_info = run_info },
			r = 0.1,
			padding = 0.05,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5),
					r = 0.1,
					outline = 1,
					outline_colour = G.C.L_BLACK,
				},
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.2 },
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									colour = disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE,
									minh = 0.6,
									minw = 2.7,
									padding = 0.07,
									r = 0.1,
									shadow = true,
									hover = true,
									one_press = true,
									button = "hpot_event_select",
									func = "hpot_event_can_select",
									ref_table = G.GAME.hpot_event_domain_choices,
									ref_value = index
								},
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = localize("Select", "blind_states"),
											scale = 0.45,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = not disabled,
										},
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { id = "blind_name", align = "cm", padding = 0.07 },
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									r = 0.1,
									outline = 1,
									outline_colour = blind_col,
									colour = darken(blind_col, 0.3),
									minw = 2.9,
									emboss = 0.1,
									padding = 0.07,
									line_emboss = 1,
								},
								nodes = {
									{
										n = G.UIT.O,
										config = {
											object = DynaText({
												string = loc_name,
												colours = { disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE },
												shadow = not disabled,
												float = not disabled,
												y_offset = -4,
												scale = 0.45,
												maxw = 2.8,
											}),
										},
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.05 },
						nodes = {
							{
								n = G.UIT.R,
								config = { id = "blind_desc", align = "cm", padding = 0.05 },
								nodes = {
									{
										n = G.UIT.R,
										config = { align = "cm" },
										nodes = {
											{
												n = G.UIT.R,
												config = { align = "cm", minh = 1.5 },
												nodes = {
													{ n = G.UIT.O, config = { object = blind_choice.animation } },
												},
											},
											text_table[1] and {
												n = G.UIT.R,
												config = {
													align = "cm",
													minh = 0.7,
													padding = 0.05,
													minw = 2.9,
												},
												nodes = {
													text_table[1] and {
														n = G.UIT.R,
														config = { align = "cm", maxw = 2.8 },
														nodes = {
															{
																n = G.UIT.T,
																config = {
																	text = text_table[1] or "-",
																	scale = 0.32,
																	colour = disabled and G.C.UI.TEXT_INACTIVE
																		or G.C.WHITE,
																	shadow = not disabled,
																},
															},
														},
													} or nil,
													text_table[2] and {
														n = G.UIT.R,
														config = { align = "cm", maxw = 2.8 },
														nodes = {
															{
																n = G.UIT.T,
																config = {
																	text = text_table[2] or "-",
																	scale = 0.32,
																	colour = disabled and G.C.UI.TEXT_INACTIVE
																		or G.C.WHITE,
																	shadow = not disabled,
																},
															},
														},
													} or nil,
												},
											} or nil,
										},
									},
									{
										n = G.UIT.R,
										config = {
											align = "cm",
											r = 0.1,
											padding = 0.05,
											minw = 3.1,
											colour = G.C.BLACK,
											emboss = 0.05,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = { align = "cm" },
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = localize("ph_blind_reward"),
															scale = 0.35,
															colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE,
															shadow = not disabled,
														},
													},
													{
														n = G.UIT.O,
														config = {
															object = DynaText({
																string = { loc_reward },
																colours = { G.C.MONEY },
																float = true,
																spacing = 3,
																scale = 0.7,
															}),
														},
													},
												},
											},
										},
									},
								},
							},
						},
					},
				},
			},
			index == total and {
				n = G.UIT.R,
				config = {
					align = "cm",
					minh = 2,
					maxh = 2
				},
			} or nil,
			index == total and {
				n = G.UIT.R,
				config = {
					align = "cm",
					minh = 0.6,
					maxh = 0.6
				},
				nodes = {
					{
						n = G.UIT.C,
						config = {
							align = "cm",
							minw = 2.3,
							maxw = 2.3
						},
					},
					{
						n = G.UIT.C,
						config = {
							align = "cm",
							colour = G.C.RED,
							r = 0.01,
							outline = 1,
							outline_colour = G.C.WHITE,
							minw = 0.5,
							maxw = 0.5,
							minh = 0.5,
							maxh = 0.5,
							button = "hpot_event_tutorial",
							hover = true,
							shadow = true,
						},
						nodes = {
							{
								n = G.UIT.T,
								config = { text = "?", colour = G.C.UI.TEXT_LIGHT, scale = 0.35 }
							}
						}
					},
				}
			} or nil,
			index == total and {
				n = G.UIT.R,
				config = {
					align = "cm",
					minh = 0.1,
					maxh = 0.1
				},
			} or nil,
		},
	}
	return t
end

G.FUNCS.hpot_event_tutorial = function(e)
	G.FUNCS.hotpot_info { menu_type = "hotpot_events" }
end

function create_UIBox_hpot_event_select()
	local choice_nodes = {}
	local choice_count = hpot_event_get_event_count({ source = "generic" }) or 2
	G.GAME.hpot_event_domain_choices_used = G.GAME.hpot_event_domain_choices_used or {}
	G.GAME.hpot_event_domain_choices = G.GAME.hpot_event_domain_choices or {}
	G.GAME.hpot_event_domains_this_run = G.GAME.hpot_event_domains_this_run or {}

	for i = 1, choice_count do
		local domain_key
		if G.GAME.hpot_event_domain_choices[i] then
			domain_key = G.GAME.hpot_event_domain_choices[i]
		else
			domain_key = hpot_event_get_event_domain()
			G.GAME.hpot_event_domain_choices_used[domain_key] = true
			G.GAME.hpot_event_domain_choices[i] = domain_key
			G.GAME.hpot_event_domains_this_run[domain_key] = true
		end

		local blind_col = HotPotato.EventDomains[domain_key].colour or event_colour

		local choice = UIBox({
			definition = {
				n = G.UIT.ROOT,
				config = { align = "cm", colour = G.C.CLEAR },
				nodes = {
					UIBox_dyn_container(
						{ create_UIBox_hpot_event_choice(domain_key, i, choice_count), },
						false,
						blind_col,
						mix_colours(G.C.BLACK, blind_col, 0.8)
					),
				},
			},
			config = { align = "bmi", offset = { x = 0, y = 0 } },
		})
		choice_nodes[#choice_nodes + 1] = { n = G.UIT.O, config = { align = "cm", object = choice } }
	end
	local t = {
		n = G.UIT.ROOT,
		config = { align = "tm", minw = width, r = 0.15, colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.5 },
				nodes = choice_nodes
			},
		},
	}
	return t
end

-----------------

function Game:update_hpot_event(dt)
	if not G.STATE_COMPLETE then
		stop_use()
		ease_background_colour_blind(G.STATES.BLIND_SELECT)
		G.E_MANAGER:add_event(Event({
			func = function()
				save_run()
				return true
			end,
		}))
		G.STATE_COMPLETE = true
		G.CONTROLLER.interrupt.focus = true
		G.E_MANAGER:add_event(Event({
			func = function()
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						hpot_event_start_scenario()
						return true
					end,
				}))
				return true
			end,
		}))
	end
end

function hpot_event_start_scenario()
	stop_use()
	local scenario_key = get_next_hpot_event(G.GAME.hpot_event_domain)
	G.GAME.round_resets.hpot_event_encountered = true
	local scenario = HotPotato.EventScenarios[scenario_key]
	G.GAME.hpot_event_scenario_data = {}
	G.GAME.hpot_event_scenario_key = scenario.key
	if not G.GAME.hpot_events_encountered then
		G.GAME.hpot_events_encountered = {}
	end
	G.GAME.hpot_events_encountered[scenario.key] = (G.GAME.hpot_events_encountered[scenario.key] or 0) + 1

	local event_ui = UIBox({
		definition = G.UIDEF.hpot_event(scenario),
		config = {
			align = "br",
			major = G.ROOM_ATTACH,
			bond = "Weak",
			offset = {
				x = -15.3,
				y = G.ROOM.T.y + 21,
			},
		},
	})

	G.hpot_event_ui = event_ui
	G.hpot_event_ui_image_area = G.hpot_event_ui:get_UIE_by_ID("image_area")
	G.hpot_event_ui_text_area = G.hpot_event_ui:get_UIE_by_ID("text_area")
	G.hpot_event_ui_choices_area = G.hpot_event_ui:get_UIE_by_ID("choices_area")

	G.hpot_event = {
		scenario = scenario,
		domain = G.GAME.hpot_event_domain,

		current_step = nil,
		previous_step = nil,
		next_step = HotPotato.EventSteps[scenario.starting_step_key],

		ability = G.GAME.hpot_event_scenario_data,

		ui = G.hpot_event_ui,
		image_area = G.hpot_event_ui_image_area,
		text_area = G.hpot_event_ui_text_area,
		choices_area = G.hpot_event_ui_choices_area,

		get_image_center = get_hpot_event_image_center,

		display_lines = hpot_event_display_lines,

		start_step = hpot_event_start_step,
		finish_scenario = hpot_event_end_scenario,
	}

	SMODS.calculate_context({ hpot_event_scenario_stppu_artist = true, event = G.hpot_event })

	G.E_MANAGER:add_event(Event({
		func = function()
			G.hpot_event_ui.alignment.offset.y = -8.5
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.75,
		func = function()
			play_sound("cardFan2")
			return true
		end,
	}))
	delay(0.25)
	G.E_MANAGER:add_event(Event({
		func = function()
			hpot_event_start_step(scenario.starting_step_key)
			return true
		end,
	}))
end

function hpot_event_move_to_scenario(key)
	if G.hpot_event then
		stop_use()
		G.GAME.facing_hpot_event = nil

		if G.hpot_event.current_step then
			G.hpot_event.current_step:finish(G.hpot_event)
			G.FUNCS.draw_from_hand_to_deck()
			SMODS.calculate_context({
				hpot_event_step_end = true,
				event = G.hpot_event
			})
		end

		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.calculate_context({ hpot_event_scenario_end = true, event = G.hpot_event })
				G.E_MANAGER:add_event(Event({
					trigger = "before",
					delay = 0.2,
					func = function()
						G.hpot_event.ui.alignment.offset.y = G.ROOM.T.y + 21
						return true
					end,
				}))
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						G.hpot_event.ui:remove()
						G.hpot_event = nil
						delay(0.3)
						return true
					end,
				}))
				force_hpot_event(key)
				hpot_event_start_scenario()
				return true
			end,
		}))
	end
end

function hpot_event_start_step(key)
	if G.hpot_event then
		local step = HotPotato.EventSteps[key]
		G.hpot_event.next_step = step

		G.E_MANAGER:add_event(Event({
			func = function()
				if G.hpot_event.current_step then
					G.hpot_event.current_step:finish(G.hpot_event)
					SMODS.calculate_context({
						hpot_event_step_end = true,
						event = G.hpot_event,
					})
				end
				G.E_MANAGER:add_event(Event({
					func = function()
						hpot_event_cleanup()
						G.hpot_event.previous_step = G.hpot_event.current_step
						G.hpot_event.current_step = G.hpot_event.next_step
						G.hpot_event.next_step = nil
						G.E_MANAGER:add_event(Event({
							func = function()
								hpot_event_prepare_text_lines()
								G.hpot_event.current_step:start(G.hpot_event)
								SMODS.calculate_context({
									hpot_event_step_stppu_artist = true,
									event = G.hpot_event,
								})
								G.E_MANAGER:add_event(Event({
									func = function()
										hpot_event_render_current_step()
										return true
									end,
								}))
								return true
							end,
						}))
						return true
					end,
				}))
				return true
			end,
		}))
	end
end

function hpot_event_end_scenario(to_combat)
	if G.hpot_event then
		stop_use()
		G.GAME.facing_hpot_event = nil

		if G.hpot_event.current_step then
			G.hpot_event.current_step:finish(G.hpot_event)
			G.FUNCS.draw_from_hand_to_deck()
			SMODS.calculate_context({
				hpot_event_step_end = true,
				event = G.hpot_event
			})
		end

		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.calculate_context({ hpot_event_scenario_end = true, event = G.hpot_event })
				G.E_MANAGER:add_event(Event({
					trigger = "before",
					delay = 0.2,
					func = function()
						G.hpot_event.ui.alignment.offset.y = G.ROOM.T.y + 21
						return true
					end,
				}))
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						G.hpot_event.ui:remove()
						G.hpot_event = nil
						delay(0.3)
						return true
					end,
				}))
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						G.GAME.hpot_event_domain_choices_used = {}
						G.GAME.hpot_event_domain_choices = {}
						G.GAME.hpot_event_domain = nil
						if not to_combat then
							G.STATE = G.STATES.BLIND_SELECT
							G.STATE_COMPLETE = false
						end
						return true
					end,
				}))
				return true
			end,
		}))
	end
end

function hpot_event_cleanup()
	if G.hpot_event then
		G.E_MANAGER:add_event(Event({
			func = function()
				set_element_object(G.hpot_event.text_area, Moveable())
				return true
			end,
		}))
		delay(0.5)
		G.E_MANAGER:add_event(Event({
			func = function()
				set_element_object(G.hpot_event.choices_area, Moveable())
				return true
			end,
		}))
	end
end

function hpot_event_prepare_text_lines()
	if G.hpot_event then
		local step = G.hpot_event.current_step

		local text_objects = {}
		-- Step text
		local event_text_content = {}
		localize({
			type = "descriptions",
			set = step.set,
			key = step.key,
			nodes = event_text_content,
			vars = step:loc_vars(G.hpot_event) or {},
			default_col = G.C.UI.TEXT_LIGHT,
		})
		local event_text_lines = {}
		for _, line in ipairs(event_text_content) do
			local text_object = UIBox({
				definition = {
					n = G.UIT.ROOT,
					config = {
						colour = G.C.CLEAR,
					},
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "c", minh = 0.35 },
							nodes = line,
						},
					},
				},
				config = {},
			})
			text_object.states.visible = false
			table.insert(text_objects, text_object)
			table.insert(event_text_lines, {
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.O,
						config = {
							object = text_object,
						},
					},
				},
			})
		end

		set_element_object(
			G.hpot_event.text_area,
			UIBox({
				definition = {
					n = G.UIT.ROOT,
					config = { colour = G.C.CLEAR },
					nodes = {
						{
							n = G.UIT.C,
							config = {
								align = "cm",
							},
							nodes = event_text_lines,
						},
					},
				},
				config = {},
			})
		)

		G.hpot_event_ui_text_objects = text_objects
		G.hpot_event_ui_next_text_object = 1
	end
end

function hpot_event_render_current_step()
	if G.hpot_event then
		local step = G.hpot_event.current_step

		-- Step buttons
		local event_buttons_content = {}
		local choices = step:get_choices(G.hpot_event)
		for i = 1, math.ceil(#choices / 4) do
			local buttons_in_column = {}
			local j = i - 1
			for k = j * 4 + 1, i * 4 do
				local choice = choices[k]
				if choice then
					table.insert(buttons_in_column, G.UIDEF.hpot_event_choice_button(step, choice))
				end
			end
			table.insert(event_buttons_content, {
				n = G.UIT.C,
				config = {
					padding = 0.075,
				},
				nodes = buttons_in_column
			})
		end

		event_buttons_content = { {
			n = G.UIT.R,
			config = {
				padding = 0.075,
			},
			nodes = event_buttons_content
		} }

		if G.hpot_event.domain == "transaction" or G.hpot_event.domain == "respite" then
			table.insert(event_buttons_content, 1, PissDrawer.Shop.currency_display_small())
		end

		local text_objects = G.hpot_event_ui_text_objects
		for i = G.hpot_event_ui_next_text_object, #G.hpot_event_ui_text_objects do
			local object = text_objects[i]
			if object then
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.75,
					func = function()
						play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
						object.states.visible = true
						return true
					end,
				}))
			end
		end
		delay(1)
		G.E_MANAGER:add_event(Event({
			func = function()
				play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
				set_element_object(
					G.hpot_event.choices_area,
					UIBox({
						definition = {
							n = G.UIT.ROOT,
							config = { colour = G.C.CLEAR },
							nodes = event_buttons_content,
						},
						config = {},
					})
				)
				return true
			end,
		}))
	end
end

function hpot_event_display_lines(amount, no_delay)
	if G.hpot_event then
		amount = amount or 1
		local text_objects = G.hpot_event_ui_text_objects
		if text_objects and G.hpot_event_ui_next_text_object then
			for i = G.hpot_event_ui_next_text_object, math.min(G.hpot_event_ui_next_text_object + amount - 1, #text_objects) do
				local object = text_objects[i]
				if object then
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = no_delay and 0 or 0.75,
						func = function()
							play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
							object.states.visible = true
							return true
						end,
					}))
				end
			end
		end
		G.hpot_event_ui_next_text_object = G.hpot_event_ui_next_text_object + amount
	end
end

--

function G.FUNCS.hpot_event_select(e)
	stop_use()
	if G.hpot_event_select then
		local domain = e.config.ref_table[e.config.ref_value]
		G.GAME.facing_hpot_event = true
		play_sound("timpani", 0.8)
		play_sound("generic1")

		G.E_MANAGER:add_event(Event({
			trigger = "before",
			delay = 0.2,
			func = function()
				G.hpot_event_select.alignment.offset.y = 40
				G.hpot_event_select.alignment.offset.x = 0
				return true
			end,
		}))
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				G.hpot_event_select:remove()
				G.hpot_event_select = nil
				delay(0.2)
				return true
			end,
		}))
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				G.RESET_JIGGLES = nil
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						G.E_MANAGER:add_event(Event({
							trigger = "immediate",
							func = function()
								G.GAME.hpot_event_domain = domain
								G.STATE = G.STATES.HOTPOT_EVENT
								G.STATE_COMPLETE = false
								return true
							end,
						}))
						return true
					end,
				}))
				return true
			end,
		}))
	end
end

function G.FUNCS.hpot_event_can_select(e)
	if G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0) then
		e.config.button = nil
	else
		e.config.button = "hpot_event_select"
	end
end

--

function G.FUNCS.hpot_event_can_execute_choice(e)
	if not e.config.old_colour then
		e.config.old_colour = e.config.colour
	end
	local choice_func = e.config.choice_func
	if
		(G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0))
		or (choice_func and not choice_func())
	then
		e.config.button = nil
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
	else
		e.config.button = "hpot_event_execute_choice"
		e.config.colour = e.config.old_colour
	end
end

function G.FUNCS.hpot_event_execute_choice(e)
	local choice_button = e.config.choice_button
	local choice_func = e.config.choice_func

	if not choice_func or choice_func() then
		stop_use()
		choice_button()
	end
end

--

function G.UIDEF.hpot_event_choice_button(step, choice)
	local loc_key = choice.no_prefix and choice.key or (step.key:lower() .. "_" .. choice.key)
	local loc_txt = G.localization.misc.EventChoices[loc_key] or choice.text or "ERROR"
	local localized = SMODS.localize_box(loc_parse_string(loc_txt), {
		default_col = G.C.UI.TEXT_LIGHT,
		vars = choice.vars or choice.loc_vars or {},
	})
	return {
		n = G.UIT.R,
		config = {
			align = "cm",
			padding = 0.08,
			r = 0.75,
			hover = true,
			colour = choice.colour or G.C.GREY,
			shadow = true,
			func = "hpot_event_can_execute_choice",
			button = "hpot_event_execute_choice",
			choice_button = choice.button,
			choice_func = choice.func,
			choice_key = loc_key,
			minh = 0.5,
			maxh = 0.5,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = { minw = 0.05 },
			},
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = localized,
			},
			{
				n = G.UIT.C,
				config = { minw = 0.05 },
			},
		},
	}
end

function G.UIDEF.hpot_event(scenario)
	local container_H = 5.6
	local container_W = G.hand.T.w + 0.15
	local container_padding = 0.1

	local header_H = 0.6
	local header_W = container_W - container_padding * 2
	local header_padding = 0.1

	local content_H = container_H - container_padding * 2 - header_H
	local content_W = container_W - container_padding * 2
	local content_padding = 0.1

	local image_area_size = (container_H - container_padding * 2 - header_H - content_padding * 2) / 1.25
	local choices_H = 2.4
	local text_H = (image_area_size * 1.25 - content_padding * 2 - choices_H)
		* ((G.GAME.hpot_event_domain == "transaction" or G.GAME.hpot_event_domain == "respite") and 0 or 1)

	local event_text_name = {}
	localize({
		type = "name",
		set = "EventScenarios",
		key = scenario.key,
		nodes = event_text_name,
		vars = scenario:loc_vars(),
		default_col = G.C.UI.TEXT_LIGHT,
	})
	local event_name_lines = {}
	for _, line in ipairs(event_text_name) do
		table.insert(event_name_lines, {
			n = G.UIT.R,
			config = { minh = 0.3 },
			nodes = line,
		})
	end

	local blind_col = (HotPotato.EventDomains[G.GAME.hpot_event_domain] or {}).colour or nil

	local main_nodes = {}

	if not scenario.hide_image_area then
		main_nodes[#main_nodes + 1] = {
			n = G.UIT.C,
			config = {
				minw = image_area_size,
				maxw = image_area_size,
				minh = image_area_size,
				maxh = image_area_size,
				colour = { 0, 0, 0, 0.1 },
				r = 0.1,
				id = "image_area",
			},
		}
	end
	main_nodes[#main_nodes + 1] = {
		n = G.UIT.C,
		config = {
			minw = 0.1,
			maxw = 0.1,
		},
	}
	main_nodes[#main_nodes + 1] = {
		n = G.UIT.C,
		nodes = {
			{
				n = G.UIT.R,
				config = {
					minh = text_H,
					maxh = text_H,
					align = "c",
					padding = 0.1,
				},
				nodes = {
					{
						n = G.UIT.O,
						config = {
							id = "text_area",
							object = Moveable(),
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = { minh = 0.1 },
			},
			{
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.C,
						config = {
							minw = 0.23,
							maxw = 0.23,
						},
					},
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "c",
									minh = choices_H,
									maxh = choices_H,
								},
								nodes = {
									{
										n = G.UIT.O,
										config = {
											id = "choices_area",
											object = Moveable(),
										},
									},
								},
							},
						}
					},
				}
			},

		},
	}

	return {
		n = G.UIT.ROOT,
		config = {
			colour = G.C.CLEAR,
			minw = container_W,
			maxw = container_W,
			minh = container_H,
			maxh = container_H,
		},
		nodes = {
			UIBox_dyn_container({
				{
					n = G.UIT.R,
					config = {
						minw = header_W,
						maxw = header_W,
						colour = G.C.DYN_UI.BOSS_MAIN,
						r = 0.1,
						emboss = 0.05,
						minh = header_H,
						maxh = header_H,
						padding = header_padding,
						align = "cm",
					},
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm" },
							nodes = event_name_lines,
						},
					},
				},
				{
					n = G.UIT.R,
					config = {
						r = 0.1,
						minh = content_H,
						maxh = content_H,
						minw = content_W,
						maxw = content_W,
						align = "c",
					},
					nodes = main_nodes,
				},
			}, nil, blind_col, blind_col and mix_colours(G.C.BLACK, blind_col, 0.8) or nil),
		},
	}
end

--

function get_next_hpot_event(domain)
	if G.GAME.hpot_event_scenario_forced_key then
		local result = G.GAME.hpot_event_scenario_forced_key
		G.GAME.hpot_event_scenario_forced_key = nil
		return result
	end
	local eligible_events = {}
	local total_weight = 0
	for key, event in pairs(HotPotato.EventScenarios) do
		if not domain or (event.domains and event.domains[domain]) then
			local weight = event:get_weight()
			if weight > 0 and event:in_pool() then
				eligible_events[key] = event
			end
		end
	end

	local min_use = 100
	for k, v in pairs(eligible_events) do
		eligible_events[k] = G.GAME.hpot_events_encountered[k] or 0
		if not HotPotato.EventScenarios[k].can_repeat then
			min_use = math.min(min_use, eligible_events[k])
		end
	end

	local weighted_events = {}
	for k, _ in pairs(eligible_events) do
		if eligible_events[k] <= min_use or HotPotato.EventScenarios[k].can_repeat then
			local weight = HotPotato.EventScenarios[k]:get_weight()
			total_weight = total_weight + weight
			table.insert(weighted_events, {
				key = k,
				weight = weight,
			})
		end
	end

	local roll = pseudorandom(pseudoseed("hpot_event" .. G.GAME.round_resets.ante))
	local weight_i = 0
	for _, v in ipairs(weighted_events) do
		weight_i = weight_i + v.weight
		if roll > 1 - (weight_i / total_weight) then
			return v.key
		end
	end

	return "hpot_nothing"
end

--

local ca_dref = CardArea.draw
function CardArea:draw(...)
	if self == G.hand and (G.STATE == G.STATES.HOTPOT_EVENT_SELECT) then
		return
	end
	if G.STATE == G.STATES.HOTPOT_EVENT or (G.STATE == G.STATES.SMODS_REDEEM_VOUCHER and G.hpot_event) then
		local step = G.hpot_event and G.hpot_event.current_step or {}
		if self == G.hand and step.hide_hand then
			return
		end
		if self == G.deck and step.hide_deck then
			return
		end
	end
	return ca_dref(self, ...)
end

local r_bref = reset_blinds
function reset_blinds(...)
	r_bref(...)
	G.GAME.round_resets.hpot_event_encountered = false
end

local r_g_ref = SMODS.current_mod.reset_game_globals or function() end
SMODS.current_mod.reset_game_globals = function(run_start)
	r_g_ref(run_start)
	if run_start then
		G.GAME.round_resets.hpot_event_encountered = false
	end
end

--

function force_hpot_event(key)
	G.GAME.hpot_event_scenario_forced_key = key
end

function get_hpot_event_image_center(card_w, card_h)
	if G.hpot_event then
		local image_area = G.hpot_event.image_area
		if image_area then
			local x = image_area.T.x + image_area.T.w / 2 - (card_w or G.CARD_W) / 2
			local y = image_area.T.y + image_area.T.h / 2 - (card_h or G.CARD_H) / 2
			return x, y
		end
		return 0, 0
	else
		return 0, 0
	end
end

-- Contexts

-- Scenario start
-- {
--     hpot_event_scenario_stppu_artist = true,
--     event = event
-- }

-- Scenario end
-- {
--     hpot_event_scenario_end = true,
--     event = event
-- }

-- Step start
-- {
--     hpot_event_step_stppu_artist = true,
--     event = event
-- }

-- Step end
-- {
--     hpot_event_step_end = true,
--     event = event
-- }

-- Variables
-- G.GAME.round_resets.hpot_event_encountered - is event was encountered this ante
