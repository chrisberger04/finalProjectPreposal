-- ADAPTED FROM HARVARD CS50X GAMES TUTORIAL: https://cs50.harvard.edu/x/2020/tracks/games/

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PLADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    math.randomseed(os.time())
    
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Progressive Pong')
    
    smallFont = love.graphics.newFont('progress.ttf', 12)
    fpsFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    image = love.graphics.newImage('Flo.png') 

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    player1score = 0
    player2score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2
    winningPlayer = 0

    player1 = Paddle(5, 20, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5 ,20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT /2 - 2, 5, 5)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = 'start'
end


function love.update(dt)

    if ball:collides(player1) then
        -- deflect ball to right
        ball.dx = -ball.dx

        sounds['paddle_hit']:play()
    end

    if ball:collides(player2) then
        -- deflect ball to left
        ball.dx = -ball.dx

        sounds['paddle_hit']:play()
    end

    if ball.y <= 0 then
        -- deflect ball down
        ball.dy = -ball.dy
        ball.y = 0

        sounds['wall_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4

        sounds['wall_hit']:play()
    end


    if ball.x <= 0 then
        player2score = player2score + 1
        servingPlayer = 1
        ball:reset()
        sounds['point_scored']:play()
        ball.dx = 100

        if player2score >= 3 then
            gameState = 'victory'
            winningPlayer = 2
        else
            gameState = 'serve'
        end    

    end

    if ball.x >= VIRTUAL_WIDTH - 4 then
        player1score = player1score + 1
        servingPlayer = 2
        ball:reset()
        sounds['point_scored']:play()
        ball.dx = -100

        if player1score >= 3 then
            gameState = 'victory'
            winningPlayer = 1
        else
            gameState = 'serve'
        end  
    end

    player1.y = ball.y

    if love.keyboard.isDown('up') then
        player2.dy = -PLADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PLADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)

end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1score = 0
            player2score = 0
        elseif gameState == 'serve' then 
            gameState = 'play'
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(45/255, 149/255, 229/255, 255/255)

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to Progressive Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Can you beat Flo? Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(image)
    elseif gameState == 'serve' then
        love.graphics.setFont(fpsFont)
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Serve!", 0, 42, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score, VIRTUAL_WIDTH/ 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2score, VIRTUAL_WIDTH/ 2 + 30, VIRTUAL_HEIGHT / 3)

    player1:render()
    player2:render()

    ball:render()

    displayFPS()
    
    push:apply('end')
end


function displayFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(fpsFont)
    love.graphics.print('FPS' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end


function displayScore()
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end