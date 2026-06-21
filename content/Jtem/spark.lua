-- This is by far the worst thing added probably

function ease_spark_points(mod, instant)
	local function _mod(mod)
		local dollar_UI = G.HUD:get_UIE_by_ID('dollar_text_UI')
		mod = mod or 0
		local text = '+'
		local col = G.C.BLUE
		if to_big(mod) < to_big(0) then
			text = '-'
			col = G.C.RED
		end
		--Ease from current chips to the new number of chips
		G.GAME.spark_points = G.GAME.spark_points + mod
		G.GAME.spark_points_display = number_format(G.GAME.spark_points, 1e10)
		check_for_unlock({ type = 'spark_points' })
		G.HUD:recalculate()
		--Popup text next to the chips in UI showing number of chips gained/lost
		attention_text({
			text = text .. tostring(math.abs(mod)),
			scale = 0.8,
			hold = 0.7,
			cover = dollar_UI.parent,
			cover_colour = col,
			align = 'cm',
		})
        dollar_UI.config.object:pop_in(0.01)
		local hpot_dollar_ui = G.shop and G.shop:get_UIE_by_ID('hotpot_currency_spark_points')
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
		_mod(mod)
	else
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				_mod(mod)
				return true
			end
		}))
	end
end

-- local c_u_h_ref = create_UIBox_HUD
-- function create_UIBox_HUD()
-- 	local nodes = c_u_h_ref()

-- 	--again, why are u hooking and not patching like everyone else??? - fey
-- 	-- whole lot of padding here
-- 	local contents = nodes.nodes[1].nodes[1].nodes

-- 	local scale = 0.4
-- 	local temp_col = G.C.DYN_UI.BOSS_MAIN
-- 	local temp_col2 = G.C.DYN_UI.BOSS_DARK

-- 	-- add text for spark points
-- 	table.insert(contents,
-- 		{
-- 			n = G.UIT.R,
-- 			config = { align = "cm", id = 'row_spark' },
-- 			nodes = {
--                 {
--                     n = G.UIT.C,
--                     config = { minw = 0.13 }
--                 },
-- 				{
-- 					n = G.UIT.C,
-- 					config = { align = "cm", padding = 0.05, minw = 3, minh = 0.6, colour = temp_col, emboss = 0.05, r = 0.1 },
-- 					nodes = {
-- 						{
-- 							n = G.UIT.R,
-- 							config = { align = "cm" },
-- 							nodes = {
-- 								{
-- 									n = G.UIT.C,
-- 									config = { align = "cm", r = 0.1, minw = 2.85, minh = 0.5, colour = temp_col2, padding = -0.8 * scale, id = 'spark_text_UI', button = "hp_open_full_jx_top_up", func = 'hp_can_open_full_jx_top_up', hover = true },
-- 									nodes = {
-- 										{
-- 											n = G.UIT.C,
-- 											config = { align = "tl", minw = 2.85 },
-- 											nodes = {
-- 												{
-- 													n = G.UIT.R,
-- 													config = { minw = 0, minh = 0 }
-- 												},
-- 												{
-- 													n = G.UIT.T,
-- 													-- Having to add manual spaces fucking SUCKS
-- 													config = { text = '    ' .. localize('hotpot_spark_points'), colour = G.C.UI.TEXT_LIGHT, scale = 0.8 * scale, id = 'spark_text_label', shadow = true }
-- 												}
-- 											}
-- 										},
-- 										{
-- 											n = G.UIT.C,
-- 											config = { align = "cr", minw = 2.85 },
-- 											nodes = {
-- 												{
-- 													n = G.UIT.R,
-- 													config = { minw = 0.5, minh = 0 }
-- 												},
-- 												{
-- 													n = G.UIT.O,
-- 													config = {
-- 														object = DynaText {
-- 															-- i want the number to display in full until 1e10 or something so here
-- 															string = {
-- 																{ ref_table = G.GAME, ref_value = 'spark_points_display' }
-- 															},
-- 															colours = { G.C.BLUE },
-- 															shadow = true,
-- 															spacing = 2,
-- 															bump = true,
-- 															scale = 0.8 * scale
-- 														}
-- 													}
-- 												}
-- 											}
-- 										},
-- 									}
-- 								},
-- 							}
-- 						},
-- 					}
-- 				},
-- 			}
-- 		})

-- 	return nodes
-- end
