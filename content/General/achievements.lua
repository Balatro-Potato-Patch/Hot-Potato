SMODS.Achievement {
    key = 'sign_here',
    hidden_name = false,
    hidden_text = true,
    bypass_all_unlocked = true,
    unlock_condition = function(self, args)
        if args.type == 'fine_print' and args.conditions == 3 then
            return true
        end
    end
}

SMODS.Achievement{
    key = 'selfcest',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return args.type == 'selfcest'
    end
}

SMODS.Achievement{
    key = 'maniac',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return args.type == 'maniac'
    end
}

SMODS.Achievement {
    key = 'rigged',
    bypass_all_unlocked = true,
    hidden_name = false,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'max_rare_caps' and args.conditions == 7)
    end
}

SMODS.Achievement {
    key = 'cungadero',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'cungadero' and args.conditions >= 97)
    end
}

SMODS.Achievement {
    key = 'aura_farming',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'aura_farming' and args.conditions.joke <= 0 and args.conditions.cons <= 0 and args.conditions.hand <= 1)
    end

}

SMODS.Achievement {
    key = 'whoppers',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self,args)
        return(args.type == 'whoppers')
    end,
}

SMODS.Achievement {
    key = 'destroy_the_stones',
    hidden_name = false,
    hidden_text = true,
    bypass_all_unlocked = true,
    unlock_condition = function(self, args)
       if args.type == 'lotus_banish' and args.key == 'j_hpot_lotus' then
           return true
       end
   end
}

SMODS.Achievement {
    key = 'max_mood',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'max_mood' and args.conditions == 'trance')
    end
}

SMODS.Achievement {
    key = 'five_lights',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'five_lights')
    end
}

SMODS.Achievement {
    key = 'fuck_soul',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'fuck_soul' and args.conditions == 10)
    end
}

SMODS.Achievement {
    key = 'nxkoo',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'nxkoo')
    end
}

SMODS.Achievement {
    key = 'true_ending',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'get_fucked_lmao')
    end
}

SMODS.Achievement {
    key = 'this_writing_is_fire',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'this_writing_is_fire' and args.conditions == 8)
    end
}

SMODS.Achievement {
    key = 'frums',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'frums')
    end
}

SMODS.Achievement {
    key = 'jonceler',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'jonceler')
    end
}

SMODS.Achievement {
    key = 'jokexodia',
    bypass_all_unlocked = true,
    hidden_name = false,
    hidden_text = true,
    unlock_condition = function(self, args)
        return (args.type == 'jokexodia')
    end
}

SMODS.Achievement {
    key = 'clippy',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    --reset_on_startup = true,
    unlock_condition = function(self, args)
        return (args.type == 'clippy')
    end
}

-- chat im starting to think true should be the default value for bypass_all_unlocked in this file
SMODS.Achievement {
    key = 'ffingers',
    bypass_all_unlocked = true,
    hidden_name = false,
    hidden_text = true,
    -- reset_on_startup = true,
    unlock_condition = function(self, args)
        return (args.type == 'ffingers')
    end
}

SMODS.Achievement {
    key = 'candyland_tobu',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    -- reset_on_startup = true,
    unlock_condition = function(self, args)
        return (args.type == 'candyland_tobu')
    end
}

SMODS.Achievement {
    key = 'deck_joker',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'deck_joker' and args.conditions >= 100)
    end
}

SMODS.Achievement {
    key = 'swoon',
    bypass_all_unlocked = true,
    hidden_name = false,
    hidden_text = true,
    unlock_condition = function(self, args)
        return (args.type == 'swoon')
    end
}

SMODS.Achievement {
    key = 'paytowin',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return (args.type == 'paytowin' and args.conditions == 8)
    end
}

SMODS.Achievement{
    key = 'big_eater',
    bypass_all_unlocked = true,
    hidden_name = true,
    hidden_text = false,
    unlock_condition = function(self, args)
        return args.type == 'greedybastardscaled' and args.conditions >= 10
    end
}