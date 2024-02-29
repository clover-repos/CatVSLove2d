function slimeLoad()
    slimeSS = love.graphics.newImage("res/ent/ene/slime.png")
    slimeG = ani.newGrid(16, 16, slimeSS:getWidth(), slimeSS:getHeight())
    slimeL = ani.newAnimation(slimeG("1-3", 1), 0.30)
    slimeA = ani.newAnimation(slimeG("1-3", 1), 0.18 / (3 / 2))
    idleAn = ani.newAnimation(slimeG("4-5", 1), 0.18)
    slimeD = ani.newAnimation(slimeG("6-8", 1), 0.25)
end

function slimeUpdate()
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

                            exV, eyV = norm(exV,eyV)

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

                                EX, EY = norm(EX,EY)

                                enem:setLinearVelocity(EX, EY)
                                enem.rT = 0.9
                            end
                        end
                    end
                end
            end
end

function slimeDraw(dt)
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


                if gs.state == gs.pls then
                    enem.s:update(publicDT)
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
end
