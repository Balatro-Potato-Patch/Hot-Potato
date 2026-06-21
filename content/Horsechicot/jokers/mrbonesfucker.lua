SMODS.Joker:take_ownership("mr_bones", {
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'hc_nxko_comment3', set = 'Other' }
    end
}, true)