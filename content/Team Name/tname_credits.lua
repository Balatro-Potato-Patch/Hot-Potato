
function G.UIDEF.tname_credits()
    local save = G.PROFILES[G.SETTINGS.profile]
    save.TNameCredits = (save.TNameCredits or 0)
    return
    {n = G.UIT.R, config = {r = 0.1,minw = 3.5, minh = 0.8,align = "cm", padding = 0, colour = G.C.BLACK}, nodes = {
        {n=G.UIT.T, config={text = localize("you_have"), scale = 0.6, colour = G.C.WHITE, shadow = true}},
        {n=G.UIT.T, config={text = "c."..number_format(G.PROFILES[HPTN.Profile]["TNameCredits"]), scale = 0.6, colour = G.C.PURPLE, shadow = true}},
    }}
end