#########################################################
# This PowerShell 4.0 script Login to OMS RMS Api
# Version: 3.0 
# Date: 27-Feb-2017
# Author: Igor Iric
#########################################################
Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }    
"@
 
[ServerCertificateValidationCallback]::Ignore();
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
# Create Body with conection parametters
$postParams = @{username = "username"; password = "pass"}

$contentTypeApp = "application/x-www-form-urlencoded"

$contentTypeFD = "multipart/form-data"

# Base Url for server
$baseUrl = "https://spor-uat.ema.europa.eu/v1/lists"

$cookies = $websession.Cookies.GetCookies($baseUrl) 

$header = @{username = "username"; password = "pass"}
# Create Web Response for logins
$WebResponse = Invoke-WebRequest -usebasicparsing -Body $postParams -Method POST -Uri ($baseUrl) -Headers $header  -ContentType $contentTypeFD -WebSession $myWebSession

# Convert response from Json to take access_token
$resource = $WebResponse