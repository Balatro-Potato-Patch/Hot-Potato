SMODS.DrawStep {
  key = 'extra',
  order = 21,
  func = function(self, layer)
    if not self.hpot_extra and self.config.center.pos_extra then
      local atlas = G.ASSET_ATLAS[self.config.center.atlas_extra or self.config.center.atlas]
      self.hpot_extra = Sprite(0, 0, atlas.px, atlas.py,
        atlas, self.config.center.pos_extra)
    end
    if self.hpot_extra then
      if self.config.center.discovered or (self.params and self.params.bypass_discovery_center) then
        if self.config.center.pos_extra then
          self.hpot_extra:set_sprite_pos(self.config.center.pos_extra)
          self.hpot_extra.role.draw_major = self
          if (self.edition and self.edition.negative and (not self.delay_edition or self.delay_edition.negative)) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
            self.hpot_extra:draw_shader('negative', nil, self.ARGS.send_to_shader, nil, self.children.center)
          elseif not self:should_draw_base_shader() then
          elseif not self.greyed then
            self.hpot_extra:draw_shader('dissolve', nil, nil, nil, self.children.center)
          end
        end

        if self.ability.name == 'Invisible Joker' and (self.config.center.discovered or self.bypass_discovery_center) then
          if self:should_draw_base_shader() then
            self.hpot_extra:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
          end
        end

        local center = self.config.center
        if center.draw_extra and type(center.draw_extra) == 'function' then
          self.hpot_extra:draw_extra(self, layer)
        end

        local edition = self.delay_edition or self.edition
        if edition then
          for k, v in pairs(G.P_CENTER_POOLS.Edition) do
            if edition[v.key:sub(3)] and v.shader then
              if type(v.draw) == 'function' then
                v:draw(self, layer)
              else
                self.hpot_extra:draw_shader(v.shader, nil, self.ARGS.send_to_shader, nil, self.children.center)
              end
            end
          end
        end
        if (edition and edition.negative) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
          self.hpot_extra:draw_shader('negative_shine', nil, self.ARGS.send_to_shader, nil, self.children.center)
        end
      end
    end
  end,
  conditions = { vortex = false, facing = 'front' },
}



local update_ref = Game.update
function Game:update(dt)
  if not HotPotatoConfig["animations_disabled"] then
    for k, v in pairs(G.P_CENTERS) do
      if not v.default_pos then v.default_pos = v.pos end
      if not v.default_pos_extra then v.default_pos_extra = v.pos_extra end
      handle_hpot_anim(v, dt)
      handle_hpot_anim_extra(v, dt)
    end
  else
    for k, v in pairs(G.P_CENTERS) do
      if not v.default_pos then v.default_pos = v.pos end
      if not v.default_pos_extra then v.default_pos_extra = v.pos_extra end
      v.pos = v.default_pos
      v.pos_extra = v.default_pos_extra
    end
  end
  if PlinkoLogic and PlinkoLogic.STATE and PlinkoLogic.STATE ~= 0 then
    G.STATE = G.STATES.PLINKO
  end
  return update_ref(self, dt)
end

function handle_hpot_anim(v, dt)
  if v.hpot_anim_states or v.hpot_anim then
    v.hpot_anim = format_hpot_anim(v.hpot_anim_states and v.hpot_anim_current_state and
      v.hpot_anim_states[v.hpot_anim_current_state] and v.hpot_anim_states[v.hpot_anim_current_state].anim or
      v.hpot_anim)
    if v.hpot_anim == nil then
      v.pos = v.default_pos
    else
      local loop = v.hpot_anim_states and v.hpot_anim_current_state and
          v.hpot_anim_states[v.hpot_anim_current_state] and
          v.hpot_anim_states[v.hpot_anim_current_state].loop
      if loop == nil then loop = true end
      if not v.hpot_anim_t then v.hpot_anim_t = 0 end
      if not v.hpot_anim.length then
        v.hpot_anim.length = 0
        for _, frame in ipairs(v.hpot_anim) do
          v.hpot_anim.length = v.hpot_anim.length + (frame.t or 0)
        end
      end
      v.hpot_anim_t = v.hpot_anim_t + dt
      if not loop and v.hpot_anim_t >= v.hpot_anim.length then
        v.hpot_anim_t = v.hpot_anim.length
      elseif loop then
        v.hpot_anim_t = v.hpot_anim_t % v.hpot_anim.length
      end
      local ix = 0
      local t_tally = 0
      for _, frame in ipairs(v.hpot_anim) do
        ix = ix + 1
        t_tally = t_tally + frame.t
        if t_tally > v.hpot_anim_t then break end
      end
      v.pos.x = v.hpot_anim[ix].x
      v.pos.y = v.hpot_anim[ix].y
    end
  end
end

function handle_hpot_anim_extra(v, dt)
  if v.hpot_anim_extra_states or v.hpot_anim_extra then
    v.hpot_anim_extra = format_hpot_anim(v.hpot_anim_extra_states and v.hpot_anim_extra_current_state and
      v.hpot_anim_extra_states[v.hpot_anim_extra_current_state] and
      v.hpot_anim_extra_states[v.hpot_anim_extra_current_state].anim or
      v.hpot_anim_extra)
    if v.hpot_anim_extra == nil then
      v.pos_extra = v.default_pos_extra
    else
      local loop = v.hpot_anim_extra_states and v.hpot_anim_extra_current_state and
          v.hpot_anim_extra_states[v.hpot_anim_extra_current_state] and
          v.hpot_anim_extra_states[v.hpot_anim_extra_current_state].loop
      if loop == nil then loop = true end
      if not v.hpot_anim_extra_t then v.hpot_anim_extra_t = 0 end
      if not v.hpot_anim_extra.length then
        v.hpot_anim_extra.length = 0
        for _, frame in ipairs(v.hpot_anim_extra) do
          v.hpot_anim_extra.length = v.hpot_anim_extra.length + (frame.t or 0)
        end
      end
      v.hpot_anim_extra_t = v.hpot_anim_extra_t + dt
      if not loop and v.hpot_anim_extra_t >= v.hpot_anim_extra.length then
        v.hpot_anim_extra_t = v.hpot_anim_extra.length
      elseif loop then
        v.hpot_anim_extra_t = v.hpot_anim_extra_t % v.hpot_anim_extra.length
      end
      local ix = 0
      local t_tally = 0
      for _, frame in ipairs(v.hpot_anim_extra) do
        ix = ix + 1
        t_tally = t_tally + frame.t
        if t_tally > v.hpot_anim_extra_t then break end
      end
      if not v.pos_extra then v.pos_extra = {} end
      v.pos_extra.x = v.hpot_anim_extra[ix].x
      v.pos_extra.y = v.hpot_anim_extra[ix].y
    end
  end
end

function format_hpot_anim(anim)
  if not anim then return nil end
  local new_anim = {}
  for _, frame in ipairs(anim) do
    if frame and (frame.x or (frame.xrange and frame.xrange.first and frame.xrange.last)) and (frame.y or (frame.yrange and frame.yrange.first and frame.yrange.last)) then
      local firsty = frame.y or frame.yrange.first
      local lasty = frame.y or frame.yrange.last
      for y = firsty, lasty, firsty <= lasty and 1 or -1 do
        local firstx = frame.x or frame.xrange.first
        local lastx = frame.x or frame.xrange.last
        for x = firstx, lastx, firstx <= lastx and 1 or -1 do
          new_anim[#new_anim + 1] = { x = x, y = y, t = frame.t or 0 }
        end
      end
    end
  end
  new_anim.t = anim.t
  return new_anim
end

SMODS.Atlas {
  key = "TeamNameAnims1",
  path = "Team Name/TeamNameAnims1.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "tname_shop_sign",
  path = "Team Name/reforge_sign.png",
  px = 113, py = 57,
  frames = 4, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "hpot_tname_arrow_sign",
  path = "Team Name/wheel_sign.png",
  px = 113, py = 57,
  frames = 4, atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
  key = "tname_shop_reforge",
  path = "Team Name/shop_button.png",
  px = 34, py = 34,
}

SMODS.Atlas({
  key = "tname_modifs_anim",
  path = "Team Name/tname_modifs.png",
  px = 71,
  py = 95,
})

SMODS.Atlas({
  key = "tname_modifs",
  path = "Team Name/tname_modifs_single.png",
  px = 71,
  py = 95,
})
