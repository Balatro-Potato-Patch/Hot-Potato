
-- watch lua Mods/Hot-Potato/Perkeocoin/plinko_ui.lua

---------------
-- Lovely UI mess
---------------

SMODS.Atlas {
  key = "hpot_plinko_sign",
  path = "plinko/plinko_sign.png",
  px = 113,py = 57,
  frames = 4, atlas_table = 'ANIMATION_ATLAS'
}

local reward_scale = 0.7

PlinkoUI = {
  s = {
    reward_area_w = 0.56 * reward_scale,
    reward_area_h = 0.56 * reward_scale * G.CARD_W/G.CARD_H, -- square
  },
  f = { },
  sprites = {
  },
  extra_sprites = {
    bitcoin = {
      atlas = "hpot_hc_plinkos",
      pos = {x = 0, y = 0}
    },
    github = {
      atlas = "hpot_hc_plinkos",
      pos = {x = 1, y = 0}
    },
    entropy = {
      atlas = "hpot_hc_plinkos",
      pos = {x = 2, y = 0}
    }
  }
}

SMODS.Atlas {
  key = "perkeorb",
  path = "plinko/perkeocoin_perkeorb.png",
  px = 40,
  py = 40,
}

SMODS.Atlas {
  key = "peg",
  path = "plinko/perkeocoin_peg.png",
  px = 10,
  py = 10,
}

SMODS.Atlas {
  key = "wall",
  path = "plinko/perkeocoin_wall2.png",
  px = 5,
  py = 110,
}

SMODS.Sound {
  key = "tada",
  path = "sfx_tada.ogg",
}

SMODS.Sound {
  key = "not_tada",
  path = "sfx_not_tada.ogg",
}

SMODS.Sound {
  key = "bottlecap",
  path = "sfx_bottlecap.ogg",
}

SMODS.Sound {
  key = "plink",
  path = "sfx_plink.ogg",
}

SMODS.Sound {
  key = "meow",
  path = "sfx_meow.ogg",
}


--SMODS.Sound {
--  key = "hit_wall",
--  path = "hit_wall.ogg",
--}

SMODS.Sound {
  key = "music_plinko",
  path = "music_plinko.ogg",
  select_music_track = function (self)
    if PlinkoLogic.STATE ~= PlinkoLogic.STATES.CLOSED then
      return 1337
    end
  end,
  hpot_title = "Plinko Theme (OST Mix)",
  hpot_purpose = {
    "Music that plays while",
    "playing Plinko"
  },
  ppu_team = { "Perkeocoin" }
}

SMODS.Sound {
  key = "music_plinko_stupid",
  path = "music_plinko_stupid.ogg",
  select_music_track = function (self)
    if false and PlinkoLogic.STATE ~= PlinkoLogic.STATES.CLOSED and PlinkoUI.sprites.changed == "stupid" then
      return 1338
    end
  end,
  hpot_title = "Meowsynthwave (OST Mix)",
  hpot_discoverable = true,
	hpot_purpose = {
		"Music that plays when a stupid",
    "orb is selected in Plinko"
	},
  ppu_team = { "Perkeocoin" }
}


function PlinkoUI.f.init_sprites()

  local orb_size = 0.343
  if not PlinkoUI.sprites.perkeorb then
    PlinkoUI.sprites.perkeorbOG = Sprite (0, 0, orb_size, orb_size, G.ASSET_ATLAS['hpot_perkeorb'])
    PlinkoUI.sprites.perkeorb = PlinkoUI.sprites.perkeorbOG
  end

  if not PlinkoUI.sprites.stupid then
    PlinkoUI.sprites.stupid = Sprite (0, 0, orb_size, orb_size, G.ASSET_ATLAS['hpot_stupidorb'])
  end

  if not PlinkoUI.sprites.morb then
    PlinkoUI.sprites.morb = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_morb'])
  end

  if not PlinkoUI.sprites.finity then
    PlinkoUI.sprites.finity = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_finityorb'])
  end

  if not PlinkoUI.sprites.caino_plinker then -- yes i misspell it on purpose
    PlinkoUI.sprites.caino_plinker = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_jtem_legendary_plinker'], { x = 0, y = 0})
  end

  if not PlinkoUI.sprites.trib_plinker then
    PlinkoUI.sprites.trib_plinker = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_jtem_legendary_plinker'], { x = 1, y = 0})
  end

  if not PlinkoUI.sprites.yorick_plinker then
    PlinkoUI.sprites.yorick_plinker = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_jtem_legendary_plinker'], { x = 2, y = 0})
  end
  
  if not PlinkoUI.sprites.chicot_plinker then
    PlinkoUI.sprites.chicot_plinker = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_jtem_legendary_plinker'], { x = 3, y = 0})
  end

  if not PlinkoUI.sprites.jcoin then
    PlinkoUI.sprites.jcoin = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_jtem_jcoin'], { x = 0, y = 0})
  end

  if not PlinkoUI.sprites.fisch then
    PlinkoUI.sprites.fisch = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS['hpot_jtem_fisch'], { x = 0, y = 0})
  end
  for i, v in pairs(PlinkoUI.extra_sprites) do
    if not PlinkoUI.sprites[i] then
      PlinkoUI.sprites[i] = Sprite (0,0,orb_size,orb_size,G.ASSET_ATLAS[v.atlas], v.pos)
    end
  end
  if not PlinkoUI.sprites.peg then
    -- scale dimensions relative to the orb
    local peg_size = PlinkoGame.s.peg_radius * (orb_size / PlinkoGame.s.ball_radius)
  

    PlinkoUI.sprites.peg = Sprite (0, 0, peg_size, peg_size, G.ASSET_ATLAS['hpot_peg'])
  end

  if not PlinkoUI.sprites.wall then
    -- scale dimensions relative to the orb
    local wall_width = PlinkoGame.s.wall_width * (orb_size / PlinkoGame.s.ball_radius)
    local wall_height = PlinkoGame.s.wall_height/2.2 * (orb_size / PlinkoGame.s.ball_radius)
  

    PlinkoUI.sprites.wall = Sprite (0, 0, wall_width, wall_height, G.ASSET_ATLAS['hpot_wall'])
  end

end


function PlinkoUI.f.adjust_rewards()
  for _, card in pairs(G.plinko_rewards.cards) do
    -- Scale down
        -- card:hard_set_T(nil, nil, G.CARD_W * PlinkoUI.s.reward_area_w, G.CARD_H * PlinkoUI.s.reward_area_h);
        card:hotpot_resize(0.8)
  end
end

function PlinkoUI.f.clear_plinko_rewards()
  for k, v in pairs(G.plinko_rewards.cards) do
    v:start_dissolve({G.C.BLACK, G.C.WHITE, G.C.RED, G.C.GREY, G.C.JOKER_GREY}, true)
  end
end

function PlinkoUI.f.update_plinko_rewards(no_load)
  if not G.plinko_rewards then
    return
  end
  PlinkoUI.f.clear_plinko_rewards()
  
  G.E_MANAGER:add_event(Event({
    delay = 0.4,
    func = (function()
      PlinkoLogic.f.generate_rewards(no_load)
      PlinkoUI.f.adjust_rewards()
      return true
    end)
  }))
end

function G.UIDEF.plinko()
    G.plinko_rewards = CardArea(
      G.hand.T.x+0,
      G.hand.T.y+9,
      PlinkoLogic.rewards.total*PlinkoUI.s.reward_area_w/reward_scale*G.CARD_W,
      PlinkoUI.s.reward_area_h/reward_scale*G.CARD_H,
      {card_limit = PlinkoLogic.rewards.total, type = 'shop', highlight_limit = 0})

    local use_ante = to_number(G.GAME.current_round.plinko_cost_reset.ante_left) > 0
    local play_dollars = not not G.GAME.plinko_dollars_cost
    local plinko_4ever = G.GAME.modifiers.hpot_plinko_4ever

    local t = {n=G.UIT.ROOT, config = {align = 'cl', colour = G.C.CLEAR}, nodes={
            UIBox_dyn_container({
                {n=G.UIT.R, config={align = "cm", padding = 0.1, emboss = 0.05, r = 0.1, colour = G.C.DYN_UI.BOSS_MAIN}, nodes={
                    {n=G.UIT.C, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
                      {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        {n=G.UIT.R,config={id = 'shop_button', align = "cm", minw = 2.8, minh = 1.5, r=0.15,colour = G.C.RED, one_press = false, button = 'hide_plinko', func = 'can_hide_plinko', hover = true,shadow = true}, nodes = {
                          {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'y', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                            {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                              -------------------
                              {n=G.UIT.T, config={text = localize(plinko_4ever and 'b_next_round_1' or "hotpot_plinko_to_shop1"), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                              -------------------
                            }},
                            {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                              -------------------
                              {n=G.UIT.T, config={text = localize(plinko_4ever and 'b_next_round_2' or "hotpot_plinko_to_shop2"), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                              -------------------
                            }}
                          }},
                        }},

                        {n=G.UIT.R, config={id= "plinko_plincoins", align = "cm", minw = 2.8, minh = play_dollars and 1.3 or 1.6, r=0.15, padding = 0.07, colour = G.C.MONEY, button = 'start_plinko', func = 'can_plinko', hover = true,shadow = true}, nodes = {
                          {n=G.UIT.C, config={align = "cm", focus_args = {button = 'x', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                            {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                              -------------------
                              {n=G.UIT.T, config={text = localize("hotpot_plinko_play"), scale = 0.7, colour = G.C.WHITE, shadow = true}},
                              -------------------
                            }},
                            not plinko_4ever and {n=G.UIT.R, config={align = "cm", maxw = 1.3, minw = 1}, nodes={
                              -------------------
                              {n=G.UIT.T, config={text = localize('$'), font = SMODS.Fonts.hpot_plincoin, scale = 0.7, colour = G.C.WHITE, shadow = true}},
                              {n=G.UIT.T, config={ref_table = G.GAME.current_round, ref_value = 'plinko_roll_cost', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                              -------------------
                            }} or nil
                          }}
                        }},

                        play_dollars and {n=G.UIT.R, config={id= "plinko_dollars", align = "cm", minw = 2.8, minh = 1.3, r=0.15, padding = 0.07, colour = G.C.GREEN, button = 'start_plinko_dollars', func = 'can_plinko_dollars', hover = true,shadow = true}, nodes = {
                          {n=G.UIT.C, config={align = "cm", }, nodes={
                            {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                              -------------------
                              {n=G.UIT.T, config={text = localize("hotpot_plinko_play"), scale = 0.7, colour = G.C.WHITE, shadow = true}},
                              -------------------
                            }},
                            not plinko_4ever and {n=G.UIT.R, config={align = "cm", maxw = 1.3, minw = 1}, nodes={
                              -------------------
                              {n=G.UIT.T, config={text = localize('$'), scale = 0.7, colour = G.C.WHITE, shadow = true}},
                              {n=G.UIT.T, config={ref_table = G.GAME.current_round, ref_value = 'plinko_roll_cost_dollars', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                              -------------------
                            }} or nil
                          }}
                        }} or nil,


                        -- 
                        -- PLINKO INFO
                        -- 

                        not plinko_4ever and {n=G.UIT.R, config={align = "cm", id="plinko_info", minw = 2.8, r=0.15, minh = 1.3 }, nodes = {
                          {n=G.UIT.C, config={align = "cm", }, nodes={
                            {n=G.UIT.R, config={align = "cm", maxw = 1.9}, nodes={
                              -------------------
                              {n=G.UIT.T, config={text = localize("hotpot_plinko_cost1"), scale = 0.75, colour = G.C.WHITE, shadow = true}},
                              -------------------
                            }},
                            {n=G.UIT.R, config={align = "cm", maxw = 1.9, minw = 1}, nodes={
                              -------------------
                              {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.GAME.current_round, ref_value = 'plinko_cost_up_in', suffix = localize('hotpot_plinko_cost2')}}, maxw = 1.35, colours = {G.C.WHITE}, font = SMODS.Fonts.hpot_plincoin, shadow = true,spacing = 2, bump = false, scale = 0.75}), }},
                              -------------------
                              }}
                            }},
                          }} or nil,
                          not plinko_4ever and {n=G.UIT.R, config={align = "cm", id="plinko_reset", minw = 2.8, r=0.15, minh = 1.3}, nodes = {
                            {n=G.UIT.C, config={align = "cm", }, nodes={
                              {n=G.UIT.R, config={align = "cm", maxw = 1.9}, nodes={
                                -------------------
                                {n=G.UIT.T, config={text = localize("hotpot_plinko_reset1"), scale = 0.75, colour = G.C.WHITE, shadow = true}},
                                -------------------
                              }},
                              {n=G.UIT.R, config={align = "cm", maxw = 1.9, minw = 1}, nodes={
                                -------------------
                                {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.GAME.current_round.plinko_cost_reset, ref_value = use_ante and 'ante_left' or 'rounds_left', suffix = use_ante and localize('hotpot_plinko_reset2_ante') or localize('hotpot_plinko_reset2_round')}}, maxw = 1.35, colours = {G.C.WHITE}, font = SMODS.Fonts.hpot_plincoin, shadow = true,spacing = 2, bump = false, scale = 0.75}), }},
                                -------------------
                                }}
                              }},
                            }} or nil,
                          plinko_4ever and {n=G.UIT.R, config={align = "cm", minh = 0.3}, nodes={}} or nil,
                          -- JTEM: Booster slot for Booster related bottlecaps
                          plinko_4ever and {n=G.UIT.R, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, maxw = 2.8, emboss = 0.05}, nodes={
                              {n=G.UIT.O, config={object = G.shop_booster, maxw = 2.8}},
                            }} or nil,
                          }},
                        }},
                    }},

                    {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, emboss = 0.05, minw = 8.2}, nodes={
                      {n=G.UIT.R, config={id = "plinking_area", align = "cm", colour = G.C.BLACK, }, nodes={

                        {n=G.UIT.R, config={id = "plinking_area", align = "tm", colour = G.C.BLACK, padding = 0., minw = 7., minh = 5.8}, nodes={
                          -- Area for the plinko minigame
                        }},

                        {n=G.UIT.R, config={align = "bm", padding = 0., }, nodes={
                          {n=G.UIT.O, config={object = G.plinko_rewards}}
                        }},
                      }},
                    }},

                }
              },
              
              }, false)
        }}
    return t
end


G.FUNCS.can_plinko = function(e)
  if PlinkoLogic.STATE ~= PlinkoLogic.STATES.IDLE or not PlinkoLogic.f.can_roll() then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
      e.config.hover = nil
      for _, child in ipairs(e.children[1].children) do
        child.children[1].config.object.colours = {G.C.UI.TEXT_INACTIVE}
      end
  else
      e.config.colour = SMODS.Gradients.hpot_plincoin
      e.config.button = 'start_plinko'
      e.config.hover = true
      for _, child in ipairs(e.children[1].children) do
        child.children[1].config.object.colours = {G.C.UI.TEXT_LIGHT}
      end
  end
end

G.FUNCS.can_plinko_dollars = function(e)
  if PlinkoLogic.STATE ~= PlinkoLogic.STATES.IDLE or not PlinkoLogic.f.can_roll_dollars() then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
      e.config.hover = nil
      for _, child in ipairs(e.children[1].children) do
        child.children[1].config.object.colours = {G.C.UI.TEXT_INACTIVE}
      end
  else
      e.config.colour = G.C.GOLD
      e.config.button = 'start_plinko_dollars'
      e.config.hover = true
      for _, child in ipairs(e.children[1].children) do
        child.children[1].config.object.colours = {G.C.UI.TEXT_LIGHT}
      end
  end
end

-- Shop button logic - inactive when game isn't idle
G.FUNCS.can_hide_plinko = function(e)
  if PlinkoLogic.STATE ~= PlinkoLogic.STATES.IDLE then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
      e.config.colour = G.C.RED
      e.config.button = 'hide_plinko'
  end
end

G.FUNCS.start_plinko_dollars = function (e)
  G.FUNCS.start_plinko(e, true)
end


G.FUNCS.start_plinko = function(e, use_dollars)
  stop_use()

  G.CONTROLLER.locks.start_plinko = true

  PlinkoLogic.STATE = PlinkoLogic.STATES.IN_PROGRESS

  PlinkoLogic.f.handle_roll(use_dollars)

  G.GAME.balls_dropped = G.GAME.balls_dropped + 1
  
  PlinkoGame.f.drop_ball()

  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.2,
    func = function()
    G.E_MANAGER:add_event(Event({
      func = function()
        G.CONTROLLER.interrupt.focus = false
        G.CONTROLLER.locks.start_plinko = false
        -- dont need to recall shop when we start plinko
        -- G.CONTROLLER:recall_cardarea_focus('shop_jokers')
        ---------------------------------------------------------------
        -- TODO : maybe this should be moved to when reward is given?
        ---------------------------------------------------------------
        SMODS.calculate_context({plinko_started = true})
        return true
      end
    }))
    return true
  end
  }))
end

local caac = CardArea.align_cards

function CardArea:align_cards()
  caac(self)

    if self == G.plinko_rewards then
      local max_cards = math.max(#self.cards, self.config.temp_limit)
      for k, card in ipairs(self.cards) do
          if not card.states.drag.is then
              card.T.r = 0
              -- There is a smarter way to do this but I cba at this point
              card.T.x = self.T.x + (self.T.w)*((k)/math.max(max_cards, 1)) - self.card_w*(0.5 - reward_scale) - 1.4085
              local highlight_height = G.HIGHLIGHT_H
              if not card.highlighted then highlight_height = 0 end
              card.T.y = self.T.y + self.T.h/2 - card.T.h/2 - highlight_height
              card.T.x = card.T.x + card.shadow_parrallax.x/30
          end
      end
      table.sort(self.cards, function (a, b) return a.T.x + a.T.w/2 < b.T.x + b.T.w/2 end)
    end

end

function update_plinko(dt)
    -- Just in case
    if G.STAGE ~= G.STAGES.RUN then return end
    PlinkoGame.f.update_plinko_world(dt)
    if not G.STATE_COMPLETE then
        stop_use()
        ease_background_colour({new_colour = HEX('ffe96e'), special_colour = G.C.GREEN, tertiary_colour = darken( G.C.BLACK,0.1), contrast = 5})
        G.STATE_COMPLETE = true
    end
end

-- Let's go gambling
G.FUNCS.show_plinko = function(e)
  stop_use()

  hide_shop()

  G.STATE = G.STATES.PLINKO
  G.STATE_COMPLETE = false
  PlinkoLogic.STATE = PlinkoLogic.STATES.IDLE
end

-- Clicked back to shop
G.FUNCS.hide_plinko = function(e)
  if G.GAME.modifiers.hpot_plinko_4ever then
    PlinkoLogic.STATE = PlinkoLogic.STATES.CLOSED
    return G.FUNCS.toggle_shop(e)
  end
  stop_use()

  for i = #G.plinko_rewards.cards,1, -1 do
    local c = G.plinko_rewards:remove_card(G.plinko_rewards.cards[i])
    c:remove()
  end

  G.STATE = G.STATES.SHOP
  G.STATE_COMPLETE = false
  ease_background_colour_blind(G.STATE)
  show_shop()

  PlinkoLogic.STATE = PlinkoLogic.STATES.CLOSED

  G.E_MANAGER:add_event(Event({func = function()
      if G.shop then G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')}) end
  return true end }))

  PissDrawer.Shop.change_shop_sign("shop_sign")

end

local ca_dref = CardArea.draw
function CardArea:draw(...)
	if self == G.hand and (G.STATE == G.STATES.PLINKO) then
		return
	end
	return ca_dref(self, ...)
end

-- meow
SMODS.Atlas{key = "stupidorb",path = "plinko/perkeocoin_stupidorb.png",px = 40,py = 40,}