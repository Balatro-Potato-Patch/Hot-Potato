SMODS.Atlas {
    key = "morb",
    path = "Jtem/plasmorbin_time.png",
    px = 40,
    py = 40
}

SMODS.Sound {
  key = "music_morbintime",
  path = "music_morbintime.ogg",
  select_music_track = function (self)
    if PlinkoLogic.STATE ~= PlinkoLogic.STATES.CLOSED and PlinkoUI.sprites.changed == "morb" then
      return 1339
    end
  end,
  hpot_discoverable = true,
	hpot_purpose = {
		"Music that plays when a plasmid",
    "orb is selected in Plinko"
	},
  ppu_team = { "Jtem" }
}

SMODS.Atlas {
    key = "finityorb",
    path = "Jtem/finitorb.png",
    px = 40,
    py = 40
}

SMODS.Sound {
  key = "music_finity",
  path = "music_plinko_finity.ogg",
  select_music_track = function (self)
    if PlinkoLogic.STATE ~= PlinkoLogic.STATES.CLOSED and PlinkoUI.sprites.changed == "finity" then
      return 1340
    end
  end,
  hpot_discoverable = true,
	hpot_purpose = {
		"Music that plays when a finity",
    "orb is selected in Plinko"
	},
  ppu_team = { "Jtem" }
}

SMODS.Sound {
  key = "music_nxkill",
  path = "music_nxkill.ogg",
  select_music_track = function(self)
    if SMODS.LAST_SELECTED_MOD_TAB == "HotPotato_1" and G.OVERLAY_MENU then
      return 1353
    end
  end,
  hpot_purpose = {
    "Music that plays while",
    "killing Nxkoo"
  },
  ppu_team = { "Jtem" }
}
SMODS.Sound {
  key = "music_training",
  path = "music_training.ogg",
    select_music_track = function(self)
    if PissDrawer.Shop.active_tab == "hotpot_shop_tab_hotpot_pissdrawer_toggle_training" then
      return 1350
    end
  end,
  hpot_purpose = {
    "Music that plays in",
    "the Training Tab"
  },
  pitch = 1,
  ppu_team = { "Jtem" }
}

SMODS.Sound {
  key = "music_delivery",
  path = "music_delivery.ogg",
    select_music_track = function(self)
    if PissDrawer.Shop.active_tab == "hotpot_shop_tab_hotpot_jtem_toggle_delivery" or (G.HP_JTEM_DELIVERY_VISIBLE and G.hpot_event) then
      return 1351
    end
  end,
  hpot_purpose = {
    "Music that plays in",
    "the Delivery tab"
  },
  ppu_team = { "Jtem" }
}

SMODS.Sound {
  key = "sfx_whistleup",
  path = "sfx_whistleup.ogg",
}

SMODS.Sound {
  key = "sfx_whistledown",
  path = "sfx_whistledown.ogg",
}

-- theres background noise since i took this while recording the game sound
-- couldnt find this while looking through the game assets lmao
SMODS.Sound {
  key = "sfx_stat_up",
  path = "sfx_stat_up.ogg",
}

SMODS.Sound {
  key = "sfx_stat_down",
  path = "sfx_stat_down.ogg",
}

SMODS.Sound {
  key = "sfx_success",
  path = "sfx_success.ogg",
}

SMODS.Sound {
  key = "sfx_failure",
  path = "sfx_failure.ogg",
}

SMODS.Atlas {
  key = "jtem_pkg",
  path = "Jtem/package_icon.png",
  px = 34,py = 34
}

SMODS.Sound {
  key = "ws_again",
  path = "sfx_again.ogg"
}

SMODS.Atlas {
  key = "jukebox_default",
  path = "Jukebox/default_coverart.png",
  px = 159,py = 159
}

SMODS.Atlas {
  key = "jukebox_undiscovered",
  path = "Jukebox/undiscovered.png",
  px = 128,py = 128
}

SMODS.Atlas {
  key = "jtem_mood",
  path = "Jtem/mood.png",
  px = 71,py = 95
}

SMODS.Atlas {
  key = "jtem_training_tarots",
  path = "Jtem/uma_tarots.png",
  px = 71,py = 95
}

SMODS.Atlas {
  key = "jtem_training_spectrals",
  path = "Jtem/training_spectral.png",
  px = 71,py = 95
}


SMODS.Atlas {
  key = "jtem_vouchers",
  path = "Jtem/Vouchers.png",
  px = 71,py = 95
}

SMODS.Atlas {
  key = "jtem_delivery_vouchers",
  path = "Jtem/joker_delivery_voucher.png",
  px = 71,py = 95
}

SMODS.Atlas {
  key = "jtemads",
  path = "Ads/Jtem.png",
  px = 200,py = 150
}

SMODS.Atlas {
  key = "jtemfuck",
  path = "Ads/fuck.png",
  px = 200,py = 150,
  frames = 16, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "jtem_postlatro",
  path = "Jtem/postlatro.png",
  px = 113,py = 57,
  frames = 4, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "jtem_legendary_plinker",
  path = "Jtem/legendary_plinker.png",
  px = 40,py = 40,
}

SMODS.Atlas {
  key = "jtem_jcoin",
  path = "Jtem/jcoin.png",
  px = 40,py = 40,
}

SMODS.Atlas {
  key = "jtem_fisch",
  path = "Jtem/gorbfish.png",
  px = 40,py = 40,
}

SMODS.Atlas {
  key = "jtem_jxtag",
  path = "Jtem/the_j.png",
  px = 34,py = 34,
}

SMODS.Atlas {
  key = "jtem_jxtag_dobule",
  path = "Jtem/jx_tag_2.png",
  px = 34,py = 34,
}

SMODS.Atlas {
  key = "jtem_aikoshen1",
  path = "Ads/aikoshenad1.png",
  px = 179,py = 97,
}

SMODS.Atlas {
  key = "jtemrally",
  path = "Ads/Rally.png",
  px = 240,py = 320,
  frames = 40, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "jtemrally",
  path = "Ads/Rally.png",
  px = 240,py = 320,
  frames = 40, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "jtem_again",
  path = "Ads/buckyAd.png",
  px = 125,py = 105,
  frames = 10, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "jtem_bts",
  path = "Ads/btsAd.png",
  px = 160,py = 108,
  frames = 51, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "jtem_ad_error1",
  path = "Ads/errorAd.png",
  px = 200,py = 150,
}

SMODS.Atlas {
  key = "jtem_slop_live",
  path = "Jtem/slop_live.png",
  px = 71,py = 95
}

SMODS.Atlas {
  key = "jtem_trainingpack",
  path = "Jtem/trainingpack.png",
  px = 71,py = 95
}

SMODS.Atlas {
  key = "jtem_jx_bundle",
  path = "Jtem/jx_trade.png",
  px = 81,py = 81,
}

SMODS.Atlas {
  key = "jtem_special_week",
  path = "Jtem/special_week.png",
  px = 71,py = 95
}

SMODS.Font {
  key = "jtem_roboto_bold",
  path = "Roboto-Bold.ttf",
  FONTSCALE = 0.085
}

-- Defines food jokers

if not SMODS.ObjectTypes.Food then
  SMODS.ObjectType {
    key = 'Food',
    default = 'j_egg',
    cards = {
      j_gros_michel = true,
      j_selzer = true,
      j_egg = true,
      j_ice_cream = true,
      j_popcorn = true,
      j_cavendish = true,
      j_turtle_bean = true,
      j_diet_cola = true,
      j_ramen = true
    },
  }
end

-- more buttons!!!
SMODS.draw_ignore_keys.hp_jtem_price_side = true
SMODS.draw_ignore_keys.hp_jtem_cancel_order = true

local funny_str = "!\"#$%&'()+-*,./\\:;<=>?[]^_~"
local font_cache = {}

SMODS.DynaTextEffect {
	key = "glitching",
	func = function(dynatext, index, letter)
		if not letter.normal_letter then
			letter.normal_letter = letter.letter
		end
		local st = pseudorandom('skip_'..index, 1, #funny_str)
		local rnd = string.sub(funny_str, st, st+1)
		font_cache[dynatext.font.key or dynatext.font.file] = font_cache[dynatext.font.key or dynatext.font.file] or {}
		font_cache[dynatext.font.key or dynatext.font.file][rnd] = font_cache[dynatext.font.key or dynatext.font.file][rnd] or love.graphics.newText(dynatext.font.FONT, rnd)
		--print(rnd)
		letter.letter = font_cache[dynatext.font.key or dynatext.font.file][rnd]
  end
}

function hp_jtem_juice_card_until(card, eval_func, first, delay, s, r, interval)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',delay = delay or 0.1, blocking = false, blockable = false, timer = 'REAL',
        func = (function() local result, s2, r2, interval2 = eval_func(card, s, r, interval) if result then if not first or first then card:juice_up(s2 or s or 0.1, r2 or r or 0.1) end;hp_jtem_juice_card_until(card, eval_func, nil, interval2 or interval or 0.8, s, r, interval2 or interval) end return true end)
    }))
end

function hp_jtem_create_UIBox_card_alert(args)
  args = args or {}
  return {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR, refresh_movement = true}, nodes={
      {n=G.UIT.R, config={align = "cm", r = 0.15, minw = 0.42, minh = 0.42, colour = args.no_bg and G.C.CLEAR or args.bg_col or ((args.red_bad and darken(G.C.RED, 0.1) or G.C.RED)), draw_layer = 1, emboss = 0.05, refresh_movement = true}, nodes={
        {n=G.UIT.O, config={object = DynaText({string = args.text or '!', colours = {args.text_colour or G.C.WHITE},shadow = true, rotate = true,H_offset = args.y_offset or 0,bump_rate = args.text and 3 or 7, bump_amount = args.bump_amount or 3, bump = true,maxw = args.maxw, text_rot = args.text_rot or  0.2, spacing = 3*(args.scale or 1), scale = args.scale or 0.48})}}
      }},
  }}
end