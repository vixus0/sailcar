WindAngle = 0.0
DesiredSailAngle = 0.1
SailAngle = 0.1
CarAngle = 0.1
SheetFactor = 1.0
ForwardForce = 0.0

function love.update(dt)
  -- Handle input
  local powah = 80
  local sheetSpeed = 2
  if love.keyboard.isDown("up") then
    SheetFactor = SheetFactor + sheetSpeed * dt
  end
  if love.keyboard.isDown("down") then
    SheetFactor = SheetFactor - sheetSpeed * dt
  end
  if love.keyboard.isDown("a") then
    CarAngle = CarAngle + powah * dt
  end
  if love.keyboard.isDown("d") then
    CarAngle = CarAngle - powah * dt
  end

  CarAngle = CarAngle % 360.0
  SheetFactor = Clamp(SheetFactor, 0.1, 1.0)

  -- Figure out the angle the sail wants to be
  DesiredSailAngle = WindAngle - CarAngle + 180.0
  DesiredSailAngle = Clamp(DesiredSailAngle, -80, 80)

  -- Constrain the possible sail angle with the sheet
  local possibleSailAngle = SheetFactor * DesiredSailAngle

  -- Update sail angle
  SailAngle = SailAngle + (possibleSailAngle - SailAngle) * 3.0 * dt

  -- Calculate force in wind direction
  ForwardForce = math.sin(math.rad(math.abs(SailAngle + CarAngle - WindAngle)))
end

function love.draw()
  love.graphics.print('wind angle: ' .. WindAngle, 10, 10)
  love.graphics.print('sail angle: ' .. SailAngle, 10, 30)
  love.graphics.print('boat angle: ' .. CarAngle, 10, 50)
  love.graphics.print('force: ' .. ForwardForce, 10, 70)
  love.graphics.print('sheet: ' .. SheetFactor, 10, 90)

  DrawCar(400, 300)
  DrawWind(50, 500)
end

function DrawCar(x, y)
  local h = 200
  local w = 100
  local sailSize = 150
  local sumAngle = CarAngle + SailAngle

  love.graphics.push()
  love.graphics.setColor(1.0, 0.5, 0.0, 1.0)
  love.graphics.translate(x, y)
  love.graphics.rotate(math.rad(CarAngle))
  love.graphics.polygon('line',
       0, -h/2,
    -w/2,  h/2,
     w/2,  h/2
  )
  ResetColor()
  DrawSail(
    0, 0,
    SailAngle,
    20 * ForwardForce * -Sign(sumAngle),
    sailSize
  )

  -- draw sheet
  love.graphics.setColor(0, 1, 0.5, 1)
  love.graphics.line(
    0, h/2 - 10,
    sailSize * -math.sin(math.rad(SailAngle)),
    sailSize * math.cos(math.rad(SailAngle))
  )
  ResetColor()
  love.graphics.pop()
end

function DrawSail(x, y, angle, swell, size)
  local np = 30
  local points = {}

  for i=1,np do
    local pointX = swell * math.sin(math.pi / np * (i-1))
    local pointY = i * size/np
    table.insert(points, pointX)
    table.insert(points, pointY)
  end

  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(math.rad(angle))
  love.graphics.line(points)
  love.graphics.pop()
end

function DrawWind(x, y)
  local h = 50
  local w = 30

  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(math.rad(WindAngle))
  love.graphics.polygon('fill',
       0, -h/2,
    -w/2,  h/2,
     w/2,  h/2
  )
  love.graphics.pop()
end

function Clamp(value, minval, maxval)
  return math.max(math.min(value, maxval), minval)
end

function ResetColor()
  love.graphics.setColor(1, 1, 1, 1)
end

function Sign(num)
  return (num >= 0 and 1) or -1
end
