local dialog = Dialog("Normal Map Shape Generator")

function coordToColor(coord)
  local colorNumber = (coord / 2 + 0.5) * (255 - dialog.data.noise)
  colorNumber = roundTo(colorNumber, tonumber(dialog.data.preround))
  colorNumber = math.random(colorNumber, colorNumber + dialog.data.noise)
  colorNumber = roundTo(colorNumber, tonumber(dialog.data.postround))
  return colorNumber
end

function roundTo(number, to)
  if to == 0 then
    return number
  end
  
  return math.floor(number - number % to)
end

function getLayer(layerName)
  for i = 1, #app.activeSprite.layers do
    if app.activeSprite.layers[i].name == layerName then
      return app.activeSprite.layers[i]
    end
  end
  
  local layer = app.activeSprite:newLayer()
  layer.name = layerName
  return layer
end

function drawNormal()
  local width = tonumber(dialog.data.width)
  local height = tonumber(dialog.data.height)
  local depth = tonumber(dialog.data.depth)
  
  local layer = getLayer(dialog.data.outputLayer)
  
  local xOffset = height > width and (height - width) / 2 or 0
  local yOffset = width > height and (width - height) / 2 or 0
  local outputImage = Image(width + xOffset * 2, height + yOffset * 2)
  
  for x = 0, width do
    for y = 0, height do
      local relativeX = x - width / 2
      local relativeY = y - height / 2
      local zSquared = (depth/2)^2 * (1 - relativeX^2 / (width/2)^2 - relativeY^2 / (height/2)^2);
      
      if zSquared < 0 then
        goto continue
      end
      
      local z = math.sqrt(zSquared)
      
      local angle = math.rad(tonumber(dialog.data.rotation))
      local rotatedX = relativeX*math.cos(angle) - relativeY*math.sin(angle)
      local rotatedY = relativeY*math.cos(angle) + relativeX*math.sin(angle)
      
      local normalX = rotatedX / (width/2)^2
      local normalY = -rotatedY / (height/2)^2
      local normalZ = z / (depth/2)^2
      local magnitude = math.sqrt(normalX^2 + normalY^2 + normalZ^2)
      local color = Color { 
        r = coordToColor(normalX / magnitude), 
        g = coordToColor(normalY / magnitude), 
        b = coordToColor(normalZ / magnitude), 
      }
      
      local drawX = rotatedX + xOffset + width / 2
      local drawY = rotatedY + yOffset + height / 2
      outputImage:drawPixel(drawX, drawY, color)
      
      -- Hack to deal with rounding after rotation causing missing pixels
      if app.pixelColor.rgbaA(outputImage:getPixel(drawX, drawY + 1)) == 0 then
        outputImage:drawPixel(drawX, drawY + 1, color)
      end
      
      ::continue::
    end
  end
  
  app.activeSprite:newCel(layer, 1, outputImage, 
    Point(tonumber(dialog.data.xPosition) - width / 2 - xOffset, tonumber(dialog.data.yPosition) - height / 2 - yOffset))
  
  app.refresh()
end

dialog:entry {
  id="outputLayer",
  label = "Output Layer: ",
  text = "Output"
}

dialog:separator {
  id="sep1", 
  text="Transform"
}

dialog:entry {
  id="xPosition",
  label = "X Position: ",
  text = "0"
}

dialog:entry {
  id="yPosition",
  label = "Y Position: ",
  text = "0"
}

dialog:entry {
  id="width",
  label = "Width: ",
  text = "10"
}

dialog:entry {
  id="height",
  label = "Height: ",
  text = "10"
}

dialog:entry {
  id="depth",
  label = "Depth: ",
  text = "10"
}

dialog:entry {
  id="rotation",
  label = "Rotation (Degrees): ",
  text = "0"
}

dialog:separator {
  id="sep2", 
  text="Effects"
}

dialog:entry {
  id="preround",
  label = "Pre-Noise Rounding: ",
  text = "1"
}

dialog:entry {
  id="noise",
  label = "Noise: ",
  text = "0"
}

dialog:entry {
  id="postround",
  label = "Post-Noise Rounding: ",
  text = "1"
}

dialog:button {
  id="execute",
  text = "Execute",
  onclick = drawNormal
}

dialog:show()