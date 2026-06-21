-- watch lua Mods/Hot-Potato/Jtem/nxklick.lua

SMODS.Sound {
    key = "nxkill",
    path = "sfx_kill.mp3"
}
SMODS.Sound {
    key = "nxunkill",
    path = "sfx_unkill.mp3"
}

function G.FUNCS.nxkclick()
    local save = G.PROFILES[G.SETTINGS.profile]
    save.JtemNXkilled = (save.JtemNXkilled or 0) + (save.JtemNXplus or 1)
    save.JtemNXneeded = math.floor(HPTN.nxkoofactor^((0.2*(save.JtemNXplus or 1))+1))
    play_sound("hpot_nxkill", nil, 0.25)
    G:save_progress()
end

function G.FUNCS.nxkrepr()
    local save = G.PROFILES[G.SETTINGS.profile]
    if save.JtemNXkilled >= save.JtemNXneeded then
    save.JtemNXkilled = 0
    save.JtemNXplus = (save.JtemNXplus or 1) + 1
    play_sound("hpot_nxunkill")
    save.JtemNXneeded = math.floor(HPTN.nxkoofactor^((0.2*(save.JtemNXplus or 1))+1))
    G:save_progress()
    end
end


function G.UIDEF.nxclicker()
    local save = G.PROFILES[G.SETTINGS.profile]
    save.JtemNXkilled = save.JtemNXkilled or 0
    save.JtemNXplus = (save.JtemNXplus or 1)
    save.JtemNXneeded = math.floor(HPTN.nxkoofactor^((0.2*(save.JtemNXplus or 1))+1))
    return {n = G.UIT.ROOT, config = {
					colour = G.C.CLEAR
				}, nodes = {
					{n = G.UIT.ROOT, config = {r = 0.1, minw = 8, minh = 6, align = "tm", padding = 0.2, colour = G.C.BLACK}, nodes = {
                        {n = G.UIT.C, config = {r = 0.1, minw = 8, minh = 6, align = "cm", colour = G.C.CLEAR}, nodes = {
                            {n = G.UIT.R, config = {r = 0.1,minw = 1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                               {n=G.UIT.T, config={ref_table = G.PROFILES[G.SETTINGS.profile], ref_value = 'JtemNXkilled', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                               {n=G.UIT.T, config={text = "nxkoo killed", scale = 0.7, colour = G.C.WHITE, shadow = true}},
                            }},
                            {n = G.UIT.R, config = {r = 0.1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                                UIBox_button {
                                    button = "nxkclick",
                                    label = {"Kill"}
                                }
                            }},
                            {n = G.UIT.R, config = {r = 0.1,minw = 1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                               {n=G.UIT.T, config={ref_table = G.PROFILES[G.SETTINGS.profile], ref_value = 'JtemNXplus', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                               {n=G.UIT.T, config={text = "per click", scale = 0.7, colour = G.C.WHITE, shadow = true}},
                            }},
                            {n = G.UIT.R, config = {r = 0.1,minw = 1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                               {n=G.UIT.T, config={ref_table = G.PROFILES[G.SETTINGS.profile], ref_value = 'JtemNXneeded', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                               {n=G.UIT.T, config={text = "for next unkill", scale = 0.7, colour = G.C.WHITE, shadow = true}},
                            }},
                            {n = G.UIT.R, config = {r = 0.1,align = "cm", padding = 0.2, colour = G.C.CLEAR}, nodes = {
                                UIBox_button {
                                    button = "nxkrepr",
                                    label = {"Unkill (+1 per click)"},
                                    colour = G.C.BLUE
                                }
                            }},
                    }}
				}}
            }}
end
