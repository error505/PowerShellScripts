# Create Body with conection parametters
$postParams = @{Instance = "InstanceName";UserName = "User";Password = "Password"}

# Base Url for server
$baseUrl = "http://localhost/DLT/"

# Rest Api Url for login
$loginUrl = "api/v1/Account/login"

# Rest Api Url to take xsd
$xdsObjectUlr = "api/v1/xml/object?ObjectId="

# Rest Api Url to take all objects
$getAllObjectsList = "api/v1/xml/objectsList"

# Get XML objects
$getXmlObject = "api/v1/xml/objectxml?ObjectId="

# RecordId
$setRecordId = "&RecordId="

# Path for saving files's to disk
$savePath = "c:\temp\"

# List of Objects
$objectsXsd = @("MARETINGAUTH","DOCUMENT","COMPOSITION","DOSSIER","DRUGPACK","LOCATION","SUBSTANCE","PERSON","TEAM","CATEGORY")

Try {
    # Create Web Response for login
    $WebResponse = Invoke-WebRequest -usebasicparsing -Body $postParams -Method POST -Uri ($baseUrl + $($loginUrl))  -ContentType application/x-www-form-urlencoded

    # Convert response from Json to take access_token
    $resource = ConvertFrom-Json $WebResponse.Content

    # Take access_token
    $HeaderValue = "Bearer " + $resource.access_token

    # Get List of All objects
    $objectlist = Invoke-WebRequest -usebasicparsing -Headers @{Authorization = $HeaderValue} -Method GET -Uri ($baseUrl + $($getAllObjectsList))
    New-Item ($savePath + "objectlist.xml") -type file -force -value $objectlist.content

    # For each drugTrack Object create new xsd
    foreach ($i in $objectsXsd) {
        $objectXSD = Invoke-WebRequest -usebasicparsing -Headers @{Authorization = $HeaderValue} -Method GET -Uri ($baseUrl + $($xdsObjectUlr) + $($i))
        New-Item ($savePath + $($i) + ".xsd") -type file -force -value $objectXSD.content
    }

    # Get XMl object
    foreach ($i in $objectsXsd) {
        $objectXML = Invoke-WebRequest -usebasicparsing -Headers @{Authorization = $HeaderValue} -Method GET -Uri ($baseUrl + $($getXmlObject) + $($i) + $($setRecordId) + "1")
        New-Item ($savePath + $($i) + ".xml") -type file -force -value $objectXML.content
    }

}
Catch {    
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Break
}
