SMODS.Stake{
    key = "missingtext",
    colour = G.C.HPOT_PINK,
    atlas = "tname_stakes2",
    pos = {x = 0, y = 0},
    sticker_atlas = "tname_stickers",
    sticker_pos = {x=3,y=3},
    applied_stakes = { "gold" },
    shiny = false,
    unlocked = false,
    prefix_config = { applied_stakes = { mod = false} },
    loc_txt = {
        name = "[Texture Missing]",
        text = {"Adds a bunch of stickers by tname.",
    "{C:inactive,s:0.7}We hope you hate it!"},
                sticker = {
                    name = "Corrupted Sticker",
                    text = {"Survived the depths",
                            "of hell",
                        "{C:inactive,s:0.7}Oh no! another sticker!"}

                }
    },
    modifiers = function()
        G.GAME.tnamestickers = true
    end,
    
	ppu_artist = { "GoldenLeaf" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
}
SMODS.Stake{
    key = "wooden",
    colour = HPTN.C.BROWN,
    atlas = "tname_stakes",
    pos = {x = 0, y = 0},
    applied_stakes = { "missingtext" },
    shiny = false,
    unlocked = false,
    loc_txt = {
        name = "Wooden Stake",
        text = {"Kills all vampires in your run"},
                sticker = {
                    name = "Wooden Sticker",
                    text = {"How did you even",
                            "get this?"}

                }
    },
    modifiers = function()
        G.GAME.modifiers.YOU_LOSE = true
    end,
    
	ppu_artist = { "GoldenLeaf" },
		idea = { "Corobo" },
	ppu_coder = { "Revo" },
	ppu_team = { "Team Name" },
}