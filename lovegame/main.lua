function love.load()
    math.randomseed(os.time())

     --no blur
    love.graphics.setDefaultFilter("nearest", "nearest")

    --Startup file import
    require("src/tools/startup")
    require('src/ent/weps/sword')

    devmode = false

    makeVars() --Declear objects
    startUp() --Finish startup
end

function love.update(dt)
    publicDT = dt

    if publicDT > 0.3 then
      publicDT = 0.3
    end

    if dt > 0.3 then
      dt = 0.3
    end

    playername = 's'

    --world:setGravity(0, 10000)

    timers()
    if ImP == false then
        if gs.state == gs.pls then
            if pl.useSword == true then
                if swordT < 0.125*3 then
                    swordT = swordT + publicDT --dt
                    sword.update()
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
                    pl.dir:gotoFrame(1)
                    pl.s = 200
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
        if gs.state == gs.ds or ds == true then
           if not cd then
            cd = placeholder
           end
            if currentCharIndex < #cd then
                char = cd:sub(currentCharIndex + 1, currentCharIndex + 1)
                currentCharIndex = currentCharIndex + 1
		if char == ',' or char == '.' then
			love.timer.sleep(pauseDelay)
		else
			love.timer.sleep(charDelay)
		end
                if char ~= " " then
                    if talkSE:isPlaying() then
                        talkSE:stop()
                    end

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
end

function love.draw()
    if level then
        cam:update()
        if level.layers['par'] then
            local para = level.layers['par'].properties.par
            level.layers['par'].x = (cam.x / 1.35) * para
            level.layers['par'].y = (cam.y / 1.35) * para
        end
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
        love.graphics.scale(2 * scale, 2 * scale)

        drawSubWin(-10,-10,pl.mH*HF:getWidth()+12,HF:getHeight()+10,1,0.5,9.5,0.9,0.1,0.1)

        if HeartFlashTime > 0 or pl.cH <= 1 then
                HeartFlashTime = HeartFlashTime - publicDT
                HeartFlashing = HeartFlashing - publicDT

                if HeartFull ~= false then
                    love.graphics.setColor(1,1,1,0.5)
                end

                if HeartFlashing <= 0 then
                    HeartFlashing = 0.075
                    if HeartFull ~= false then
                        HeartFull = false
                        love.graphics.setColor(1,0.8,0.8,0.8)
                    else
                        HeartFull = true
                        love.graphics.setColor(1,1,1,1)
                    end
                end
            else
                love.graphics.setColor(1,1,1,0.5)
            end

        for i = 1, pl.mH do
            local HS = HF
            local HW = HS:getWidth()
            local HHE = HS:getHeight()

            if i > pl.cH then
                HS = HE
            end
            if pl.cH - i == -0.5 then
                HS = HH
            end
            local OF = (i - 1) * HW

            love.graphics.draw(HS, 2 / 4 + OF + 0.25, 2 / 4 - 0.5,0,0.9)
        end
        love.graphics.pop()
        love.graphics.setColor(1,1,1,1)
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
        if not t:isPlaying() then
          t = love.audio.newSource("res/audio/music/Slimebackstorymain.mp3", "stream")
          t:setLooping(true)
          t:play()
          if devmode == true then
              t:setVolume(0)
          end
        end


        love.graphics.setColor(0.3, 0.1, 1)
        love.graphics.rectangle('fill', 0, 0, w, h)
        love.graphics.setColor(1, 1, 1)

        --text
        tsT = "Press 'Enter'!"

        if not selectIcon then
            selectIcon = pl.ani.walkR:clone()
        end

        if inputdelayE then
            inputdelayE = inputdelayE - publicDT
            if inputdelayE <= 0 then
              gs.state = gs.pls
              if t:isPlaying() then
                t:stop()
                loadNewMap(
                    nil,
                    "res/levels/map3.lua",
                    3,
                    "res/audio/music/mute.ogg",
                    true,
                    "<- Village ahead!",
                    "Dungeon soon!"
                )
              end
            end
        end

        selectIcon:update(publicDT)

        ox = font:getWidth(tsT)
        oy = font:getHeight(tsT)

        --draw startscreen
        drawSubWin(w / 2 - (ox / 2) - 8, h / 4.5 - (oy / 2) - 4, ox + 8, oy + 4, 1,nil,nil,1,1,1,1,1,1)
        love.graphics.print(tsT, w / 2 - (ox / 2), h / 4.5 - (oy / 2))

        --text
        tsT = "Start!"

        ox = font:getWidth(tsT)
        oy = font:getHeight(tsT)

        --draw startscreen
        selectIcon:draw(pl.SS,w / 2 - (ox / 2) - 16*7.5*scalew, h / 2 - (oy / 2) - 16*6*scalew,nil,6*scalew)
        drawSubWin(w / 2 - (ox / 2) - 8, h / 2 - (oy / 2) - 4, ox + 8, oy + 4, 1,nil,nil,1,1,1,1,1,1)
        love.graphics.print(tsT, w / 2 - (ox / 2), h / 2 - (oy / 2))

        tsT = "Slime Outbreak"

        ox = font:getWidth(tsT)
        oy = font:getHeight(tsT)

        if not colorr then
          colorr = 0
          colorg = 0
          colorb = 0

          crs = 0.8
          cgs = 0.9
          cbs = 0.7
        end
        
        local publicDT = publicDT

        if publicDT > 0.05 then
          publicDT = 0.05
        end

        colorr = colorr + crs * publicDT
        colorg = colorg + cgs * publicDT
        colorb = colorb + cbs * publicDT

        if colorr > 1 or colorr < 0 then
          crs = -crs
        end

        if colorg > 1 or colorg < 0 then
          cgs = -cgs
        end

        if colorb > 1 or colorb < 0 then
          cbs = -cbs
        end

	love.graphics.push()
	love.graphics.scale(2,2)

        drawSubWin(w / 4 - (ox / 2) - 8, h / 32 - (oy / 2) - 8, ox + 8, oy + 4, 1,nil,nil,1,1,1,1,1,1)

        love.graphics.setColor(colorr, colorg, colorb)

        love.graphics.print(tsT, w / 4 - (ox / 2), h / 32 - (oy / 2))

        love.graphics.setColor(1, 1, 1)

        love.graphics.pop()
    end

    if gs.state == gs.ds or ds == true then
        drawSubWin(nil, h - w/6 - 10,  w - w/5 , w/6 , 70*scalew,0,-2)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(cd:sub(1, currentCharIndex), w / 8, h - w/6 + (5*scale))
        love.graphics.setColor(255, 255, 255)
    end

    touchScreen()

    if cheating == true then
        love.graphics.draw(cheat,cheatW,cheatH,nil,cheatW,cheatH)
    end
end

function love.keypressed(key)
    if gs.state == gs.ds then
        if key == 'x' then
        if dst >= 1 / 5 then
            pl.dir = pl.ani.down
            pl.d = 'down'

            gs.state = gs.pls

            dst = 0
            cr = true
            currentCharIndex = 0
        end
        end

        if key == 'lshift' or key == 'rshift' and currentCharIndex < #cd then
           currentCharIndex = #cd - 1
        end

    elseif gs.state == gs.pls then
            if key == 'x' then
                openChests()

                local px, py = pl.coll:getPosition()

                local co = world:queryCircleArea(px, py, 15, {"t"})

                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text
                    if co[1].name ~= '' then
                        cd = co[1].name
                    end
                end

                co = world:queryCircleArea(px, py, 15, {"t2"})
                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text2
                    if co[1].name ~= '' then
                        cd = co[1].name
                    end
                end

                co = world:queryCircleArea(px, py, 15, {"t3"})
                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text3
                    if co[1].name ~= '' then
                        cd = co[1].name
                    end
                end
                co = world:queryCircleArea(px, py, 15, {"t4"})
                if #co > 0 and pl.dir == pl.ani.up then
                    gs.state = gs.ds
                    cd = text4
                    if co[1].name ~= '' then
                        cd = co[1].name
                    end
                end
        end
end
end

function love.keyreleased(key)
    if gs.state == gs.pls then
        if key == "z" and pl.swim == false and pl.useSword == false then
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


                sw:setType("static")

                sw:setFixedRotation(true)
                sw:setCollisionClass("sw")

                sword:tree()
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
            if not inputdelayE then
            	inputdelayE = 0.12
            	selectSE:play()
            end
        end
    end
end
