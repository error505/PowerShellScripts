#########################################################
# This PowerShell 4.0 script creates Import files with Invoke-RestMethod
# Version: 3.0 
# Date: 15-May-2017
# Author: Igor Iric
#########################################################
$ResultURL = ($baseUrl + $($sendSus))    

# Create Body with conection parametters
#If you have database instance use Instance if not just remove it and use username and password.
$postParams = @{Instance = "YourInstance";UserName = "YourUserName";Password = "YouR#PaSSw0rd"}

# Base Url for server
$baseUrl = "http://localhost/YourAppName/"

$importUrl = "api/v1/xml/"

# Rest Api Url for login
$loginUrl = "api/v1/Account/login"

$FilePath = 'D:\sus\IIL.xml'

# Create Web Response for login
$WebResponse = Invoke-WebRequest -usebasicparsing -Body $postParams -Method POST -Uri ($baseUrl + $($loginUrl))  -ContentType application/x-www-form-urlencoded

# Convert response from Json to take access_token
$resource = ConvertFrom-Json $WebResponse.Content

# Take access_token
$HeaderValue = "Bearer " + $resource.access_token
$fileBin = [IO.File]::ReadAllBytes($FilePath)

# Convert byte-array to string (without changing anything)
$enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")
$fileEnc = $enc.GetString($fileBin)

$boundary = [System.Guid]::NewGuid().ToString()    # 

$LF = "`r`n"
$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"smeStatus.xml`"",
	"Content-Type: application/octet-stream$LF",
    $fileEnc,
    "--$boundary--$LF"
    ) -join $LF

$WebResponseImport =  Invoke-RestMethod -Uri ($baseUrl + $($importUrl)) -Headers @{Authorization = $HeaderValue} -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`""-Body $bodyLines

   
