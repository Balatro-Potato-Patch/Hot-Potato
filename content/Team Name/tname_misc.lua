PotatoPatchUtils.Team {
	name = 'Team Name',
	colour = HEX('fdd48e'),
	short_credit = true
}

SMODS.Sound {
  key = "music_reforge",
  path = "music_reforge_menu.ogg",
  pitch = 1,
  select_music_track = function (self)
    if PissDrawer.Shop.active_tab == "hotpot_shop_tab_hotpot_tname_toggle_reforge" then
      return 1349
    end
  end,
  hpot_purpose = {
    "Music that plays while",
    "reforging a Joker"
  },
  
	ppu_team = { "Team Name" }
}

SMODS.Sound {
  key = "tname_losecred",
  path = "sfx_creditslose.ogg",
}
SMODS.Sound {
  key = "tname_gaincred",
  path = "sfx_creditsgain.ogg",
}
SMODS.Sound {
  key = "tname_reforge",
  path = "sfx_reforge.ogg",
}


HPTN.C = {
	BROWN = HEX("916400"),
}


SMODS.Gradient({
	key = "hpot_red_to_green",
	colours = {
		HEX("ff6961"),
		HEX("77DD77"),
	},
	cycle = 3.5,
})

SMODS.Gradient({
	key = "hpot_green_to_red",
	colours = {
		HEX("77DD77"),
		HEX("ff6961"),
	},
	cycle = 3.5,
})


local loc_old = loc_colour
function loc_colour(_c, _default)
	if not G.ARGS.LOC_COLOURS then
		loc_old()
	end
	G.ARGS.LOC_COLOURS.hpot_rtg = SMODS.Gradients["hpot_red_to_green"]
  G.ARGS.LOC_COLOURS.hpot_gtr = SMODS.Gradients["hpot_green_to_red"]
	return loc_old(_c, _default)
end

-- for iris select button

G.FUNCS.can_pull_card = function(e)
	local card = e.config.ref_table
	if #G.consumeables.cards < G.consumeables.config.card_limit then
		e.config.colour = G.C.RED
		e.config.button = "pull_card"
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end
G.FUNCS.pull_card = function(e)
	local card = e.config.ref_table
	card.area:remove_card(card)
	card:add_to_deck()
	G.consumeables:emplace(card)
end
