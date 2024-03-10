--init bugspray
chestStates = {}
--Test
function mapIDTable(tablename)
    tablename[1] = {}
    tablename[2] = {}
    tablename[2.5] = {}
    tablename[3] = {}
    tablename[5] = {}
end

function love.load()
    math.randomseed(os.time())

    placeholder = 'Error404 no text found.' --Placeholder text so the game does not crash if you put nothing in.


    cheat = love.graphics.newImage('res/gfx/cheat.jpg')


    --Declare and import stuff
    require("src/firststart/startup") --Imports extra functions
    makeVars() --Declear more stuff
    isOpen = {}
    ImP = false

    targetFPS = 60
    updateTime = 1 / targetFPS
    frame = 0

    mapIDTable(isOpen)

    --setup some imports
    cam = came()
    world = wf.newWorld(0, 0)

    --collisionClassIds
    makecollclass()
    firstFramwS = true

    --load
    pl:load()

    pl.noct = 0

    cheating = false

    --devmode
    if arg[2] == 'devmode' and arg[1] == '/home/catvsdog/lovegame/' then
        devmode = true
    elseif arg[2] == 'devmode' and arg[1] ~= '/home/catvsdog/lovegame/' or arg[2] == 'cheat' and '/home/catvsdog/lovegame/' then
        cheating = true
    end

    if devmode == true then
        pl.hasSword = true
    end
    --chest and slime images
    chestSS = love.graphics.newImage("res/tile/chest.png")
    chestG = ani.newGrid(16, 16, chestSS:getWidth(), chestSS:getHeight())

    slimeLoad()

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
    font = love.graphics.newFont("res/font/font.ttf", 43*scalew)
end

function love.update(dt)
    publicDT = dt

    frame = frame + dt

    if frame >= 20 then
        collectgarbage('collect')
        frame = 0
    end

    if level then
        TS = level.tileheight
        mW = level.width * TS
        mH = level.height * TS
    end

    if mapI then
        if mapI == 1 then isOpenI = 1 end
        if mapI == 2 then isOpenI = 2 end
        if mapI == 2.5 then isOpenI = 3 end
        if mapI == 3 then isOpenI = 4 end
        if mapI == 5 then isOpenI = 5 end
    end

    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    cheatW =  w / cheat:getWidth()
    cheatH =  h / cheat:getHeight()


    if ImP == false then
        if gs.state == gs.ps then
            if randomVar == nil then
                randomVar = 0
            end

            randomVar = randomVar + 1
            if randomVar > 100 then
                randomVar = 0
            end
        end

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

            if pl.useSword == true then
                if swordT < 0.125 and firstFramwS == true then
                    firstFramwS = true
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
                cd = "You died... But for testing I'll give your health back."
                reH = true
            end

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
                                    cd = "You found a sword! You can now kill enemys."
                                    pl.hasSword = true
                                    if not gsSE:isPlaying() then
                                        gsSE:play()
                                    end
                                elseif obj.name == "swL" then
                                    gs.state = gs.ds
                                    cd = 'It\'s a paper! It says, "Go down \nthe stairs!"'
                                else
                                    gs.state = gs.ds
                                    cd = "Ehh, ... nothing?!"
                                end
                            end
                        else
                            pl.sh = true
                        end
                    end
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
                        placeholder,
                        "Meow!... Check out my show on YouTube '@CatVSDog.'!"
                    )
                    pl.coll:setPosition(TS * 17 + TS / 2, TS * 24 + TS / 2)

                    if waterfall:isPlaying() then
                        waterfall:pause()
                    end
                elseif mapI == 5 then
                    loadNewMap(nil, "res/levels/map3.lua", 3, "res/audio/music/mute.ogg")
                    pl.coll:setPosition(TS * 18 + TS / 2 - TS * 2, TS * 12 + TS / 4 + TS * 3)

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

            slimeUpdate(dt)

             if level then
                TS = level.tileheight
                mW = level.width * TS
                mH = level.height * TS
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
    love.timer.sleep(updateTime)
end

function love.draw()
    if level then
        cam:update()
    end

    love.graphics.setFont(font)
    upPLI()

    if gs.state == gs.pls or gs.state == gs.ps or gs.state == gs.trs or gs.state == gs.ds or gs.state == gs.death then
        cam:attach()

        if level.layers['par'] and level.layers['par'].properties.par < 1.0 then
            level:drawLayer(level.layers['par'])
        end

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

        slimeDraw()

        co = world:queryCircleArea(pl.coll:getX(),pl.coll:getY(),100,{"t","t2","t3",'t4'})

        if #co > 0 then
            for i, coll in ipairs(co) do
                beforePlayer(talkI,-25,talkI:getWidth()*2,talkI:getHeight()*5,4,coll)
            end
        end

	for i, tree in ipairs(trees) do
        if tree.isBad == true then
            love.graphics.setColor(1,0.8,0.8)
        end
        if tree.flT then
            if tree.flT > 0 then
                if gs.state == gs.pls then
                    tree.flT = tree.flT - publicDT
                end
                love.graphics.setColor(0.5,0,0)
            end
        end
        beforePlayer(treeI,nil,treeI:getWidth()*(4.1/2),treeI:getHeight()*3.3,4.1,tree)
        love.graphics.setColor(255,255,255)
	end


        if isH == true then
            love.graphics.setColor(255, 0, 0, 0.4)
        end

        pl.shD()
        pl:draw()

        love.graphics.setColor(255, 255, 255)

        co = world:queryCircleArea(pl.coll:getX(),pl.coll:getY(),100,{"t","t2","t3",'t4'})

        if #co > 0 then
            for i, coll in ipairs(co) do
                --love.graphics.draw()
                afterPlayer(talkI,-25,talkI:getWidth()*2,talkI:getHeight()*5,4,coll)
            end
        end

	for i, tree in ipairs(trees) do
        if tree.isBad == true then
            love.graphics.setColor(1,0.8,0.8)
        end

        if tree.flT then
            if tree.flT > 0 then
                if gs.state == gs.pls then
                    tree.flT = tree.flT - publicDT
                end
                love.graphics.setColor(0.5,0,0)
            end
        end
        afterPlayer(treeI,nil,treeI:getWidth()*(4.1/2),treeI:getHeight()*3.3,4.1,tree)
        love.graphics.setColor(255,255,255)
	end

        if pl.swim == true then
            level:drawLayer(level.layers["swimU"])
        end

        level:drawLayer(level.layers["tree"])

        if level.layers['par'] and level.layers['par'].properties.par >= 1.0 then
            level:drawLayer(level.layers['par'])
        end

        if drawworld == true and devmode == true then
            world:draw()
        end

        cam:detach()

        if dark == true then
        --Shader code rewrite soon! why Glsl!!!! :( TEST TODO:
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
        drawSubWin(nil,h/10,w - w / 5, h - h/5,60)
    end

    if gs.state == gs.ts then
        tsT = "Press 'Enter'!"
        ox = tsT:len() * 5 * scale
        love.graphics.print(tsT, w / 2 - ox, h / 2)
    end
    if gs.state == gs.ds then
        drawSubWin(nil, h - 265,  w - w/5 , 256 , 60)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(cd:sub(1, currentCharIndex), w / 8, h - 225)
        love.graphics.setColor(255, 255, 255)
    end
    if cheating == true then
        love.graphics.draw(cheat,cheatW,cheatH,nil,cheatW,cheatH)
    end
end

function love.keypressed(key)
    if key == 'x' then
    if gs.state == gs.ds then
        if dst >= 1 / 5 then
            love.graphics.setLineWidth(1)
            gs.state = gs.pls
            dst = 0
            cr = true
            currentCharIndex = 0
        end
    elseif gs.state == gs.pls then
                local px, py = pl.coll:getPosition()

                local co = world:queryCircleArea(px, py, 15, {"t"})

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
                    sw.di = sU
                elseif pl.d == "down" then
                    sw = world:newRectangleCollider(pl.coll:getX() - 20, pl.coll:getY() + 10, 10, 40)
                    sw.di = sD
                elseif pl.d == "left" then
                    sw = world:newRectangleCollider(pl.coll:getX() - 65, pl.coll:getY() - 15, 40, 10)
                    sw.di = sL
                elseif pl.d == "right" then
                    sw = world:newRectangleCollider(pl.coll:getX() + 25, pl.coll:getY() - 10, 40, 10)
                    sw.di = sR
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
                            enem.s = slimeD:clone()
                        end
                    end
                end

                sw:setType("static")

                sw:setFixedRotation(true)
                sw:setCollisionClass("sw")
                if pl.d == "up" or pl.d == "down" then
                    sqx = 5
                    sqy = 20

                    swordColliders = world:queryRectangleArea(sw:getX() - sqx, sw:getY() - sqy, 10, 40, {"tree"})
                else
                    sqx = 20
                    sqy = 5

                    swordColliders = world:queryRectangleArea(sw:getX() - sqx, sw:getY() - sqy, 40, 10, {"tree"})
                end

		if #swordColliders > 0 then
			for i, coll in ipairs(swordColliders) do
                if coll.health == nil then coll.health = 4 end
                    coll.health = coll.health - 1
                    coll.flT = 0.2

                    if coll.health <= 0 then

                        coll:destroy()
                        pl.noct = pl.noct + 1
                    if coll.isBad ~= true then
                        if pl.noct == 1 then
                            gs.state = gs.ds
                            cd = 'Hold up buddy, what about #teamtrees?'
                        elseif pl.noct == 2 then
                            gs.state = gs.ds
                            cd = 'Stop now.'
                        elseif pl.noct == 3 then
                            gs.state = gs.ds
                            cd = 'Last warning!'
                        elseif pl.noct == 4 then
                            gs.state = gs.ds
                            cd = 'I\'m not powerless you know.'

                            spawnSlime(pl.coll:getX(),pl.coll:getY() + TS,100)
                            spawnSlime(pl.coll:getX(),pl.coll:getY() - TS,100)

                            spawnSlime(pl.coll:getX() + TS,pl.coll:getY(),100)
                            spawnSlime(pl.coll:getX() - TS,pl.coll:getY(),100)
                        elseif pl.noct == 5 then
                            gs.state = gs.ds
                            cd = 'I give up.'
                        else
                            --Do nothing.
                        end
                    else
                        gs.state = gs.ds
                        cd = 'That tree looked kinda sus so good job!'
                    end
                    end

                    pl.swipe:stop()
                if coll.health > 0 then
                    if treeCut:isPlaying() then
                        treeCut:stop()
                    end
                        treeCut:play()
                else
                    treeDie:stop()
                    treeDie:play()
                end
            end
        end
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
            setWindowSize(nil, 1000, 700)
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
                love.graphics.setLineWidth(1)

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
        if key == "return" and cheating == false then
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
