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

gosub, CreateLicense
return


;라이센스 기간연장 윈도우 생성
CreateLicense:
	Gui,3:+ToolWindow
	Gui,3:font,BOLD ,s12
	Gui,3:Add, Text, x40 y8 w200 h20 +Center, GM Trader 기간 연장
	Gui,3:Add, Text, x35 y33 w80 h20 +Center, 계정
	Gui,3:Add, Text, x25 y63 w80 h20 +Center, 비밀번호
	Gui,3:Add, Text, x5 y93 w90 h20 +Center, 비밀번호 확인
	Gui,3:Add, Edit, x120 y33 w110 h20 vEditUserID,
	Gui,3:Add, Edit, x120 y63 w110 h20 vEditUserPW Password*,
	Gui,3:Add, Edit, x120 y93 w110 h20 vEditUserPW2 Password*,
	Gui,3:Add, Text, x35 y124 w80 h20 +Center, S/N
	Gui,3:Add, Edit, x120 y124 w110 h20 vEditUserSN,
	Gui,3:Add, Button, x120 y159 w110 h30 gBtnContinue, 이용기간 연장
	Gui,3:Add, Text, x30 y160 w80 h20, 텔레그램
	Gui,3:Add, Text, x15 y179 w100 h20, "aiauto1004"
	Gui,3:Show, w250 h199, [기간연장]
return

3GuiClose:
ExitApp
Return



;이용기간연장
;기존에 회원가입 된 회원의 이용기간을 기준으로 연장합니다.
;1.이용기간이 남은경우: 남은 이용기간 + 연장일수
;2.이용기간이 끝난경우: 현재 일자 + 연장일수
BtnContinue:

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
	if(res_member <= 0)
	{
		msgbox, 계정이 존재하지 않습니다.
		return
	}
	
	StringSplit, OutData, url_out_data0, |
	OutData1 := Crypt.Encrypt.StrDecrypt(OutData1, aes_pw, aes_typ, hash_typ)
	OutData2 := Crypt.Encrypt.StrDecrypt(OutData2, aes_pw, aes_typ, hash_typ)
	OutData3 := Crypt.Encrypt.StrDecrypt(OutData3, aes_pw, aes_typ, hash_typ)	
	
	;비밀번호확인
	if(EditUserPW != EditUserPW2)
	{
		msgbox, 비밀번호가 동일하지 않습니다.
		return	
	}
	else
	{
		UserPW := EditUserPW
		
		;비밀번호 체크
		if(OutData1 != UserPW)
		{
			msgbox, [오류] 비밀번호가 틀립니다.
			ExitApp
			return
		}
	}	
	
	;인증코드 확인
	;인증코드의 이용일수 확인
	SN := EditUserSN
	sn_url := default_url . "/Code/" . SN
	whttp.Open("GET", sn_url)
	whttp.Send()	
	whttp.WaitForResponse()
	url_out_data := whttp.ResponseText	
	
	;인증코드 존재여부 판단
	;인증코드가 존재하지 않으면 html header를 생성하므로 header에서 <구분자로 존재여부 판단
	res := InStr(url_out_data, "<") 
	if(res=0) ;인증코드 존재
	{
		endday :=
		CodeDate := url_out_data
		StringSplit, OutData, url_out_data0, |
		OutData1 := Crypt.Encrypt.StrDecrypt(OutData1, aes_pw, aes_typ, hash_typ)
		OutData2 := Crypt.Encrypt.StrDecrypt(OutData2, aes_pw, aes_typ, hash_typ)
		OutData3 := Crypt.Encrypt.StrDecrypt(OutData3, aes_pw, aes_typ, hash_typ)
		 
		;인증받은 코드삭제		
		whttp.Open("POST", code_php_url)
		whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		whttp.Send("MyCode=" . UriEncode(SN))
		whttp.WaitForResponse()
		
		;해당 사용자의 이용기간 만료여부 판단		
		whttp.Open("GET", time_url)
		whttp.Send()
		whttp.WaitForResponse()
		url_out_date := whttp.ResponseText
		RegExMatch(url_out_date, "(\d{4}-\d{2}-\d{2})", OutArray)	
		today := StrReplace(OutArray1 ,"-" ,"") ;현재일자
		useday := StrReplace(OutData2 ,"-" ,"" ) ;이용일자
		useday -= today, days ;남은일수=이용일자-현재일자
		if(useday > 0) ;이용기간남음(남은 이용기간 + 연장일수)
		{			
			today := StrReplace(OutData2 ,"-" ,"") ;변경전 이용일자
			today += CodeDate, days
			FormatTime, endday, %today%, yyyy-MM-dd ;변경후 이용일자
		}
		else ;이용기간만료(현재 일자 + 연장일수)
		{
			;현재날짜 및 종료날짜(인증코드의 이용기간 적용) 구하기
			whttp.Open("GET", time_url)
			whttp.Send()
			whttp.WaitForResponse()
			url_out_date := whttp.ResponseText
			RegExMatch(url_out_date, "(\d{4}-\d{2}-\d{2})", OutArray)		
			today := StrReplace(OutArray1 ,"-" ,"") ;현재일자
			today += CodeDate, days
			FormatTime, endday, %today%, yyyy-MM-dd ;이용일자		
		}
				
		;계정상태 변경
		UserPW := Crypt.Encrypt.StrEncrypt(UserPW, aes_pw, aes_typ, hash_typ)	
		endday := Crypt.Encrypt.StrEncrypt(endday, aes_pw, aes_typ, hash_typ)
		loginyn:= Crypt.Encrypt.StrEncrypt("[OFF]", aes_pw, aes_typ, hash_typ)		
		whttp.Open("POST", member_php_url)
		whttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		whttp.Send("UserID=" . UriEncode(UserID) . "&State=" . UriEncode(UserPW . "|" . endday . "|" . loginyn))
		whttp.WaitForResponse()
		
		msgbox, [이용기간연장] 완료되었습니다.
		ExitApp
		return
			
	}
	else ;인증코드 미존재
		msgbox, 인증코드가 올바르지 않습니다.
return

#include .\include\uriencode.ahk
#Include .\include\Crypt.ahk
#Include .\include\CryptConst.ahk
#Include .\include\CryptFoos.ahk
#Include .\SkinForm.ahk