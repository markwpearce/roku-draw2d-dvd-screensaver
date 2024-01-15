' Main() function provided for convenience - real screensavers are run from runScreenSaver()
' but this makes it easier to side load as an app to debug
sub main()
  runScreenSaver()
end sub


' All screensavers in the Roku environment use the RunScreenSaver() function
sub runScreenSaver()
  ' Set the size of the screen
  screenSize = {width: 1920, height: 1080}

  ' Load Image files
  logoImage = CreateObject("roBitmap", "pkg:/images/rokulogo.jpg")
  logoSize = {width: logoImage.getWidth(), height: logoImage.getHeight()}

  ' Get the bounds for when the logo will bounce
  logoBounds = {
    x: screenSize.width - logoSize.width,
    y: screenSize.height - logoSize.height
  }

  ' Get a random starting position
  logoPosition = {
    x: rnd(screenSize.width - logoSize.width),
    y: rnd(screenSize.height - logoSize.height)
  }

  ' Keep track of direction: 1 is right or down, -1 is left or up
  direction = {
    x: 1,
    y: 1
  }

  ' How fast should the image move? (in pixels)
  speedPerSecond = 200

  ' Make the screen object to draw to
  screen = CreateObject("roScreen", true, screenSize.width, screenSize.height)
  screen.setAlphaEnable(true)

  ' Add a message port to the screen so we can listen for input
  inputPort = CreateObject("roMessagePort")
  screen.setMessagePort(inputPort)
  frameTimer = CreateObject("roTimespan")

  shouldChangeColorOnBounce = true

  ' Set the blend color to white (no change) at start
  blendColor = -1

  while true
    ' Check if there was any input
    inputMsg = inputPort.GetMessage()
    if type(inputMsg) = "roUniversalControlEvent"
      ' Exit on any remote control key press
      exit while
    end if

    ' Clear the screen to black
    screen.clear(256)

    ' Draw the image
    screen.drawObject(logoPosition.x, logoPosition.y, logoImage, blendColor)

    ' How long has it been since the last frame?
    lastFrameTimeSeconds = frameTimer.TotalMilliseconds() / 1000

    ' Get positions for where the logo will be if it continues moving in same direction
    nextX = logoPosition.x + direction.x * speedPerSecond * lastFrameTimeSeconds
    nextY = logoPosition.y + direction.y * speedPerSecond * lastFrameTimeSeconds

    didBounce = false

    ' Check X and Y location for if it went outside the bounds
    ' If it did, fix position, and change direction
    if nextX < 0
      nextX = abs(nextX)
      direction.x *= -1
      didBounce = true
    else if nextX > logoBounds.x
      offerRun = nextX - logoBounds.x
      nextX = logoBounds.x - offerRun
      direction.x *= -1
      didBounce = true
    end if

    if nextY < 0
      nextY = abs(nextY)
      direction.Y *= -1
      didBounce = true
    else if nextY > logoBounds.y
      offerRun = nextY - logoBounds.y
      nextY = logoBounds.y - offerRun
      direction.y *= -1
      didBounce = true
    end if

    logoPosition = {
      x: nextX,
      y: nextY
    }

    if didBounce and shouldChangeColorOnBounce
      blendColor = getRandomColor()
    end if

    ' Mark the time, so we can calculate how long this frame took
    frameTimer.mark()

    ' Draw to the screen
    screen.swapBuffers()
  end while
end sub

' Gets a random RGB color
function getRandomColor() as integer
  red% = rnd(255)
  green% = rnd(255)
  blue% = rnd(255)
  return (red% << 24) + (green% << 16) + (blue% << 8) + 255
end function

