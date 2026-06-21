function hpot_joker_train_indicator_definition(stat, num, colours)
	return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.C, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {shadow = true, text = num and to_number(num) < 0 and "v" or "^", colour = (colours or {})[1] or G.C.FILTER, scale = 1}},
            }},
            {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {shadow = true, text = (num and ((to_number(num) >= 0 and "+"..num) or num)) or "+0", colour = (colours or {})[1] or G.C.FILTER, scale = 0.7}},
            }},
            {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {shadow = true, text = stat and localize("hotpot_"..stat) or "?", colour = (colours or {})[2] or G.C.UI.TEXT_LIGHT, scale = 0.6}},
            }},
        }}
    }}
end

function move_train_text(node, positive)
    ---@type UIElement
    local arrow = node.children[1]
    local number = node.children[2]
    local stat = node.children[3]

    if positive then
        arrow:ease_move({x = 0, y = -0.75}, nil, nil, nil, nil, nil, nil, nil, "inexpo")
        number:ease_move({y = -0.5}, 25)
        stat:ease_move({y = -0.5}, 25)
    else
        arrow:ease_move({x = 0, y = 0.75}, nil, nil, nil, nil, nil, nil, nil, "inexpo")
        number:ease_move({y = 0.5}, 25)
        stat:ease_move({y = 0.5}, 25)
    end
end

function Card:create_train_popup(stat, num)
    num = to_number(num)
    local train_popup = nil
    hotpot_add_event{
        trigger = "before",
        delay = 0.2,
        func = function()
            G.GAME.train_popup_num = G.GAME.train_popup_num or 0
            G.GAME.train_popup_num = G.GAME.train_popup_num + 1
            train_popup = G.GAME.train_popup_num
            repeat
                if self.children["hpot_train"..train_popup] then
                    train_popup = train_popup + 1
                end
            until not self.children["hpot_train"..train_popup]
            
            if (num or 0) >= 0 then
                G.C["hpot_train"..train_popup] = copy_table(G.C.FILTER)
                play_sound("hpot_sfx_stat_up", nil, 0.7)
            else
                G.C["hpot_train"..train_popup] = copy_table(G.C.BLUE)
                play_sound("hpot_sfx_stat_down", nil, 0.7)
            end
            G.C["hpot_train_stat"..train_popup] = copy_table(G.C.UI.TEXT_LIGHT)
            self:juice_up(0.1,0.1)
            self.children["hpot_train"..train_popup] = UIBox{
                definition = hpot_joker_train_indicator_definition(stat, num, {G.C["hpot_train"..train_popup], G.C["hpot_train_stat"..train_popup]}), 
                config = {
                    align = "cmi", 
                    offset = {x = math.random(-150,150)/100, y = math.random(-100,100)/100},
                    parent = self
                }
            }
            if (num or 0) >= 0 then
                self.children["hpot_train"..train_popup].UIRoot.children[1].children[1]:align(0,0.5)
            else
                self.children["hpot_train"..train_popup].UIRoot.children[1].children[1]:align(0,-0.5)
            end
            move_train_text(self.children["hpot_train"..train_popup].UIRoot.children[1], (num or 0) >= 0)
            hotpot_add_event{
                blocking = false,
                blockable = false,
                func = function()
                    if not self.children["hpot_train"..train_popup] or not self.children["hpot_train"..train_popup].remove then return true end
                    if G.C["hpot_train_stat"..train_popup][4] <= 0 or G.C["hpot_train"..train_popup][4] <= 0 then
                        self.children["hpot_train"..train_popup]:remove()
                        self.children["hpot_train"..train_popup] = nil
                        G.GAME.train_popup_num = (G.GAME.train_popup_num or 1) - 1
                        return true
                    end
                end,
            }
            return true
        end,
    }
    hotpot_add_event{
        blocking = false,
        trigger = "after",
        delay = 0.6,
        func = function()
            hotpot_add_event{
                blocking = false,
                blockable = false,
                trigger = "ease",
                delay = 2.5,
                ref_table = G.C["hpot_train"..train_popup],
                ref_value = 4,
                ease_to = 0,
            }
            hotpot_add_event{
                blocking = false,
                blockable = false,
                trigger = "ease",
                delay = 2.5,
                ref_table = G.C["hpot_train_stat"..train_popup],
                ref_value = 4,
                ease_to = 0,
            }
            return true
        end,
    }
end