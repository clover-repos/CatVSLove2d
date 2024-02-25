--init bugspray
chestStates = {}
--Test
function love.load()
    --SudoRandomSetup
    math.randomseed(os.time())
    --Declare and import stuff
    require("lib/func") --Imports extra functions
    makeVars() --Declear more stuff
    isOpen = {}
    ImP = false

    isOpen[1] = {}
    isOpen[2] = {}
    isOpen[2.5] = {}
    isOpen[3] = {}
    isOpen[5] = {}

    --setup some imports
    cam = came()
    world = wf.newWorld(0, 0)

    --collisionClassIds
    makecollclass()
    firstFramwS = true

    --load
    pl:load()

    --devmode
    devmode = true

    if devmode == true then
        pl.hasSword = true
    end
    --chest and slime images
    chestSS = love.graphics.newImage("res/tile/chest.png")
    chestG = ani.newGrid(16, 16, chestSS:getWidth(), chestSS:getHeight())

    slimeSS = love.graphics.newImage("res/ent/ene/slime.png")
    slimeG = ani.newGrid(16, 16, slimeSS:getWidth(), slimeSS:getHeight())
    slimeL = ani.newAnimation(slimeG("1-3", 1), 0.15)
    slimeA = ani.newAnimation(slimeG("1-3", 1), 0.18 / (3 / 2))
    idleAn = ani.newAnimation(slimeG("4-5", 1), 0.18)
    slimeD = ani.newAnimation(slimeG("6-8", 1), 0.25)

    deaT = 0.50

    cheststate = {}
    cheststate.state0 = ani.newAnimation(chestG("1-1", 1), 0.25)
    cheststate.state1 = ani.newAnimation(chestG("2-2", 1), 0.50)
    chestI = cheststate.state0

    --titlescreen theme
    t = love.audio.newSource("res/audio/music/title.ogg", "stream")
    t:setLooping(true)
    t:play()
    if devmode == true then
        t:setVolume(0)
    end

    --fullscreen
    setWindowSize(true, 1920, 1080)
    setScale()
    font = love.graphics.newFont("res/font/font.ttf", 18 * scale)
end

function love.update(dt)
    publicDT = dt

    if mapI then
        if mapI == 1 then isOpenI = 1 end
        if mapI == 2 then isOpenI = 2 end
        if mapI == 2.5 then isOpenI = 3 end
        if mapI == 3 then isOpenI = 4 end
        if mapI == 5 then isOpenI = 5 end
    end

    w = love.graphics.getWidth()
    h = love.graphics.getHeight()
    if ImP == false then
        if level then
            level:update(publicDT)
        end
        if gs.state == gs.death then
            if deathT < 0.16667 then
                deathT = deathT + publicDT
            end
            if deathT >= 0.16667 then
                deathT = 0
                gs.state = gs.pls
            end
        end

        if cr == true then
            crt = crt + publicDT --dt
            if crt >= 0.16667 * 2 then
                cr = false
                crt = 0
            end
        end

        if gs.state == gs.pls then
            slimeL:update(dt)
            slimeA:update(dt)
            idleAn:update(dt)
            for i, enem in ipairs(ene) do
                if enem.dying == true and enem:isDestroyed() == false then
                    slimeD:update(dt)
                end
            end
            slimeD:update(dt)
            if pl.useSword == true then
                if swordT < 0.125 and firstFramwS == true then
                    firstFramwS = false
                    if pl.d == "up" then end
                    
                    if pl.d == "down" then end
                    
                    if pl.d == "left" then end
                    
                    if pl.d == "right" then end
                end

                if swordT < 0.125*3 then
                    swordT = swordT + publicDT --dt
                end
                if swordT >= 0.125*3 then
                    pl.useSword = false
                    swordT = 0
                    if pl.swim == false then
                        pl.ani.up = pl.ani.walkU
                        pl.ani.down = pl.ani.walkD
                        pl.ani.left = pl.ani.walkL
                        pl.ani.right = pl.ani.walkR
                    end
                    upPLI()
                    sw:destroy()
                    pl.ani.swordU:gotoFrame(1)
                    pl.ani.swordD:gotoFrame(1)
                    pl.ani.swordL:gotoFrame(1)
                    pl.ani.swordR:gotoFrame(1)
                    firstFramwS = true
                    pl.dir:gotoFrame(1)
                end
            end

            if pl.cH > pl.mH then
                pl.cH = pl.mH
            end

            if reH == true and gs.state == gs.pls then
                pl.cH = pl.mH
                reH = false
            end

            if pl.cH <= 0 then
                gs.state = gs.ds
                cd = "You died... But for testing I'll \ngive your health back."
                reH = true
            end

            TS = level.tileheight
            mW = level.width * TS
            mH = level.height * TS

            pl:update(publicDT)
            pl.dir:update(dt)

            local co = world:queryRectangleArea(pl.coll:getX(), pl.coll:getY(), 16, 16, {"ws"})
            if #co > 0 and not waterfall:isPlaying() then
                waterfall:play()
            end
            co = world:queryRectangleArea(pl.coll:getX(), pl.coll:getY(), 16, 16, {"we"})
            if #co > 0 and waterfall:isPlaying() then
                waterfall:stop()
            end

            water()
            pl.InviColl() --If player is swiming or not he then can go through some colliders.

            if love.keyboard.isDown("x") then
                local px, py = pl.coll:getPosition()

                if pl.dir == pl.ani.right then
                    px = px + 30
                elseif pl.dir == pl.ani.left then
                    px = px - 30
                elseif pl.dir == pl.ani.up then
                    py = py - 30
                elseif pl.dir == pl.ani.down then
                    py = py + 30
                end

                -- Check for chests
                local co = world:queryCircleArea(px, py, 15, {"ch"})
                for _, collider in ipairs(co) do
                    if chestStates[collider] == 0 then
                        if pl.dir == pl.ani.up then
                            chestStates[collider] = 1
                            for i, obj in ipairs(level.layers["ch"].objects) do
                                if obj.name == "sw" then
                                    gs.state = gs.ds
                                    cd = "You found the sword!.. So...\n...Um."
                                    pl.hasSword = true
                                    if not gsSE:isPlaying() then
                                        gsSE:play()
                                    end
                                elseif obj.name == "swL" then
                                    gs.state = gs.ds
                                    cd = 'It\'s a paper! It says, "Go down \nthe stairs!"'
                                else
                                    gs.state = gs.ds
                                    cd = "Nothing."
                                end
                            end
                        else
                            pl.sh = true
                        end
                    end
                end

                if pl.dir == pl.ani.right then
                    px = px - 30
                elseif pl.dir == pl.ani.left then
                    px = px + 30
                elseif pl.dir == pl.ani.up then
                    py = py + 30
                elseif pl.dir == pl.ani.down then
                    py = py - 30
                end

                co = world:queryCircleArea(px, py, 15, {"t"})
                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text
                end

                co = world:queryCircleArea(px, py, 15, {"t2"})
                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text2
                end

                co = world:queryCircleArea(px, py, 15, {"t3"})
                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text3
                end
                co = world:queryCircleArea(px, py, 15, {"t4"})
                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text4
                end
            end

            world:update(publicDT)

            --change map
            co = world:queryCircleArea(pl.coll:getX(), pl.coll:getY(), 20, {"cm"})        
	if #co > 0 and mapT <= 0 and m == true then
		if mapI == 1 then
                    loadNewMap(true, "res/levels/map2.lua", 2, "res/audio/music/WM.ogg")
                    pl.swim = false
                    pl.run = false
                    pl.s = 200
                    pl.ani.up = pl.ani.walkU
                    pl.ani.down = pl.ani.walkD
                    pl.ani.left = pl.ani.walkL
                    pl.ani.right = pl.ani.walkR
                    upPLI()

                    pl.coll:setPosition(mW / 2 + mW / 8 + 50, mH - (140 * 5))

                    if waterfall:isPlaying() then
                        waterfall:pause()
                    end
                elseif mapI == 2 then
                    loadNewMap(
                        nil,
                        "res/levels/map.lua",
                        1,
                        "res/audio/music/mute.ogg",
                        nil,
                        "<- Village ahead!",
                        "Dungeon soon!"
                    )
                    if not waterfall:isPlaying() then
                        waterfall:play()
                    end
                    pl.coll:setPosition(TS * 15, TS * 3)
                elseif mapI == 3 then
                    loadNewMap(
                        nil,
                        "res/levels/house1.lua",
                        5,
                        nil,
                        nil,
                        " ................ \n It's not nice to check others stuff!",
                        "Meow!... Check out my show on \nYouTube '@CatVSDog.'!"
                    )
                    pl.coll:setPosition(TS * 17 + TS / 2, TS * 24 + TS / 2)

                    if waterfall:isPlaying() then
                        waterfall:pause()
                    end
                elseif mapI == 5 then
                    loadNewMap(nil, "res/levels/map3.lua", 3, "res/audio/music/mute.ogg")
                    pl.coll:setPosition(TS * 18 + TS / 2, TS * 12 + TS / 2)

                    if waterfall:isPlaying() then
                        waterfall:pause()
                    end
                end
                mapT = 1.5
            end

            co = world:queryCircleArea(pl.coll:getX(), pl.coll:getY(), 20, {"cm2"})     
	if #co > 0 and m == true then --dt
                if mapT <= 0 then
                    if mapI == 1 then
                        loadNewMap(nil, "res/levels/map3.lua", 3, "res/audio/music/mute.ogg")
                        pl.coll:setPosition(mW - TS / 2, mH / 2 + TS * 3)
                    elseif mapI == 2 then
                        loadNewMap(true, "res/levels/map2.5.lua", 2.5, "res/audio/music/WM.ogg")
                        pl.coll:setPosition(mW - TS / 2, mH / 2 + 16)
                    elseif mapI == 2.5 then
                        loadNewMap(true, "res/levels/map2.lua", 2, "res/audio/music/WM.ogg")
                        pl.coll:setPosition(mW / 3, mH / 2 + TS * 3)
                    elseif mapI == 3 then
                        loadNewMap(
                            nil,
                            "res/levels/map.lua",
                            1,
                            "res/audio/music/mute.ogg",
                            nil,
                            "<- Village ahead!",
                            "Dungeon soon!"
                        )
                        pl.coll:setPosition(TS / 2, mH / 2 + mH / 10)
                    end
                    mapT = 1.5
                end
            end

            if mapT > 0 then
                mapT = mapT - publicDT --dt
            end

            if level.layers["ene"] then
                local px = pl.coll:getX()
                local py = pl.coll:getY()
                es = 180
                e = world:queryCircleArea(px, py, 200, {"ene"})
                for i, enem in ipairs(e) do
                    if enem:isDestroyed() == false and enem.hC == false then
                        exV = 0
                        eyV = 0
                        ex = enem:getX()
                        ey = enem:getY()

                        if #e > 0 and not enem.isDying == true then
                            if enem.state == idle then
                                enem.state = attack
                                enem.idleA = false
                            end

                            if ex < px then
                                exV = es
                            end

                            if ex > px then
                                exV = -es
                            end

                            if ex == px then
                                exV = 0
                            end

                            if ey < py then
                                eyV = es
                            end

                            if ey > py then
                                eyV = -es
                            end

                            if ey == py then
                                eyV = 0
                            end

                            local sL = 0.7073

                            if exV ~= 0 and eyV ~= 0 then
                                exV = exV * sL
                                eyV = eyV * sL
                            end

                            enem:setLinearVelocity(exV, eyV)
                        end
                    end
                end
                for i, enem in ipairs(ene) do
                    if enem.isDying == true and enem:isDestroyed() == false then
                        enem.lastMoments = enem.lastMoments - publicDT
                        if enem.lastMoments <= 0 then
                            enem:destroy()
                            slimeD:gotoFrame(1)
                        end
                    end
                    if enem.s then
                    end
                    if #e == 0 then
                        if enem:isDestroyed() == false then
                            if enem.state == attack or enem.hC == true then
                                enem.state = idle
                                enem.rT = 0.000001
                                enem:setLinearVelocity(0, 0)
                            end

                            enem.rT = enem.rT - publicDT --dt

                            if enem.rT <= 0 then
                                local EX = math.random(3)
                                local EY = math.random(3)

                                if EX < 2 then
                                    EX = -es
                                elseif EX < 2.5 then
                                    EX = es
                                else
                                    EX = 0
                                end

                                if EY < 2 then
                                    EY = -es
                                elseif EY < 2.5 then
                                    EY = es
                                else
                                    EY = 0
                                end

                                if EY == 0 and EX == 0 then
                                    enem.idleA = true
                                else
                                    enem.idleA = false
                                end

                                local sL = 0.7073

                                if EX ~= 0 and EY ~= 0 then
                                    EX = EX * sL
                                    EY = EY * sL
                                end

                                enem:setLinearVelocity(EX, EY)
                                enem.rT = 0.9
                            end
                        end
                    end
                end
            end
        end
        if gs.state == gs.ds then
            if currentCharIndex < #cd then
                local char = cd:sub(currentCharIndex + 1, currentCharIndex + 1)
                currentCharIndex = currentCharIndex + 1
		if char == ',' or char == '.' then
			love.timer.sleep(pauseDelay)
		else	
			love.timer.sleep(charDelay)		
		end
                if char ~= " " then
                    talkSE:play()
                end
            else
                if dst < 1 / 5 then
                    dst = dst + publicDT
                end
                if dst >= 1 / 5 then
                    if love.keyboard.isDown("x") then
                        love.graphics.setLineWidth(1)
                        gs.state = gs.pls
                        dst = 0
                        cr = true
                        currentCharIndex = 0
                        pl.dir = pl.ani.down
                        pl.d = "down"
                    end
                end
            end
        end
    end
    if ImP == true then
        ImT = ImT - publicDT
        if ImT <= 0 then
            ImP = false
        end
    end
    reinitSize()
end

function love.draw()
    love.graphics.setFont(font)
    upPLI()

    if gs.state == gs.pls or gs.state == gs.ps or gs.state == gs.trs or gs.state == gs.ds or gs.state == gs.death then
        cam:update()

        cam:attach()

        level:drawLayer(level.layers["ground"])
        level:drawLayer(level.layers["ground2"])
        level:drawLayer(level.layers["tree2"])
        if pl.swim == false then
            level:drawLayer(level.layers["swimU"])
        end

        for i, obj in ipairs(level.layers["ch"].objects) do
            local chest = che[i]
            if chestStates[chest] == 0 then
                chestI = cheststate.state0
            elseif chestStates[chest] == 1 then
                chestI = cheststate.state1
                isOpen[mapI][i] = true
            end
            chestI = chestStates[chest] == 0 and cheststate.state0 or cheststate.state1
            chestI:draw(chestSS, obj.x, obj.y, nil, 4)
        end

        if level.layers["ene"] then
            for i, enem in ipairs(ene) do
                if enem:isDestroyed() == false then
                    if enem.state == idle then
                        enem.s = slimeL
                    elseif enem.state == attack then
                        enem.s = slimeA
                    end
                    if enem.idleA == true then
                        enem.s = idleAn
                    end
                    if enem.isDying == true then
                        enem.s = slimeD
                    end

                    local x, y = enem:getPosition()
                    if enem.hC == true then
                        love.graphics.setColor(255, 0, 0, 0.9)
                        if gs.state == gs.pls then
                            enem.hT = enem.hT + publicDT --dt
                        end
                    end
                    enem.s:draw(slimeSS, x - 8 * 4, y - 8 * 5, nil, 3.9)
                    if enem.hT >= 1 / 6 then
                        enem.hT = 0
                        enem.hC = false
                        enem:setLinearVelocity(0, 0)
                    end

                    love.graphics.setColor(255, 255, 255)
                end
            end
        end

	for i, tree in ipairs(trees) do
        	beforePlayer("treeS",treeI,nil,treeI:getWidth()*(3.8/2),treeI:getHeight()*3,3.8,tree)
	end

        if isH == true then
            love.graphics.setColor(255, 0, 0, 0.4)
        end

        pl.shD()
        pl:draw()

        love.graphics.setColor(255, 255, 255)
	
	for i, tree in ipairs(trees) do
        	afterPlayer("treeS",treeI,nil,treeI:getWidth()*(3.8/2),treeI:getHeight()*3,3.8,tree)
	end

        if pl.swim == true then
            level:drawLayer(level.layers["swimU"])
        end

        level:drawLayer(level.layers["tree"])

        if drawworld == true and devmode == true then
            world:draw()
        end

        cam:detach()

        if dark == true then
        --Shader code rewrite soon! why Glsl!!!! :(
        end
        love.graphics.push()
        love.graphics.scale(4 * scale, 4 * scale)
        for i = 1, pl.mH do
            local HS = HF
            local HW = HS:getWidth()

            if i > pl.cH then
                HS = HE
            end
            if pl.cH - i == -0.5 then
                HS = HH
            end
            local OF = (i - 1) * HW
            love.graphics.draw(HS, 2 / 4 + OF, 2 / 4)
        end
        love.graphics.pop()
    end

    if gs.state == gs.death then
        love.graphics.setColor(255, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(255, 255, 255)
    end

    if gs.state == gs.ps then
        psT = "Paused!"
        ox = psT:len() * 5 * scale
        love.graphics.print(psT, w / 2 - ox, h / 2)
    end
    if gs.state == gs.ts then
        tsT = "Press 'Enter'!"
        ox = tsT:len() * 5 * scale
        love.graphics.print(tsT, w / 2 - ox, h / 2)
    end
    if gs.state == gs.ds then
        i = w / 10
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", i, h - 128 * 2 - 10, w - (i * 2), 128 * 2, 60)
        love.graphics.setLineWidth(10)
        love.graphics.setColor(255, 255, 255, 0.8)
        love.graphics.rectangle("fill", i, h - 128 * 2 - 10, w - (i * 2), 128 * 2, 60)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(cd:sub(1, currentCharIndex), w / 8, h - 110 * 2)
        love.graphics.setColor(255, 255, 255)
    end
end

function love.keyreleased(key)
    if gs.state == gs.pls then
        if key == "z" and pl.swim == false then
            pl.s = 200
            pl.run = false
            pl.ani.up = pl.ani.walkU
            pl.ani.down = pl.ani.walkD
            pl.ani.left = pl.ani.walkL
            pl.ani.right = pl.ani.walkR
            upPLI()
        end
        if pl.hasSword == true and pl.useSword == false then
            if key == "x" and pl.swim == false then
                pl.useSword = true
                pl.ani.up = pl.ani.swordU
                pl.ani.down = pl.ani.swordD
                pl.ani.left = pl.ani.swordL
                pl.ani.right = pl.ani.swordR
                upPLI()
                pl.swipe:play()

                if pl.d == "up" then
                    sw = world:newRectangleCollider(pl.coll:getX() - 20, pl.coll:getY() - 50, 10, 40)
                elseif pl.d == "down" then
                    sw = world:newRectangleCollider(pl.coll:getX() - 20, pl.coll:getY() + 10, 10, 40)
                elseif pl.d == "left" then
                    sw = world:newRectangleCollider(pl.coll:getX() - 65, pl.coll:getY() - 15, 40, 10)
                elseif pl.d == "right" then
                    sw = world:newRectangleCollider(pl.coll:getX() + 25, pl.coll:getY() - 10, 40, 10)
                end

                local sqx = 0
                local sqy = 0

                if pl.d == "up" or pl.d == "down" then
                    sqx = 5
                    sqy = 20

                    swordColliders = world:queryRectangleArea(sw:getX() - sqx, sw:getY() - sqy, 10, 40, {"ene"})
                else
                    sqx = 20
                    sqy = 5

                    swordColliders = world:queryRectangleArea(sw:getX() - sqx, sw:getY() - sqy, 40, 10, {"ene"})
                end

                for _, enem in ipairs(swordColliders) do
                    if enem.h and enem.h > 0 then
                        enem.h = enem.h - 1
                        hSE:play()
                        enem.hC = true
                        enem.state = idle

                        if pl.d == "up" then
                            enem:setLinearVelocity(0, -500)
                        end
                        if pl.d == "down" then
                            enem:setLinearVelocity(0, 500)
                        end
                        if pl.d == "left" then
                            enem:setLinearVelocity(-500, 0)
                        end
                        if pl.d == "right" then
                            enem:setLinearVelocity(500, 0)
                        end

                        pl.sh = true
                        shakeDuration = 0.1

                        if enem.h <= 0 then
                            enem.isDying = true
                            enem.lastMoments = deaT
                            pl.sh = true
                            shakeDuration = 0.25
                            ImP = true
                            ImT = 0.1
                        end
                    end
                end

                sw:setType("static")

                sw:setFixedRotation(true)
                sw:setCollisionClass("sw")
            end
        end

        if key == "space" then
            if drawworld == false then
                drawworld = true
            else
                drawworld = false
            end
        end
    end
    if key == "f11" then
        if full == true then
            full = false
            setWindowSize(nil, 800, 600)
        else
            full = true
            setWindowSize(true, 1920, 1080)
        end
    end --FIXED!
    if gs.state == gs.pls or gs.state == gs.ps then
        if key == "return" then
            if gs.state == gs.pls then
                gs.state = gs.ps

                if waterfall:isPlaying() then
                    rW = true
                    waterfall:pause()
                end

                if pl.splashBSE:isPlaying() then
                    rSB = true
                    pl.splashBSE:pause()
                end

                if pl.splashMSE:isPlaying() then
                    rSM = true
                    pl.splashMSE:pause()
                end

                if mapM:isPlaying() then
                    mM = true
                    mapM:pause()
                end
            elseif gs.state == gs.ps then
                gs.state = gs.pls

                if rW == true then
                    waterfall:play()
                    rW = false
                end

                if rSB == true then
                    pl.splashBSE:play()
                    rSB = false
                end

                if rSM == true then
                    pl.splashMSE:play()
                    rSM = false
                end

                if mM == true then
                    mapM:play()
                    mM = false
                end

                if pl.run == true then
                    pl.run = false
                    pl.ani.up = pl.ani.walkU
                    pl.ani.down = pl.ani.walkD
                    pl.ani.left = pl.ani.walkL
                    pl.ani.right = pl.ani.walkR
                    pl.s = 200
                    upPLI()
                end
            end
        end
    end
    if gs.state == gs.ts then
        if key == "return" then
            gs.state = gs.pls
            if t:isPlaying() then
                t:stop()
                loadNewMap(
                    nil,
                    "res/levels/map.lua",
                    1,
                    "res/audio/music/mute.ogg",
                    true,
                    "<- Village ahead!",
                    "Dungeon soon!"
                )
            end
        end
    end
end