function love.load()
  WindAngle = 0.0
  SailAngle = 0.1
  CarAngle = 0.1
  CarPos = {X = 500, Y = 500}
  CarVel = {X = 0, Y = 0}
  SheetFactor = 1.0
  WindForce = 0.0
  WindStrength = 50.0

  love.window.setFullscreen(true)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function love.update(dt)
  CarAngle = CarAngle % 360.0
  SheetFactor = Clamp(SheetFactor, 0.1, 1.0)

  -- Figure out the angle the sail wants to be
  local desiredSailAngle = Clamp(WindAngle - CarAngle + 180.0, -80, 80)

  -- Constrain the possible sail angle with the sheet
  local possibleSailAngle = SheetFactor * desiredSailAngle

  -- Update sail angle
  SailAngle = SailAngle + (possibleSailAngle - SailAngle) * 3.0 * dt

  -- Calculate force in wind direction
  WindForce = WindStrength * math.abs(math.sin(math.rad(math.abs(SailAngle + CarAngle - WindAngle))))

  -- Update car position
  local carVec = {X = math.sin(math.rad(CarAngle)), Y = math.cos(math.rad(CarAngle))}
  local carVecT = {X = carVec.Y, Y = carVec.X}
  local sailVecT = {X = math.cos(math.rad(SailAngle+CarAngle)), Y = math.sin(math.rad(SailAngle+CarAngle))}
  local windVec = {X = math.sin(math.rad(WindAngle)), Y = -math.cos(math.rad(WindAngle))}

  local carVecDotCarVel = Dot(carVec, CarVel)
  local carVecTDotCarVel = Dot(carVecT, CarVel)
  local sailVecTDotWindVec = Dot(sailVecT, windVec)
  local carForce = {
    X = sailVecT.X * WindForce * sailVecTDotWindVec + 0.05 * WindStrength * windVec.X - 0.5 * carVecDotCarVel * carVec.X - 5.0 * carVecTDotCarVel * carVecT.X,
    Y = sailVecT.Y * WindForce * sailVecTDotWindVec + 0.05 * WindStrength * windVec.Y - 0.5 * carVecDotCarVel * carVec.X - 5.0 * carVecTDotCarVel * carVecT.Y,
  }

  CarVel.X = CarVel.X + carForce.X * dt
  CarVel.Y = CarVel.Y + carForce.Y * dt

  CarPos.X = CarPos.X + CarVel.X * dt
  CarPos.Y = CarPos.Y + CarVel.Y * dt

  -- Handle input
  local carVelLen = math.sqrt(Dot(CarVel, CarVel))
  local powah = math.atan(carVelLen / 50) * 80
  local sheetSpeed = 2

  print(powah)

  if love.keyboard.isDown('w') then
    SheetFactor = SheetFactor + sheetSpeed * dt
  end
  if love.keyboard.isDown('s') then
    SheetFactor = SheetFactor - sheetSpeed * dt
  end
  if love.keyboard.isDown('a') then
    CarAngle = CarAngle + powah * dt
  end
  if love.keyboard.isDown('d') then
    CarAngle = CarAngle - powah * dt
  end

end

function love.draw()
  love.graphics.print('wind angle: ' .. WindAngle, 10, 10)
  love.graphics.print('sail angle: ' .. SailAngle, 10, 30)
  love.graphics.print('car angle: ' .. CarAngle, 10, 50)
  love.graphics.print('force: ' .. WindForce, 10, 70)
  love.graphics.print('sheet: ' .. SheetFactor, 10, 90)
  love.graphics.print('x: ' .. CarPos.X .. ' y: ' .. CarPos.Y, 10, 110)

  DrawCar(CarPos.X, CarPos.Y)
  DrawWind(50, love.graphics.getHeight() - 40)
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
    20 * -WindForce/WindStrength * Sign(SailAngle),
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

function Dot(vec1, vec2)
  return vec1.X * vec2.X + vec1.Y * vec2.Y
end
