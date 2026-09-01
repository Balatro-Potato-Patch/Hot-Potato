
SMODS.DrawStep {
    key = 'hp_misc_buttons',
    order = -31,
    func = function(self)
        --Draw any tags/buttons
        if self.children.hp_jtem_price_side then self.children.hp_jtem_price_side:draw() end
        if self.children.hp_jtem_cancel_order then self.children.hp_jtem_cancel_order:draw() end
    end,
}

SMODS.DrawStep {
	key = 'train_button',
	order = -30,
	func = function(self)
		--Draw any tags/buttons
		if self.children.hpot_train_button and self.highlighted then self.children.hpot_train_button:draw() end
        if self.children.hpot_reforge_button and self.highlighted then self.children.hpot_reforge_button:draw() end
        if self.children.hpot_move_to_train and self.highlighted then self.children.hpot_move_to_train:draw() end
        if self.children.hp_nursery_buttons and self.highlighted then self.children.hp_nursery_buttons:draw() end
	end,
}