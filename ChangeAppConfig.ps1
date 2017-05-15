# Read the existing ConfigFile
$path = 'C:\Temp\App.config'

# Load File
$doc = New-Object System.Xml.XmlDocument
$doc.Load($path)
# Change selected nodes
$config = $doc.SelectSingleNode("//add[@key='instance']")
$config.value = "Instance"
$config = $doc.SelectSingleNode("//add[@key='userName']")
$config.value = "NewUserName"
$config = $doc.SelectSingleNode("//add[@key='password']")
$config.value = "NewPassword"
$config = $doc.SelectSingleNode("//add[@key='baseUrl']")
$config.value = "http://localhost/domain/"
#Save file
$doc.Save($path)
Write-Host "...Backup of the App.config completed..."