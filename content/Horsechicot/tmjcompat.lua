--we do this post_load because. to be honest i dont actually know. its more stable i guess?
local lock = false
local old_love_update = love.update
function love.update(dt)
    if not lock then
        lock = true
        love.update = old_love_update
        if TMJ then
            TMJ.SEARCH_FIELD_FUNCS[#TMJ.SEARCH_FIELD_FUNCS+1] = function(center)
                if center.hotpot_credits then
                    local rets = {}
                    for i, v in pairs(center.hotpot_credits) do
                        if type(v) == "string" then
                            table.insert(rets, v)
                        elseif type(v) == "table" then
                            for l, v2 in pairs(v) do
                                table.insert(rets, v2)
                            end
                        end
                    end
                    return rets
                end
            end
        end
    end
    return old_love_update(dt)
end
