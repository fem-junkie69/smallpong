#NoEnv
#Persistent
SetBatchLines, -1
SetWinDelay, -1

GameWidth := 800
GameHeight := 600

BallSize := 10
BallX := GameWidth // 2
BallY := GameHeight // 2
BallSpeedX := 5
BallSpeedY := 5

PaddleWidth := 10
PaddleHeight := 100
PlayerPaddleX := 50
PlayerPaddleY := (GameHeight // 2) - (PaddleHeight // 2)
OpponentPaddleX := GameWidth - 50 - PaddleWidth
OpponentPaddleY := (GameHeight // 2) - (PaddleHeight // 2)
PaddleSpeed := 10
OpponentBaseSpeed := 7 ; Base speed for opponent
OpponentSpeed := OpponentBaseSpeed ; Initial opponent speed

Score := 0
HitCount := 0 ; Counter for hits

SpeedMultiplier := 0.1 ; Slower increase in speed for ball
OpponentSpeedIncreaseRate := 0.1 ; Slower increase for opponent paddle speed per hit

Gui, +AlwaysOnTop -Caption
Gui, Show, w%GameWidth% h%GameHeight%, Pong
Gui, Add, Button, x10 y10 w70 h30 gExitGame, Exit

SetTimer, UpdateGame, 16
Return

UpdateGame:
    BallX += BallSpeedX
    BallY += BallSpeedY

    if (BallY <= 0 || BallY + BallSize >= GameHeight)
        BallSpeedY := -BallSpeedY

    ; Player Paddle Collision
    if (BallX <= PlayerPaddleX + PaddleWidth && BallY + BallSize >= PlayerPaddleY && BallY <= PlayerPaddleY + PaddleHeight) {
        BallSpeedX := -BallSpeedX
        BallX := PlayerPaddleX + PaddleWidth
        HitCount++ ; Increment hit counter
        BallSpeedX += (BallSpeedX > 0 ? SpeedMultiplier : -SpeedMultiplier) ; Increase speed in X direction slowly
        BallSpeedY += (BallSpeedY > 0 ? SpeedMultiplier : -SpeedMultiplier) ; Increase speed in Y direction slowly
    }

    ; Opponent Paddle Collision
    if (BallX + BallSize >= OpponentPaddleX && BallY + BallSize >= OpponentPaddleY && BallY <= OpponentPaddleY + PaddleHeight) {
        BallSpeedX := -BallSpeedX
        BallX := OpponentPaddleX - BallSize
        HitCount++ ; Increment hit counter
        BallSpeedX += (BallSpeedX > 0 ? SpeedMultiplier : -SpeedMultiplier) ; Increase speed in X direction slowly
        BallSpeedY += (BallSpeedY > 0 ? SpeedMultiplier : -SpeedMultiplier) ; Increase speed in Y direction slowly
    }

    if (BallX <= 0 || BallX + BallSize >= GameWidth) {
        MsgBox, 64, Game Over, Final Score: %Score%`nPress OK to restart.
        Reload
    }

    if GetKeyState("Up", "P") and PlayerPaddleY > 0
        PlayerPaddleY -= PaddleSpeed
    if GetKeyState("Down", "P") and PlayerPaddleY + PaddleHeight < GameHeight
        PlayerPaddleY += PaddleSpeed

    ; Gradual increase in opponent paddle speed after each hit
    OpponentSpeed := OpponentBaseSpeed + (HitCount * OpponentSpeedIncreaseRate)

    ; Improved AI to better track the ball
    if (BallSpeedX > 0) { ; Only move when the ball is approaching
        if (BallY < OpponentPaddleY + PaddleHeight // 2 && OpponentPaddleY > 0)
            OpponentPaddleY -= OpponentSpeed
        else if (BallY > OpponentPaddleY + PaddleHeight // 2 && OpponentPaddleY + PaddleHeight < GameHeight)
            OpponentPaddleY += OpponentSpeed
    }

    Gosub, RedrawGame
Return

RedrawGame:
    Gui, +LastFound
    hdc := DllCall("GetDC", "Ptr", WinExist())
    DllCall("Gdi32.dll\Rectangle", "Ptr", hdc, "Int", 0, "Int", 0, "Int", GameWidth, "Int", GameHeight) ; Clear screen
    DllCall("Gdi32.dll\Rectangle", "Ptr", hdc, "Int", PlayerPaddleX, "Int", PlayerPaddleY, "Int", PlayerPaddleX + PaddleWidth, "Int", PlayerPaddleY + PaddleHeight) ; Draw Player Paddle
    DllCall("Gdi32.dll\Rectangle", "Ptr", hdc, "Int", OpponentPaddleX, "Int", OpponentPaddleY, "Int", OpponentPaddleX + PaddleWidth, "Int", OpponentPaddleY + PaddleHeight) ; Draw Opponent Paddle
    DllCall("Gdi32.dll\Ellipse", "Ptr", hdc, "Int", BallX, "Int", BallY, "Int", BallX + BallSize, "Int", BallY + BallSize) ; Draw Ball
    
    DllCall("ReleaseDC", "Ptr", WinExist(), "Ptr", hdc)
Return

ExitGame:
    ExitApp
