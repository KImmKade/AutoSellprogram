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
SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName) ; For 유니코드
	}else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
		}
}