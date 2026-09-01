function hotpot_horsechicot_market_section_init_cards()
  G.GAME.shop.market_joker_max = G.GAME.shop.market_joker_max or 2
  if G.GAME.market_table then
    G.market_jokers:load(G.GAME.market_table)
    G.GAME.market_table = nil
  else
    if not G.GAME.market_filled then
      G.GAME.market_filled = {}
      for i = 1, to_number(G.GAME.shop.market_joker_max) - #G.market_jokers.cards do
        local new_shop_card
        if G.GAME.modifiers.no_shop_jokers then
          new_shop_card = SMODS.create_card { set = "BlackMarketJokerless", area = G.market_jokers, bypass_discovery_ui = true, bypass_discovery_center = true }
        else
          new_shop_card = SMODS.create_card { set = "BlackMarket", area = G.market_jokers, bypass_discovery_ui = true, bypass_discovery_center = true }
        end
        G.market_jokers:emplace(new_shop_card)
        create_market_card_ui(new_shop_card)
        new_shop_card:juice_up()
        G.GAME.market_filled[#G.GAME.market_filled + 1] = new_shop_card.config.center.key
      end
      -- save_run()
    else
      for i, v in pairs(G.GAME.market_filled) do
        local c = SMODS.create_card {
          key = v,
          bypass_discovery_ui = true,
          bypass_discovery_center = true
        }
        create_market_card_ui(c)
        G.market_jokers:emplace(c)
      end
      for i, v in pairs(G.market_jokers.cards) do
        create_market_card_ui(v)
      end
    end
  end
  G.harvest_cost = G.harvest_cost or 0
end

function G.UIDEF.hotpot_horsechicot_market_section()
  G.GAME.shop.market_joker_max = G.GAME.shop.market_joker_max or 2

  G.harvest_cost = G.harvest_cost or 0
end

function remove_if_exists(thingy)
  if thingy then thingy:remove() end
end

G.FUNCS.hotpot_horsechicot_toggle_market = function() -- takn from deliveries
  if (G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0)) then return end
  stop_use()
  PissDrawer.Shop.change_shop_sign("hpot_hc_shop_sign", { percent = 1.3 })
  PissDrawer.Shop.change_shop_panel(PissDrawer.Shop.black_market, PissDrawer.Shop.create_black_market_areas,
    PissDrawer.Shop.black_market_post, PissDrawer.Shop.area_keys.black_market)
  ease_background_colour({ new_colour = G.C.BLACK, special_colour = darken(G.C.BLACK, 0.6), tertiary_colour = darken(
  G.C.BLACK, 0.4), contrast = 3 })
end

G.FUNCS.market_return = function()

end

local start_run_ref = Game.start_run
function Game:start_run(args)
  G.HP_HC_MARKET_VISIBLE = nil
  local saveTable = args.savetext or nil
  if not saveTable then
    G.GAME.cryptocurrency = 0.5
    G.GAME.current_round.market_reroll_cost = 0.5
    G.GAME.market_filled = nil
  end
  local ret = start_run_ref(self, args)
  if saveTable and saveTable.cardAreas then
    G.GAME.market_table = saveTable.cardAreas.market_jokers
  end
  G.GAME.current_round.market_reroll_cost = tonumber(G.GAME.current_round.market_reroll_cost) or 0
  G.GAME.cryptocurrency = G.GAME.cryptocurrency or 0.5
  return ret
end

function ease_cryptocurrency(plink, instant)
  if plink then
    local function _mod(mod)
      local dollar_UI = G.HUD:get_UIE_by_ID('dollar_text_UI')
      mod = mod or 0
      local text = '+£'
      if to_big(mod) < to_big(0) then
        text = '-£'
      end

      G.GAME.cryptocurrency = G.GAME.cryptocurrency + plink

      dollar_UI.config.object:update()
      G.HUD:recalculate()
      --Popup text next to the chips in UI showing number of chips gained/lost
      attention_text({
        text = text .. tostring(math.abs(mod)),
        scale = 0.8,
        hold = 0.7,
        cover = dollar_UI.parent,
        cover_colour = SMODS.Gradients.hpot_advert,
        align = 'cm',
        font = SMODS.Fonts['hpot_plincoin']
      })
      dollar_UI.config.object:pop_in(0.01)
      local hpot_dollar_ui = G.shop and G.shop:get_UIE_by_ID('hotpot_currency_cryptocurrency')
      if hpot_dollar_ui then
        attention_text({
          text = text .. tostring(math.abs(mod)),
          scale = hpot_dollar_ui.children[1].children[1].config.object.scale,
          hold = 0.7,
          cover = hpot_dollar_ui,
          cover_colour = col,
          align = 'cm',
          font = SMODS.Fonts.hpot_plincoin
        })
      end

      --Play a chip sound
      play_sound('coin1')
    end
    if instant then
      _mod(plink)
    else
      G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
          _mod(plink)
          return true
        end
      }))
    end
  end
end

G.FUNCS.can_reroll_market = function(e)
  if (to_big(G.GAME.cryptocurrency - G.GAME.current_round.market_reroll_cost) < to_big(0)) and G.GAME.current_round.market_reroll_cost ~= 0 then
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  else
    e.config.colour = SMODS.Gradients.hpot_advert
    e.config.button = 'reroll_market'
  end
end

G.FUNCS.reroll_market = function(e)
  stop_use()
  G.CONTROLLER.locks.shop_reroll = true
  if G.CONTROLLER:save_cardarea_focus('market_jokers') then G.CONTROLLER.interrupt.focus = true end
  if to_big(G.GAME.current_round.market_reroll_cost) > to_big(0) then
    ease_cryptocurrency(-G.GAME.current_round.market_reroll_cost)
  end
  G.E_MANAGER:add_event(Event({
    trigger = 'immediate',
    func = function()
      G.GAME.current_round.market_reroll_cost = G.GAME.current_round.market_reroll_cost + 0.5
      if G.GAME.modifiers.unstable then
        G.GAME.current_round.market_reroll_cost = G.GAME.current_round.market_reroll_cost *
            math.floor((pseudorandom("unstable_deck_market_reroll") * 0.4 - 0.19 + 1) * 100) / 100
      end
      for i = #G.market_jokers.cards, 1, -1 do
        local c = G.market_jokers:remove_card(G.market_jokers.cards[i])
        c:remove()
        c = nil
      end

      --save_run()

      play_sound('coin2')
      play_sound('other1')

      --
      for i = 1, to_number(G.GAME.shop.market_joker_max) - #G.market_jokers.cards do
        local new_market_card
        if G.GAME.modifiers.no_shop_jokers then
          new_market_card = SMODS.create_card { set = "BlackMarketJokerless", area = G.market_jokers, bypass_discovery_ui = true, bypass_discovery_center = true }
        else
          new_market_card = SMODS.create_card { set = "BlackMarket", area = G.market_jokers, bypass_discovery_ui = true, bypass_discovery_center = true }
        end
        G.market_jokers:emplace(new_market_card)
        create_market_card_ui(new_market_card)
        new_market_card:juice_up()
      end
      --
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.3,
    func = function()
      G.E_MANAGER:add_event(Event({
        func = function()
          G.CONTROLLER.interrupt.focus = false
          G.CONTROLLER.locks.shop_reroll = false
          G.CONTROLLER:recall_cardarea_focus('market_jokers')
          SMODS.calculate_context({ reroll_market = true, cost = reroll_cost })
          return true
        end
      }))
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    func = function()
      save_run(); return true
    end
  }))
end

function Card:get_market_cost()
  local value = 0.8
  if self.config.center.set == "Tarot" then
    value = 0.6
  elseif self.config.center.set == "Booster" and self.config.center.credits then
    value = 0.5 + self.config.center.credits / 50
  elseif self.config.center.set == "Joker" then
    value = 1 + self.config.center.cost / 10
  end
  if G.GAME.modifiers.unstable then
    value = math.floor(value * (pseudorandom("unstable_deck_market_cost") * 0.4 - 0.19 + 1) * 100) / 100
  end
  if G.GAME.dark_connections then
    value = value * 0.75
  end
  if self.config.center.hidden then value = value * 2 end
  return value
end

local set_costref = Card.set_cost
function Card:set_cost(...)
  set_costref(self, ...)
  if self.area and self.area == G.market_jokers then
    self.market_cost = self:get_market_cost()
  end
end

function create_market_card_ui(card, type, area)
  if not card.market_cost then
    card.market_cost = card:get_market_cost()
  end
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.43,
    blocking = false,
    blockable = false,
    func = (function()
      if card.opening then return true end
      local t1 = {
        n = G.UIT.ROOT,
        config = { minw = 0.6, align = 'tm', colour = darken(G.C.BLACK, 0.2), shadow = true, r = 0.05, padding = 0.05, minh = 1 },
        nodes = {
          {
            n = G.UIT.R,
            config = { align = "cm", colour = lighten(G.C.BLACK, 0.1), r = 0.1, minw = 1, minh = 0.55, emboss = 0.05, padding = 0.03 },
            nodes = {
              { n = G.UIT.O, config = { object = DynaText({ string = { { prefix = "£", ref_table = card, ref_value = 'market_cost' } }, font = SMODS.Fonts['hpot_plincoin'], colours = { SMODS.Gradients.hpot_advert }, shadow = true, silent = true, bump = true, pop_in = 0, scale = 0.5 }) } },
            }
          }
        }
      }
      local t2 = card.ability.set == 'Voucher' and {
        n = G.UIT.ROOT,
        config = { ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.GREEN, shadow = true, r = 0.08, minh = 0.94, func = 'can_redeem_from_market', one_press = true, button = 'redeem_from_shop', hover = true },
        nodes = {
          { n = G.UIT.T, config = { text = localize('b_redeem'), colour = G.C.WHITE, scale = 0.4 } }
        }
      } or card.ability.set == 'Booster' and {
        n = G.UIT.ROOT,
        config = { ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.GREEN, shadow = true, r = 0.08, minh = 0.94, func = 'can_open_from_market', one_press = true, button = 'open_booster', hover = true },
        nodes = {
          { n = G.UIT.T, config = { text = localize('b_open'), colour = G.C.WHITE, scale = 0.5 } }
        }
      } or {
        n = G.UIT.ROOT,
        config = { ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.GOLD, shadow = true, r = 0.08, minh = 0.94, func = 'can_buy_from_market', one_press = true, button = 'buy_from_shop', hover = true },
        nodes = {
          { n = G.UIT.T, config = { text = localize('b_buy'), colour = G.C.WHITE, scale = 0.5 } }
        }
      }
      local t3 = {
        n = G.UIT.ROOT,
        config = { id = 'buy_and_use', ref_table = card, minh = 1.1, padding = 0.1, align = 'cr', colour = G.C.RED, shadow = true, r = 0.08, minw = 1.1, func = 'can_buy_and_use_from_market', one_press = true, button = 'buy_from_shop', hover = true, focus_args = { type = 'none' } },
        nodes = {
          { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
          {
            n = G.UIT.C,
            config = { align = 'cm' },
            nodes = {
              {
                n = G.UIT.R,
                config = { align = 'cm', maxw = 1 },
                nodes = {
                  { n = G.UIT.T, config = { text = localize('b_buy'), colour = G.C.WHITE, scale = 0.5 } }
                }
              },
              {
                n = G.UIT.R,
                config = { align = 'cm', maxw = 1 },
                nodes = {
                  { n = G.UIT.T, config = { text = localize('b_and_use'), colour = G.C.WHITE, scale = 0.3 } }
                }
              },
            }
          }
        }
      }


      card.children.price = UIBox {
        definition = t1,
        config = {
          align = "tm",
          offset = { x = 0, y = 1.5 },
          major = card,
          bond = 'Weak',
          parent = card
        }
      }

      card.children.buy_button = UIBox {
        definition = t2,
        config = {
          align = "bm",
          offset = { x = 0, y = -0.3 },
          major = card,
          bond = 'Weak',
          parent = card
        }
      }

      if card.ability.consumeable then --and card:can_use_consumeable(true, true)
        card.children.buy_and_use_button = UIBox {
          definition = t3,
          config = {
            align = "cr",
            offset = { x = -0.3, y = 0 },
            major = card,
            bond = 'Weak',
            parent = card
          }
        }
      end

      card.children.price.alignment.offset.y = card.ability.set == 'Booster' and 0.5 or 0.38

      return true
    end)
  }))
end

G.FUNCS.can_buy_from_market = function(e)
  if ((to_big(e.config.ref_table.market_cost - G.GAME.cryptocurrency) > to_big(0.0001)) and (to_number(e.config.ref_table.market_cost) > 0)) and not (Entropy and Entropy.has_rune("rune_entr_naudiz")) then
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  else
    e.config.colour = SMODS.Gradients.hpot_advert
    e.config.button = 'buy_from_shop'
  end
  if e.config.ref_parent and e.config.ref_parent.children.buy_and_use then
    if e.config.ref_parent.children.buy_and_use.states.visible then
      e.UIBox.alignment.offset.y = -0.6
    else
      e.UIBox.alignment.offset.y = 0
    end
  end
end

G.FUNCS.can_buy_and_use_from_market = function(e)
  if ((((to_big(e.config.ref_table.market_cost - G.GAME.cryptocurrency) > to_big(0.0001)) and (to_number(e.config.ref_table.market_cost) > 0)) or (not e.config.ref_table:can_use_consumeable()))) and not (Entropy and Entropy.has_rune("rune_entr_naudiz")) then
    e.UIBox.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  else
    if e.config.ref_table.highlighted then
      e.UIBox.states.visible = true
    end
    e.config.colour = G.C.SECONDARY_SET.Voucher
    e.config.button = 'buy_from_shop'
  end
end

G.FUNCS.can_redeem_from_market = function(e)
  if ((to_big(e.config.ref_table.market_cost - G.GAME.cryptocurrency) > to_big(0.0001)) and (to_number(e.config.ref_table.market_cost) > 0)) and not (Entropy and Entropy.has_rune("rune_entr_naudiz")) then
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  else
    e.config.colour = G.C.GREEN
    e.config.button = 'use_card'
  end
end

G.FUNCS.can_open_from_market = function(e)
  if (to_big(e.config.ref_table.market_cost - G.GAME.cryptocurrency) > to_big(0.0001)) and (to_number(e.config.ref_table.market_cost) > 0) and not (Entropy and Entropy.has_rune("rune_entr_naudiz")) then
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  else
    e.config.colour = G.C.GREEN
    e.config.button = 'use_card'
  end
end


G.FUNCS.can_harvest_market = function(e)
  if G.jokers and #G.jokers.highlighted == 1 and not SMODS.is_eternal(G.jokers.highlighted[1]) and not G.GAME.current_round.harvested then
    e.config.colour = G.C.RED
    e.config.button = 'harvest_market'
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.harvest_market = function(e)
  if G.jokers.highlighted[1].ability.quantum_1 then
    local mother = G.jokers.highlighted[1].ability.quantum_2
    local father = G.jokers.highlighted[1].ability.quantum_1
    if G.jokers.highlighted[1].ability.is_primary_mother then
      mother = G.jokers.highlighted[1].ability.quantum_1
      father = G.jokers.highlighted[1].ability.quantum_2
    end
    if mother.ability.ordered and mother.key == "j_perkeo" and father.key == "j_hpot_hc_genghis_khan" then
      check_for_unlock({ type = "maniac" })
    end
  end
  G.jokers.highlighted[1]:start_dissolve()
  ease_cryptocurrency(G.harvest_cost)
  if HotPotatoConfig.family_friendly then
    play_sound("hpot_harvest_joy")
  else
    play_sound("hpot_harvest")
  end
  G.harvest_cost = 0
  G.GAME.current_round.harvested = true
  SMODS.calculate_context { organs_harvested = true, card_harvested = G.jokers.highlighted[1] }
end

local highlight_ref = Card.highlight
function Card:highlight(is)
  highlight_ref(self, is)
  if G.jokers then
    if is and G.jokers.highlighted[1] == self then
      G.harvest_cost = math.floor(self:get_market_cost() * 0.8 * 5) / 5
    elseif not is and self.area == G.jokers and #G.jokers.highlighted == 0 then
      G.harvest_cost = 0
    end
    if not is and #G.jokers.highlighted == 1 then
      G.harvest_cost = math.floor(G.jokers.highlighted[1]:get_market_cost() * 0.8 * 5) / 5
    end
    if G.GAME.underground_control then
      G.harvest_cost = (G.harvest_cost or 0) * 1.25
    end
  end
end

SMODS.Sound {
  key = "harvest",
  path = "sfx_the_flesh_consumes_all.mp3"
}

SMODS.Sound {
  key = "harvest_joy",
  path = "sfx_the_JOY_JOYS_all.mp3"
}

SMODS.Atlas {
  key = "hc_shop_sign",
  path = "Horsechicot/market_sign.png",
  px = 113, py = 57,
  frames = 4, atlas_table = 'ANIMATION_ATLAS'
}

function add_round_eval_crypto(config)
  local config = config or {}
  local width = G.round_eval.T.w - 0.51
  local num_dollars = to_big(config.cryptocurrency or 1)
  local scale = 0.9

  if not G.round_eval.divider_added then
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.25,
      func = function()
        local spacer = {
          n = G.UIT.R,
          config = { align = "cm", minw = width },
          nodes = {
            { n = G.UIT.O, config = { object = DynaText({ string = { '......................................' }, colours = { G.C.WHITE }, shadow = true, float = true, y_offset = -30, scale = 0.45, spacing = 13.5, font = G.LANGUAGES['en-us'].font, pop_in = 0 }) } }
          }
        }
        G.round_eval:add_child(spacer, G.round_eval:get_UIE_by_ID('bonus_round_eval'))
        return true
      end
    }))
  end
  delay(0.6)
  G.round_eval.divider_added = true

  delay(0.2)

  G.E_MANAGER:add_event(Event({
    trigger = 'before',
    delay = 0.5,
    func = function()
      --Add the far left text and context first:
      local left_text = {}
      if config.name == 'cryptocurrency' then
        table.insert(left_text,
          { n = G.UIT.T, config = { text = config.cryptocurrency, scale = 0.8 * scale, colour = SMODS.Gradients.hpot_advert, shadow = true, juice = true } })
        table.insert(left_text,
          { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = 'hotpot_cryptocurrency_cashout', vars = { 0 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
      elseif string.find(config.name, 'joker') then
        table.insert(left_text,
          { n = G.UIT.O, config = { object = DynaText({ string = localize { type = 'name_text', set = config.card.config.center.set, key = config.card.config.center.key }, colours = { G.C.FILTER }, shadow = true, pop_in = 0, scale = 0.6 * scale, silent = true }) } })
      end
      local full_row = {
        n = G.UIT.R,
        config = { align = "cm", minw = 5 },
        nodes = {
          { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.55, minh = 0.61, align = "cl" }, nodes = left_text },
          { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.45, align = "cr" },              nodes = { { n = G.UIT.C, config = { align = "cm", id = 'dollar_' .. config.name }, nodes = {} } } }
        }
      }

      G.round_eval:add_child(full_row, G.round_eval:get_UIE_by_ID('bonus_round_eval'))
      play_sound('cancel', config.pitch or 1)
      play_sound('highlight1', (1.5 * config.pitch) or 1, 0.2)
      if config.card and config.card.juice_up then config.card:juice_up(0.7, 0.46) end
      return true
    end
  }))
  local dollar_row = 0
  if num_dollars > to_big(60) then
    G.E_MANAGER:add_event(Event({
      trigger = 'before',
      delay = 0.38,
      func = function()
        G.round_eval:add_child(
          {
            n = G.UIT.R,
            config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. config.name },
            nodes = {
              { n = G.UIT.O, config = { object = DynaText({ string = { "£" .. num_dollars }, font = SMODS.Fonts['hpot_plincoin'], colours = { G.C.ORANNGE }, shadow = true, pop_in = 0, scale = 0.65, float = true }) } }
            }
          },
          G.round_eval:get_UIE_by_ID('dollar_' .. config.name))

        play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7)
        play_sound('coin6', 1.3, 0.8)
        return true
      end
    }))
  else
    for i = 1, to_number(math.max(num_dollars or 1, 1)) do
      G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.18 - ((num_dollars > to_big(20) and 0.13) or (num_dollars > to_big(9) and 0.1) or 0),
        func = function()
          if i % 30 == 1 then
            G.round_eval:add_child(
              { n = G.UIT.R, config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. config.name }, nodes = {} },
              G.round_eval:get_UIE_by_ID('dollar_' .. config.name))
            dollar_row = dollar_row + 1
          end

          local r = { n = G.UIT.T, config = { text = "£", font = SMODS.Fonts['hpot_plincoin'], colour = SMODS.Gradients.hpot_advert, scale = ((num_dollars > to_big(20) and 0.28) or (num_dollars > to_big(9) and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true } }
          play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7 - (num_dollars > to_big(20) and 0.2 or 0))

          if config.name == 'blind1' then
            G.GAME.current_round.dollars_to_be_earned = G.GAME.current_round.dollars_to_be_earned:sub(2)
          end

          G.round_eval:add_child(r, G.round_eval:get_UIE_by_ID('dollar_row_' .. (dollar_row) .. '_' .. config.name))
          G.VIBRATION = G.VIBRATION + 0.4
          return true
        end
      }))
    end
  end

  -- might cause issues. Dollars cashout adds up everything and sends "bottom" cashout. Might need similar implementation if more plincoin cashouts are added
  G.GAME.current_round.cryptocurrency = (G.GAME.current_round.cryptocurrency or 0) + config.cryptocurrency
end
