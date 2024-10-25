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

;글로벌 변수 선언
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

;GUI
Gui, Add, GroupBox, x2 y9 w320 h300 , User Account Manager Winning Trader Main
{
	Gui, Add, Text, x12 y29 w90 h20 , # 계정 리스트
	Gui, Add, Edit, x12 y49 w300 h120 vEditUserList +ReadOnly, 
	Gui, Add, Text, x12 y179 w110 h20 , # 계정 찾기 및 보기
	Gui, Add, Edit, x12 y199 w300 h30 vEditUserInfo +ReadOnly, 
	Gui, Add, Text, x12 y239 w70 h20 , 사용자 계정
	Gui, Add, Edit, x92 y239 w220 h20 vEditUserID, 
	Gui, Add, Button, x12 y262 w150 h40 gBtnUserFind, 계정 찾기
	Gui, Add, Button, x162 y262 w150 h20 gBtnUserLock, 계정 만료
	Gui, Add, Button, x162 y282 w150 h20 gBtnUserDel, 계정 삭제
}

Gui, Add, GroupBox, x2 y319 w320 h120 , Generation
{
	Gui, Add, Text, x12 y344 w74 h20 , 코드 기한(일)
	Gui, Add, Edit, x92 y339 w60 h20 vEditCodeDay +number, 
	Gui, Add, Text, x158 y344 w30 h20 , 개수
	Gui, Add, Edit, x185 y339 w60 h20 vEditCodeEA +number, 
	Gui, Add, Button, x252 y338 w60 h22 gBtnCodeAdd, 코드 발행
	Gui, Add, Text, x12 y374 w70 h20 , 발행 된 코드
	Gui, Add, Edit, x92 y369 w220 h20 vEditCode, 
	Gui, Add, Button, x12 y399 w300 h30 gBtnCodeDel, 발행 된 코드 삭제
}

Gui, Add, GroupBox, x332 y9 w290 h240 , View Code
{
	Gui, Add, Edit, x342 y29 w270 h170 vEditViewCode +ReadOnly, 
	Gui, Add, Button, x342 y209 w270 h30 gBtnAllRefresh, 모니터링 화면 새로고침
}

Gui, Show, w634 h452, GMTrader Main Admin

gosub, doFindAllUser ;모든 사용자목록 가져오기
gosub, doFindAllCode ;모든 코드목록 가져오기

return

;============================================================
;						User Account Manager
;============================================================

BtnUserFind:
	gosub, doUserFind
return


BtnUserLock:
	gosub, doUserLock
return


BtnUserDel:
	gosub, doUserDel
return


;모든 사용자목록 가져오기
doFindAllUser:

	;모든 GUI값 가져오기
	Gui, Submit, nohide
	
	;모든 사용자목록 가져오기
	whttp.Open("POST", member_php_url)
	whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	whttp.Send(UriEncode("ViewMB"))
	whttp.WaitForResponse()	
	url_out_data := whttp.ResponseText	
	url_out_data := StrReplace(url_out_data ,"</br>" ,"") ;태그삭제
	GuiControl,, EditUserList, %url_out_data%

return


;특정 사용자의 모든정보 가져오기
doUserFind:
	
	;사용자정보 에디트박스 초기화
	GuiControl,, EditUserInfo, 
	
	;모든 GUI값 가져오기	
	Gui, Submit, nohide
	
	;사용자ID 유효성검사
	if(EditUserID = "")
	{
		msgbox, 아이디를 입력해주세요.
		return
	}
	
	;사용자목록에 있는 사용자인지 유효성검사
	if(Instr(EditUserList, EditUserID) = 0)
	{
		msgbox, 입력이 올바르지 않거나 계정이 존재하지 않습니다.
		return		
	}
	
	UserID := EditUserID
	member_url := default_url . "/Members/" . UserID
	whttp.Open("POST", member_url)
	whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	whttp.Send(UriEncode("ViewMB"))	
	whttp.WaitForResponse()
	url_out_data_info := whttp.ResponseText	
	
	;구분자별로 데이터 복호화
	StringSplit, OutData, url_out_data_info, |
	OutData1 := Crypt.Encrypt.StrDecrypt(OutData1, aes_pw, aes_typ, hash_typ) ;비밀번호
	OutData2 := Crypt.Encrypt.StrDecrypt(OutData2, aes_pw, aes_typ, hash_typ) ;이용기간
	OutData3 := Crypt.Encrypt.StrDecrypt(OutData3, aes_pw, aes_typ, hash_typ) ;접속상태
	
	;문자조합하여 에디트박스에 보여주기
	input_data := OutData1 . "|" . OutData2 . "|" . OutData3	
	GuiControl,, EditUserInfo, %input_data%
	
return


;특정 사용자의 이용기간 만료처리
doUserLock:

	;모든 GUI값 가져오기	
	Gui, Submit, nohide
	
	if(EditUserInfo=="" || EditUserID="")
	{
		msgbox, 해당 사용자ID 또는 조회 된 상세정보가 존재하지 않습니다.
		return
	}
	
	UserID   := EditUserID
	
	StringSplit, OutData, EditUserInfo, |
	UserPW := Crypt.Encrypt.StrEncrypt(OutData1, aes_pw, aes_typ, hash_typ)	
	UseDay := Crypt.Encrypt.StrEncrypt(OutData2, aes_pw, aes_typ, hash_typ)
	UserStat:= Crypt.Encrypt.StrEncrypt(OutData3, aes_pw, aes_typ, hash_typ)
	
	whttp.Open("POST", member_php_url)
	whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	whttp.Send("UserID=" . UriEncode(UserID) . "&State=" . UriEncode(UserPW . "|" . "" . "|" . UserStat))
	whttp.WaitForResponse()
	
	gosub, doUserFind
	
	msgbox, 해당 사용자의 이용기간이 만료처리 되었습니다.

return


;특정 사용자의 모든정보 삭제
doUserDel:

	;모든 GUI값 가져오기	
	Gui, Submit, nohide
	
	if(EditUserInfo=="" || EditUserID="")
	{
		msgbox, 해당 사용자ID 또는 조회 된 상세정보가 존재하지 않습니다.
		return
	}
	
	UserID := EditUserID
	whttp.Open("POST", member_php_url)
	whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	whttp.Send("OutMem=" . UriEncode(UserID))
	whttp.WaitForResponse()
	
	gosub, doFindAllUser
	
	;사용자정보 에디트박스 초기화
	GuiControl,, EditUserInfo, 	
	GuiControl,, EditUserID, 
	
	msgbox, 해당 사용자(%UserID%)가 삭제 되었습니다.

return


;============================================================
;						Generation
;============================================================

BtnCodeAdd:
	gosub, doCodeAdd
return

BtnCodeDel:
	gosub, doCodeDel
return


;코드발행
doCodeAdd:

	;모든 GUI값 가져오기	
	Gui, Submit, nohide
	
	;발행 일수 및 개수 유효성검사
	if(EditCodeDay="" || EditCodeEA="")
	{
		msgbox, 발행 기간 또는 개수를 입력해주세요.
		return
	}
	
	
	CodeDay := EditCodeDay
	CodeEA := EditCodeEA	
	
	;입력갯수만큼 코드발행
	loop, %CodeEA%
	{		
		whttp.Open("POST", code_php_url)
		whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		whttp.Send("content=" . UriEncode(CodeDay))
		whttp.WaitForResponse()
	}
	
	gosub, doFindAllCode ;모든 코드목록 가져오기
	
	msgbox, 생성 되었습니다.
	
return


;코드삭제
doCodeDel:

	;모든 GUI값 가져오기	
	Gui, Submit, nohide
	
	;발행 일수 및 개수 유효성검사
	if(EditCode="")
	{
		msgbox, 코드를 입력해주세요.
		return
	}
	
	;코드목록에 있는 코드인지 유효성검사
	if(Instr(EditViewCode, EditCode) = 0)
	{
		msgbox, 코드번호가 잘못되었거나 존재하지 않습니다.
		return		
	}
	
	CodeDel := EditCode
	whttp.Open("POST", code_php_url)
	whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	whttp.Send("MyCode=" . UriEncode(CodeDel))
	whttp.WaitForResponse()	

	gosub, doFindAllCode ;모든 코드목록 가져오기
	
	msgbox, 삭제 되었습니다.

return


;============================================================
;						View Code
;============================================================

BtnAllRefresh:

	gosub, doFindAllUser ;모든 사용자목록 가져오기
	gosub, doFindAllCode ;모든 코드목록 가져오기
	
return


;모든 코드목록 가져오기
doFindAllCode:

	;모든 GUI값 가져오기
	Gui, Submit, nohide
	
	;모든 사용자목록 가져오기
	whttp.Open("POST", code_php_url)
	whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	whttp.Send(UriEncode("ViewCode"))
	whttp.WaitForResponse()	
	url_out_data := whttp.ResponseText
	url_out_data := StrReplace(url_out_data ,"</br>" ,"") ;태그삭제
	GuiControl,, EditViewCode, %url_out_data%

return


;============================================================
;						End
;============================================================


GuiClose:
ExitApp

#include .\include\uriencode.ahk
#Include .\include\Crypt.ahk
#Include .\include\CryptConst.ahk
#Include .\include\CryptFoos.ahk
#Include .\SkinForm.ahk