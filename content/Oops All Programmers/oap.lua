OAP = {}                                     -- GET GLOBAL NOW!!!!!!!
PotatoPatchUtils.Team {
    name = 'OAP',
    colour = HEX('80f1c3'),
    loc = true
}

local rgg_ref = SMODS.current_mod.reset_game_globals
function SMODS.current_mod.reset_game_globals(run_start) -- i am the worst developer of all time - trif
    rgg_ref(run_start)                                   -- so sorry
    reset_commit_farmer()
end

-- atlas stuff, keep it at the end probably
SMODS.Atlas { key = "oap_jokers", path = "Oops! All Programmers/oap_jokers.png", px = 71, py = 95 }
SMODS.Atlas { key = "oap_tarots", path = "Oops! All Programmers/oap_tarots.png", px = 71, py = 95 }
SMODS.Atlas { key = "oap_pb", path = "Oops! All Programmers/oap_pb.png", px = 71, py = 95 }
SMODS.Atlas { key = "oap_self_insert", path = "Oops! All Programmers/oap_self_insert.png", px = 71, py = 95 }

--ads
SMODS.Atlas { key = "oap_roffle", path = "Ads/roffleland.png", px = 218, py = 121 }
SMODS.Atlas { key = "oap_danielad", path = "Ads/findhim.png", px = 125, py = 188 }
SMODS.Atlas { key = "oap_barga", path = "Ads/barga.png", px = 218, py = 270 }
SMODS.Atlas { key = "oap_sex", path = "Ads/sex.png", px = 218, py = 140 } -- hey what the fuck - myst
SMODS.Atlas { key = "oap_superepicramp", path = "Ads/SuperEpicRamp.png", px = 218, py = 153 }
SMODS.Atlas { key = "oap_thanosyikes", path = "Ads/thanosYikes.png", px = 218, py = 217 }
SMODS.Atlas { key = "oap_palombi", path = "Ads/palombi.png", px = 224, py = 250 }
SMODS.Atlas { key = "oap_lebron", path = "Ads/lebron.png", px = 100, py = 100 }
SMODS.Atlas { key = "oap_donut", path = "Ads/donut.png", px = 200, py = 263 }
SMODS.Atlas { key = "oap_greg", path = "Ads/gregregation.png", px = 225, py = 225 }
SMODS.Atlas { key = "oap_isopods", path = "Ads/isopods.png", px = 400, py = 225 }
SMODS.Atlas { key = "oap_Death", path = "Ads/Death.png", px = 343, py = 340 }

-- sounds
SMODS.Sound {
    key = 'forgiveness',
    path = 'sfx_forgiveness.ogg'
}
SMODS.Sound {
    key = 'music_abnormalitychoice',
    path = 'music_abnormalitychoice.ogg',
    pitch = 0.7,
    volume = 0.8,
    sync = false,
    select_music_track = function(self)
        if G.GAME.abno_choice_music then return 10000000 end
        return false
    end,
    hpot_discoverable = true,
    hpot_purpose = {
        "Music that plays in the",
        "Abnormality Choice event"
    },
    ppu_team = { 'OAP' }
}
