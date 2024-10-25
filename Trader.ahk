﻿Loop, %0%
{
 param := %A_Index%
 params .= A_Space . param
}
ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
if not A_IsAdmin
{
 If A_IsCompiled
  DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
 Else
  DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
 ExitApp
}

#NoEnv
#KeyHistory 0
#NoTrayIcon
#SingleInstance,ignore
ListLines, Off
SetWinDelay, 0
SetKeyDelay,0
SetBatchLines, -1

SkinForm(Apply, A_ScriptDir . "\img\USkin.dll", A_ScriptDir . "\img\Relapse.msstyles")


gosub, trader1
return

trader1:
            {
                SetBatchLines, -1
                coordmode, pixel, screen
                coordmode, mouse, screen
                coordmode, tooltip, screen
                OnMessage(0x201, "LButton_Down")


                Gui,7:Add,Picture,x0 y0, %Main%
                Gui,7:Font,S10 bold,Arial
                Gui,7:Add,StatusBar,x0 y130 w200 h10 vstt,
                Gui,7:Add,Button,x0 y122 w88 h40 gbtn1,시작
                Gui,7:Add,Button,x88 y122 w88 h40 gbtn3,정지
                Gui,7:Add,Button,x176 y122 w88 h40 gbtn2,구역
                Gui,7:Add,Button,x263 y122 w88 h40 gbtn4,로그아웃
                gui,7:add,button,x0 y122 w88 h40 gbtn5, 재시작
                GuiControl,7: hide, 재시작
                Gui,7:Add,Checkbox, x250 y98 w15 h15 vCheck3, ;판매 전용
                Gui,7:Add,CheckBox, x100 y98 w15 h15 vCheck1, ;익절 버튼
                Gui,7:Add,CheckBox, x200 y98 w15 h15 vCheck2, ;손절 버튼
                gui,7:Add,Checkbox, x320 y98 w15 h15 vCheck4, ;익절감지스탑버튼
                gui,7:+alwaysontop +ToolWindow
                Gui,7:Show,w345 h185, Winning 프로그램 V%curVer%
                guicontrol,7: disable,정지
                return



                btn3:
                guicontrol,7: Disable, 정지
                FormatTime,now,% A_Now,hh:mm:ss
                SB_SetText("♬" now . " 정지 되었습니다.")
                guicontrol,7: hide0, 재시작
                guicontrol,7: enable, check1
                guicontrol,7: enable, Check2
                guicontrol,7: enable, Check3
                Pause
                Return

                btn5:
                pause, toggle
                guicontrol,7:hide, 재시작
                guicontrol,7:hide, 재시작
                FormatTime,now,% A_Now,hh:mm:ss
                SB_SetText("♬" now . " 재시작 되었습니다.")
                guicontrol,7:enable, 정지
                Return

                btn4:
                gosub, doLoginStop
                ExitApp
                return

                7GuiClose:
                gosub, doLoginStop
                ExitApp
                return



                btn1:
                GuiControl,7: Disable, 시작
                FormatTime,now,% A_Now,hh:mm:ss
                SB_SetText("♬" now . "시작 되었습니다.")
                guicontrol,7: enable, 정지
                CoordMode, Mouse, Screen
                CoordMode, Pixel, Screen
                GuiControlGet, check1
                guicontrolget, Check2
                guicontrolget, Check3
                guicontrolget, check4
                


                if (Check3 = 0 && check4 = 0)
                {
                    GuiControlGet, Check1
                    guicontrolget, Check2
                    if(check1 = 0 || check2 = 0)
                    {
                        guicontrol, 7: Disable, Check3
                        guicontrol, 7: disable, check4    
                    }
                    loop
                    {
                        PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_2, , RGB Fast ;좌표에서 파란색 검색
                        if (ErrorLevel = 1) ;없을때
                        {
                            FormatTime,now,% A_Now,hh:mm:ss
                            SB_SetText("♬" now . " 매수 완료")
                            sleep 500
                            ControlClick, TXiButton4, ahk_class TMap_Frm ;매수
                            GuiControlGet, Check1
                            if (Check1 = 1)
                            {
                                ikson(Ikjul)
                            }
                            Guicontrolget, Check2
                            if (Check2 = 1)
                            {
                                ikson(sonjul)
                            }
                            loop
                            {
                                PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_2, , RGB Fast
                                if (ErrorLevel = 0)
                                {
                                    ControlClick, TXiButton7, ahk_class TMap_Frm ; 청산
                                    FormatTime,now,% A_Now,hh:mm:ss
                                    SB_SetText("♬" now . " 청산 완료")
                                    Break
                                }
                            }
                        }
                        Else ;파란색 있을때
                        {
                            PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_1, ,Fast RGB ;빨간색 검색
                            if (ErrorLevel = 1) ;빨간색 없을때
                            {
                                FormatTime,now,% A_Now,hh:mm:ss
                                SB_SetText("♬" now . " 매도 완료")
                                ControlClick, TXiButton5, ahk_class TMap_Frm ; 매도
                                sleep 500
                                GuiControlGet, Check1
                                if (Check1 = 1)
                                {
                                    sleep 500
                                    ikson(Ikjul)
                                }

                                Guicontrolget, Check2
                                if (Check2 = 1)
                                {
                                    sleep 500
                                    ikson(sonjul)
                                }
                                loop
                                {
                                    PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_1, , Fast RGB ;빨간색 검색
                                    if (ErrorLevel = 0)
                                    {
                                        ControlClick, TXiButton7, ahk_class TMap_Frm ; 청산
                                        FormatTime,now,% A_Now,hh:mm:ss
                                        SB_SetText("♬" now . " 청산 완료")
                                        Break
                                    }
                                }
                            }
                        }
                    }
                }
                if(Check3 = 1)
                {
                    GuiControl, 7: disable, check1
                    guicontrol, 7: disable, Check2
                    guicontrol, 7: disable, check4
                    loop
                    {
                        PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_2, , RGB Fast ;좌표에서 파란색 검색
                        if (ErrorLevel = 1) ;없을때
                        {
                            FormatTime,now,% A_Now,hh:mm:ss
                            SB_SetText("♬" now . " 매수 신호 확인")
                            sleep 500
                            loop
                            {
                                PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_2, , RGB Fast
                                if (ErrorLevel = 0)
                                {
                                    ControlClick, TXiButton7, ahk_class TMap_Frm ; 청산
                                    FormatTime,now,% A_Now,hh:mm:ss
                                    SB_SetText("♬" now . " 청산 완료")
                                    Break
                                }
                            }
                        }
                        Else ;파란색 있을때
                        {
                            PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_1, ,Fast RGB ;빨간색 검색
                            if (ErrorLevel = 1) ;빨간색 없을때
                            {
                                FormatTime,now,% A_Now,hh:mm:ss
                                SB_SetText("♬" now . " 매도 신호 감지")
                                loop
                                {
                                    PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_1, , Fast RGB ;빨간색 검색
                                    if (ErrorLevel = 0)
                                    {
                                        ControlClick, TXiButton7, ahk_class TMap_Frm ; 청산
                                        FormatTime,now,% A_Now,hh:mm:ss
                                        SB_SetText("♬" now . " 청산 완료")
                                        Break
                                    }
                                }
                            }
                        }
                    }
                }
                if (check4 = 1)
                {
                    GuiControl, 7: disable, check1
                    guicontrol, 7: disable, Check2
                    guicontrol, 7: disable, check3


                    PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_2, , RGB Fast ;좌표에서 파란색 검색
                    if (ErrorLevel = 1) ;없을때
                    {
                        FormatTime,now,% A_Now,hh:mm:ss
                        SB_SetText("♬" now . " 매수 신호 확인")
                        sleep 500
                        loop
                        {
                            PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_2, , RGB Fast
                            if (ErrorLevel = 0)
                            {
                                ControlClick, TXiButton7, ahk_class TMap_Frm ; 청산
                                FormatTime,now,% A_Now,hh:mm:ss
                                SB_SetText("♬" now . " 청산 완료")
                                MsgBox, 오작동 방지를 위해 종료합니다.
                                gosub, doLoginStop
                                ExitApp
                                Break
                            }
                        }
                    }
                    Else ;파란색 있을때
                    {
                        PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_1, ,Fast RGB ;빨간색 검색
                        if (ErrorLevel = 1) ;빨간색 없을때
                        {
                            FormatTime,now,% A_Now,hh:mm:ss
                            SB_SetText("♬" now . " 매도 신호 감지")
                            loop
                            {
                                PixelSearch, xp, yp, MX_1, MY_1, MX_2, MY_2, pxl_code_1, , Fast RGB ;빨간색 검색
                                if (ErrorLevel = 0)
                                {
                                    ControlClick, TXiButton7, ahk_class TMap_Frm ; 청산
                                    FormatTime,now,% A_Now,hh:mm:ss
                                    SB_SetText("♬" now . " 청산 완료")
                                    MsgBox, 오작동 방지를 위해 종료합니다.
                                    gosub, doLoginStop
                                    ExitApp
                                    Break
                                }
                            }
                        }
                    }
                }
            }
            ;-----------------------------------------------------GUI 버튼 2번 ~
            ikson(iksonimg) ;익절, 손절 마우스 클릭 함수
            {
                WinActivate, ahk_class TMap_Frm
                ImageSearch, ximage6, yimage6, 0, 0, A_ScreenWidth, A_ScreenHeight, %iksonimg%
                if (Errorlevel = 0)
                {
                    sleep 100
                    MouseClick, left, ximage6, yimage6, 1
                    mousemove, 0, 0
                }
            }

            btn2:
            FormatTime,now,% A_Now,hh:mm:ss
            SB_SetText("♬" now . " 인식할 구역을 셋팅하세요.")


            Gui, Submit, NoHide
            SetBatchLines, -1
            CoordMode, pixel, screen
            CoordMode, mouse, screen
            KeyWait, LButton, Down
            MouseGetPos, MX_1, MY_1
            FormatTime,now,% A_Now,hh:mm:ss
            SB_SetText("♬" now . " 구역 셋팅 완료")





            GUI,2:Default
            Gui,2: +alwaysontop -caption + Border + LastFound +ToolWindow
            winset, TransColor, F0F0F0,
            While( getkeystate( "Lbutton", "P") )
            {
                    MouseGetPos, MX_2, MY_2
                    gui,2: show, % "x" MX_1 " y" MY_1 " w" MX_2 - MX_1 " h" MY_2 - MY_1, first_square_gui
            }

            X := MX_1
            Y := MY_1
            W := MX_2 - MX_1
            H := MY_2 - MY_1
            hthickness := 2
            wthickness := 2



            Gui,3:+alwaysontop +toolwindow -caption
            Gui,3:color,0XFFE400
            Gui,4:+alwaysontop +toolwindow -caption
            Gui,4:color,0XFFE400
            Gui,5:+alwaysontop +toolwindow -caption
            Gui,5:color,0XFFE400
            Gui,6:+alwaysontop +toolwindow -caption
            Gui,6:color,0XFFE400



            Gui,3:show , x%MX_1%  y%MY_1% w%W% h%hthickness%, firstline_gui
            Gui,4:show , x%MX_1%  y%MY_1% w%wthickness% h%H%, secondline_gui
            Gui,5:show , x%MX_2%  y%MY_1% w%wthickness% h%H%, thirdline_gui
            Gui,6:show , x%MX_1% y%MY_2% w%W% h%hthickness%, fourthline_gui
Return


#Include .\SkinForm.ahk
#Include .\login.ahk
#include .\include\uriencode.ahk
#Include .\include\Crypt.ahk
#Include .\include\CryptConst.ahk
#Include .\include\CryptFoos.ahk