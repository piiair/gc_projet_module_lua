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


return utilMath


