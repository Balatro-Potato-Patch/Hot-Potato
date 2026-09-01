local ad_corners_radius = 0.1

function hp_isDesktopPlatform()
    return love.system.getOS() == "Windows" or love.system.getOS() == "OS X" or love.system.getOS() == "Linux"
end

HotPotato.Ads = {
    Adverts = { -- Adverts are pulled from this pool most of the time.
        ad_lusty = {atlas = 'hpot_Perkeocoin_Ads', pos = {x=1,y=0}, base_size = 0.75},
        ad_hawaii = {atlas = 'hpot_Perkeocoin_Ads', pos = {x=2, y=0}, base_size = 0.75},
        ad_triboulet = {atlas = 'hpot_TribouletAd', pos = {x=0,y=0}, animated = true, base_size = 0.75},
        ad_attack = {atlas = 'hpot_Perkeocoin_Ads', pos = {x=0, y=0}, base_size = 0.75, max_scale = 0.5},
        ad_dotty = {atlas = 'hpot_DottyAd', pos = {x=0, y=0}, base_size = 0.6, max_scale = 0.6},
        ad_perkeoboss = {atlas = 'hpot_PerkeoBoss', pos = {x=0, y=0}, base_size = 0.35, max_scale = 0.10},
        -- Jtem :))))
        ad_obsidian = {atlas = "hpot_jtemads",pos = {x=0,y=1}},
        ad_what = {atlas = "hpot_jtemads",pos = {x=2,y=0}},
        ad_blank = {atlas = "hpot_jtemads",pos = {x=0,y=0}},
        ad_naner = {atlas = "hpot_jtemads",pos = {x=1,y=1}},
        ad_rally = {atlas = "hpot_jtemrally",pos = {x=0,y=0},animated = true, base_size = 0.6, max_scale = 0.15},
        ad_fuck = {atlas = "hpot_jtemfuck",pos = {x=0,y=0},animated = true, base_size = 0.7, max_scale = 0.25},
        ad_sauce = {atlas = 'hpot_jtemads',pos = {x=1,y=2}},
        ad_singles = {atlas = 'hpot_jtemads',pos = {x=2,y=2}},
        ad_aikoshen1 = {atlas = 'hpot_jtem_aikoshen1',pos = {x=0,y=0}},
        ad_error1 = {atlas = 'hpot_jtem_ad_error1',pos = {x=0,y=0}},
        ad_broken_page = {atlas = 'hpot_jtemads',pos = {x=3,y=0}},

        ad_indiepaketphoenix = hp_isDesktopPlatform() and {atlas = 'hpot_paket_balala',pos = {x=0,y=0},video = true} or nil,
        -- Horsechicot
        ad_banana = {atlas = "hpot_hcbananaad", pos = {x = 0, y = 0}},
        ad_numberslop = {atlas = "hpot_hcnumberslop", pos = {x = 0, y = 0}},
        -- Oops! All Programmers
        ad_roffle = {atlas = "hpot_oap_roffle", pos = {x = 0, y = 0}},
        ad_daniel = {atlas = "hpot_oap_danielad", pos = {x = 0, y = 0}},
        ad_palombi = {atlas = "hpot_oap_palombi", pos = {x = 0, y = 0}, base_size = 0.6, max_scale = 0.1},
        ad_death = {atlas = "hpot_oap_Death", pos = {x = 0, y = 0}, base_size = 0.4, max_scale = 0.15},
    },
    Shitposts = { -- Adverts are very rarely pulled from this pool.
        ad_digging = {atlas = 'hpot_Perkeocoin_Ads', pos = {x=3,y=0}, animated = false, base_size = 0.75},
        ad_smoothie = {atlas = 'hpot_ProtoShitposts', pos = {x=0,y=0}, animated = false, base_size = 0.55, max_scale = 0.2},
        ad_peeling = {atlas = 'hpot_ProtoShitposts', pos = {x=1,y=0}, animated = false, base_size = 0.25, max_scale = 0.3},
        ad_spectred = {atlas = 'hpot_SpectredAd', pos = {x=0,y=0}, animated = true, base_size = 0.75},
        ad_sweebro = {atlas = 'hpot_Perkeocoin_Ads', pos = {x=0,y=1}, animated = false, base_size = 0.75},
        -- Jtem
        ad_moonpiss = {atlas = "hpot_jtemads",pos = {x=1,y=0}},
        ad_labubu = {atlas = 'hpot_jtemads',pos = {x=2,y=1}},
        ad_4f6368 = {atlas = 'hpot_jtemads',pos = {x=0,y=2}},
        ad_bts = {atlas = 'hpot_jtem_bts',pos = {x=0,y=0}, animated = true},
        ad_again = {atlas = 'hpot_jtem_again',pos = {x=0,y=0}, animated = true},
        ad_beachday = {atlas = 'hpot_jtemads',pos = {x=3,y=2}},
        ad_astolfo = {atlas = 'hpot_jtemads',pos = {x=4,y=2}},
        ad_jtem = {atlas = 'hpot_jtemads',pos = {x=3,y=1}},
        ad_404 = {atlas = 'hpot_jtemads',pos = {x=4,y=0}},
        ad_403 = {atlas = 'hpot_jtemads',pos = {x=4,y=1}},
        -- Team Name
        ad_tname = {atlas = "hpot_tname_ads",pos = {x=0,y=0}},
        ad_twinx = {atlas = "hpot_tname_ads",pos = {x=1,y=0}},
        -- Horsechicot
        ad_mustard = {atlas = "hpot_hcmustard", pos = {x = 0, y = 0}},
        ad_windows = {atlas = "hpot_hcwindows", pos = {x = 0, y = 0}},
        ad_red = {atlas = "hpot_hcred", pos = {x = 0, y = 0}},
        ad_horseyworseys = {atlas = "hpot_hchorseyworseys", pos = {x = 0, y = 0}},
        -- Oops! All Programmers
        ad_sex = {atlas = "hpot_oap_sex", pos = {x = 0, y = 0}},
        ad_trolley = {atlas = "hpot_oap_superepicramp", pos = {x = 0, y = 0}},
        ad_thanos = {atlas = "hpot_oap_thanosyikes", pos = {x = 0, y = 0}},
        ad_lebron = {atlas = "hpot_oap_lebron", pos = {x = 0, y = 0}},
        ad_donut = {atlas = "hpot_oap_donut", pos = {x = 0, y = 0}, base_size = 0.6, max_scale = 0.1},
        ad_greg = {atlas = "hpot_oap_greg", pos = {x = 0, y = 0}, base_size = 0.5, max_scale = 0.25},
        ad_isopods = {atlas = "hpot_oap_isopods", pos = {x = 0, y = 0}, base_size = 0.4, max_scale = 0.1},
        ad_barga = {atlas = "hpot_oap_barga", pos = {x = 0, y = 0}, base_size = 0.6, max_scale = 0.15},
        ad_birdcoin = {atlas = "hpot_birdcoin",pos = {x=0,y=0}},
        ad_codeofethics = {atlas = "hpot_codeofethics",pos = {x=0,y=0}},
        ad_newartcomingsoon = {atlas = "hpot_newartcomingsoon",pos = {x=0,y=0}},
    },
    Special = { -- Adverts in this pool can never naturally spawn.
        ad_animated = {atlas = 'hpot_AbbieMindwave', pos = {x=0,y=0}, animated = true, base_size = 0.25, max_scale = 0.25},
    }
    -- Defaults = {atlas = 'hpot_Perkeocoin_Ads', pos = {x=0,y=0}, animated = false, base_size = 0.75, max_scale = 0.5}
}

for i, v in pairs(HotPotato.Ads.Adverts) do
    if v.video and not hp_isDesktopPlatform() then
        HotPotato.Ads.Adverts[i] = nil
    end
end
for i, v in pairs(HotPotato.Ads.Shitposts) do
    if v.video and not hp_isDesktopPlatform() then
        HotPotato.Ads.Adverts[i] = nil
    end
end
for i, v in pairs(HotPotato.Ads.Special) do
    if v.video and not hp_isDesktopPlatform() then
        HotPotato.Ads.Adverts[i] = nil
    end
end

--- In case you haven't played HotPot yet, Ads appear after the Boss Blind is defeated.
--- They can also appear from a certain Joker, or a particular Consumable type.
--- Ads are not *actually* advertising anything - they are just meant to be silly :3

-- Normal ad atlas. Note that size can be anything, but this is the recommended px/py
SMODS.Atlas({key = 'Perkeocoin_Ads', px = 150, py = 100, path = 'Ads/Ads.png', atlas_table = "ASSET_ATLAS"}):register()

-- Animated ad atlas - animated ads use the default animation logic (i.e. have the same fps as Blind Chips)
SMODS.Atlas({key = 'TribouletAd', px = 150, py = 100, path = 'Ads/Tribouletad.png', frames = 16, atlas_table = 'ANIMATION_ATLAS'}):register()

-- Video ad atlas - Must be an ogv file. (Sorry, this is a Love2d limitation.)
-- SMODS.Video({ key = "paket_balala", path = "ad_paket.ogv", px = 240, py = 240 }):register()

-- Tutorial banner:
SMODS.Atlas({ key = 'TutorialAdBanner', px = 150, py = 31, path = 'Ads/AdBanners.png', atlas_table = "ASSET_ATLAS"}):register()

-- Other ad atli used by Perkeocoin:
SMODS.Atlas({key = 'ProtoShitposts', px = 300, py = 400, path = 'Ads/ProtoAds.png', atlas_table = "ASSET_ATLAS"}):register()
SMODS.Atlas({ key = 'SpectredAd', px = 281, py = 118, frames = 10, path = 'Ads/Spectred.png', atlas_table = 'ANIMATION_ATLAS'}):register()
SMODS.Atlas({ key = 'AbbieMindwave', px = 300, py = 300, path = 'Ads/AbbieMindwave.png', frames = 4, atlas_table = 'ANIMATION_ATLAS'}):register()
SMODS.Atlas({ key = 'DottyAd', px = 170, py = 150, path = 'Ads/DottyAd.png', atlas_table = 'ASSET_ATLAS'}):register()
SMODS.Atlas({ key = 'PerkeoBoss', px = 470, py = 326, path = 'Ads/PerkeoBoss.png', atlas_table = 'ASSET_ATLAS'}):register()

SMODS.Shader { key = "ad", path = "ad.fs" }

local apply_to_run_ref = Back.apply_to_run
function Back:apply_to_run()
    G.GAME.hotpot_total_ads = 0
    G.GAME.hotpot_ads_closed = 0
    return apply_to_run_ref(self)
end

function create_UIBox_ad(args)
    local ad = args.ad
    local adNum = args.id
    local scale = args.scale
    local ad_atlas = nil
    local ad_image = nil

    if ad.animated and ad.animated == true then
        ad_atlas = G.ANIMATION_ATLAS[(ad.atlas or 'hpot_Perkeocoin_Ads')]
        ad_image = AnimatedSprite(0,0,(ad_atlas.px/49)*scale,(ad_atlas.py/49)*scale,ad_atlas,{x = math.ceil((pseudorandom('random_start')*ad_atlas.frames) - 0.5), y = ad.pos.y})
    else
        ad_atlas = (ad.video and SMODS.Videos or G.ASSET_ATLAS)[(ad.atlas or 'hpot_Perkeocoin_Ads')]
        if ad.video then
            -- required to set the damn dimensions that are not even a factor when its a video
            ad_atlas.image = {
                getDimensions = function(self)
                    return ad_atlas.px, ad_atlas.py
                end
            }
        end
        ad_image = Sprite(0,0,(ad_atlas.px/49)*scale,(ad_atlas.py/49)*scale,ad_atlas,(ad.pos or {x=0,y=0}))
        if not ad.video and ad_corners_radius and ad_corners_radius > 0 then
            ad_image:get_pos_pixel() -- Fix shader crash
            ad_image:define_draw_steps {
                { shader = 'hpot_ad', send = {
                    {name = 'image_details', ref_table = ad_image, ref_value = 'image_dims'},
                    {name = 'texture_details', ref_table = ad_image.RETS, ref_value = 'get_pos_pixel'}
                }},
            }
        end
        if ad.video then
            ad_atlas.image = nil
            ad_image.video = love.graphics.newVideo(ad_atlas.video_stream, {dpiscale = 1})
            ad_image.video:play()
            -- tweak the video audio source to use the current volume
            local source = ad_image.video:getSource()
            if source then
                source:setVolume(((G.SETTINGS.SOUND.volume/100.0)*(G.SETTINGS.SOUND.music_volume/100.0))/1.5)
            end
        end
    end


    local ad_content = {n=G.UIT.R, config = {colour = G.C.GREY, r = 0.3, align = 'cm'}, nodes = {
                        {n = G.UIT.O, config = {object = ad_image, r = 0.3}}
                    }}
    
    local tutorial_banner = nil
    local tutorial = args.tutorial or false
    local tutorial_content = nil

    if tutorial then
        tutorial_banner = Sprite(0,0,(150/49)*scale,(31/49)*scale,G.ASSET_ATLAS['hpot_TutorialAdBanner'], {x=0,y=0})
        tutorial_content = {n=G.UIT.R, config = {colour = G.C.GREY, r = 0.3, align = 'cr'}, nodes = {
                        {n = G.UIT.O, config = {object = tutorial_banner, r = 0.3}}
                        }}
                    
    end

    local t = {n = G.UIT.ROOT, config = {colour = G.C.GREY, minh = 1, r = ad_corners_radius, instance_type = 'CARD', padding = 0.05,  outline = 0.5, outline_colour = G.C.GREY, shadow = true}, nodes = {
        {n=G.UIT.R, config = {colour = G.C.GREY, minh = 0.33, align = 'cr', r = 0.05, padding = 0.01}, nodes = {
            {n=G.UIT.C, config = {colour = G.C.CLEAR, align = 'cl'}, nodes = {
                {n=G.UIT.T, config = {text = 'ad_'..adNum.." ", colour = G.C.UI.TEXT_LIGHT, scale = 0.3, align = 'cl'}}
            }},
            {n=G.UIT.C, config = {align = 'cm', colour = G.C.RED, minw = 0.3, minh = 0.3,r = 0.3, button = 'remove_ad', adnum = adNum}, nodes = {
                -- use vanilla font: resources/fonts/GoNotoCJKCore.ttf
                {n=G.UIT.T, config = {text = '×', font = G.FONTS[9], colour = G.C.UI.TEXT_LIGHT, shadow = false, padding = 0.045, scale = 0.3}}
            }}
        }},
        tutorial_content,
        ad_content
    }}
    return t
end

G.FUNCS.remove_ad = function(args)
    local remove_this_ad = nil
    if type(args) == 'table' then
        for k, v in ipairs(G.GAME.hotpot_ads) do
            if v.config.id == args.config.adnum then
                remove_this_ad = v
                table.remove(G.GAME.hotpot_ads, k)
                break
            else
            end
        end
    else
        for k, v in ipairs(G.GAME.hotpot_ads) do
            if v.config.id == args then
                remove_this_ad = v
                table.remove(G.GAME.hotpot_ads, k)
                break
            else
            end
        end
    end

    for i=1, #G.jokers.cards do
        local effects = eval_card(G.jokers.cards[i], {cardarea = G.jokers, close_ad = remove_this_ad})
        if effects.jokers then
            card_eval_status_text(G.jokers.cards[i], 'jokers', nil, nil, nil, effects.jokers)
        end
    end

    if remove_this_ad then remove_this_ad:remove() end
    G.GAME.hotpot_ads_closed = G.GAME.hotpot_ads_closed + 1
    save_run()
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    local result = start_run_ref(self, args)

    G.GAME.hotpot_ads = {}
    if args and args.savetext and type(args.savetext.hotpot_ads) == "table" then
        for k, v in ipairs(args.savetext.hotpot_ads) do
            local new_ad = UIBox{
                definition = create_UIBox_ad{ad = v.key, id = v.id, scale = v.scale, tutorial = v.tutorial},
                config = {align="cm", offset = {x=0,y=0}, instance_type = 'CARD', bond = 'Weak', draggable = true, collideable = true, can_collide = true}
            }
            new_ad.config.id = v.id
            new_ad.config.key = v.key
            new_ad.config.scale = v.scale
            new_ad.config.tutorial = v.tutorial
            new_ad:align_to_major()
            new_ad.config.major = nil
            new_ad:set_role{role_type = 'Major'}
            new_ad:hard_set_T(v.position.x, v.position.y,new_ad.T.w, new_ad.T.h)
            G.GAME.hotpot_ads[k] = new_ad
        end
    end
    G.jokers.config.highlighted_limit = 1e100
    G.consumeables.config.highlighted_limit = 1e100
    return result
end

function save_ad(ad)
    return{
        key = ad.config.key,
        id = ad.config.id,
        offset = ad.alignment.offset,
        position = {x = ad.T.x, y = ad.T.y},
        scale = ad.config.scale,
        tutorial = ad.config.tutorial,
    }
end

local end_round_ref = end_round
function end_round()
    if G.GAME.blind:get_type() == "Boss" then
        local number_of_ads = 1+(math.ceil((pseudorandom('ad_num')-0.5)*2))
        create_ads(number_of_ads)
        G.GAME.market_filled = nil
        PissDrawer.Shop.market_spawn = false
    else
        local number_of_ads = math.floor(pseudorandom('ad_num')*2)
        create_ads(number_of_ads)
    end
    return end_round_ref()
end

function create_ads(number_of_ads)
    if next(SMODS.find_card("j_hpot_balatro_free_smods_download_2025")) then
        number_of_ads = math.floor(number_of_ads + pseudorandom("free_smods_extra_ads") * 2)
    end
    for i = 1, to_number(number_of_ads) do
        if next(SMODS.find_card("j_hpot_balatro_premium", false)) then
            G.GAME.hotpot_total_ads = G.GAME.hotpot_total_ads + 1
            for i=1, #G.jokers.cards do
                local effects = eval_card(G.jokers.cards[i], {cardarea = G.jokers, close_ad = true})
                if effects.jokers then
                    card_eval_status_text(G.jokers.cards[i], 'jokers', nil, nil, nil, effects.jokers)
                end
            end
        else
            G.E_MANAGER:add_event(Event({
            func = function()
                local ad_to_use = nil
                local tutorial_ad = false
                if G.GAME.hotpot_total_ads == 0 then
                    tutorial_ad = true
                end

                local ad_type_poll = pseudorandom('ad_type')
                if ad_type_poll <= 0.9 then
                    ad_to_use = pseudorandom_element(HotPotato.Ads.Adverts,'generate_ad')
                else
                    ad_to_use = pseudorandom_element(HotPotato.Ads.Shitposts,'generate_ad')
                end

                local ad_scale = (ad_to_use.base_size or 0.60) + ((ad_to_use.max_scale or 0.25)*pseudorandom('ad_scale'))
                G.GAME.hotpot_total_ads = G.GAME.hotpot_total_ads + 1
                G.GAME.hotpot_ads = G.GAME.hotpot_ads or {}
                local new_ad = UIBox{
                    definition = create_UIBox_ad{ad = ad_to_use, id = G.GAME.hotpot_total_ads,scale = ad_scale, tutorial = tutorial_ad},
                    config = {align="cm", offset = {x=0,y=0}, instance_type = 'CARD', major = G.ROOM_ATTACH, bond = 'Weak', draggable = true, collideable = true, can_collide = true, foc}
                }
                new_ad:align_to_major()
                new_ad.config.major = nil
                new_ad:set_role{role_type = 'Major'}
                new_ad.T.x = new_ad.T.x + (pseudorandom('ad_x_offset')-0.5)*16
                new_ad.T.y = new_ad.T.y + (pseudorandom('ad_y_offset')-0.5)*9
                new_ad.config.id = G.GAME.hotpot_total_ads
                new_ad.config.key = ad_to_use
                new_ad.config.scale = ad_scale
                new_ad.config.tutorial = tutorial_ad
                new_ad.config.ad = true
                G.GAME.hotpot_ads[#G.GAME.hotpot_ads+1] = new_ad
            return true end}))
        end
    end
    if number_of_ads > 0 then
        for i=1, #G.jokers.cards do
            local effects = eval_card(G.jokers.cards[i], {cardarea = G.jokers, create_ad = number_of_ads})
            if effects.jokers then
                card_eval_status_text(G.jokers.cards[i], 'jokers', nil, nil, nil, effects.jokers)
            end
        end
    end
end


--- Change ads to push each other + ads cannot be stuffed off screen
--#region Ads restrictions

-- Feel free to make this border dynamic (don't have time to figure this out)
local screen_border = {-1.8, -0.8, 21.8, 12.2}



local function dist_squared(vec)
    return vec.x^2 + vec.y^2
end

local function find_closest_ad(key, ad)
    local closest = nil
    local closest_dist = 999999

    for relative_key, relative_ad in pairs(G.GAME.hotpot_ads) do
        if relative_key == key then
            goto continue
        end

        -- Distance between center points for each ad
        local dist = dist_squared {
            x = (ad.VT.x + ad.VT.w/2) - (relative_ad.VT.x + relative_ad.VT.w/2),
            y = (ad.VT.y + ad.VT.h/2) - (relative_ad.VT.y + relative_ad.VT.h/2),
        }
        if closest == nil or dist < closest_dist then
            closest = relative_ad
            closest_dist = dist
        end

        ::continue::
    end
    return closest
end

local function normalize(vec)
    local len = (vec.x^2 + vec.y^2) ^0.5
    -- No division by 0
    if len < 0.00001 then
        len = 0.00001
    end
    vec.x = vec.x/len
    vec.y = vec.y/len
    return vec
end

local function fix_T(T)
    T.x = math.max(screen_border[1], math.min(screen_border[3] - T.w, T.x))
    T.y = math.max(screen_border[2], math.min(screen_border[4] - T.h, T.y))
end

local game_update = Game.update
function Game:update(...)
    if G.real_dt and G.GAME and G.GAME.hotpot_ads and not G.freeze_ads then

        local speed = G.real_dt * 0.033

        for key, ad in pairs(G.GAME.hotpot_ads) do

            local closest = find_closest_ad(key, ad)
            if closest then
                local dir_vector = {
                        x = (ad.VT.x + ad.VT.w/2) - (closest.VT.x + closest.VT.w/2),
                        y = (ad.VT.y + ad.VT.h/2) - (closest.VT.y + closest.VT.h/2),
                }
                -- If hitboxes intersect
                if
                    math.abs(dir_vector.x) < (ad.VT.w/2 + closest.VT.w/2) and
                    math.abs(dir_vector.y) < (ad.VT.h/2 + closest.VT.h/2)
                then
                    normalize(dir_vector)
                    ad.T.x = ad.T.x + dir_vector.x * speed
                    ad.T.y = ad.T.y + dir_vector.y * speed
                    fix_T(ad.T)

                    -- Push the other ad as well
                    closest.T.x = closest.T.x - dir_vector.x * speed
                    closest.T.y = closest.T.y - dir_vector.y * speed
                    fix_T(closest.T)
                    goto continue
                end
            end

            fix_T(ad.T)
            ::continue::
        end
    end
    
    return game_update(self, ...)
end
--#endregion
