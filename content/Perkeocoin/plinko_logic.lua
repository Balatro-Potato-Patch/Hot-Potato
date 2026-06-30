
---------------
-- Rewards, Rolls, etc.
---------------


G.STATES.PLINKO = 2934856393


PlinkoLogic = {
    -- Settings
    s = {
      default_roll_cost = 1,
      rolls_to_up_cost = 3,
      plincoins_per_round = 1,
    },
    
    -- GENERAL INFO    
    STATES = {
        CLOSED = 0,
        IDLE = 1,
        IN_PROGRESS = 2,
        REWARD = 3,
    },
    STATE = 0,

    
    rewards = {
        total = 7,
        per_rarity = {
            ['Common'] = 3,
            ['Uncommon'] = 2,
            ['Rare'] = 1,
            ['Bad'] = 1
        }
    },

    roll_cost_reset = {
        -- No vouchers
        {ante_left = 2, rounds_left = 0},
        -- Tier 1
        {ante_left = 1, rounds_left = 0},
        -- Tier 2
        {ante_left = 0, rounds_left = 1},
    },
    
    -- Functions
    f = { },
}

--#region Game logic

function PlinkoLogic.f.reset_plinko()
  PlinkoLogic.STATE = PlinkoLogic.STATES.IDLE
  PlinkoGame.f.init_dummy_ball()
end

function PlinkoLogic.f.generate_rewards(no_load)
  if no_load then
    PissDrawer.Shop['load_plinko_rewards'] = nil
  end
  local load_rewards = PissDrawer.Shop['load_plinko_rewards']
  if load_rewards then
    if load_rewards.cards and #load_rewards.cards > 0 then
      G.plinko_rewards:load(load_rewards)
      return
    end
  end
  local tipping_my_point = SMODS.find_card("j_hpot_tipping_point", false)
  local extra_rare = 0
  for _, v in ipairs(tipping_my_point) do
    extra_rare = extra_rare + v.ability.extra.tipping
  end
  extra_rare = math.floor(extra_rare)
  if extra_rare > 0 then
      G.GAME.plinko_rewards.Rare = math.min(7, PlinkoLogic.rewards.per_rarity.Rare + extra_rare)
      check_for_unlock({ type = "max_rare_caps", conditions = G.GAME.plinko_rewards.Rare })

      G.GAME.plinko_rewards.Common = math.max(0, PlinkoLogic.rewards.per_rarity.Common - extra_rare)
      extra_rare = math.max(0, extra_rare - PlinkoLogic.rewards.per_rarity.Common)

      G.GAME.plinko_rewards.Uncommon = math.max(0, PlinkoLogic.rewards.per_rarity.Uncommon - extra_rare)
      extra_rare = math.max(0, extra_rare - PlinkoLogic.rewards.per_rarity.Uncommon)

      G.GAME.plinko_rewards.Bad = math.max(0, PlinkoLogic.rewards.per_rarity.Bad - extra_rare)

      G.GAME.plinko_rewards.moving_pegs = true
  else
      G.GAME.plinko_rewards.Rare = PlinkoLogic.rewards.per_rarity.Rare
      G.GAME.plinko_rewards.Common = PlinkoLogic.rewards.per_rarity.Common
      G.GAME.plinko_rewards.Uncommon = PlinkoLogic.rewards.per_rarity.Uncommon
      G.GAME.plinko_rewards.Bad = PlinkoLogic.rewards.per_rarity.Bad
      G.GAME.plinko_rewards.moving_pegs = false
  end

  for rarity, amount in pairs(G.GAME.plinko_rewards) do
    if type(amount) == "number" then
      for i = 1, amount do
        local card = SMODS.create_card {
          set = "bottlecap_"..rarity,
          rarity = rarity
        }
        if rarity == 'Bad' then
          card:set_edition("e_negative", nil, true)
        else
          card:set_edition(nil, nil, true)
        end
        card.ability.extra.chosen = rarity
        if pseudorandom("legendary_cap") < 0.003 and card.config.center.pools.bottlecap_Legendary then
          card.ability.extra.chosen = "Legendary"
        end
        G.plinko_rewards:emplace(card)
      end
    end
  end
  G.plinko_rewards:shuffle('plink')
end

-- GIVE REWARD

function PlinkoLogic.f.won_reward(reward_num)
  assert(type(reward_num) == "number", "won_reward must be called with a number")
  
  G.E_MANAGER:add_event(Event({
      trigger = 'after', delay = 0.5,
      func = function()
                          
        PlinkoGame.f.remove_balls()
          return true
      end
  }))


  local reward = assert(G.plinko_rewards.cards[reward_num], "reward #"..tostring(reward_num).." does not exist! was something wrong with plinko?")

  draw_card(G.plinko_rewards, G.play, 1, 'up', true, reward, nil, nil)

  local start = G.TIMERS.REAL
  local first_time = true

  G.E_MANAGER:add_event(Event{delay = 0.5, blocking = false, func = function ()
    if reward.ability.extra.chosen == 'Bad' then
      play_sound('hpot_not_tada')
    else
      play_sound('hpot_tada')
    end
    return true
  end})

  G.E_MANAGER:add_event(Event({
    delay = 5,
    func = function()
      if first_time then
        first_time = false
        PlinkoUI.f.clear_plinko_rewards()

        G.CONTROLLER:snap_to {node = G.plinko_rewards.cards[1]}
      end

      if G.TIMERS.REAL - start < 3 then
        return false
      end

      local card = G.play.cards[1]
      if card then
        card:use_consumeable()
        SMODS.calculate_context({using_consumeable = true, consumeable = card, area = G.plinko_rewards})
        card:start_dissolve({G.C.BLACK, G.C.WHITE, G.C.RED, G.C.GREY, G.C.JOKER_GREY}, true, 4)
        play_sound('hpot_bottlecap')
      end

      G.E_MANAGER:add_event(Event({
        func = function()
          G.E_MANAGER:add_event(Event({
            func = function()
              PlinkoUI.f.update_plinko_rewards(true)
              PlinkoLogic.f.update_roll_cost()

              G.E_MANAGER:add_event(Event({
                func = function()
                  PlinkoLogic.f.reset_plinko()
                  if card and not card.config.center.ignore_save then
                      save_run();
                  end
                  return true
                end,
              }))
              return true
            end
          }))
          return true
        end,
      }))

      return true
    end
  }))
end

--#endregion

--#region Roll cost logic

-- NOTE FOR VOUCHER IMPL: 
-- run PlinkoLogic.f.reset_cost(true) to update when the roll cost is gonna reset

function PlinkoLogic.f.reset_cost(keep_roll_cost)
  local current_level = 1
  if false and G.GAME.used_vouchers['hpot_plincoin2'] then
    current_level = 3
  elseif G.GAME.used_vouchers['hpot_currency_exchange2'] then
    current_level = 2
  end

  if not keep_roll_cost then
    PlinkoLogic.f.change_roll_cost(PlinkoLogic.s.default_roll_cost)
    G.GAME.current_round.plinko_rolls = 0
    G.GAME.current_round.plinko_cost_up_in = G.GAME.rolls_to_up_cost
  end
  G.GAME.current_round.plinko_cost_reset = copy_table(PlinkoLogic.roll_cost_reset[current_level])
end

function PlinkoLogic.f.ante_up(mod)
  G.GAME.current_round.plinko_cost_reset.ante_left = math.max(0, G.GAME.current_round.plinko_cost_reset.ante_left - mod)

  if G.GAME.current_round.plinko_cost_reset.ante_left <= 0 and G.GAME.current_round.plinko_cost_reset.rounds_left <= 0 then
    PlinkoLogic.f.reset_cost()
  end
end

local ea = ease_ante
function ease_ante(mod)
  ea(mod)
  if to_big(mod) >to_big(0) then
    PlinkoLogic.f.ante_up(mod)
  end
end


function PlinkoLogic.f.round_up(mod)
  G.GAME.current_round.plinko_cost_reset.rounds_left = math.max(0, G.GAME.current_round.plinko_cost_reset.rounds_left - mod)
  
  if G.GAME.current_round.plinko_cost_reset.ante_left <= 0 and G.GAME.current_round.plinko_cost_reset.rounds_left <= 0 then
    PlinkoLogic.f.reset_cost()
  end
end

local er = ease_round
function ease_round(mod)
  er(mod)
  PlinkoLogic.f.round_up(mod)
end

function PlinkoLogic.f.update_roll_cost()
  G.GAME.current_round.plinko_cost_up_in = G.GAME.rolls_to_up_cost - G.GAME.current_round.plinko_rolls % G.GAME.rolls_to_up_cost

  -- Cost grows every 3 rounds +1
  if G.GAME.current_round.plinko_rolls % G.GAME.rolls_to_up_cost == 0 then
    PissDrawer.Shop.reset_plinko_counter = nil
    PlinkoLogic.f.change_roll_cost(G.GAME.current_round.plinko_roll_cost + 1)
  end
end

function PlinkoLogic.f.change_roll_cost(new_val)
  if G.GAME.modifiers.hpot_plinko_4ever then new_val = 0 end
  G.GAME.current_round.plinko_roll_cost = new_val
  G.GAME.current_round.plinko_roll_cost_dollars = G.GAME.plinko_dollars_cost and (G.GAME.plinko_dollars_cost * G.GAME.current_round.plinko_roll_cost)
end

function PlinkoLogic.f.can_roll()
  return to_big(G.GAME.plincoins) >= to_big(G.GAME.current_round.plinko_roll_cost)
end

function PlinkoLogic.f.can_roll_dollars()
  local cost = G.GAME.current_round.plinko_roll_cost * G.GAME.plinko_dollars_cost

  return not ((to_big((G.GAME.dollars-G.GAME.bankrupt_at) - cost) < to_big(0)) and cost ~= 0)
end

function PlinkoLogic.f.handle_roll(use_dollars)
  if use_dollars then
    ease_dollars(-G.GAME.current_round.plinko_roll_cost * G.GAME.plinko_dollars_cost)
  else
    ease_plincoins(-G.GAME.current_round.plinko_roll_cost)
  end

  G.GAME.current_round.plinko_rolls = G.GAME.current_round.plinko_rolls + 1
  PissDrawer.Shop.reset_plinko_counter = G.GAME.current_round.plinko_rolls % 3 == 0
end

--#endregion