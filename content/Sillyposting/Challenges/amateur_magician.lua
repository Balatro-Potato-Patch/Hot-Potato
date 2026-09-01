SMODS.Challenge {
    key = 'amateur_magician',
    rules = {
        custom = {
            { id = 'hpot_reduce_select_size' },
        }
    },
    apply = function(self, back)
        change_max_highlight(-1)
    end,
    restrictions = {banned_cards = {
        {id = "c_death"},
        {id = "c_lovers"},
        {id = "c_chariot"},
        {id = "c_justice"},
        {id = "c_devil"},
        {id = "c_tower"},
        {id = "c_talisman"},
        {id = "c_aura"},
        {id = "c_deja_vu"},
        {id = "c_trance"},
        {id = "c_medium"},
        {id = "c_cryptid"},
        {id = "c_hpot_arcade_machine"},
        {id = "j_hpot_wizard_tower"},
        {id = "j_hpot_golden_apple"},
    }, banned_other = {}}
}