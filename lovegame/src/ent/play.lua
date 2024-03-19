pl = {} -- The player table *holly music plays*.
pl.ani = {} --The player's sub-table for animations.

function pl.InviColl()
    pl.coll:setPreSolve(
            function(collider_1, collider_2, contact)
                if collider_1.collision_class == "pl" and collider_2.collision_class == "gc" then
                    local px, py = collider_1:getPosition()
                    local tx, ty = collider_2:getPosition()

                    if pl.swim then
                        contact:setEnabled(false)--dt
                    else
                        contact:setEnabled(true)
                    end
                elseif collider_1.collision_class == "pl" and collider_2.collision_class == "wc" then
                    local px, py = collider_1:getPosition()
                    local tx, ty = collider_2:getPosition()

                    if pl.swim then
                        contact:setEnabled(true)
                    else
                        contact:setEnabled(false)
                    end
                elseif collider_1.collision_class == "pl" and collider_2.collision_class == "ene" and collider_2.tang == false then
                    local px, py = collider_1:getPosition()
                    local tx, ty = collider_2:getPosition()

                    if isH == true and HTI > 1/6 then
                        contact:setEnabled(false)
                    else
                        contact:setEnabled(true)
                    end
                end
            end
        )
end

function pl.load()
    --Health Images
    HH = love.graphics.newImage("res/ent/share/hH.png")
    HF = love.graphics.newImage("res/ent/share/hF.png")
    HE = love.graphics.newImage("res/ent/share/hE.png")
    treeI = love.graphics.newImage("res/env/tree1.png")
    talkI = love.graphics.newImage('res/gfx/talk.png')

    --STATS
    pl.run = false
    pl.swim = false
    pl.hasSword = false
    pl.useSword = false

    sD = math.rad(90)
    sU = math.rad(270)
    sL = math.rad(180)
    sR = 0

	pl.offY = 0

    pl.s = 200

    swordI = love.graphics.newImage('res/ent/ply/sword.png')

    HTI = 0
    pl.mH = 3
    pl.cH = 3
    isH = false

    --switch weppons? soon?
    pl.sw = 1 --sword

    pl.a = 2 --arrow

    pl.cWep = 0 -- current weppon

    --TIMERS

    timer = 0
    timerSE = 0

    pl.coll = world:newBSGRectangleCollider(800, 800, 32.5,32.5,12)
    pl.coll:setFixedRotation(true)
    world:addCollisionClass("pl", {ignores = {"wa", "ws", "we", "cm", "cm2", "cm3", "cm4","t","t2","t3",'t4','ewa'}})
    world:addCollisionClass("sw", {ignores = {"wa", "ws", "we", "cm", "cm2", "cm3", "cm4","t","t2","t3",'t4','ewa','sw','wall','tree','ch','pl','ene'}})
    pl.coll:setCollisionClass("pl")

    pl.SS = love.graphics.newImage("res/ent/ply/play.png")
    pl.g = ani.newGrid(16, 32, pl.SS:getWidth(), pl.SS:getHeight())

    --animations and directions
    pl.ani.walkU = ani.newAnimation(pl.g("1-4", 3), 0.20)
    pl.ani.walkD = ani.newAnimation(pl.g("1-4", 1), 0.20)
    pl.ani.walkL = ani.newAnimation(pl.g("1-4", 4), 0.20)
    pl.ani.walkR = ani.newAnimation(pl.g("1-4", 2), 0.20)

    pl.ani.runU =  ani.newAnimation(pl.g("1-4", 3), 0.18/1.5)
    pl.ani.runD = ani.newAnimation(pl.g("1-4", 1), 0.18/1.5)
    pl.ani.runL = ani.newAnimation(pl.g("1-4", 4), 0.18/1.5)
    pl.ani.runR = ani.newAnimation(pl.g("1-4", 2), 0.18/1.5)

    pl.ani.swimU = ani.newAnimation(pl.g("1-4", 3+4), 0.30)
    pl.ani.swimD = ani.newAnimation(pl.g("1-4", 1+4), 0.30)
    pl.ani.swimL = ani.newAnimation(pl.g("1-4", 4+4), 0.30)
    pl.ani.swimR = ani.newAnimation(pl.g("1-4", 2+4), 0.30)

    pl.ani.swordU = ani.newAnimation(pl.g("6-8", 3), 0.125)
    pl.ani.swordD = ani.newAnimation(pl.g("6-8", 1), 0.125)
    pl.ani.swordL = ani.newAnimation(pl.g("6-8", 4), 0.125)
    pl.ani.swordR = ani.newAnimation(pl.g("6-8", 2), 0.125)

    pl.ani.up = pl.ani.walkU
    pl.ani.down = pl.ani.walkD
    pl.ani.left = pl.ani.walkL
    pl.ani.right = pl.ani.walkR

    pl.dir = pl.ani.up
    pl.d = 'up'

    pl.shad = love.graphics.newImage("res/ent/share/shad.png")
    pl.splash = love.graphics.newImage("res/ent/share/splash.png")

    pl.splashBSE = love.audio.newSource("res/audio/sfx/splashB.ogg", "static")
    pl.splashMSE = love.audio.newSource("res/audio/sfx/splashM.ogg", "static")

    pl.swipe = love.audio.newSource("res/audio/sfx/swipe.ogg",'static')

    pl.splash1X = 0
    pl.splash1Y = 0

    pl.splash2X = 0
    pl.splash2Y = 0
end

drawworld = false

function pl.update(dt)
    m = false
    local x = 0
    local y = 0
    pl.cx = pl.coll:getX()
    pl.cy = pl.coll:getY()

    if isH == true then
        if HTI < 0.5 then
            HTI = HTI + publicDT
        else
            HTI = 0
            isH = false
        end
    end

    local co = world:queryCircleArea(pl.coll:getX(), pl.coll:getY(), 18, {"ene"})
for i, enem in ipairs(co) do
	if enem.isDying == true then
		EcH = true
	else
		EcH = false	
	end
end
    if #co > 0 and isH == false and not isDog == true and not EcH == true then
            pl.cH = pl.cH - 0.5
            hSE:play()
            isH = true
            pl.sh = true
	    if pl.cH < pl.mH/2 then
            gs.state = gs.death
            pl.sh = true
	    end
    end

    if pl.useSword == false then

    if love.keyboard.isDown('z') and pl.swim == false then
        pl.s = 285
        if pl.run == false then
            pl.run = true
            pl.ani.up = pl.ani.runU
            pl.ani.down = pl.ani.runD
            pl.ani.left = pl.ani.runL
            pl.ani.right = pl.ani.runR
        end
    end

	--Simi Grid Like Movement

    if love.keyboard.isDown("up","w") then
        uP = true
	uT = 0.205
    end
    if love.keyboard.isDown("down","s") then
       dP = true
	dT = 0.205
    end
    if love.keyboard.isDown("left","a") then
        lP = true
	lT = 0.205
    end
    if love.keyboard.isDown("right","d") then
        rP = true
	rT = 0.205
    end

	if dP == true then
		 y = pl.s
        	pl.dir = pl.ani.down
        	m = true
        	pl.d = 'down'
		dT = dT - publicDT
		if dT <= 0 then
			dP = false
		end
	end

	if uP == true then
		uT = uT - publicDT
		if uT <= 0 then
			uP = false
		end		
		y = -pl.s
       		pl.dir = pl.ani.up
        	m = true
        	pl.d = 'up'
	end
	
	if rP == true then
		rT = rT - publicDT
		if rT <= 0 then
			rP = false
		end
		x = pl.s
        	pl.dir = pl.ani.right
        	m = true
        	pl.d = 'right'
	end
	
	if lP == true then
		lT = lT - publicDT
		if lT <= 0 then
			lP = false
		end	
		x = -pl.s
        	pl.dir = pl.ani.left
        	m = true
        	pl.d = 'left'
	end

    x, y = norm(x,y)

    pl.coll:setLinearVelocity(x, y)
    end
    if pl.useSword == true then
    pl.coll:setLinearVelocity(0, 0)
    end
	
	-- Out of bonds handle.

         if pl.coll:getX() > mW then
            pl.coll:setPosition(mW,pl.coll:getY())
        end

        if pl.coll:getX() < 0 then
            pl.coll:setPosition(0,pl.coll:getY())
        end

        if pl.coll:getY() > mH then
            pl.coll:setPosition(pl.coll:getX(),mH)
        end

        if pl.coll:getY() < 0 then
            pl.coll:setPosition(pl.coll:getX(),0)
        end

    if pl.swim == true then
        timer = timer + publicDT
        if timer >= 1/6 and m == true then
            pl.splash1X = math.random((7 * 3))
            pl.splash1Y = math.random((6 * 3))
            pl.splash2X = math.random((7 * 2.9))
            pl.splash2Y = math.random((6 * 2.9))
            timer = 0
        end
        if m == true then
            timerSE = timerSE + publicDT
            if timerSE >= 0.5 then
                pl.splashMSE:play()
                timerSE = 0
            end
        elseif pl.splashMSE:isPlaying() then
            pl.splashMSE:stop()
        end
    end

	if m == false and pl.swim == false and pl.useSword == false then
		pl.dir:gotoFrame(1)
	end
end

function pl.shD()
    if pl.swim == true then     
	love.graphics.draw(pl.shad, pl.coll:getX()-8, pl.coll:getY() - (1.5 * 6), nil, 4, nil, 6, 9)
    end
end

function pl.draw()
	if pl.d == "up" and pl.useSword == true then
            love.graphics.draw(swordI, sw:getX() - 10, sw:getY() + 20, sw.di, 3)
	end
	if pl.d == "left" and pl.useSword == true then
            love.graphics.draw(swordI, sw:getX() + 35, sw:getY() + 9, sw.di, 3)
    end
    if pl.d == "right" and pl.useSword == true then
            love.graphics.draw(swordI, sw:getX() - 35, sw:getY() - 10, sw.di, 3)
    end

    pl.dir:draw(pl.SS, pl.coll:getX()-7.5, pl.coll:getY() - 45 - pl.offY,nil, 3.1, nil, 6, 9)

    if pl.swim == true and m == true then
        love.graphics.draw(pl.splash, pl.coll:getX() - pl.splash1X, pl.coll:getY() - (4 * 3) - pl.splash1Y, nil, 3, nil, 6, 9)
        love.graphics.draw(pl.splash, pl.coll:getX() - pl.splash2X, pl.coll:getY() - (4 * 3) - pl.splash2Y, nil, 3)
    end

	if pl.d == "down" and pl.useSword == true then
        love.graphics.draw(swordI, sw:getX() + 10, sw:getY() - 40, sw.di, 3)
    end
end
