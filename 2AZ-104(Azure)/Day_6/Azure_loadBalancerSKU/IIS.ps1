# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Get Hostname and IP Address
$hostname = $env:COMPUTERNAME
$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet" | Where-Object { $_.IPAddress -notlike "169.*" -and $_.IPAddress -notlike "127.*" }).IPAddress

# Create custom index.html
$html = @"
<html>
<head>
<title>$hostname</title>
</head>
<body style="font-family: Arial; text-align: center; margin-top: 100px;">
<h1>This is $hostname</h1>
<p>IP Address: $ip</p>
</body>
</html>
"@

# Write the HTML file to IIS root
$path = "C:\inetpub\wwwroot\index.html"
$html | Out-File -FilePath $path -Encoding UTF8 -Force