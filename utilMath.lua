local utilMath = {}

function utilMath.distance(xStart, yStart, xEnd, yEnd)
  return ((xEnd - xStart) ^ 2 + (yEnd - yStart) ^ 2) ^ 0.5
end

function utilMath.absoluteDistance(xStart, yStart, xEnd, yEnd)
  return math.abs(((xEnd - xStart) ^ 2 + (yEnd - yStart) ^ 2) ^ 0.5)
end

function utilMath.getAngle(xStart, yStart, xEnd, yEnd, pResultType)
  if pResultType == "rad" then
    return math.atan2(yEnd - yStart, xEnd - xStart)
  elseif pResultType == "degRelative" then
    return math.deg(math.atan2(yEnd - yStart, xEnd - xStart))
  elseif pResultType == "degAbsolute" then
    local result = math.deg(math.atan2(yEnd - yStart, xEnd - xStart))
    if result < 0 then
      result = result + 360
    end
    return result
  end
end

function utilMath.verifyCollideGeneral(pRefX, pRefY, pRefW, pRefH, pObjX, pObjY, pObjW, pObjH)
  local isCollide = false

  if pRefX >= pObjX - pObjW / 2 - pRefW / 2 and
  pRefX <= pObjX + pObjW / 2 + pRefW / 2 and
  pRefY >= pObjY - pObjH / 2 - pRefH / 2 and
  pRefY <= pObjY + pObjH / 2 + pRefH / 2 then
    isCollide = true
  end

  return isCollide
end

function utilMath.verifyCollideAxeX(pRefX, pRefW, pObjX, pObjW)
  local isCollide = false

  if pRefX >= pObjX - pObjW / 2 - pRefW / 2 and pRefX <= pObjX + pObjW / 2 + pRefW / 2 then
    isCollide = true
  end

  return isCollide
end

function utilMath.verifyCollideAxeY(pRefY, pRefH, pObjY, pObjH)
  local isCollide = false

  if pRefY >= pObjY - pObjH / 2 - pRefH / 2 and pRefY <= pObjY + pObjH / 2 + pRefH / 2 then
    isCollide = true
  end

  return isCollide
end

function utilMath.verifyCollideScreenBorders(pObj, pScreenW, pScreenH, pTypeCollision, pHasImg)
  local isCollide = false
  local hasImage = pHasImg or true

  if hasImage then
    if pTypeCollision == "inside" then
      if pObj.x < 0 + pObj.image:getWidth()/2 or
        pObj.x > pScreenW - pObj.image:getWidth()/2 or
        pObj.y < 0 + pObj.image:getHeight()/2 or
        pObj.y > pScreenH - pObj.image:getHeight()/2 then
          isCollide = true
      end
    elseif pTypeCollision == "outside" then
      if pObj.x < 0 - pObj.image:getWidth()/2 or
      pObj.x > pScreenW + pObj.image:getWidth()/2 or
      pObj.y < 0 - pObj.image:getHeight()/2 or
      pObj.y > pScreenH + pObj.image:getHeight()/2 then
        isCollide = true
      end
    end
  else
    if pTypeCollision == "inside" then
      if pObj.x < 0 + pObj.w/2 or
        pObj.x > pScreenW - pObj.w/2 or
        pObj.y < 0 + pObj.h/2 or
        pObj.y > pScreenH - h/2 then
          isCollide = true
      end
    elseif pTypeCollision == "outside" then
      if pObj.x < 0 - pObj.w/2 or
      pObj.x > pScreenW + pObj.w/2 or
      pObj.y < 0 - pObj.h/2 or
      pObj.y > pScreenH + pObj.h/2 then
        isCollide = true
      end
    end
  end
  

  return isCollide
end

return utilMath


