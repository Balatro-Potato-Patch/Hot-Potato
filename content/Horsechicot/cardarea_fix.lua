--i believe this imporved performance? i think handy had a bug where everything renders regardless. this is almost certainly a reimplementation of a vanilla optimization
local old = Card.draw
function Card:draw(...)
    if not ((self.VT.x >= G.ROOM.T.w) or (self.VT.y >= G.ROOM.T.h)) then
        return old(self, ...)
    end
end
