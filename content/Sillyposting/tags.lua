SMODS.Atlas({key = "SillypostingTags", path = "Sillyposting/Tags.png", px = 34, py = 34, atlas_table = "ASSET_ATLAS"}):register()
SMODS.Tag {
    key = "job",
    atlas = "SillypostingTags",
    pos = { x = 0, y = 0 },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_hpot_czech_mega
    end,
    min_ante = 2,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.PURPLE, function()
                local booster = SMODS.create_card { key = 'p_hpot_czech_mega', area = G.play }
                booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
                booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
                booster.T.w = G.CARD_W * 1.27
                booster.T.h = G.CARD_H * 1.27
                booster.cost = 0
                booster.from_tag = true
                G.FUNCS.use_card({ config = { ref_table = booster } })
                booster:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
    ppu_artist = {'Jaydchw'},
    ppu_coder = {'UnusedParadox'},
    ppu_team = {'Sillyposting'}
}
SMODS.Tag {
    key = "plincoin",
    atlas = "SillypostingTags",
    pos = { x = 1, y = 0 },
    config = { plincoins = 5 },
    loc_vars = function(self, info_queue, tag)
        return { vars = { tag.config.plincoins } }
    end,
    apply = function(self, tag, context)
        if context.type == 'eval_plincoin' then
            if G.GAME.last_blind and G.GAME.last_blind.boss then
                tag:yep('+', SMODS.Gradients.hpot_plincoin, function()
                    return true
                end)
                tag.triggered = true
                return {
                    plincoins = tag.config.plincoins,
                    condition = localize('ph_defeat_the_boss'),
                    pos = tag.pos,
                    tag = tag
                }
            end
        end
    end,
    ppu_artist = {'Supernova'},
    ppu_coder = {'UnusedParadox'},
    ppu_team = {'Sillyposting'}
}
