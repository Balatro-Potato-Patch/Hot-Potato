-- waiter waiter ! more useless features please !

-- The Jukebox is an additional tab in the mod settings.
-- Sounds prefixed with `music_` are automatically added.
--
-- Metadata about the music track is meant to be saved within
-- the music track as a vorbis comment. This includes album covers.
--
-- It is recommended for the metadata to contain these tags:
-- TITLE - the title of the music track
-- ARTIST - the composer of the music track
--
-- Specific music tag editors also allow you to put images in the metadata.
-- The image MUST be a 159x159 jpeg.
-- Images may be considered as 'invalid' due to limitations.
-- There will be a default one shown if it doesn't have one, or if its regarded as invalid.

require 'bit'
base64 = SMODS.load_file("Jtem/base64.lua")()

---@class Jtem.MusicTag
---@field title string? Title of the music provided. Can be empty.
---@field artist string? Artist of the music provided. Can be empty.
---@field key string
---@field discoverable boolean?
---@field discovered boolean?
---@field order? integer
---@field mod? Mod

JTJukebox = {}
---@type Jtem.MusicTag[]
JTJukebox.MusicTags = {}
---@type table<string, Jtem.MusicTag>
JTJukebox.Music = {}
JTJukebox.Current = 0

-- Turns a 4 character long byte array in little endian into a unsigned 32 bit integer
---@param str string Byte array represented as a string
---@return number
function get_32_bit_integer_le(str)
	local l, m, n, o = string.byte(str, 1, 4)
	return l + (bit.lshift(m, 8)) + (bit.lshift(n, 16)) + (bit.lshift(o, 24))
end

-- Turns a 4 character long byte array in big endian into a unsigned 32 bit integer
---@param str string Byte array represented as a string
---@return number
function get_32_bit_integer_be(str)
	local l, m, n, o = string.byte(str, 1, 4)
	return (bit.lshift(l, 24)) + (bit.lshift(m, 16)) + (bit.lshift(n, 8)) + o
end

-- Decodes a base64 image from a vorbis comment
---@param str string Base64 string to decode
---@param name string Atlas name identifier
function decode_vorbis_comment_img(str, name)
	local decoded = base64.decode(str)
	local idx = 1

	--NFS.write(HotPotato.path .. name .. "_og.jpg", decoded)

	-- https://www.rfc-editor.org/rfc/rfc9639.html#name-picture
	-- note: most of these are unused, but might be important later idk
	-- image type according to table 13
	local type = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4

	-- mime type
	local type_len = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4
	local mime_type = string.sub(decoded, idx, idx + type_len - 1); idx = idx + type_len

	-- optional description
	local desc_len = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4
	local desc = string.sub(decoded, idx, idx + desc_len - 1); idx = idx + desc_len

	-- image properties
	local width = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4
	local height = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4
	local color_depth = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4
	local num_colors = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4
	local len = get_32_bit_integer_be(string.sub(decoded, idx, idx + 4)); idx = idx + 4

	-- actual image data
	NFS.write(HotPotato.path .. name .. ".jpg", string.sub(decoded, idx, idx + len - 1))
	local byte_data = NFS.newFileData(HotPotato.path .. name .. ".jpg")
	local img_data = love.image.newImageData(byte_data)
	NFS.remove(HotPotato.path .. name .. ".jpg")

	-- meant to be fed into G.ASSET_ATLAS
	return {
		path = "",
		full_path = "",
		image_data = img_data,
		px = img_data:getWidth(),
		py = img_data:getHeight(),
		image = love.graphics.newImage(img_data),
		type = "",
		name = name
	}
end

-- Creates a MusicTag from a desired path. Also creates its respective cover image if applicable.
---@param path string Path to the music file.
---@param music_name string Identifier for the MusicTag.
---@return Jtem.MusicTag
function JTJukebox.read_music_tags(path, music_name)
	local data = NFS.read('data', path)
	if not data then return {} end
	local str = data:getString() -- byte arrays aren't a thing in lua :P
	-- find first 'vorbis' string. determines if its actually a vorbis file
	local idx = string.find(str, 'vorbis')
	---@type Jtem.MusicTag
	local info = { key = music_name, order = #JTJukebox.MusicTags + 1, mod = SMODS.Sounds[music_name].mod, hotpot_credits = SMODS.Sounds[music_name].hotpot_credits }
	-- POST: Check if we defined this in the SMODS.Sound definition instead
	if SMODS.Sounds[info.key] then
		info.title = SMODS.Sounds[info.key].hpot_title or nil
		info.artist = SMODS.Sounds[info.key].hpot_artist or nil
	end
	if idx > 0 then
		-- find second vorbis string
		local v = string.find(str, 'vorbis', idx + 6)
		if not v then return info end
		idx = v + 6
		-- Skip over vendor_string
		local vendor_length = get_32_bit_integer_le(string.sub(str, idx, idx + 4))
		idx = idx + vendor_length + 4
		-- get comment size
		local comment_size = get_32_bit_integer_le(string.sub(str, idx, idx + 4))
		idx = idx + 4
		-- get every comment based on comment size
		for i = 1, comment_size do
			-- comment length
			local len = get_32_bit_integer_le(string.sub(str, idx, idx + 4))
			idx = idx + 4
			local comment = string.sub(str, idx, idx + len - 1)
			-- split string between =
			for key, value in string.gmatch(comment, '([^=]+)=(.*)') do
				local comment_name = string.lower(key)
				-- This is an image. Do not add to final info as it is unnecessary
				if comment_name == "metadata_block_picture" then
					-- just in case...
					value = value .. "=="
					local success, atlas = pcall(decode_vorbis_comment_img, value, music_name)
					if success then
						G.ASSET_ATLAS[(music_name or path)] = atlas
					else
						print("Failed to create atlas image for music " .. music_name)
					end
				elseif not info[comment_name] then
					-- add it to our info
					info[comment_name] = value
				end
			end
			-- change index based on length
			idx = idx + len
		end
	end
	print("Injected music " .. music_name .. " for the Jukebox!")
	info.key = music_name
	return info
end

-- Inject this when creating a new music sound
local old_inject = SMODS.Sound.inject
SMODS.Sound.inject = function(self, i)
	old_inject(self, i)
	-- for now only filter hot potato's music tracks
	if string.find(self.key, "music_") and self.mod == HotPotato then
		local _, tag = pcall(JTJukebox.read_music_tags, self.full_path, self.key)
		-- check if it should be discoverable
		if self.hpot_discoverable then
			tag.discoverable = true
		end
		JTJukebox.Music[tag.key] = tag
        JTJukebox.MusicTags[#JTJukebox.MusicTags + 1] = tag
        -- process descriptions
        G.localization.descriptions.hpot_jukebox = G.localization.descriptions.hpot_jukebox or {}
        G.localization.descriptions.hpot_jukebox[tag.key] = G.localization.descriptions.hpot_jukebox[tag.key] or {}
        G.localization.descriptions.hpot_jukebox[tag.key].name = G.localization.descriptions.hpot_jukebox[tag.key].name or
            { tag.title, "{C:edition,s:0.6}" .. tag.artist }
        G.localization.descriptions.hpot_jukebox[tag.key].text = G.localization.descriptions.hpot_jukebox[tag.key].text or
            self.hpot_purpose or { "???" }
	end
end

local old_pre_inject = SMODS.Sound.pre_inject_class or function() end
SMODS.Sound.pre_inject_class = function(self, ...)
    old_pre_inject(self, ...)
    JTJukebox.MusicTags = {}
end

-- check if we have discovered this
local set_profile_progress_ref = set_profile_progress
function set_profile_progress()
	set_profile_progress_ref()
	G.PROFILES[G.SETTINGS.profile]["hpot_discovered_tracks"] = G.PROFILES[G.SETTINGS.profile]["hpot_discovered_tracks"] or
		{}
	for tag, t in pairs(JTJukebox.Music) do
		if G.PROFILES[G.SETTINGS.profile]["hpot_discovered_tracks"][tag] and t.discoverable then
			t.discovered = true
		end
	end
end

local old_unlock_all = G.FUNCS.unlock_all
function G.FUNCS.unlock_all(...)
    old_unlock_all(...)
    G.PROFILES[G.SETTINGS.profile]["hpot_discovered_tracks"] = G.PROFILES[G.SETTINGS.profile]["hpot_discovered_tracks"] or
		{}
    for tag, t in pairs(JTJukebox.Music) do
		if t.discoverable then
            G.PROFILES[G.SETTINGS.profile]["hpot_discovered_tracks"][tag] = true
			t.discovered = true
		end
	end
end

-- just add my shit bruh
JTJukebox.create_collection_ui = function(_pool, rows, args)
	args = args or {}
	args.w_mod = args.w_mod or 1
	args.h_mod = args.h_mod or 1
	args.card_scale = args.card_scale or 1
	local deck_tables = {}
	local pool = _pool
	if #pool == 0 then
		pool = {}
		for k, v in pairs(_pool) do
			pool[#pool + 1] = v
		end
	end

	G.your_collection = {}
	local cards_per_page = 0
	local row_totals = {}
	for j = 1, #rows do
		if cards_per_page >= #pool and args.collapse_single_page then
			rows[j] = nil
		else
			row_totals[j] = cards_per_page
			cards_per_page = cards_per_page + rows[j]
			G.your_collection[j] = CardArea(
				G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
				(args.w_mod * rows[j] + 0.25) * G.CARD_W,
				args.h_mod * G.CARD_H,
				{ card_limit = rows[j], type = args.area_type or 'title', highlight_limit = 0, collection = true }
			)
			table.insert(deck_tables,
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.07, no_fill = true },
					nodes = {
						{ n = G.UIT.O, config = { object = G.your_collection[j] } }
					}
				})
		end
	end

	local options = {}
	for i = 1, math.ceil(#pool / cards_per_page) do
		table.insert(options, localize('k_page') .. ' ' .. tostring(i) .. '/' ..
			tostring(math.ceil(#pool / cards_per_page)))
	end

	G.FUNCS.SMODS_card_collection_page = function(e)
		if not e or not e.cycle_config then return end
		for j = 1, #G.your_collection do
			for i = #G.your_collection[j].cards, 1, -1 do
				local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
				c:remove()
				c = nil
			end
		end
		for j = 1, #rows do
			for i = 1, rows[j] do
				local center = pool[i + row_totals[j] + (cards_per_page * (e.cycle_config.current_option - 1))]
				if not center then break end
				local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y,
					args.card_w or (G.CARD_W * args.card_scale), args.card_h or (G.CARD_H * args.card_scale),
					G.P_CARDS.empty, (args.center and G.P_CENTERS[args.center]) or center)
				if args.modify_card then args.modify_card(card, center, i, j) end
				if not args.no_materialize then card:start_materialize(nil, i > 1 or j > 1) end
				G.your_collection[j]:emplace(card)
			end
		end
		INIT_COLLECTION_CARD_ALERTS()
	end

	G.FUNCS.SMODS_card_collection_page { cycle_config = { current_option = 1 } }

	local t = create_UIBox_generic_options({
		colour = G.ACTIVE_MOD_UI and
			((G.ACTIVE_MOD_UI.ui_config or {}).collection_colour or (G.ACTIVE_MOD_UI.ui_config or {}).colour),
		bg_colour = G.ACTIVE_MOD_UI and
			((G.ACTIVE_MOD_UI.ui_config or {}).collection_bg_colour or (G.ACTIVE_MOD_UI.ui_config or {}).bg_colour),
		back_colour = G.ACTIVE_MOD_UI and
			((G.ACTIVE_MOD_UI.ui_config or {}).collection_back_colour or (G.ACTIVE_MOD_UI.ui_config or {}).back_colour),
		outline_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_outline_colour or
			(G.ACTIVE_MOD_UI.ui_config or {}).outline_colour),
		back_func = (args and args.back_func) or G.ACTIVE_MOD_UI and "openModUI_" .. G.ACTIVE_MOD_UI.id or
			'your_collection',
		snap_back = args.snap_back,
		infotip = args.infotip,
		contents = {
			{ n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
			(not args.hide_single_page or cards_per_page < #pool) and {
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					create_option_cycle({
						options = options,
						w = 4.5,
						cycle_shoulders = true,
						opt_callback =
						'SMODS_card_collection_page',
						current_option = 1,
						colour = G.ACTIVE_MOD_UI and
							(G.ACTIVE_MOD_UI.ui_config or {}).collection_option_cycle_colour or G.C.RED,
						no_pips = true,
						focus_args = { snap_to = true, nav = 'wide' }
					})
				}
			} or nil,
		}
	})
	return t
end

local function jukebox_collection_ui(e)
	return JTJukebox.create_collection_ui(JTJukebox.MusicTags, { 6, 6, 6 }, {
		snap_back = true,
		hide_single_page = true,
		collapse_single_page = true,
		center = 'c_base',
		h_mod = 0.8,
		back_func = G.ACTIVE_MOD_UI and "openModUI_" .. G.ACTIVE_MOD_UI.id or 'your_collection',
		infotip = {
			"Some music tracks are unlocked",
			"when you encounter them for the first time"
		},
		modify_card = function(card, center)
			local temp_blind = Sprite(card.children.center.T.x, card.children.center.T.y, 2.2, 2.2,
				(center.discoverable and not center.discovered) and G.ASSET_ATLAS["hpot_jukebox_undiscovered"] or
				G.ASSET_ATLAS[center.key] or G.ASSET_ATLAS["hpot_jukebox_default"], { x = 0, y = 0 })
			temp_blind.states.click.can = false
			temp_blind.states.drag.can = false
			temp_blind.states.hover.can = true
			card.children.center = temp_blind
			temp_blind:set_role({ major = card, role_type = 'Glued', draw_major = card })
			local spr = nil
			if center.discoverable and not center.discovered then
				-- create funny thing here
				card.config.center = SMODS.shallow_copy(card.config.center)
				card.config.center.soul_pos = { x = 1, y = 0 }
				spr = Sprite(card.children.center.T.x, card.children.center.T.y, 2.2, 2.2,
					G.ASSET_ATLAS["hpot_jukebox_undiscovered"], { x = 1, y = 0 })
				spr.states.click.can = false
				spr.states.drag.can = false
				spr.states.hover.can = true
				spr.role.draw_major = card
				card.children.floating_sprite = spr
			end
			card.set_sprites = function(...)
				local args = { ... }
				--if not args[1].animation then return end -- fix for debug unlock
				local c = card.children.center
				Card.set_sprites(...)
				card.children.center = c
				card.children.floating_sprite = spr
			end
			card.T.w = 2.2
			card.T.h = 2.2
			temp_blind:define_draw_steps({
				{ shader = 'dissolve', shadow_height = 0.05 },
				{ shader = 'dissolve' }
			})
			temp_blind.float = true
			card.hpot_jukebox_key = center.key
			local old_click = card.click
			card.click = function(self)
				old_click(self)
				if not (center.discoverable and not center.discovered) then
					JTJukebox.CurrentlyPlaying = (center.title and (center.title .. " - " .. center.artist) or center.key) ..
						" - "
					JTJukebox.ActuallyPlaying = center.key
					JTJukebox.Current = JTJukebox.Music[center.key].order
					G.FUNCS[G.ACTIVE_MOD_UI and "openModUI_" .. G.ACTIVE_MOD_UI.id or 'your_collection'](e)
				end
			end
		end,
	})
end

G.FUNCS.your_collection_hpot_jukebox = function()
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu {
		definition = jukebox_collection_ui()
	}
end

---@param config table
---@return table
function create_center_aligned_text(config)
	return {
		n = G.UIT.R,
		config = { align = "cm", r = 0.2, maxw = config.maxw or 1e300 },
		nodes = {
			{
				n = G.UIT.T,
				config = config
			}
		}
	}
end

function G.FUNCS.hpot_jukebox_play(e)
	G.FUNCS.your_collection_hpot_jukebox(e)
end

function G.FUNCS.hpot_jukebox_shuffle(e)
	local pool = {}
	for k, v in pairs(JTJukebox.MusicTags) do
		if not (v.discoverable and not v.discovered) then
			pool[#pool+1] = v
		end
	end
	local random = pseudorandom_element(pool, "hpot_jukebox_shuffle")
	if random then
		JTJukebox.CurrentlyPlaying = (random.title and (random.title .. " - " .. random.artist) or random.key) ..
			" - "
		JTJukebox.ActuallyPlaying = random.key
		JTJukebox.Current = JTJukebox.Music[random.key].order
		G.FUNCS[G.ACTIVE_MOD_UI and "openModUI_" .. G.ACTIVE_MOD_UI.id or 'your_collection'](e)
	end
end

function G.FUNCS.hpot_jukebox_stop(e)
	JTJukebox.CurrentlyPlaying = localize('hotpot_jukebox_default_music_title')
	JTJukebox.ActuallyPlaying = nil
	JTJukebox.Current = 0
	G.ALBUM_CARD:start_dissolve()
	G.ALBUM_CARD.hpot_jukebox_none = true
	G.ALBUM_CARD.ability_UIBox_table = G.ALBUM_CARD:generate_UIBox_ability_table()
	local desc = G.UIDEF.card_h_popup(G.ALBUM_CARD)
	if G.ALBUM_DESC then G.ALBUM_DESC:remove() end
	---@type balatro.UIElement
	local uibox = e.UIBox:get_UIE_by_ID("hpot_jukebox_desc")
	if uibox then
		G.ALBUM_DESC = UIBox {
			definition = desc,
			config = { align = "cm", instance_type = "POPUP" }
		}
		uibox.config.object = G.ALBUM_DESC
		uibox.UIBox:recalculate()
		G.OVERLAY_MENU:recalculate()
	end
end

function G.FUNCS.hpot_jukebox_can_stop_playback(e)
	if JTJukebox.ActuallyPlaying then
		e.config.colour = G.C.RED
		e.config.button = 'hpot_jukebox_stop'
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

-- Jukebox tab lmao
function JTJukebox.MusicTab()
	local current = JTJukebox.MusicTags[JTJukebox.Current]
	JTJukebox.CurrentlyPlaying = JTJukebox.CurrentlyPlaying or localize('hotpot_jukebox_default_music_title')
	-- scrolling text
	local titleDynaText = DynaText {
		string = {
			{
				ref_table = JTJukebox,
				ref_value = "CurrentlyPlaying"
			}
		},
		colours = { G.C.DARK_EDITION },
		bump = true,
		silent = true,
		pop_in_rate = 99999,
		spacing = 2,
		maxw = 10 - 0.5,
		does_scroll = true,
		non_recalc = true,
		shadow = true,
	}
	titleDynaText.config.stencil = function()
		love.graphics.rectangle(
			"fill",
			titleDynaText.T.x * G.TILESIZE * G.TILESCALE,
			titleDynaText.T.y * G.TILESIZE * G.TILESCALE,
			(10 - 0.5) * G.TILESIZE * G.TILESCALE,
			10 * G.TILESIZE * G.TILESCALE
		)
	end

	-- album card
	G.ALBUM_CARD = Card(0, 0, 3.6, 3.6, G.P_CARDS.empty, G.P_CENTERS.c_base)
	G.ALBUM_CARD.states.drag.can = true
	G.ALBUM_CARD_AREA = CardArea(
		G.ROOM.T.w / 2, G.ROOM.T.h / 2, 3.8, 3.8, { type = "title" }
	)
	if G.ALBUM_CARD.children and G.ALBUM_CARD.children.center then
		G.ALBUM_CARD.children.center:remove()
		local sprite = Sprite(G.ALBUM_CARD.T.x, G.ALBUM_CARD.T.y, G.ALBUM_CARD.T.w, G.ALBUM_CARD.T.h,
			JTJukebox.Current > 0 and G.ASSET_ATLAS[current.key] or G.ASSET_ATLAS["hpot_jukebox_default"],
			{ x = 0, y = 0 })
		sprite.states.hover = G.ALBUM_CARD.states.hover
		sprite.states.click = G.ALBUM_CARD.states.click
		sprite.states.drag = G.ALBUM_CARD.states.drag
		sprite.states.collide.can = false
		sprite:set_role({ major = G.ALBUM_CARD, role_type = 'Glued', draw_major = G.ALBUM_CARD })
		G.ALBUM_CARD.children.center = sprite
		G.ALBUM_CARD.hpot_jukebox_key = current and current.key
		G.ALBUM_CARD.hpot_jukebox_none = JTJukebox.Current == 0
		local old_hover = G.ALBUM_CARD.hover
		G.ALBUM_CARD.hover = function(self)
			old_hover(self)
			self.config.h_popup = nil
			self.config.h_popup_config = nil
			if self.children.h_popup then
				self.children.h_popup:remove()
				self.children.h_popup = nil
			end
		end
		if G.ALBUM_CARD.hpot_jukebox_none then
			G.ALBUM_CARD.states.visible = false
		end
	end
	-- set descriptions
	G.ALBUM_CARD.ability_UIBox_table = G.ALBUM_CARD:generate_UIBox_ability_table()
	local desc = G.UIDEF.card_h_popup(G.ALBUM_CARD)
	G.ALBUM_DESC = UIBox {
		definition = desc,
		config = { align = "cm" }
	}
	G.ALBUM_CARD_AREA:emplace(G.ALBUM_CARD)
	if not G.ALBUM_CARD.hpot_jukebox_none then
		G.ALBUM_CARD:start_materialize()
	end

	return {
		n = G.UIT.ROOT,
		config = { colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.C,
				config = {
					r = 0.1,
					align = "tm",
					padding = 0.2,
					colour = G.C.BLACK
				},
				nodes = {
					{
						n = G.UIT.R,
						config = {
							align = "tm",
						},
						nodes = {
							-- Banner
							{
								n = G.UIT.R,
								config = {
									r = 0.1,
									minw = 10,
									minh = 1,
									align = "cm",
									padding = 0.2,
									colour = darken(G.C.BLACK, 0.2),
									emboss = 0.05,
								},
								nodes = {
									{
										n = G.UIT.O,
										config = {
											object = titleDynaText,
											id = 'hpot_jukebox_text'
										}
									},
								}
							},
						}
					},
					{
						n = G.UIT.R,
						config = {
							align = "tm",
							padding = 0.2,
						},
						nodes = {
							{
								n = G.UIT.C,
								config = {
									r = 0.2,
									align = "tm",
									padding = 0.125,
									colour = G.C.L_BLACK,
									emboss = 0.05,
									minw = 4.2
								},
								nodes = {
									{
										n = G.UIT.C,
										config = {
											r = 0.2,
											align = "tm",
											padding = 0.125,
											colour = G.C.BLACK,
											emboss = 0.05,
											minw = 4
										},
										nodes = {
											{
												n = G.UIT.R,
												config = { align = "cm" },
												nodes = {
													{ n = G.UIT.T, config = { text = localize("hotpot_current_track"), scale = 0.4, colour = G.C.L_BLACK } },
												}
											},
											-- Cover art (if any)
											{
												n = G.UIT.R,
												config = {
													align = "cm",
													padding = 0.2,
												},
												nodes = {
													{
														n = G.UIT.O,
														config = {
															object = G.ALBUM_CARD_AREA,
															id = 'hpot_jukebox_cover_art'
														},
													}
												}
											},
											{ n = G.UIT.R, config = { align = "cm", minh = 0.05 } }
										}
									},

								}
							},
							{
								n = G.UIT.C,
								config = {
									r = 0.1,
									align = "cm",
									padding = 0.1,
									colour = G.C.CLEAR
								},
								nodes = {
									-- Track description
									{
										n = G.UIT.R,
										config = {
											align = "cm",
											--padding = -0.2, -- Negative padding strikes again
										},
										nodes = {
											{
												n = G.UIT.O,
												config = {
													object = G.ALBUM_DESC,
													id = "hpot_jukebox_desc",
													align = "cm"
												}
											}
										}
									},
									-- Playback controls
									{
										n = G.UIT.R,
										config = {
											align = "cm",
										},
										nodes = {
											-- play butan
											-- NOTE: Originally the plan here was to make this a collection button
											-- where you would pick the music you want from the collection menu
											-- to save time I just did this but if you wanna do that then ok
											-- 09/28 haya: I'm back.
											{
												n = G.UIT.C,
												config = { align = "cm", minh = 0.75, minw = 4, colour = G.C.GREEN, r = 0.2, emboss = 0.05, button = 'hpot_jukebox_play', button_dist = 0.1, hover = true },
												nodes = {
													create_center_aligned_text { align = "cm", text = localize('hotpot_jukebox_request'), colour = G.C.UI.TEXT_LIGHT, maxw = 3.5, scale = 0.5, shadow = true }
												},
											},
										}
									},
									{
										n = G.UIT.R,
										config = {
											align = "cm",
										},
										nodes = {
											-- unplay butan
											{
												n = G.UIT.C,
												config = { align = "cm", minh = 0.75, minw = 4, colour = G.C.RED, r = 0.2, emboss = 0.05, button = 'hpot_jukebox_stop', func = "hpot_jukebox_can_stop_playback", button_dist = 0.1, hover = true },
												nodes = {
													create_center_aligned_text { align = "cm", text = localize('hotpot_jukebox_unrequest'), colour = G.C.UI.TEXT_LIGHT, maxw = 3.5, scale = 0.5, shadow = true }
												},
											},
										}
									},
									{
										n = G.UIT.R,
										config = {
											align = "cm",
										},
										nodes = {
											-- shuffle
											{
												n = G.UIT.C,
												config = { align = "cm", minh = 0.75, minw = 4, colour = G.C.FILTER, r = 0.2, emboss = 0.05, button = 'hpot_jukebox_shuffle', button_dist = 0.1, hover = true },
												nodes = {
													create_center_aligned_text { align = "cm", text = localize('hotpot_jukebox_shuffle'), colour = G.C.UI.TEXT_LIGHT, maxw = 3.5, scale = 0.5, shadow = true }
												},
											},
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
end
