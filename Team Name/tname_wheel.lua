-- hello other teams. im so bad at coding (revo) so this just sucks but i wanted to keep it anyway
-- feel free to play arround with it and try to make it better (please)
-- i cant code :pensive:

-- PLEASE DO MORE WITH WHEEL I BEG

-- mostly copied from plinko btw
G.STATES.WHEEL = 9182657195

-- dont mind the G.GAME ones please i was to lazy to change them to use Wheel{}
Wheel = {
  STATE = {
    SPUN = nil,          -- is spinning
    IDLE = true          -- is idle
  },
  should_spin = true,    -- should it spin?
  Price = 15,            -- price
  Price_default = 15,    -- reset price
  ResetCheck = 0,        -- used for something below check there
  a = 0,                 -- same thing as ResetCheck
  KeepVval = 0,          -- save G.GAME.vval here cause it caused some issues
  Increase = 15,         -- to incrase with
  cost_up = 2,           -- when to up the cost (round)
  ante_left = 1,         -- when to reset the cost (ante)
  default_ante_left = 1, --resets
  default_cost_up = 2,   --resets
  ARROWS = {             -- the arrows yippe

  },
  accel = 0.6
}

SMODS.ObjectType {
    key = "Arrow",
    default = "j_hpot_the_arrow_1"
}

SMODS.Arrow = SMODS.Joker:extend({ -- the arrow thingy
  rarity = 1,
  unlocked = true,
  discovered = true,
  pos = { x = 0, y = 0 },
  config = {},
  set = "Arrow",
  class_prefix = "j",
  required_params = {
    "key",
  },
  in_pool = function(self, args)
    return args and args.source == "hpot_arrows"
  end,
  no_doe = true,
  inject = function(self)
    SMODS.Center.inject(self) -- ~i placed this in the wrong spot~  not anymore

    Wheel.ARROWS[#Wheel.ARROWS + 1] = self
  end
})

for i = 1, 10 do
  SMODS.Arrow({
    key = "the_arrow_" .. i,
    atlas = "tname_wheels",
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    no_collection = true,
    pos = {
      x = (i - 1),
      y = 0,
    },
  })
end

-- was from JoyousSpring (originally)
local cardarea_align_cards_ref = CardArea.align_cards -- <- i dont understand how i made this work either
-- made this actually work but im bad at math so it's kinda janky so TODO -N'
-- fuck do you mean "make this actually work" whats the issue
function CardArea:align_cards()
  cardarea_align_cards_ref(self)
  -- if G.GAME.should_rotate then
    if self == G.wheel_arrow then
      for k, card in ipairs(self.cards) do
        if G.GAME.keep_rotation then
          card.T.r = G.GAME.keep_rotation
        end
        if not G.GAME.wheel_card then
          G.GAME.wheel_card = card
        end
        if G.GAME.rotating then
          Wheel.t = Wheel.t or 6
          if not G.GAME.vval then G.GAME.vval = Wheel.KeepVval end
          Wheel.b = Wheel.b or 0
          card.T.r = card.T.r + Wheel.accel - math.min((Wheel.b / Wheel.t) * 0.1, 0.09)
          Wheel.accel = Wheel.accel - 0.001
          if Wheel.accel < 0.1 then Wheel.accel = 0.1 end
          if card.T.r >= ((Wheel.b + 1) * math.pi * 2) then
            Wheel.b = Wheel.b + 1
          end
          G.GAME.keep_rotation = card.T.r
          if Wheel.b >= Wheel.t and math.ceil((card.T.r - (Wheel.b) * math.pi * 2) * 10) >= G.GAME.vval and Wheel.accel <= 0.1 then
            G.GAME.keep_rotation = card.T.r - (Wheel.b) * math.pi * 2
            if not G.GAME.fake_rotate then
              local reward = math.floor(((((card.T.r / (math.pi * 2)) - 0.1875) % 1) * 8) + 1)
              grant_wheel_reward(G.wheel_rewards.cards[reward])
              G.GAME.rotating = nil
              G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.7,
                func = function()
                  reset_wheel()
                  return true
                end
              }))
            end
            G.GAME.keep_rotation = card.T.r
          end
        end
      end
    end
  -- end
end

-- remove after ( for testing ) ( i did not remove and its not indeed being used by the main code)
function set_wheel(no_arrow, vval_only, no_load)
  if not G.GAME.vval then
    G.GAME.vval = math.random(1, 63)
    G.GAME.winning_vval = (G.GAME.vval / 10)
    Wheel.KeepVval = G.GAME.vval
  end
  G.GAME.should_rotate = true
  if not vval_only then
    if not no_arrow and (G.wheel_arrow and #G.wheel_arrow.cards == 0) then
      local k = pseudorandom_element(Wheel.ARROWS, "hpot_arrows", { source = "hpot_arrows" }).key
      local card = SMODS.add_card({ key = k, area = G.wheel_arrow })
      card.no_ui = true
      card.states.hover.can = false
    end

    if not no_load then
        if PissDrawer.Shop.load_wheel_rewards then
          local load_rewards = PissDrawer.Shop.load_wheel_rewards
          if load_rewards then
            PissDrawer.Shop.load_wheel_rewards = nil
            if load_rewards.cards and #load_rewards.cards > 0 then
              G.wheel_rewards:load(load_rewards)
              return
            end
          end
        else
          generate_wheel_rewards()
        end
    end

    if not G.GAME.wheel_reset then
      G.GAME.wheel_reset = true
    end
  end
end

function reset_wheel() -- reset EVERYTHING :D
  G.GAME.should_rotate = nil
  G.GAME.wheel_card = nil
  G.GAME.rotating = nil
  G.GAME.vval = nil
  G.GAME.fake_rotate = nil
  Wheel.b = nil

  Wheel.STATE.IDLE = true
  Wheel.STATE.SPUN = nil
end

function spin_wheel(fake) -- spinning the wheel
  play_sound("card1")

  Wheel.STATE.IDLE = nil -- set states
  Wheel.STATE.SPUN = true
  Wheel.accel = 0.5

  if fake then
    G.GAME.fake_rotate = true
  else
    G.GAME.fake_rotate = nil
  end

  G.GAME.rotating = true -- start the rotation

  -- local event
  -- event = Event {
  --   blockable = false,
  --   blocking = false,
  --   trigger = "after",
  --   delay = 3,
  --   timer = "UPTIME",
  --   func = function()
  --     reset_wheel()
  --     return true
  --   end
  -- }
  -- G.E_MANAGER:add_event(event)
end

-- transformed the plinko one
function generate_wheel_rewards(_amount)
	-- Logic for extra reward with that rarity is kinda ass
	-- didn't have time to think of something better
  for i=1, _amount or 8 do
    local rewards = { "Joker", "Consumable" }
    if G.GAME.modifiers.no_shop_jokers then rewards = {"Consumable"} end
    local reward = pseudorandom_element(rewards, "hpot_arrows_rewards_type")
    if reward == "Joker" then
      local acard = SMODS.create_card({
        set = "Joker",
      })
      acard.states.click.can = false
      G.wheel_rewards:emplace(acard)
    else
      if reward == "Consumable" then
        local allcons = {}
        for k, _ in pairs(SMODS.ConsumableTypes) do
          if #get_current_pool(k) then
            table.insert(allcons, k)
          end
        end
        local sett = pseudorandom_element(allcons, "hpot_arrows_consumable_set")
        if sett == "bottlecap" then
          local raritiy_table = {
            ["Bad"] = 1,
            ["Uncommon"] = 2,
            ["Common"] = 3,
            ["Rare"] = 1,
          }
  
          local rarities = {}
          for rarity, amount in pairs(raritiy_table) do
            if type(amount) == "number" then
              rarities[#rarities + 1] = rarity
            end
          end
  
          local rarity = pseudorandom_element(rarities, "hpot_arrows_rewards")
          local card = SMODS.create_card({
            set = "bottlecap_" .. rarity,
            rarity = rarity,
          })
          if rarity == "Bad" then
            card:set_edition("e_negative")
          else
            card:set_edition()
          end
          card.states.click.can = false
          card.ability.extra.chosen = rarity
          G.wheel_rewards:emplace(card)
        else
          local acard = SMODS.create_card({
            set = sett,
          })
          acard.states.click.can = false
          G.wheel_rewards:emplace(acard)
        end
  
      end
    end
  end
end


-- granting the wheel (from plinko as well)
function grant_wheel_reward(card)

  local start = G.TIMERS.REAL
  local first_time = true

  draw_card(G.wheel_rewards, G.play, 1, 'up', true, card, nil, nil)

  G.E_MANAGER:add_event(Event { delay = 0.5, blocking = false, func = function()
    play_sound('hpot_tada')
    return true
  end })

  G.E_MANAGER:add_event(Event({
    delay = 5,
    func = function()
      remove_wheel_rewards()
      if first_time then
        first_time = false
        G.CONTROLLER:snap_to { node = G.wheel_rewards.cards[1] }
      end

      if G.TIMERS.REAL - start < 3 then
        return false
      end

      local card = G.play.cards[1]
      if card.ability.set == "bottlecap" then
        card:use_consumeable()
        SMODS.calculate_context({ using_consumeable = true, consumeable = card, area = G.wheel_rewards })
        card:start_dissolve({ G.C.BLACK, G.C.WHITE, G.C.RED, G.C.GREY, G.C.JOKER_GREY }, true, 4)
        play_sound('hpot_bottlecap')
      else -- fuck elseif
        if card.ability.set == "Joker" then
          if (#G.jokers.cards < G.jokers.config.card_limit) or (card.edition and card.edition == "e_negative") then
            HPTN.move_card(card, G.jokers)
            card.states.click.can = true
          else
            G.E_MANAGER:add_event(Event({
				trigger = "before",
				delay = 0.4,
				func = function()
					attention_text({
						text = localize("k_no_room_ex"),
						scale = 1.3,
						hold = 1.4,
						major = card,
						backdrop_colour = G.C.SECONDARY_SET.Tarot,
						align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and "tm" or "cm",
						offset = {
							x = 0,
							y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0,
						},
						silent = true,
					})
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.06 * G.SETTINGS.GAMESPEED,
						blockable = false,
						blocking = false,
						func = function()
							play_sound("tarot2", 0.76, 0.4)
							return true
						end,
					}))
					play_sound("tarot2", 1, 0.4)
					card:juice_up(0.3, 0.5)
					return true
				end,
			}))
            card:start_dissolve()
          end
        else
          if (#G.consumeables.cards < G.consumeables.config.card_limit) or (card.edition and card.edition == "e_negative") then
            HPTN.move_card(card, G.consumeables)
            card.states.click.can = true
          else
            G.E_MANAGER:add_event(Event({
				trigger = "before",
				delay = 0.4,
				func = function()
					attention_text({
						text = localize("k_no_room_ex"),
						scale = 1.3,
						hold = 1.4,
						major = card,
						backdrop_colour = G.C.SECONDARY_SET.Tarot,
						align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and "tm" or "cm",
						offset = {
							x = 0,
							y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0,
						},
						silent = true,
					})
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.06 * G.SETTINGS.GAMESPEED,
						blockable = false,
						blocking = false,
						func = function()
							play_sound("tarot2", 0.76, 0.4)
							return true
						end,
					}))
					play_sound("tarot2", 1, 0.4)
					card:juice_up(0.3, 0.5)
					return true
				end,
			}))
            card:start_dissolve()
          end
        end
      end

      G.E_MANAGER:add_event(Event({
        func = function()
            G.E_MANAGER:add_event(Event({
              func = function()
                  -- I dont care, just fix vouhers not resetting state, fuck you
                  G.STATE = G.STATES.WHEEL
                  if Wheel.cost_up == 0 then
                      Wheel.Price = Wheel.Price + Wheel.Increase
                      Wheel.cost_up = Wheel.default_cost_up
                      PissDrawer.Shop.reset_wheel_counter = nil
                  end
                  PissDrawer.Shop.load_wheel_rewards = nil
                  generate_wheel_rewards()
                  set_wheel(true, nil, true)
      
                  G.E_MANAGER:add_event(Event({
                      func = function()
                          save_run()
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
    end
  }))
end

-- removing existing rewards
function remove_wheel_rewards()
  for _, card in ipairs(G.wheel_rewards.cards) do
    card:start_dissolve({ G.C.BLACK, G.C.WHITE, G.C.RED, G.C.GREY, G.C.JOKER_GREY }, true)
  end
end

G.FUNCS.can_wheel_spin = function(e)
  if Wheel.STATE.IDLE and HPTN.check_if_enough_credits(Wheel.Price) then
    e.config.colour = G.GAME.seeded and G.C.ORANGE or G.C.PURPLE
    for _, child in ipairs(e.children[1].children) do
        child.children[1].config.object.colours = {G.C.UI.TEXT_LIGHT}
      end
    e.config.button = 'wheel_spin'
    e.config.hover = true
  else
    for _, child in ipairs(e.children[1].children) do
      child.children[1].config.object.colours = {G.C.UI.TEXT_INACTIVE}
    end
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
    e.config.hover = nil
  end
end

G.FUNCS.wheel_spin = function(e)
  HPTN.ease_credits(-Wheel.Price)

  Wheel.cost_up = Wheel.cost_up - 1
  if Wheel.cost_up == 0 then PissDrawer.Shop.reset_wheel_counter = true end
  spin_for_real_this_time(3)
end

function spin_for_real_this_time(t)
  if not t then
    t = 3
  end
  Wheel.b = t

  stop_use()
  spin_wheel()            -- spin it
  Wheel.should_spin = nil -- its spining so it shouldnt spin
  Wheel.a = 0             -- set to 0 to restart
end

function wheel_reset_cost()
  Wheel.Price = Wheel.Price_default -- reset te wheel cost
end

function wheel_ante_up(mod) -- check if ante went up
  Wheel.ante_left = math.max(0, Wheel.ante_left - mod)

  if Wheel.ante_left <= 0 then
    wheel_reset_cost()
  end

  Wheel.ante_left = Wheel.default_ante_left
end

local ea = ease_ante
function ease_ante(mod)
  ea(mod)
  wheel_ante_up(mod)
end

--idk
local ca_dref = CardArea.draw
function CardArea:draw(...)
  if self == G.hand and (G.STATE == G.STATES.WHEEL) then
    return
  end
  return ca_dref(self, ...)
end

local ca_can_highlight = CardArea.can_highlight
function CardArea:can_highlight(...)
  if self.wheel_rewards_area then
    return false
  end
  return ca_can_highlight(self, ...)
end

-- updte rewards
local next_round_button_for_delivery_area_destruction = G.FUNCS.toggle_shop
function G.FUNCS.toggle_shop(e)
    PissDrawer.Shop.load_wheel_rewards = nil
    return next_round_button_for_delivery_area_destruction(e)
end