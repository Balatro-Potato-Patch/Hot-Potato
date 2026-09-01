--GRRR *GROWLS*, BACK OFF buddy hes MINE
SMODS.Joker:take_ownership("chicot", {
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'hc_lily_comment', set = 'Other' }
    end
}, true)