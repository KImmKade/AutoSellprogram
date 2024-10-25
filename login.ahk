Loop, %0%
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

buy := "img\buys.bmp" ;매수
sell := "img\sells.bmp" ;매도
liq := "img\liq.png" ;청산
ikjul := "img\Ikjul.png" ;익절
sonjul := "img\Sonjul.png" ;손절
Main := "img\Main.PNG" ;메인이미지
MainT := "img\MainT.PNG" ;수동이미지
pxl_code_1 := "0XFF0032" ;빨강색
pxl_code_2 := "0X0000FA" ;파란색
curVer := 1.0 ; 버전

urldownloadtofile, http://citrus0831.cafe24.com/aiaru/ver.txt, ver.txt ;버전


fileread, UpdateVer, ver.txt
filedelete, ver.txt



if(curVer!=UpdateVer)
{
      msgbox, 이전 버전입니다. `n잠시후 프로그램이 재실행 됩니다.
      run, http://idrs1504.cafe24.com/Futhtml
      exitapp
}


    ;글로벌 변수 선언
    global OutData :=
    global UserID :=
    global UserPW :=
    global UseDay :=
    global UserStat :=
    global default_url 		:= "http://idrs1504.cafe24.com/aiaru"
    global code_php_url 	:= default_url . "/Code/Code.php"
    global member_php_url 	:= default_url . "/Members/Members.php"
    global time_url 		:="http://free.timeanddate.com/clock/i48q1xm9/n235/tlkr47/tt1/tw0/tm3/td2"
    global whttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")

    ;암복호화키(꼭 기억하셔야합니다. 키가 바뀌면 이전키로 암호화된 데이터는 키값이 다르기 때문에 복호화가 불가능합니다.)
    ;되도록이면 처음 한번 셋팅한 키값으로만 사용하시기 바랍니다.
    global aes_pw := "0511"
    global aes_typ := 7 ;aes_256 
    global hash_typ := 4 ;sha_256

    ;GUI 생성
    Gui,1: font,bold,s12
    Gui,1: Add, Text, x0 y9 w350 h20 +Center, Winning Trader
    Gui,1: Add, Text, x17 y39 w100 h20 +Center, 계 정
    Gui,1: Add, Text, x5 y69 w100 h20 +Center,  계정 비번
    Gui,1: Add, Edit, x100 y39 w140 h20 vEditLoginID, 
    Gui,1: Add, Edit, x100 y69 w140 h20 vEditLoginPW Password*, 
    Gui,1: Add, Button, x250 y39 w90 h50 gBtnLogin, 로그인
    Gui,1: Add, Button, x100 y99 w70 h30 gshow,안내
    Gui,1: Add, Button, x170 y99 w70 h30 gBtnSignPopWin, 회원가입
    Gui,1: Add, Button, x250 y99 w90 h30 gexit,종료
    Gui,1: Show, w350 h143, [로그인]
    return

    ;로그인 버튼클릭 이벤트
    BtnLogin:
        gosub, doLoginStart
    return

    Enter::
    gosub, doLoginStart
    return

    NumpadEnter::
    gosub, doLoginStart
    return

    ;회원가입 버튼클릭 이벤트
    BtnSignPopWin:
        gosub, CreatePopDlg ;회원가입 윈도우 생성
    return

    show:
    GUI,10: Show, w320 h130,[위닝트레이더 Q&A]
    GUI,10: ADD, Text, x90 y10 w150 h20 +Center,위닝트레이더 문의
    GUI,10: ADD, Text, x5 y40 w200 h20,1. 이용기간은 1계약당 30일입니다.
    return

    exit:
    ExitApp
    return

    ;로그인 함수
    doLoginStart:

        ;모든 GUI값 가져오기
        Gui,1: Submit, nohide
        
        ;global 변수 초기화
        OutData :=
        UserID  :=
        UserPW  :=
        UseDay  :=
        UserStat :=
        
        ;모든 에디트박스 유효검사
        if(EditLoginID="" || EditLoginPW="")
        {
            msgbox, 입력이 올바르지 않습니다.
            ExitApp
            return
        }
        
        ;계정존재체크
        UserID := EditLoginID
        member_url := default_url . "/Members/" . UserID
        whttp.Open("GET", member_url)
        whttp.Send()	
        whttp.WaitForResponse()
        url_out_data0 := whttp.ResponseText
        res_member := InStr(url_out_data0, "|")
        if(res_member <= 0)
        {
            msgbox, 계정이 존재하지 않습니다.
            ExitApp
            return
        }	
        
        StringSplit, OutData, url_out_data0, |
        OutData1 := Crypt.Encrypt.StrDecrypt(OutData1, aes_pw, aes_typ, hash_typ)
        OutData2 := Crypt.Encrypt.StrDecrypt(OutData2, aes_pw, aes_typ, hash_typ)
        OutData3 := Crypt.Encrypt.StrDecrypt(OutData3, aes_pw, aes_typ, hash_typ)
        
        ;비밀번호 체크
        if(OutData1 != EditLoginPW)
        {
            msgbox, [접속오류!] 비밀번호가 틀립니다.
            ExitApp
            return
        }
        
        ;중복접속체크
        if(OutData3 = "[ON]")
        {
            msgbox, [중복접속!] 이미 접속 된 계정이 존재합니다.
            ExitApp
            return
        }
        
        ;남은 이용일수 체크	
        whttp.Open("GET", time_url)
        whttp.Send()
        whttp.WaitForResponse()
        url_out_date := whttp.ResponseText
        RegExMatch(url_out_date, "(\d{4}-\d{2}-\d{2})", OutArray)	
        today := StrReplace(OutArray1 ,"-" ,"") ;현재일자
        useday := StrReplace(OutData2 ,"-" ,"" ) ;이용일자	
        useday -= today, days ;남은일수=이용일자-현재일자
        if(useday <= 0)
        {
            msgbox, [기간만료!] 이용기간이 만료되었습니다.
            ExitApp
            return	
        }
        
        ;계정 상태변경
        UserID   := EditLoginID
        UserPW := Crypt.Encrypt.StrEncrypt(EditLoginPW, aes_pw, aes_typ, hash_typ)	
        UseDay := Crypt.Encrypt.StrEncrypt(OutData2, aes_pw, aes_typ, hash_typ)
        UserStat:= Crypt.Encrypt.StrEncrypt("[ON]", aes_pw, aes_typ, hash_typ)		
        whttp.Open("POST", member_php_url)
        whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        whttp.Send("UserID=" . UriEncode(UserID) . "&State=" . UriEncode(UserPW . "|" . UseDay . "|" . UserStat))
        whttp.WaitForResponse()
        {
            MsgBox, 만료날짜 : %OutData2%
            gui,1: Hide
            Hotkey, enter, Off
            Hotkey, NumpadEnter, Off
            gosub, trader1
            return
        }

;로그인 종료함수
    doLoginStop:

        ;로그인->종료 시 계정 상태 OFF로 변경
        UserStat:= Crypt.Encrypt.StrDecrypt(UserStat, aes_pw, aes_typ, hash_typ)	
        if(UserStat = "[ON]")
        {
            UserID   := EditLoginID
            UserPW := Crypt.Encrypt.StrEncrypt(EditLoginPW, aes_pw, aes_typ, hash_typ)	
            UseDay := Crypt.Encrypt.StrEncrypt(OutData2, aes_pw, aes_typ, hash_typ)
            UserStat:= Crypt.Encrypt.StrEncrypt("[OFF]", aes_pw, aes_typ, hash_typ)		
            whttp.Open("POST", member_php_url)
            whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
            whttp.Send("UserID=" . UriEncode(UserID) . "&State=" . UriEncode(UserPW . "|" . UseDay . "|" . UserStat))
            whttp.WaitForResponse()	
        }
    return


GuiClose:
gosub, doLoginStop
ExitApp
return


#include .\SkinForm.ahk
#include .\SignUp.ahk
#include .\License.ahk
#include .\Trader.ahk