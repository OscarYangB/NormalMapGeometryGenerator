local dialog = Dialog("Normal Map Shape Generator")

function coordToColor(coord)
  return (coord / 2 + 0.5) * 255
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
  local layer = getLayer(dialog.data.outputLayer)
  
  local outputImage = Image(200, 300)
  
  local radius = tonumber(dialog.data.radius)
  
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
        a = 255
      }

      --print(coordToColor(x / magnitude))
      outputImage:drawPixel(x + radius, y + radius, color)
      
      ::continue::
    end
  end
  
  app.activeSprite:newCel(layer, 1, outputImage, Point(tonumber(dialog.data.xPosition), tonumber(dialog.data.yPosition)))
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

dialog:button {
  id="execute",
  text = "Execute",
  onclick = drawNormal
}

dialog:show()