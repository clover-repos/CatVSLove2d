sword = {}

function sword.update()
    for _, enem in ipairs(ene) do
        if enem.h and enem.h > 0 and enem.hC ~= true and enem:enter('sw') then
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
            shakeDuration = 0.5
            shakeMagnitude = 4

                        if enem.h <= 0 then
                            enem.isDying = true
                            enem.lastMoments = deaT
                            pl.sh = true
                            shakeDuration = 1
                            shakeMagnitude = 6
                            ImP = true
                            ImT = 0.2
                            enem.s = slimeD:clone()
                        end
                    end
                end
end

function sword.tree()
    local sqx
    local sqy

    if pl.d == "up" or pl.d == "down" then
        sqx = 5
        sqy = 20

        swordColliders = world:queryRectangleArea(sw:getX() - sqx, sw:getY() - sqy, 10, 40, { "tree" })
    else
        sqx = 20
        sqy = 5

        swordColliders = world:queryRectangleArea(sw:getX() - sqx, sw:getY() - sqy, 40, 10, { "tree" })
    end

    if #swordColliders > 0 then

        pl.sh = true
        shakeMagnitude = 4

        for i, coll in ipairs(swordColliders) do
            if not coll.flT then
                coll.flT = 0
            end

            if coll.health == nil then
                coll.health = 4
            end
            if coll.flT <= 0 then
                coll.health = coll.health - 1
                coll.flT = 0.5

                if coll.health <= 0 then

                    coll:destroy()

                    if coll.isBad ~= true then
                        pl.noct = pl.noct + 1

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

                            spawnSlime(pl.coll:getX(), pl.coll:getY() + TS, nil, true, true)
                            spawnSlime(pl.coll:getX(), pl.coll:getY() - TS, nil, true, true)

                            spawnSlime(pl.coll:getX() + TS, pl.coll:getY(), nil, true, true)
                            spawnSlime(pl.coll:getX() - TS, pl.coll:getY(), nil, true, true)
                        elseif pl.noct == 5 then
                            gs.state = gs.ds
                            cd = 'I give up.'
                        else

                        end
                    else
                        gs.state = gs.ds
                        cd = 'You destroyed the fake tree, good joob!'
                        gsSE:play()
                    end
                end

                pl.swipe:stop()
                if coll.health > 0 then
                    if treeCut:isPlaying() then
                        treeCut:stop()
                    end
                    treeCut:play()
                else
                    treeCut:stop()
                    treeDie:stop()
                    treeDie:play()
                end
            end
        end
end
end
