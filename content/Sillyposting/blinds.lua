SMODS.Atlas({ key = "SillypostingBlinds", path = "Sillyposting/Blinds.png", px = 34, py = 34, atlas_table = "ANIMATION_ATLAS", frames = 21})

SMODS.Blind {
    key = "quartz",
    atlas = "SillypostingBlinds",
    pos = { x= 0, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 3 },
    boss_colour = HEX("4DD8B5"),
    calculate = function(self, blind, context)
        if not blind.disabled and context.press_play then
            ease_plincoins(-1)
        end
    end,
    ppu_artist = {"Supernova"},
    ppu_coder = {"Eris"},
    ppu_team = {"Sillyposting"}
}
