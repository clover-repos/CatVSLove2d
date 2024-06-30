function openChests()
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
                                if collider.name == "sw" then
                                    gs.state = gs.ds
                                    cd = "You found a sword! You can now kill enemys."
                                    pl.hasSword = true
                                    if not gsSE:isPlaying() then
                                        gsSE:play()
                                    end
                                elseif collider.name == "swL" then
                                    gs.state = gs.ds
                                    cd = 'It\'s a paper! It says, "Go down the stairs!"'
                                elseif collider.name == 'h1' then
                                    pl.cH = pl.cH + 0.5
                                    gs.state = gs.ds
                                    cd = 'You drink a basic potion.'
                                    if pl.cH > pl.mH then
                                        cd = Hfull
                                        pl.cH = pl.cH - 0.5
                                        return
                                    end
                                elseif collider.name == 'h2' then
                                    pl.cH = pl.cH + 1
                                    gs.state = gs.ds
                                    cd = 'You drink a strong potion.'
                                    if pl.cH > pl.mH then
                                        cd = Hfull
                                        pl.cH = pl.cH - 1
                                        return
                                    end
                                else
                                    gs.state = gs.ds
                                    cd = "This chest is a placeholder, there is nothing currently here."
                                end
                                chestStates[collider] = 1
                        else
                            pl.sh = true
                        end
                    end
                end
        end
