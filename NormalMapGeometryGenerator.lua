local dialog = Dialog("Normal Map Shape Generator")

function coordToColor(coord)
  return roundTo((coord / 2 + 0.5) * 255, tonumber(dialog.data.roundedTo))
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
  local radius = tonumber(dialog.data.radius)
  local layer = getLayer(dialog.data.outputLayer)
  
  local outputImage = Image(radius * 2, radius * 2)
  
  for x = -radius, radius do
    for y = -radius, radius do
      local zSquared = radius^2 - x^2 - y^2;
      
      if zSquared < 0 then
        goto continue
      end
      
      local z = math.sqrt(zSquared)
      local magnitude = math.sqrt(x^2 + y^2 + z^2)
      local color = Color { 
        r = coordToColor(x / magnitude), 
        g = coordToColor(-y / magnitude), 
        b = coordToColor(z / magnitude), 
      }

      outputImage:drawPixel(x + radius, y + radius, color)
      
      ::continue::
    end
  end
  
  app.activeSprite:newCel(layer, 1, outputImage, 
    Point(tonumber(dialog.data.xPosition) - radius, tonumber(dialog.data.yPosition) - radius))
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
  id="radius",
  label = "Radius: ",
  text = "10"
}

dialog:entry {
  id="roundedTo",
  label = "Rounded To: ",
  text = "1"
}

dialog:button {
  id="execute",
  text = "Execute",
  onclick = drawNormal
}

dialog:show()