--(idk if this has to go here, but i assume its better if this is done before any files are loaded so nothing crashes because of it not being called yet)
--for adding custom loc_colours, dont touch this!
loc_colour()

-- CONFIG
--#region Config

HotPotato = SMODS.current_mod

--#endregion

-- Nested check
assert(HotPotato.lovely, "Lovely not initalized.\n\nMake sure your Hot Potato folder is not nested (there should be a bunch of files in the Hot Potato folder and not just another folder).\n\n")

--logo
SMODS.Atlas {
	key = "logo",
	path = 'hotpotlogo.png',
	px = 320,
	py = 138
}

-- colours
HotPotato.colours = {
	primary = HEX('f2af5b'),
	secondary = HEX('b7660f'),
}

--Main Menu
HotPotato.menu_cards = function()
	if HotPotatoConfig.menu then
		return {
			remove_original = true,
			{key = 'j_hpot_thetruehotpotato'},
			{key = 'j_hpot_birthdayboy'},
			func = function()
				for k, v in pairs(G.title_top.cards) do
					if v.config.center_key == 'j_hpot_birthdayboy' then
						v.no_ui = false
						break
					end
				end
			end
		}
	end
end

local gmm = Game.main_menu
function Game:main_menu(change_context)
    local ret = gmm(self, change_context)

    if HotPotatoConfig.menu then
        -- Creates hotpot Logo Sprite
        local SC_scale = 1.1 * (G.debug_splash_size_toggle and 0.8 or 1)
        G.SPLASH_HOTPOT_LOGO = Sprite(0, 0,
            6.8 * SC_scale,
            6.8 * SC_scale * (G.ASSET_ATLAS["hpot_logo"].py / G.ASSET_ATLAS["hpot_logo"].px),
            G.ASSET_ATLAS["hpot_logo"], { x = 0, y = 0 }
        )
        G.SPLASH_HOTPOT_LOGO:set_alignment({
            major = G.title_top,
            type = 'cm',
            bond = 'Strong',
            offset = { x = 0, y = 3.25 }
        })
        G.SPLASH_HOTPOT_LOGO:define_draw_steps({ {
            shader = 'dissolve',
        } })

        -- Define logo properties
        G.SPLASH_HOTPOT_LOGO.tilt_var = { mx = 0, my = 0, dx = 0, dy = 0, amt = 0 }

        G.SPLASH_HOTPOT_LOGO.dissolve_colours = { HotPotato.colours.primary, HotPotato.colours.secondary }
        G.SPLASH_HOTPOT_LOGO.dissolve = 1

        G.SPLASH_HOTPOT_LOGO.states.collide.can = true

        -- Define node functions for Logo
        function G.SPLASH_HOTPOT_LOGO:click()
            play_sound('button', 1, 0.3)
            SMODS.LAST_SELECTED_MOD_TAB = nil
            G.FUNCS['openModUI_HotPotato']()
            G.OVERLAY_MENU:get_UIE_by_ID("overlay_menu_back_button").config.button = "exit_overlay_menu_HotPotato"
        end

        G.FUNCS.exit_overlay_menu_HotPotato = function()
            G.ACTIVE_MOD_UI = nil
            G.FUNCS.exit_overlay_menu()
        end

        function G.SPLASH_HOTPOT_LOGO:hover()
            G.SPLASH_HOTPOT_LOGO:juice_up(0.05, 0.03)
            play_sound('paper1', math.random() * 0.2 + 0.9, 0.35)
            Node.hover(self)
        end

        function G.SPLASH_HOTPOT_LOGO:stop_hover() Node.stop_hover(self) end

        --Logo animation
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = change_context == 'splash' and 3.6 or change_context == 'game' and 4 or 1,
            blockable = false,
            blocking = false,
            func = (function()
                play_sound('magic_crumple' .. (change_context == 'splash' and 2 or 3),
                    (change_context == 'splash' and 1 or 1.3), 0.9)
                play_sound('whoosh1', 0.2, 0.8)
                ease_value(G.SPLASH_HOTPOT_LOGO, 'dissolve', -1, nil, nil, nil,
                    change_context == 'splash' and 2.3 or 0.9)
                G.VIBRATION = G.VIBRATION + 1.5
                return true
            end)
        }))

        -- make the title screen use different background colors
        G.SPLASH_BACK:define_draw_steps({ {
            shader = 'splash',
            send = {
                { name = 'time',       ref_table = G.TIMERS,                ref_value = 'REAL_SHADER' },
                { name = 'vort_speed', val = 0.4 },
                { name = 'colour_1',   ref_table = HotPotato.colours, ref_value = 'primary' },
                { name = 'colour_2',   ref_table = HotPotato.colours, ref_value = 'secondary' },
            }
        } })
    end

    return ret
end


--talisman
to_big = to_big or function(x) return x end
to_number = to_number or function(x) return x end
--oh my fucking god at this point just install luajit2

-- FILE LOADING
--#region File Loading
local blacklist = {
	['titletext.lua'] = true,
	['base64.lua'] = true
}
local path = SMODS.current_mod.path

-- Annoyingly load title text lua
assert(SMODS.load_file("content/Jtem/titletext.lua"))()
PotatoPatchUtils.load_files(path .. 'content', blacklist)
--#endregion

-- MISC
--#region Miscelaneous

-- Add optional features here
HotPotato.optional_features = {
	retrigger_joker = true,
	post_trigger = true,
}
HotPotato.extra_tabs = function()
	return {
		--clickris
		{
			label = "Kill Kris",
			tab_definition_function = G.UIDEF.clickris
		},
		-- Jukebox
		{
			label = "Jukebox",
			tab_definition_function = JTJukebox.MusicTab
		},
	}
end
--#endregion

if not HotPotatoConfig then HotPotatoConfig = {} end
HotPotatoConfig = SMODS.current_mod.config

local hpotConfigTab = function()
	hpot_nodes = {}
	config = { n = G.UIT.R, config = { align = "tm", padding = 0 }, nodes = { { n = G.UIT.C, config = { align = "tm", padding = 0.05 }, nodes = {} } } }
	hpot_nodes[#hpot_nodes + 1] = config
	hpot_nodes[#hpot_nodes + 1] = create_toggle({
		label = localize("hotpot_disable_animations"),
		active_colour = HEX("40c76d"),
		ref_table = HotPotatoConfig,
		ref_value = "animations_disabled",
		callback = function()
		end,
	})
	hpot_nodes[#hpot_nodes + 1] = create_toggle({
		label = localize("hotpot_family_friendly"),
		active_colour = HEX("40c76d"),
		ref_table = HotPotatoConfig,
		ref_value = "family_friendly",
		callback = function()
			HotPotato.reload_localization()
		end
	})
	hpot_nodes[#hpot_nodes + 1] = create_toggle({
		label = localize("hotpot_window_title"),
		active_colour = HEX("40c76d"),
		ref_table = HotPotatoConfig,
		ref_value = "window_title",
		callback = function()
			if HotPotatoConfig.window_title then
				HotPotato.set_window_title()
			else
				love.window.setTitle("Balatro")
			end
		end,
	})
	hpot_nodes[#hpot_nodes + 1] = create_toggle({
		label = localize("hotpot_custom_menu"),
		active_colour = HEX("40c76d"),
		ref_table = HotPotatoConfig,
		ref_value = "menu",
		callback = function()
		end,
	})
	return {
		n = G.UIT.ROOT,
		config = {
			emboss = 0.05,
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "cm",
			padding = 0.2,
			colour = G.C.BLACK,
		},
		nodes = hpot_nodes,
	}
end

HotPotato.badge_colour = SMODS.Gradients["hpot_advert"]

HotPotato.config_tab = hpotConfigTab

SMODS.current_mod.calculate = function(self, context)
	return SMODS.merge_effects(
		Horsechicot:calculate(context) or {}
	)
end

HotPotato.set_window_title = function()
	if HotPotatoConfig.window_title then
		local title = "Balatro: " ..
			((type(HPJTTT.text[HPJTTT.chosen]) == 'string' and HPJTTT.text[HPJTTT.chosen]) or 'Now with images!')
		if HPJTTT.balala then
			title = "Balala"
		end
		love.window.setTitle(title)
	end
end
HotPotato.set_window_title()

--#region Credits

-- credits button on mod page
HotPotato.custom_ui = function(mod_nodes)
	mod_nodes[#mod_nodes + 1] = {
		n = G.UIT.R,
		config = { minw = 4, minh = 4, align = "cm", padding = 0.2 },
		nodes = {
			UIBox_button({
				label = { localize('hotpot_credits_button') },
				minw = 5,
				colour = HotPotato.badge_colour,
				button =
				"create_UIBox_credits"
			}),
			UIBox_button({
				label = { localize('hotpot_feature_info_button') },
				minw = 5,
				colour = HotPotato.badge_colour,
				button =
				"feature_info_menu"
			})
		}
	}
end

-- credits ui

--- Creates credit ui for a specific team number
---@param team integer
HotPotato.generate_credit_UIBox = function(team)
	-- members definition
	local m = G.localization.InfoMenu.hotpot_credits[team or 1].members
	local areas = {}
	if G.HOT_POTATO_CREDIT_AREAS then
		for _, area in ipairs(G.HOT_POTATO_CREDIT_AREAS) do
			area:remove()
		end
	end
	G.HOT_POTATO_CREDIT_AREAS = {}
	G.HOT_POTATO_CREDIT_NODES = {}
	for i, member in ipairs(m) do
		G.HOT_POTATO_CREDIT_AREAS[i] = CardArea(G.ROOM.T.x, G.ROOM.T.y, G.CARD_W / 1.25, G.CARD_H / 1.25,
			{ type = "title_2", card_limit = 1, highlight_limit = 0 })
		-- create a card for this potato
		local atlas = member.atlas or "Joker"
		local pos = member.pos or { x = 0, y = 0 }
		local card = Card(G.ROOM.T.x, G.ROOM.T.y, G.CARD_W / 1.25, G.CARD_H / 1.25, nil, G.P_CENTERS.c_base)
		card.config.center = copy_table(card.config.center)
		card.config.center.atlas = atlas
		card.config.center.pos = pos
		if member.soul_pos then
			card.config.center.soul_pos = member.soul_pos
		end
		if member.extra then
			card.hpot_extra = member.extra
		end
		card:set_sprites(card.config.center)
		G.HOT_POTATO_CREDIT_AREAS[i]:emplace(card)

		local function create_text_box(args)
			local desc_node = {}
			local loc_target = args.loc_target and copy_table(args.loc_target)
			HotPotato.localize { type = 'descriptions', loc_target = { text = loc_target }, nodes = desc_node, scale = 1, text_colour = G.C.UI.TEXT_LIGHT, vars = args.vars or {}, stylize = true, no_shadow = true }
			desc_node = hp_desc_from_rows(desc_node, true, "cm")
			desc_node.config.align = "cm"

			return {
				n = G.UIT.R,
				config = { align = "cm", colour = G.C.L_BLACK, r = 0.2, shadow = true },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm", padding = 0.05 },
						nodes = {
							desc_node
						}
					},
				}
			}
		end

		-- description
		card.hover = function(self)
			local info_nodes = {
				n = G.UIT.R,
				config = { align = "cm", padding = 0, colour = G.C.CLEAR },
				nodes = {
					{ n = G.UIT.C, config = { align = "cm", padding = 0.2 }, nodes = {} },
				}
			}
			local target = member.text
			if target then
				for _, v in ipairs(target) do
					info_nodes.nodes[1].nodes[#info_nodes.nodes[1].nodes + 1] = create_text_box({ loc_target = v })
				end
			end
			if member.name == 'Fey' then
				local atlas = G.ASSET_ATLAS['hpot_pdr_meguna']
				info_nodes.nodes[1].nodes[1] = {
					n = G.UIT.O, config = {object = Sprite(0, 0, 5, 5, atlas, {x = 0, y = 0})
					}
				}
			end
			self:juice_up(0.05, 0.03)
			play_sound('paper1', math.random() * 0.2 + 0.9, 0.35)
			card.config.h_popup = info_nodes
			card.config.h_popup_config = self:align_h_popup()
			Moveable.hover(self)
		end

		-- for nxkoo specifically
		if member.name == "Nxkoo" then
			card.click = function(self)
				if not card.cantclicklmao then
					G.E_MANAGER:add_event(Event {
						trigger = 'ease',
						delay = 0.4,
						ease = 'elastic',
						ref_table = card.T,
						ref_value = "h",
						ease_to = 0,
						func = function(n)
							check_for_unlock({type = "nxkoo"})
							return n
						end
					})
					card.cantclicklmao = true
					G.FUNCS.krisclick()
				end
				Moveable.click(self)
			end
		end

		-- name node for the fancy people
		local temp_subname_node = {}
		HotPotato.localize { type = 'name', loc_target = { name = member.name }, nodes = temp_subname_node, scale = 0.8, text_colour = G.C.L_BLACK, stylize = true, no_shadow = true, no_pop_in = true, no_bump = true, no_silent = true, no_spacing = true }
		temp_subname_node = hp_desc_from_rows(temp_subname_node, true, "cm", nil, 0)
		temp_subname_node.config.align = "cm"

		-- create node for this mf
		G.HOT_POTATO_CREDIT_NODES[i] = {
			n = G.UIT.C,
			config = { align = "cm", id = "hpot_credit_node_" .. member.name },
			nodes = {
				{
					n = G.UIT.C,
					config = {
						r = 0.2,
						align = "cm",
						padding = 0.125,
						colour = G.C.L_BLACK,
						minw = G.CARD_W / 1.2 + 0.2,
						minh = G.CARD_H * 1.2
					},
					nodes = {
						{
							n = G.UIT.C,
							config = {
								r = 0.2,
								align = "tm",
								padding = 0.1,
								colour = G.C.BLACK,
								minw = G.CARD_W / 1.2,
								minh = G.CARD_H * 1.2
							},
							nodes = {
								{
									n = G.UIT.R,
									config = { align = "cm" },
									nodes = {
										temp_subname_node
									}
								},
								{
									n = G.UIT.R,
									config = {
										align = "cm",
									},
									nodes = {
										{
											n = G.UIT.O,
											config = {
												object = G.HOT_POTATO_CREDIT_AREAS[i],
											},
										}
									}
								},
							}
						},

					}
				},
			}
		}
	end

	local max_columns = 1
	-- can i stop naming this math.ciel initially...
	-- i am not type-moon coded i promise
	local max_pool_len = math.min(math.ceil(#m / max_columns), 3)
	local current_member = 1
	local table_nodes = {}

	for i = 1, max_pool_len do
		table_nodes[#table_nodes + 1] = {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.1 },
			nodes = {}
		}
	end

	local count = 0
	for _, node in ipairs(G.HOT_POTATO_CREDIT_NODES) do
		if count > max_pool_len then
			count = 0
			current_member = current_member + 1
		end
		count = count + 1
		table_nodes[current_member].nodes[#table_nodes[current_member].nodes + 1] = node
	end

	-- create a card for this member
	return {
		n = G.UIT.C,
		config = { minw = 11, colour = G.C.CLEAR, align = "cm", id = "hotpot_credits_page" },
		nodes = table_nodes
	}
end

function G.FUNCS.regenerate_hotpot_credits_page(e)
	if not e then return end
	if not e.cycle_config then return end
	local page = G.OVERLAY_MENU:get_UIE_by_ID("hotpot_credits_page")
	if page then
		page:remove()
		local uibox = HotPotato.generate_credit_UIBox(e.cycle_config.current_option)
		page.UIBox:add_child(uibox, page)
		page.UIBox:recalculate()
	end
end

function G.FUNCS.create_UIBox_credits(e)
	local uibox = HotPotato.generate_credit_UIBox(1)
	local options = {}
	for week, team in ipairs(G.localization.InfoMenu.hotpot_credits) do
		options[#options + 1] = localize('hotpot_credits_week') .. " " .. week .. " - " .. team.name
	end
	SMODS.LAST_SELECTED_MOD_TAB = nil
	local t = create_UIBox_generic_options({
		colour = G.ACTIVE_MOD_UI and
			((G.ACTIVE_MOD_UI.ui_config or {}).collection_colour or (G.ACTIVE_MOD_UI.ui_config or {}).colour),
		bg_colour = G.ACTIVE_MOD_UI and
			((G.ACTIVE_MOD_UI.ui_config or {}).collection_bg_colour or (G.ACTIVE_MOD_UI.ui_config or {}).bg_colour),
		back_colour = G.ACTIVE_MOD_UI and
			((G.ACTIVE_MOD_UI.ui_config or {}).collection_back_colour or (G.ACTIVE_MOD_UI.ui_config or {}).back_colour),
		outline_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_outline_colour or
			(G.ACTIVE_MOD_UI.ui_config or {}).outline_colour),
		back_func = G.ACTIVE_MOD_UI and "openModUI_" .. G.ACTIVE_MOD_UI.id or 'your_collection',
		contents = {
			{
				n = G.UIT.C,
				config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.2 },
						nodes = {
							{
								n = G.UIT.O,
								config = {
									object = DynaText {
										string = localize('hotpot_credits_title'),
										float = true,
										pop_in = 0,
										pop_in_rate = 4,
										silent = true,
										shadow = true,
										scale = 1,
										rotate = true,
										colours = { G.C.EDITION }
									}
								}
							}
						}
					},
					{
						n = G.UIT.R,
						config = { align = "cm", minh = 8 },
						nodes = {
							uibox
						}
					},
					{
						n = G.UIT.R,
						config = {
							align = "cm"
						},
						nodes = {
							create_option_cycle({
								options = options,
								w = 11,
								scale = 0.8,
								cycle_shoulders = true,
								opt_callback =
								'regenerate_hotpot_credits_page',
								current_option = 1,
								colour = G.ACTIVE_MOD_UI and
									(G.ACTIVE_MOD_UI.ui_config or {}).collection_option_cycle_colour or G.C.RED,
								no_pips = true,
								focus_args = { snap_to = true, nav = 'wide' }
							})
						}
					}
				}
			},
		}
	})
	G.FUNCS.overlay_menu {
		definition = t
	}
end

--#endregion

--#region Feature Info

function G.FUNCS.feature_info_menu(e)
	local contents = {}
	for info, menu in pairs(G.localization.InfoMenu) do
		if info ~= "hotpot_credits" then
			local fname = "hotpot_info_menu_" .. info
			G.FUNCS[fname] = function(e)
				G.FUNCS.hotpot_info { menu_type = info, back_func = "feature_info_menu", no_first_time = true }
			end
			contents[#contents + 1] = UIBox_button({
				label = { HotPotato.localize { type = 'name_text', loc_target = { name = menu.name } } },
				minw = 5,
				button =
					fname
			})
		end
	end
	SMODS.LAST_SELECTED_MOD_TAB = nil
	G.FUNCS.overlay_menu {
		definition = create_UIBox_generic_options({
			colour = G.ACTIVE_MOD_UI and
				((G.ACTIVE_MOD_UI.ui_config or {}).collection_colour or (G.ACTIVE_MOD_UI.ui_config or {}).colour),
			bg_colour = G.ACTIVE_MOD_UI and
				((G.ACTIVE_MOD_UI.ui_config or {}).collection_bg_colour or (G.ACTIVE_MOD_UI.ui_config or {}).bg_colour),
			back_colour = G.ACTIVE_MOD_UI and
				((G.ACTIVE_MOD_UI.ui_config or {}).collection_back_colour or (G.ACTIVE_MOD_UI.ui_config or {}).back_colour),
			outline_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_outline_colour or
				(G.ACTIVE_MOD_UI.ui_config or {}).outline_colour),
			back_func = G.ACTIVE_MOD_UI and "openModUI_" .. G.ACTIVE_MOD_UI.id or 'your_collection',
			contents = {
				{
					n = G.UIT.C,
					config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05, padding = 0.1, minw = 7 },
					nodes = {
						{
							n = G.UIT.R,
							config = { minw = 4, minh = 4, align = "cm", padding = 0.15 },
							nodes = contents
						}
					}
				}
			}
		})
	}
end

--#endregion
