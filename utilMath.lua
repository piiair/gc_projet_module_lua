local utilMath = {}

function utilMath.distance(xStart, yStart, xEnd, yEnd)
  return ((xEnd - xStart) ^ 2 + (yEnd - yStart) ^ 2) ^ 0.5
end

function utilMath.absoluteDistance(xStart, yStart, xEnd, yEnd)
  return math.abs(((xEnd - xStart) ^ 2 + (yEnd - yStart) ^ 2) ^ 0.5)
end

function utilMath.getAngle(xStart, yStart, xEnd, yEnd, pStringRadOrDegree)
  if pStringRadOrDegree == "rad" then
    return math.atan2(yEnd - yStart, xEnd - xStart)
  elseif pStringRadOrDegree == "degree" then
    local angleDeg = math.deg(math.atan2(yEnd - yStart, xEnd - xStart))
    if angleDeg < 0 then 
      angleDeg = angleDeg + 360
    end
    return angleDeg
  end
end


return utilMath


