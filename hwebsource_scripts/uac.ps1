REG ADD HKLM\SOFTWARE\Microsoft\Windows\Currentversion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f

Shutdown /r /c "Rebooting to Enable UAC" /d UP:2:18
