Enable-PSRemoting -Force -SkipNetworkProfileCheck
New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My
$cert = $(Get-ChildItem -path cert:\LocalMachine\My|Where-Object {$_.Subject -eq "CN=$env:COMPUTERNAME"})
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint –Force
Get-ChildItem WSMan:\Localhost\listener | Where -Property Keys -eq 'Transport=HTTP' | Remove-Item -Recurse
Set-Item wsman:\localhost\client\trustedhosts * -Force
New-NetFirewallRule -DisplayName "Allow WinRm HTTPS" -Direction Inbound -LocalPort 5986 -Action Allow -Profile Any -Protocol TCP
