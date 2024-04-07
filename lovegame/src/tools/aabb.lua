--[[

This version of AABB is ripped from here:
    https://github.com/Jeepzor/Pong-tutorial/blob/main/Episode%202/main.lua
,thanks!

]]

function checkCollision(a, b)
    --Takes two arguments, the rectangles we want to check for collision.
    if a.x + a.width > b.x and a.x < b.x + b.width and a.y + a.height > b.y and a.y < b.y + b.height then
        -- Is A, intersecting B
        return true -- Returns the boolean value true, indicating that A and B are colliding.
    else
        return false -- Returns the boolean value false, indicating that A and B are not colliding.
    end
end
