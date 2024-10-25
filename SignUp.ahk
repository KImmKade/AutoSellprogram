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

gosub, CreatePopDlg
return

;회원가입 윈도우 생성
CreatePopDlg:
	Gui,2:+ToolWindow
	Gui,2:font,bold,s12
	Gui,2:Add, Text, x40 y8 w200 h20 +Center, 회원가입
	Gui,2:Add, Text, x35 y33 w80 h20 +Center, 계정
	Gui,2:Add, Text, x25 y63 w80 h20 +Center, 비밀번호
	Gui,2:Add, Text, x5 y93 w90 h20 +Center, 비밀번호 확인
	Gui,2:Add, Edit, x120 y33 w110 h20 vEditUserID,
	Gui,2:Add, Edit, x120 y63 w110 h20 vEditUserPW Password*,
	Gui,2:Add, Edit, x120 y93 w110 h20 vEditUserPW2 Password*,
	Gui,2:Add, Text, x35 y124 w80 h20 +Center, S/N
	Gui,2:Add, Edit, x120 y124 w110 h20 vEditUserSN,
	Gui,2:Add, Button, x120 y159 w110 h30 gBtnSign, 회원가입
	Gui,2:Show, w250 h199, [회원가입]
return

2GuiClose:
ExitApp
Return

BtnSign:

	Gui, Submit, nohide
	
	;모든 에디트박스 유효검사
	if(EditUserID="" || EditUserPW="" || EditUserPW2="" || EditUserSN="")
	{
		msgbox, 입력이 올바르지 않습니다.
		return
	}
	
	;계정중복체크
	UserID := EditUserID
	member_url := default_url . "/Members/" . UserID
	whttp.Open("GET", member_url)
	whttp.Send()	
	whttp.WaitForResponse()
	url_out_data0 := whttp.ResponseText
	res_member := InStr(url_out_data0, "|")
	if(res_member > 0)
	{
		msgbox, 계정이 존재 합니다.
		return
	}
	
	;비밀번호확인
	if(EditUserPW != EditUserPW2)
	{
		msgbox, 비밀번호가 동일하지 않습니다.
		return	
	}
	else
	{
		UserPW := EditUserPW
	}	
	
	;라이센스 코드 확인
	;해당 쿠폰의 이용일수 확인
	SN := EditUserSN
	sn_url := default_url . "/Code/" . SN
	whttp.Open("GET", sn_url)
	whttp.Send()	
	whttp.WaitForResponse()
	url_out_data := whttp.ResponseText
	
	;쿠폰이 존재하지 않으면 html header를 생성하므로 header에서 <구분자로 쿠폰 존재여부 판단
	res := InStr(url_out_data, "<") 
	if(res=0) 
	{
		CodeDate := url_out_data
		 
		;인증받은 코드삭제			
		whttp.Open("POST", code_php_url)
		whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		whttp.Send("MyCode=" . UriEncode(SN))
		whttp.WaitForResponse()
		
		;현재날짜 및 종료날짜(쿠폰이용기간 적용) 구하기
		whttp.Open("GET", time_url)
		whttp.Send()
		whttp.WaitForResponse()
		url_out_date := whttp.ResponseText
		RegExMatch(url_out_date, "(\d{4}-\d{2}-\d{2})", OutArray)		
		today := StrReplace(OutArray1 ,"-" ,"") ;현재일자
		today += CodeDate, days
		FormatTime, endday, %today%, yyyy-MM-dd ;이용일자
				
		;계정 추가
		whttp.Open("POST", member_php_url)
		whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		UserPW := Crypt.Encrypt.StrEncrypt(UserPW, aes_pw, aes_typ, hash_typ)	
		endday := Crypt.Encrypt.StrEncrypt(endday, aes_pw, aes_typ, hash_typ)
		loginyn:= Crypt.Encrypt.StrEncrypt("[OFF]", aes_pw, aes_typ, hash_typ)
		whttp.Send("UserID=" . UriEncode(UserID) . "&State=" . UriEncode(UserPW . "|" . endday . "|" . loginyn))
		whttp.WaitForResponse()
		
		msgbox, [생성완료] 계정생성이 완료되었습니다.
		
		ExitApp
		return		
	}
	else
		msgbox, 인증코드가 올바르지 않습니다.	
return

#Include .\SkinForm.ahk
#include .\include\uriencode.ahk
#Include .\include\Crypt.ahk
#Include .\include\CryptConst.ahk
#Include .\include\CryptFoos.ahk