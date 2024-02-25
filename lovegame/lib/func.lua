idle = 1
attack = 2

function makeVars()
    currentCharIndex = 0
    cr = false
    
    shakeMagnitude = 4

    reH = false
    --no blur
    love.graphics.setDefaultFilter("nearest", "nearest")
    --mouse
    love.mouse.setVisible(false)
    --timers
    mapT = 0
    swordT = 0
    dst = 0
    crt = 0
    shakeDuration = 0.25
    charDelay = 0.03
    pauseDelay = 0.25
    deathT = 0
    --Gamestates with number as an ID.

    gs = {}
    gs.pls = 0
    gs.ps = 1
    gs.ts = 2
    gs.trs = 3
    gs.ds = 4
    gs.death = 5

    --THE GAMESTATE!!

    gs.state = gs.ts

    --audio
    gsSE = love.audio.newSource("res/audio/sfx/gs.ogg", "static")
    talkSE = love.audio.newSource("res/audio/sfx/t.ogg", "static")
    waterfall = love.audio.newSource("res/audio/music/WM.ogg", "stream")
    waterfall:setLooping(true)
    hSE = love.audio.newSource("res/audio/sfx/hurt.mp3", "static")
    --import
    require("lib/play")
    came = require("lib/camera")
    sti = require("lib/sti")
    wf = require("lib/windfield")
    require("lib/flux")
    ani = require("lib/ani")
end

function setWindowSize(ful, width, height)
    if ful then
        full = true
        love.window.setFullscreen(true)
        windowWidth = love.graphics.getWidth()
        windowHeight = love.graphics.getHeight()
    else
        full = false
        if width == nil or height == nil then
            windowWidth = 1920
            windowHeight = 1080
        else
            windowWidth = width
            windowHeight = height
        end
        love.window.setMode( windowWidth, windowHeight)
    end
end

function setScale()
    local scFactor = 7.3/2.5
    scale = (scFactor / 1200) * windowHeight

    if cam then
        cam:zoomTo(scale)
    end

    if cam and cam.scaleAdjust then cam.scaleAdjust = 0 end
end

function reinitSize()
    -- Reinitialize everything
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    setScale()
    font = love.graphics.newFont("res/font/font.ttf", 18*scale)
end

function loadNewMap(isD,mapPath, mapID, music,first,t,t2,t3,t4)
    if isD then
        dark = true
    else
        dark = false
    end

    --nil music handle
    if music == nil then
        music = 'res/audio/music/mute.ogg' --audio file with no sound
    end
    --map load
    if first and music then
       mapM = love.audio.newSource(music,'stream')
    end
    --level dialogue
    if t then
        text = t
    end
    if t2 then
        text2 = t2
    end
    if t3 then
        text3 = t3
    end
    if t4 then
        text4 = t4
    end

    --map id
    mapI = mapID
    if mapM:isPlaying() then
        mapM:stop()
    end

    if music then
        mapM = love.audio.newSource(music, "stream")
        mapM:setLooping(true)
        mapM:play()
    end
    -- Destroy existing colliders

    if not first then
    for i, wall in ipairs(walls) do
        if wall:isDestroyed() == false then
            wall:destroy()
        end
    end

    for i, wc in ipairs(wcs) do
        if wc:isDestroyed() == false then
            wc:destroy()
        end
    end

    for i, gc in ipairs(gcs) do
        if gc:isDestroyed() == false then
            gc:destroy()
        end
    end

    for i, talk in ipairs(talks) do
        if talk:isDestroyed() == false then
            talk:destroy()
        end
    end

    for i, talk2 in ipairs(talks2) do
        if talk2:isDestroyed() == false then
            talk2:destroy()
        end
    end

    for i, talk3 in ipairs(talks3) do
        if talk3:isDestroyed() == false then
            talk3:destroy()
        end
    end

    for i, talk4 in ipairs(talks4) do
        if talk4:isDestroyed() == false then
            talk4:destroy()
        end
    end

    for i, enem in ipairs(ene) do
        if enem:isDestroyed() == false then
            enem:destroy()
        end
    end

    for i, ch in ipairs(che) do
        if ch:isDestroyed() == false then
            ch:destroy()
        end
    end

    for i, wate in ipairs(wat) do
        if wate:isDestroyed() == false then
            wate:destroy()
        end
    end

    for i, ewate in ipairs(ewat) do
        if ewate:isDestroyed() == false then
            ewate:destroy()
        end
    end

    for i, wen in ipairs(we) do
        if wen:isDestroyed() == false then
            wen:destroy()
        end
    end

    for i, wst in ipairs(ws) do
        if wst:isDestroyed() == false then
            wst:destroy()
        end
    end

    for i, cm in ipairs(cma) do
        if cm:isDestroyed() == false then
            cm:destroy()
        end
    end

    for i, cm2 in ipairs(cma2) do
        if cm2:isDestroyed() == false then
            cm2:destroy()
        end
    end

    for i, cm3 in ipairs(cma3) do
        if cm3:isDestroyed() == false then
            cm3:destroy()
        end
    end

    for i, cm4 in ipairs(cma4) do
        if cm4:isDestroyed() == false then
            cm4:destroy()
        end
    end

    for i, tree in ipairs(trees) do
        if tree:isDestroyed() == false then
            tree:destroy()
        end
    end
    end

    walls = {}
    ene = {}
    che = {}
    wat = {}
    ewat = {}
    we = {}
    ws = {}
    cma = {}
    cma2 = {}
    cma3 = {}
    cma4 = {}
    talks = {}
    talks2 = {}
    talks3 = {}
    talks4 = {}
    wcs = {}
    gcs = {}
    trees = {}


    -- Load new map
    level = sti(mapPath)

    -- Load new colliders for the new map
    if level.layers and level.layers["coll"] then
        for i, obj in ipairs(level.layers["coll"].objects) do
            wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setCollisionClass("wall")
            wall:setType("static")
            table.insert(walls, wall)
        end
    end

    if level.layers and level.layers["talk"] then
        for i, obj in ipairs(level.layers["talk"].objects) do
            talk = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            talk:setCollisionClass("t")
            talk:setType("static")
            table.insert(talks, talk)
        end
    end

    if level.layers and level.layers["wc"] then
        for i, obj in ipairs(level.layers["wc"].objects) do
            wc = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wc:setCollisionClass("wc")
            wc:setType("static")
            table.insert(wcs, wc)
        end
    end

    if level.layers and level.layers["treeS"] then
        for i, obj in ipairs(level.layers["treeS"].objects) do
            tree = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            tree:setCollisionClass("tree")
            tree:setType("static")
            table.insert(trees, tree)
        end
    end

    if level.layers and level.layers["gc"] then
        for i, obj in ipairs(level.layers["gc"].objects) do
            gc = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            gc:setCollisionClass("gc")
            gc:setType("static")
            table.insert(gcs, gc)
        end
    end

    if level.layers and level.layers["talk2"] then
        for i, obj in ipairs(level.layers["talk2"].objects) do
            talk2 = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            talk2:setCollisionClass("t2")
            talk2:setType("static")
            table.insert(talks2, talk2)
        end
    end

     if level.layers and level.layers["talk3"] then
        for i, obj in ipairs(level.layers["talk3"].objects) do
            talk3 = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            talk3:setCollisionClass("t3")
            talk3:setType("static")
            table.insert(talks3, talk3)
        end
    end

    if level.layers and level.layers["talk4"] then
        for i, obj in ipairs(level.layers["talk4"].objects) do
            talk4 = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            talk4:setCollisionClass("t4")
            talk4:setType("static")
            table.insert(talks4, talk4)
        end
    end

    if level.layers and level.layers["ene"] then
        for i, obj in ipairs(level.layers["ene"].objects) do
            enem = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            enem:setCollisionClass("ene")
            enem:setFixedRotation(true)
            enem:setMass(30) -- Set initial mass
            enem.h = obj.properties.h
            enem.hC = false
            enem.hT = 0
            enem.rT = 1
            enem.state = idle
            enem:setPostSolve(function(collider, other, contact, normalimpulse, tangentimpulse)
            local vx, vy = collider:getLinearVelocity()
            collider:setLinearVelocity(0, 0)  -- Stop dynamic collider from being pushed
    end)
            table.insert(ene, enem)
        end
    end

    if level.layers and level.layers["ch"] then
        for i, obj in ipairs(level.layers["ch"].objects) do
            ch = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            ch:setCollisionClass("ch")
            ch:setType("static")
            ch.o = obj.properties.open
            table.insert(che, ch)
        end
    end
    
	for i, chest in ipairs(che) do
		if not chestStates[chest] then
			if not isOpen[mapID][i] then
				chestStates[chest] = 0
			else
				chestStates[chest] = 1	
			end            
        	end
    	end

    if level.layers and level.layers["water"] then
        for i, obj in ipairs(level.layers["water"].objects) do
            wate = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wate:setCollisionClass("wa")
            wate:setType("static")
            table.insert(wat, wate)
        end
    end

    if level.layers and level.layers["ewater"] then
        for i, obj in ipairs(level.layers["ewater"].objects) do
            ewate = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            ewate:setCollisionClass("ewa")
            ewate:setType("static")
            table.insert(ewat, ewate)
        end
    end

    if level.layers and level.layers["we"] then
        for i, obj in ipairs(level.layers["we"].objects) do
            wen = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wen:setCollisionClass("we")
            wen:setType("static")
            table.insert(we, wen)
        end
    end

    if level.layers and level.layers["ws"] then
        for i, obj in ipairs(level.layers["ws"].objects) do
            wst = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wst:setCollisionClass("ws")
            wst:setType("static")
            table.insert(ws, wst)
        end
    end

    if level.layers and level.layers["cm"] then
        for i, obj in ipairs(level.layers["cm"].objects) do
            cm = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            cm:setCollisionClass("cm")
            cm:setType("static")
            table.insert(cma, cm)
        end
    end
    if level.layers and level.layers["cm2"] then
        for i, obj in ipairs(level.layers["cm2"].objects) do
            cm2 = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            cm2:setCollisionClass("cm2")
            cm2:setType("static")
            table.insert(cma2, cm2)
        end
    end
    if level.layers and level.layers["cm3"] then
        for i, obj in ipairs(level.layers["cm3"].objects) do
            cm3 = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            cm3:setCollisionClass("cm3")
            cm3:setType("static")
            table.insert(cma3, cm3)
        end
    end
    if level.layers and level.layers["cm4"] then
        for i, obj in ipairs(level.layers["cm4"].objects) do
            cm4 = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            cm4:setCollisionClass("cm4")
            cm4:setType("static")
            table.insert(cma4, cm4)
        end
    end
end
function makecollclass()
    world:addCollisionClass("wall")
    world:addCollisionClass("we")
    world:addCollisionClass("ws")
    world:addCollisionClass("ch")
    world:addCollisionClass("wa")
    world:addCollisionClass("ewa")
    world:addCollisionClass("cm")
    world:addCollisionClass("cm2")
    world:addCollisionClass("cm3")
    world:addCollisionClass("cm4")
    world:addCollisionClass("t")
    world:addCollisionClass("t2")
    world:addCollisionClass("t3")
    world:addCollisionClass("t4")
    world:addCollisionClass("wc")
    world:addCollisionClass('gc')
    world:addCollisionClass('tree')
    world:addCollisionClass("ene", {ignores = {"ws", "we", "cm", "cm2", "cm3", "cm4","t","t2","t3",'t4','ewa'}})
end

function upPLI()
    if pl.d == 'up' then
        pl.dir = pl.ani.up
    end
    if pl.d == 'down' then
        pl.dir = pl.ani.down
    end
    if pl.d == 'left' then
        pl.dir = pl.ani.left
    end
    if pl.d == 'right' then
        pl.dir = pl.ani.right
    end
end

function water()
    co = world:queryRectangleArea(pl.coll:getX(), pl.coll:getY(), 16, 16, {"wa"})
        if #co > 0 and pl.swim == false then
            pl.swim = true
            pl.s = 100
            pl.run = false
            pl.splashBSE:play()
            pl.ani.up = pl.ani.swimU
            pl.ani.down = pl.ani.swimD
            pl.ani.left = pl.ani.swimL
            pl.ani.right = pl.ani.swimR
            pl.dir:draw(pl.SS, pl.coll:getX(), pl.coll:getY() - 18, nil, 4, nil, 6, 9)
        end
        co = world:queryRectangleArea(pl.coll:getX(), pl.coll:getY(), 16, 16, {"ewa"})
        if #co > 0 and pl.swim == true then
            pl.swim = false
            pl.s = 200
            pl.splashMSE:stop()
            pl.splashBSE:stop()
            pl.ani.up = pl.ani.walkU
            pl.ani.down = pl.ani.walkD
            pl.ani.left = pl.ani.walkL
            pl.ani.right = pl.ani.walkR
            pl.dir:draw(pl.SS, pl.coll:getX(), pl.coll:getY() - 18, nil, 4, nil, 6, 9)
    end
end

function beforePlayer(layer,image,oY,x,y,scale,coll)
	 if level.layers[layer] then
                local dr = image

		if not oY or oY == 'def' then oY = 7 end

                if coll:getY() + oY <= pl.coll:getY() then
                    love.graphics.draw(
                        dr,
                        coll:getX() - x,
                        coll:getY() - y,
                        nil,
                        scale
                    )
                end
            end
end


function afterPlayer(layer,image,oY,x,y,scale,coll)
	 if level.layers[layer] then
                local dr = image

		if not oY or oY == 'def' then oY = 7 end

                if coll:getY() + oY > pl.coll:getY() then
                    love.graphics.draw(
                        dr,
                        coll:getX() - x,
                        coll:getY() - y,
                        nil,
                        scale
                    )
                end
            end
end