local function currencies_dictionary()
	local result = {
		dollars = {
			symbol = "$", -- waiting for correct one
			colour = G.C.MONEY,
			ref_value = "dollars",
		},
		plincoins = {
			symbol = "$",
			colour = SMODS.Gradients["hpot_plincoin"],
			ref_value = "plincoins",
			font = SMODS.Fonts.hpot_plincoin,
		},
		cryptocurrency = {
			symbol = "£",
			colour = SMODS.Gradients["hpot_advert"],
			ref_value = "cryptocurrency",
			font = SMODS.Fonts.hpot_plincoin,
		},
		spark_points = {
			symbol = localize("hotpot_reforge_sparks"),
			colour = G.C.BLUE,
			ref_value = "spark_points",
			font = SMODS.Fonts.hpot_plincoin,
		},
		credits = G.GAME.seeded and {
			symbol = localize("hotpot_reforge_budget"),
			colour = G.C.ORANGE,
			ref_value = "budget",
			font = SMODS.Fonts.hpot_plincoin,
		} or {
			symbol = localize("hotpot_reforge_credits"),
			colour = G.C.PURPLE,
			ref_value = "TNameCredits",
			ref_table = G.PROFILES[G.SETTINGS.profile],
			font = SMODS.Fonts.hpot_plincoin,
		},
	}
	result.budget = result.credits
	return result
end
local function arrays_equal(a, b)
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

function hpot_currencies_to_display()
	if G.STATE == G.STATES.PLINKO then
		if G.GAME.used_vouchers["v_hpot_currency_exchange"] or G.GAME.used_vouchers["v_hpot_currency_exchange2"] then
			return { "plincoins", "dollars" }
		else
			return { "plincoins" }
		end
	end
	if G.STATE == G.STATES.WHEEL then
		return { "credits" }
	end
	if G.STATE == G.STATES.NURSERY then
		return { "dollars" }
	end
    if G.STATE == G.STATES.SMODS_BOOSTER_OPENED and SMODS.OPENED_BOOSTER then
        local kind = SMODS.OPENED_BOOSTER.config.center.kind
        if kind == "hpot_czech" then
            return { "plincoins" }
        elseif kind == "hpot_aura" then
            return { "credits" }
        end
    end
	if G.STATE == G.STATES.SHOP then
		local current_tab = PissDrawer.Shop.active_tab
		if type(current_tab) == "table" then
		elseif current_tab == "hotpot_shop_tab_hotpot_tname_toggle_reforge" then
			return { "credits" }
		elseif current_tab == "hotpot_shop_tab_hotpot_pissdrawer_toggle_training" then
			return { "spark_points" }
		elseif current_tab == "hotpot_shop_tab_hotpot_horsechicot_toggle_market" then
			return { "cryptocurrency" }
		elseif current_tab == "hotpot_shop_tab_return_to_shop" then
			return { "dollars" }
		end
	end
end

function hpot_display_currencies(list)
	local container = G.HUD:get_UIE_by_ID("dollar_text_UI")
	if not container then
		return
	end

	local dictionary = currencies_dictionary()
	local result_string = {}
	for _, currency_key in ipairs(list) do
		local currency = dictionary[currency_key]
		assert(currency, "Invalid currency to display")
		table.insert(result_string, {
			ref_table = currency.ref_table or G.GAME,
			ref_value = currency.ref_value,
			prefix = currency.symbol,
			colour = currency.colour,
			font = currency.font,
		})
	end

	local new_dyna = DynaText({
		string = result_string,
		maxw = 1.35,
		colours = { G.C.MONEY },
		shadow = true,
		spacing = 2,
		bump = true,
		scale = 2.2 * 0.4,
		silent = true,
	})
	container.config.object:remove()
	container.config.object = new_dyna
	container.parent.UIBox:recalculate()
	new_dyna:pop_in(0.1)
end

local old_displayed = { "dollars" }
local function update_displayed_currencies()
	if not G.HUD or not G.GAME then
		return
	end
	local new_displayed = hpot_currencies_to_display() or { "dollars" }
	table.sort(new_displayed)
	if not arrays_equal(old_displayed, new_displayed) then
		old_displayed = new_displayed
		hpot_display_currencies(new_displayed)
	end
end

local old_update = Game.update
function Game:update(...)
	old_update(self, ...)
	update_displayed_currencies()
end
