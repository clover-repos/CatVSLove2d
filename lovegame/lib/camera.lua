local cos, sin = math.cos, math.sin

local camera = {}
camera.__index = camera

-- Movement interpolators (for camera locking/windowing)
camera.smooth = {}

function  camera.update()

		--follow player

		cam:lookAt(pl.coll:getX(), pl.coll:getY())

        --stop cam when map is done.
        if cam.x < (w / 2) / scale then
            cam.x = (w / 2) / scale
        end

        if cam.y < (h / 2) / scale then
            cam.y = (h / 2) / scale
        end

        if cam.x > (mW - (w / 2) / scale) then
            cam.x = (mW - (w / 2) / scale)
        end

        if cam.y > (mH - (h / 2) / scale) then
            cam.y = (mH - (h / 2) / scale)
        end

        --cam shake
	if gs.state == gs.pls then
        if pl.sh == true then
            if shakeDuration > 0 then
                local offsetX = love.math.random(-shakeMagnitude, shakeMagnitude)
                local offsetY = love.math.random(-shakeMagnitude, shakeMagnitude)
                cam:move(offsetX, offsetY)
                shakeDuration = shakeDuration - publicDT
            else
                -- Reset camera position after shake is done
                shakeDuration = 0.25
                pl.sh = false
            end
        end
	end

	cam.x = math.floor(cam.x)
	cam.y = math.floor(cam.y)
end

function camera.smooth.none()
    return function(dx, dy) return dx, dy end
end

function camera.smooth.linear(speed)
    assert(type(speed) == "number", "Invalid parameter: speed = " .. tostring(speed))
    return function(dx, dy, s)
        local d = math.sqrt(dx * dx + dy * dy)
        local dts = math.min((s or speed) * love.timer.getDelta(), d)
        if d > 0 then
            dx, dy = dx / d, dy / d
        end

        return dx * dts, dy * dts
    end
end

function camera.smooth.damped(stiffness)
    assert(type(stiffness) == "number", "Invalid parameter: stiffness = " .. tostring(stiffness))
    return function(dx, dy, s)
        local dts = love.timer.getDelta() * (s or stiffness)
        return dx * dts, dy * dts
    end
end

local function new(x, y, zoom, rot, smoother)
    x, y = x or love.graphics.getWidth() / 2, y or love.graphics.getHeight() / 2
    zoom = zoom or 1
    rot = rot or 0
    smoother = smoother or camera.smooth.none()
    return setmetatable({ x = x, y = y, scale = zoom, rot = rot, smoother = smoother }, camera)
end

function camera:lookAt(x,y)
	self.x, self.y = x, y
	return self
end

function camera:move(dx,dy)
	self.x, self.y = self.x + dx, self.y + dy
	return self
end

function camera:position()
	return self.x, self.y
end

function camera:rotate(phi)
	self.rot = self.rot + phi
	return self
end

function camera:rotateTo(phi)
	self.rot = phi
	return self
end

function camera:zoom(mul)
	self.scale = self.scale * mul
	return self
end

function camera:zoomTo(zoom)
	self.scale = zoom
	return self
end

function camera:attach(x,y,w,h, noclip)
	x,y = x or 0, y or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	self._sx,self._sy,self._sw,self._sh = love.graphics.getScissor()
	if not noclip then
		love.graphics.setScissor(x,y,w,h)
	end

	local cx,cy = x+w/2, y+h/2
	love.graphics.push()
	love.graphics.translate(cx, cy)
	love.graphics.scale(self.scale)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
	love.graphics.pop()
	love.graphics.setScissor(self._sx,self._sy,self._sw,self._sh)
end

function camera:draw(...)
	local x,y,w,h,noclip,func
	local nargs = select("#", ...)
	if nargs == 1 then
		func = ...
	elseif nargs == 5 then
		x,y,w,h,func = ...
	elseif nargs == 6 then
		x,y,w,h,noclip,func = ...
	else
		error("Invalid arguments to camera:draw()")
	end

	self:attach(x,y,w,h,noclip)
	func()
	self:detach()
end

-- world coordinates to camera coordinates
function camera:cameraCoords(x,y, ox,oy,w,h)
	ox, oy = ox or 0, oy or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
	local c,s = cos(self.rot), sin(self.rot)
	x,y = x - self.x, y - self.y
	x,y = c*x - s*y, s*x + c*y
	return x*self.scale + w/2 + ox, y*self.scale + h/2 + oy
end

-- camera coordinates to world coordinates
function camera:worldCoords(x,y, ox,oy,w,h)
	ox, oy = ox or 0, oy or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local c,s = cos(-self.rot), sin(-self.rot)
	x,y = (x - w/2 - ox) / self.scale, (y - h/2 - oy) / self.scale
	x,y = c*x - s*y, s*x + c*y
	return x+self.x, y+self.y
end

function camera:mousePosition(ox,oy,w,h)
	local mx,my = love.mouse.getPosition()
	return self:worldCoords(mx,my, ox,oy,w,h)
end

-- camera scrolling utilities
function camera:lockX(x, smoother, ...)
	local dx, dy = (smoother or self.smoother)(x - self.x, self.y, ...)
	self.x = self.x + dx
	return self
end

function camera:lockY(y, smoother, ...)
	local dx, dy = (smoother or self.smoother)(self.x, y - self.y, ...)
	self.y = self.y + dy
	return self
end

function camera:lockPosition(x,y, smoother, ...)
	return self:move((smoother or self.smoother)(x - self.x, y - self.y, ...))
end

function camera:lockWindow(x, y, x_min, x_max, y_min, y_max, smoother, ...)
	-- figure out displacement in camera coordinates
	x,y = self:cameraCoords(x,y)
	local dx, dy = 0,0
	if x < x_min then
		dx = x - x_min
	elseif x > x_max then
		dx = x - x_max
	end
	if y < y_min then
		dy = y - y_min
	elseif y > y_max then
		dy = y - y_max
	end

	-- transform displacement to movement in world coordinates
	local c,s = cos(-self.rot), sin(-self.rot)
	dx,dy = (c*dx - s*dy) / self.scale, (s*dx + c*dy) / self.scale

	-- move
	self:move((smoother or self.smoother)(dx,dy,...))
end

-- the module
return setmetatable({ new = new, smooth = camera.smooth },
    { __call = function(_, ...) return new(...) end })
