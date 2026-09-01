--[[ bigButtonBirthdayBash = {

}
local peeButtRef = UIBox.init
function UIBox:init(args)
    local ret = peeButtRef(self, args)
    if args.config.button and not bigButtonBirthdayBash[ret] then
        table.insert(bigButtonBirthdayBash, ret)
    end
    return ret
end

function G.UIDEF.hotpot_pissdrawer_piss_button()
end ]]

--commented out until I can figure it out
