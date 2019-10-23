; ====================================================================================================
; Function:       Interval-based reminder to help with eye strain and fatigue
; AHK version:    1.1.30.01 (U32)
; Script version: 1.0.00.02/2019-07-25/Max Lepper
; Credits:        Additonal eye graphics created from "open" state
;                 Audio files provided with Windows
; ====================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; This software is freeware with a Creative Commons Attribution-NonCommercial-ShareAlike License.
; ====================================================================================================

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1


; ****** EMBED INSTRUCTIONS ******
; Graphics
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\eye_open.png, %A_temp%\eye_open.png, 0
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\eye_closed.png, %A_temp%\eye_closed.png, 0
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\eye_left.png, %A_temp%\eye_left.png, 0
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\eye_right.png, %A_temp%\eye_right.png, 0

; Audio
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\chimes.wav, %A_temp%\chimes.wav, 0
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\complete.wav, %A_temp%\complete.wav, 0
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\paused.wav, %A_temp%\paused.wav, 0
FileInstall, C:\Users\mlepper.SCOTT\Documents\Personal\Scripts\Projects\EyeHelper\resume.wav, %A_temp%\resume.wav, 0


; ********** VARIABLES **********
; Vars for the main reminder timer
global reminderInterval = 20 ; in minutes
global reminderDuration = reminderInterval * 60 * 1000
global pauseActive := FALSE

; GUI coordinates
global guiX := 1505
global guiY := 0

; Animation vars
global imgState := 0
global animDuration := 1500
global blinkSegment := TRUE
global twentySegment := FALSE
global leftrightFlipper := FALSE

; GUI-friendly timer second values
global blinkSeconds := 10
global blinkCountdown := blinkSeconds
global twentySeconds := 20
global twentyCountdown := twentySeconds

; Timer-friendly millisecond values
global blinkDuration := blinkSeconds * 1000
global twentyDuration := twentySeconds * 1000


; ********** APP **********
MsgBox,
(
Eye Helper is now active! 
    
Your first notification will appear in %reminderInterval% minutes. 
Press F9 to pause/resume the reminder timer.
Press F10 at any time to close Eye Helper.
) 
StartLoop()
Return

; ********** FUNCTIONS **********

; We can't jump to labels from inside functions, soooo, start the reminder timer here!
StartLoop()
{
    SetTimer, ReminderTimer, %reminderDuration%
}

; When the reminder timer fires, alert the user and draw the GUI
ReminderTimer()
{
    SetTimer, ReminderTimer, Delete
    ; SoundPlay, %A_WinDir%\Media\Windows Ding.wav
    SoundPlay, %A_temp%\chimes.wav
    DrawGui()
}

; When our reminder interval fires, create a fresh GUI and reset variables that change
DrawGui()
{
    global

    blinkCountdown := blinkSeconds
    twentyCountdown := twentySeconds

    ; Add all of our images for the animations and build the GUI
    Gui, +AlwaysOnTop -Border
    gui, font, s14, Calibri 

    Gui Add, Picture, x10 y90 w180 h95 vleftOpen, %A_temp%\eye_open.png
    Gui Add, Picture, x10 y90 w180 h95 vleftClosed, %A_temp%\eye_closed.png
    Gui Add, Picture, x10 y90 w180 h95 vleftLookLeft, %A_temp%\eye_left.png
    Gui Add, Picture, x10 y90 w180 h95 vleftLookRight, %A_temp%\eye_right.png

    Gui Add, Picture, x220 y90 w180 h95 vrightOpen, %A_temp%\eye_open.png
    Gui Add, Picture, x220 y90 w180 h95 vrightClosed, %A_temp%\eye_closed.png
    Gui Add, Picture, x220 y90 w180 h95 vrightLookLeft, %A_temp%\eye_left.png
    Gui Add, Picture, x220 y90 w180 h95 vrightLookRight, %A_temp%\eye_right.png

    Gui Add, Text, x165 y190 w80 h40 Center vguiTimerVal, %blinkCountdown%
    Gui Add, Button, x165 y190 w80 h40 vstartButton gStartSegmentTimer, START

    Gui Add, Text, x10 y10 w390 h70 Center vguiMainText, It's time to blink and drink! Take a sip of water and then press start to begin %blinkSeconds% seconds of blinking.

    Gui Show, NoActivate x%guiX% y%guiY% w410 h240, Window


    ; Init with open eyes
    Guicontrol, Hide, leftClosed
    Guicontrol, Hide, rightClosed
    Guicontrol, Hide, leftLookLeft
    Guicontrol, Hide, rightLookLeft
    Guicontrol, Hide, leftLookRight
    Guicontrol, Hide, rightLookRight

    Guicontrol, Show, leftOpen
    Guicontrol, Show, rightOpen


    ; Timer for animations
    SetTimer, AnimTimer, %animDuration%
}

; Fires on START button press, handles all segments
StartSegmentTimer()
{
    if(blinkSegment = TRUE)
    {
        GuiControl, Text, guiTimerVal, %blinkCountdown%
        Guicontrol, Hide, startButton
        GuiControl, Text, guiMainText, Start blinking!
        SetTimer, BlinkExerciseTimer, %blinkDuration%
        SetTimer, TextUpdateTimer, 1000
    }
    if(twentySegment = TRUE)
    {
        GuiControl, Text, guiTimerVal, %twentyCountdown%
        Guicontrol, Hide, startButton
        GuiControl, Text, guiMainText, Start focusing!
        SetTimer, TwentyExerciseTimer, %twentyDuration%
        SetTimer, TextUpdateTimer, 1000
    }
}


; Fires on Blink exercise complete
BlinkExerciseTimer()
{
    blinkSegment := FALSE
    twentySegment := TRUE
    SetTimer, BlinkExerciseTimer, Delete 
    SetTimer, TextUpdateTimer, Delete
    SoundPlay, %A_temp%\chimes.wav

    GuiControl, Text, guiMainText, Now find something about 20 feet away and try to focus on it for the next %twentySeconds% seconds. Press start when you're ready.
    Guicontrol, Show, startButton
}


; Fires on Twenty exercise complete
TwentyExerciseTimer()
{
    ; Reset for the next interval
    blinkSegment := TRUE
    twentySegment := FALSE

    Gui, Destroy
    SetTimer, TwentyExerciseTimer, Delete 
    SetTimer, TextUpdateTimer, Delete
    SetTimer, AnimTimer, Delete 
    
    SoundPlay, %A_temp%\complete.wav
    
    ; Instead of being interrupted with a message box, put a new GUI in the same space
    Gui, +AlwaysOnTop -Border
    gui, font, s16, Calibri 

    Gui Add, Text, x10 y10 w390 h220 Center, 
    (
    Eye exercises complete! 
        
    You will be notified again in %reminderInterval% minutes. 
    Press F9 to pause/resume the reminder timer.
    Press F10 at any time to close Eye Helper.
    )

    Gui Show, NoActivate x%guiX% y%guiY% w410 h240, Window

    Sleep, 3000
    Gui, Destroy

    StartLoop()
}


; This updates the timer value while running
TextUpdateTimer()
{
    if((blinkSegment = TRUE) & (blinkCountdown > 0))
    {
        blinkCountdown -= 1
        GuiControl, Text, guiTimerVal, %blinkCountdown%
    }
    if((twentySegment = TRUE) & (twentyCountdown > 0))
    {
        twentyCountdown -= 1
        GuiControl, Text, guiTimerVal, %twentyCountdown%
    }
}


; This handles all of our animations for different segments
AnimTimer()
{
    if (blinkSegment = TRUE)
    {
        imgState := Mod((imgState + 1),2)
    }
    if (twentySegment = TRUE)
    {
        if (leftrightFlipper = FALSE)
        {
            if (imgState = 1)
            {
                imgState := 2
                leftrightFlipper := TRUE
            }
            else
            {
                imgState := 1
            }
        }
        else
        {
            if (imgState = 1)
            {
                imgState := 3
                leftrightFlipper := FALSE
            }
            else
            {
                imgState := 1
            }
        }
    }

    ; Redraw the images on the GUI according to the current mode    
    if (imgState = 0) 
    {
        Guicontrol, Hide, leftOpen
        Guicontrol, Hide, rightOpen
        Guicontrol, Hide, leftLookLeft
        Guicontrol, Hide, rightLookLeft
        Guicontrol, Hide, leftLookRight
        Guicontrol, Hide, rightLookRight

        Guicontrol, Show, leftClosed
        Guicontrol, Show, rightClosed
    }
    if (imgState = 1) 
    {
        Guicontrol, Hide, leftClosed
        Guicontrol, Hide, rightClosed
        Guicontrol, Hide, leftLookLeft
        Guicontrol, Hide, rightLookLeft
        Guicontrol, Hide, leftLookRight
        Guicontrol, Hide, rightLookRight

        Guicontrol, Show, leftOpen
        Guicontrol, Show, rightOpen
    }
    if (imgState = 2) 
    {
        Guicontrol, Hide, leftOpen
        Guicontrol, Hide, rightOpen
        Guicontrol, Hide, leftClosed
        Guicontrol, Hide, rightClosed
        Guicontrol, Hide, leftLookRight
        Guicontrol, Hide, rightLookRight

        Guicontrol, Show, leftLookLeft
        Guicontrol, Show, rightLookLeft
    }
    if (imgState = 3) 
    {
        Guicontrol, Hide, leftOpen
        Guicontrol, Hide, rightOpen
        Guicontrol, Hide, leftClosed
        Guicontrol, Hide, rightClosed
        Guicontrol, Hide, leftLookLeft
        Guicontrol, Hide, rightLookLeft

        Guicontrol, Show, leftLookRight
        Guicontrol, Show, rightLookRight
    }
}


; ********** HOTKEYS ********** 

F9::
    pauseActive := !pauseActive
    if (pauseActive = TRUE)
    {
        ; Clean up everything
        blinkSegment := TRUE
        twentySegment := FALSE

        Gui, Destroy
        SetTimer, ReminderTimer, Delete
        SetTimer, BlinkExerciseTimer, Delete 
        SetTimer, TwentyExerciseTimer, Delete 
        SetTimer, TextUpdateTimer, Delete
        SetTimer, AnimTimer, Delete 
        
        SoundPlay, %A_temp%\paused.wav
        
        ; Instead of being interrupted with a message box, put a new GUI in the same space
        Gui, +AlwaysOnTop -Border
        gui, font, s16, Calibri 

        Gui Add, Text, x10 y10 w390 h220 Center, 
        (
        Eye Helper is currently suspended.

        Press F9 again to restart the reminder timer.
        Press F10 to exit.
        )

        Gui Show, NoActivate x%guiX% y%guiY% w410 h240, Window

        Sleep, 1500
        Gui, Destroy
        Return
    }
    
    if (pauseActive = FALSE)
    {
        ; Instead of being interrupted with a message box, put a new GUI in the same space
        Gui, +AlwaysOnTop -Border
        gui, font, s16, Calibri 

        SoundPlay, %A_temp%\resume.wav

        Gui Add, Text, x10 y10 w390 h220 Center, 
        (
        Eye Helper is now resumed!

        Your first notification will appear in %reminderInterval% minutes. 
        Press F9 to pause the reminder timer.
        Press F10 at any time to close Eye Helper.
        )

        Gui Show, NoActivate x%guiX% y%guiY% w410 h240, Window

        Sleep, 1500
        Gui, Destroy

        StartLoop()
    }
    Return

F10:: 
    Gui, Destroy
    SetTimer, ReminderTimer, Delete
    SetTimer, BlinkExerciseTimer, Delete 
    SetTimer, TwentyExerciseTimer, Delete 
    SetTimer, TextUpdateTimer, Delete
    SetTimer, AnimTimer, Delete 
    MsgBox, Eye Helper stopped!
    ExitApp