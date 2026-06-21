SMODS.Tag {
    key = "illegal",
    atlas = "hc_tags",
    pos = { x = 0, y = 0 },
    config = { bitcoins = 4 },
    loc_vars = function(self, info_queue, tag)
        return { vars = { tag.config.bitcoins } }
    end,
    apply = function(self, tag, context)
        if context.type == "immediate" then
            ease_cryptocurrency(tag.config.bitcoins)
            tag:yep('+', G.C.ORANGE, function()
                return true
            end)
            tag.triggered = true
        end
    end,
    ppu_coder = { "lord.ruby" },
    ppu_artist = { "lord.ruby" },
    ppu_team = { "Horsechicot" }
}