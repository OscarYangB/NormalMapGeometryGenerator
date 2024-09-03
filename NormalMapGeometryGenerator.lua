local dialog = Dialog("Normal Map Shape Generator")

function coordToColor(coord)
  local colorNumber = (coord / 2 + 0.5) * (255 - dialog.data.imperfectionRange)
  colorNumber = roundTo(colorNumber, tonumber(dialog.data.roundedTo))
  colorNumber = math.random(colorNumber, colorNumber + dialog.data.imperfectionRange)
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
  
  local outputImage = Image(width, height)
  
  for x = 0, width do
    for y = 0, height do
      local relativeX = x - width / 2
      local relativeY = y - height / 2
      local zSquared = (depth/2)^2 * (1 - relativeX^2 / (width/2)^2 - relativeY^2 / (height/2)^2);
      
      if zSquared < 0 then
        goto continue
      end
      
      local z = math.sqrt(zSquared)
      local magnitude = math.sqrt(relativeX^2 + relativeY^2 + z^2)
      local color = Color { 
        r = coordToColor(relativeX / magnitude), 
        g = coordToColor(-relativeY / magnitude), 
        b = coordToColor(z / magnitude), 
      }

      outputImage:drawPixel(x, y, color)
      
      ::continue::
    end
  end
  
  app.activeSprite:newCel(layer, 1, outputImage, 
    Point(tonumber(dialog.data.xPosition) - width / 2, tonumber(dialog.data.yPosition) - height / 2))
  app.refresh()
end

dialog:entry {
  id="outputLayer",
  label = "Output Layer: ",
  text = "Output"
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

dialog:entry {
  id="roundedTo",
  label = "Rounded To: ",
  text = "1"
}

dialog:entry {
  id="imperfectionRange",
  label = "Imperfection Range: ",
  text = "0"
}

dialog:button {
  id="execute",
  text = "Execute",
  onclick = drawNormal
}

dialog:show()