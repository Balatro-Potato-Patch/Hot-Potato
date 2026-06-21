-- watch lua Mods/Hot-Potato/Jtem/nxklick.lua

SMODS.Sound {
    key = "nxkill",
    path = "sfx_kill.mp3"
}
SMODS.Sound {
    key = "nxunkill",
    path = "sfx_unkill.mp3"
}

function G.FUNCS.krisclick()
    local save = G.PROFILES[G.SETTINGS.profile]
    save.JtemKriskilled = (save.JtemKriskilled or 0) + (save.JtemKrisplus or 1)
    save.JtemKrisneeded = math.floor(HPTN.krisfactor^((0.2*(save.JtemKrisplus or 1))+1))
    play_sound("hpot_nxkill", nil, 0.25)
    G:save_progress()
end

function G.FUNCS.krisrepr()
    local save = G.PROFILES[G.SETTINGS.profile]
    if save.JtemKriskilled >= save.JtemKrisneeded then
    save.JtemKriskilled = 0
    save.JtemKrisplus = (save.JtemKrisplus or 1) + 1
    play_sound("hpot_nxunkill")
    save.JtemKrisneeded = math.floor(HPTN.krisfactor^((0.2*(save.JtemKrisplus or 1))+1))
    G:save_progress()
    end
end


function G.UIDEF.clickris()
    local save = G.PROFILES[G.SETTINGS.profile]
    save.JtemKriskilled = save.JtemKriskilled or 0
    save.JtemKrisplus = (save.JtemKrisplus or 1)
    save.JtemKrisneeded = math.floor(HPTN.krisfactor^((0.2*(save.JtemKrisplus or 1))+1))
    return {n = G.UIT.ROOT, config = {
					colour = G.C.CLEAR
				}, nodes = {
					{n = G.UIT.ROOT, config = {r = 0.1, minw = 8, minh = 6, align = "tm", padding = 0.2, colour = G.C.BLACK}, nodes = {
                        {n = G.UIT.C, config = {r = 0.1, minw = 8, minh = 6, align = "cm", colour = G.C.CLEAR}, nodes = {
                            {n = G.UIT.R, config = {r = 0.1,minw = 1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                               {n=G.UIT.T, config={ref_table = G.PROFILES[G.SETTINGS.profile], ref_value = 'JtemKriskilled', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                               {n=G.UIT.T, config={text = "kris killed", scale = 0.7, colour = G.C.WHITE, shadow = true}},
                            }},
                            {n = G.UIT.R, config = {r = 0.1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                                UIBox_button {
                                    button = "krisclick",
                                    label = {"Kill"}
                                }
                            }},
                            {n = G.UIT.R, config = {r = 0.1,minw = 1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                               {n=G.UIT.T, config={ref_table = G.PROFILES[G.SETTINGS.profile], ref_value = 'JtemKrisplus', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                               {n=G.UIT.T, config={text = "per click", scale = 0.7, colour = G.C.WHITE, shadow = true}},
                            }},
                            {n = G.UIT.R, config = {r = 0.1,minw = 1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                               {n=G.UIT.T, config={ref_table = G.PROFILES[G.SETTINGS.profile], ref_value = 'JtemKrisneeded', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                               {n=G.UIT.T, config={text = "for next unkill", scale = 0.7, colour = G.C.WHITE, shadow = true}},
                            }},
                            {n = G.UIT.R, config = {r = 0.1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                                UIBox_button {
                                    button = "krisrepr",
                                    label = {"Unkill (+1 per click)"},
                                    colour = G.C.BLUE
                                }
                            }},
                    }}
				}}
            }}
end
