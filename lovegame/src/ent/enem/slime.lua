function slimeLoad()
    slimeSS = love.graphics.newImage("res/ent/ene/slime.png")
    slimeG = ani.newGrid(16, 16, slimeSS:getWidth(), slimeSS:getHeight())
    slimeL = ani.newAnimation(slimeG("1-3", 1), 0.19)
    slimeA = ani.newAnimation(slimeG("1-3", 1), 0.18 / (3 / 2))
    idleAn = ani.newAnimation(slimeG("4-5", 1), 0.30)
    slimeD = ani.newAnimation(slimeG("6-8", 1), 0.25)
end

function slimeUpdate()
    if level.layers["ene"] then

        --Attack
        for i, enem in ipairs(ene) do
            if enem.isDying == true then
                EcH = true
                break
            else
                EcH = false
            end
        end

        local enemyQ = world:queryRectangleArea(pl.coll:getX()-17, pl.coll:getY()-19, 34, 38, {"ene"})

        if #enemyQ > 0 and isH == false and not isDog == true and not EcH == true then
            pl.cH = pl.cH - 0.5
            hSE:play()
            isH = true

            HeartFlashTime = 1
            HeartFlashing = 0.075
            HeartFull = true

            shakeMagnitude = 8

            pl.sh = true

            if pl.cH <= pl.mH / 2 then
                gs.state = gs.death
                pl.sh = true
            end
        end

        --Ai
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
                        enem.dir = 'right'
                    end

                    if ex > px then
                        exV = -es
                        enem.dir = 'left'
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

                    exV, eyV = norm(exV, eyV)

                    enem:setLinearVelocity(exV, eyV)
                end
            end
        end
        for i, enem in ipairs(ene) do
            if enem.isDying == true and enem:isDestroyed() == false then
                enem.lastMoments = enem.lastMoments - publicDT
                if enem.lastMoments <= 0 then
                    enem:destroy()
                    enem.isDying = false
                end
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
                            enem.dir = 'left'
                        elseif EX < 2.5 then
                            EX = es
                            enem.dir = 'right'
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

                        EX, EY = norm(EX, EY)

                        enem:setLinearVelocity(EX, EY)
                        enem.rT = 0.9
                    end
                end
            end
        end

        --Stop enemys from going off the map.

        for i, enemy in ipairs(ene) do
            if enemy:isDestroyed() == false then
                if enemy:getX() < 0 then
                    enemy:setPosition(0, enemy:getY())
                end

                if enemy:getX() > mW then
                    enemy:setPosition(mW, enemy:getY())
                end

                if enemy:getY() < 0 then
                    enemy:setPosition(enemy:getX(), 0)
                end
                if enemy:getY() > mH then
                    enemy:setPosition(enemy:getX(), mH)
                end
            end
        end
    end
end

function slimeDraw(dt)
    if level.layers["ene"] then
        for i, enem in ipairs(ene) do
            --Thanks so much this works, even if it's not a proper fix I'm using it. It works and thats all I care about.

            if enem.selectedAnimation == nil then
                enem.animations = {
                    slimeL:clone(),
                    slimeA:clone(),
                    idleAn:clone(),
                    slimeD:clone()
                }

                enem.selectedAnimation = 1 -- variable control which animation to run
            end

            if enem:isDestroyed() == false then
                if enem.state == idle then
                    --enem.s = slimeL
                    enem.selectedAnimation = 1 --select the proper animation
                elseif enem.state == attack then
                    --enem.s = slimeA
                    enem.selectedAnimation = 2 --select the proper animation
                end
                if enem.idleA == true then
                    --enem.s = idleAn
                    enem.selectedAnimation = 3 --select the proper animation
                end
                if enem.isDying == true then
                    --enem.s = slimeD
                    enem.selectedAnimation = 4 --select the proper animation
                end

                local x, y = enem:getPosition()
                if enem.hC == true then
                    love.graphics.setColor(255, 0, 0, 0.9)
                    if gs.state == gs.pls then
                        enem.hT = enem.hT + publicDT --dt
                    end
                end

                if gs.state == gs.pls then
                    --enem.s:update(publicDT)
                    enem.animations[enem.selectedAnimation]:update(publicDT) --update only the selected animation
                end

                --enem.s:draw(slimeSS, x - 8 * 4, y - 8 * 5, nil, 3.9)
                if enem.dir == 'right' then
                  enem.animations[enem.selectedAnimation]:draw(slimeSS, x - 8 * 4 + 64, y - 8 * 5, 0, -4,4) -- draw only the selected animation
                else
                  enem.animations[enem.selectedAnimation]:draw(slimeSS, x - 8 * 4, y - 8 * 5, 0, 4) -- draw only the selected animation
                end
                if enem.hT >= 1 / 6 then
                    enem.hT = 0
                    enem.hC = false
                    enem:setLinearVelocity(0, 0)
                end

                love.graphics.setColor(255, 255, 255)
            end
        end
    end
end
