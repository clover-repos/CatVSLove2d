tT = {}

function tT.start()
    touchImage = love.graphics.newImage('res/gfx/tap.png')

    touchScale = 8
end

function touchScreen()
    local t = love.touch.getTouches()

    for i = 1, #t do
        touchx, touchy = love.touch.getPosition(t[i])
        local tx, ty = love.touch.getPosition(t[i])
        love.graphics.draw(touchImage,tx-touchImage:getWidth()*(touchScale/2*scalew),ty-touchImage:getHeight()*(touchScale/2*scalew),nil,touchScale*scalew)
    end
end
