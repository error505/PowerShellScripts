#########################################################
# PowerShell Script For Items
# from XML
# Version: 1.0 
# Date: 29-May-2019
# Author: Igor Iric
#########################################################


function RunImport {
    param(
        [scriptblock]$ScriptBlock
    )
    Write-Host "$($ScriptBlock.ToString())" -ForegroundColor "Green"
    
    & $ScriptBlock
    
     $xmlDocumentPath = "/wwwroot/upload/import/News.xml"
     #Get News XML from ulpoad location
     [xml]$XmlDocument = Get-Content -Path $xmlDocumentPath  -Encoding UTF8
     $XmlDocument.GetType().FullName
     $XmlDocument.docs.doc | Format-Table -AutoSize
     $bulk = New-Object "Sitecore.Data.BulkUpdateContext"
     #GUID for Feature Branch Template for News Details Page 
     $templateGuid = "{619E7707-4486-4517-9E5E-94BDA5685ED3}"
     #News Details Page Feature Branch Template Path
     $newsDetailsPageFeatureBranchTemplate = "/sitecore/templates/Branches/Project/Intranet/Intranet News"
     #GUID for Image Template
     $imageTemplateGuid = "{DAF085E8-602E-43A6-8299-038FF171349F}"
     $date = [DateTime]::Now
     #Guid for ImageGalery Template
     $imageGaleryTemplateId = "{B83AA941-0DB1-4E68-9F89-8477676B3F5A}"
     #Path to sitecore bucket folder
     $path = "/sitecore/content/Develop/Intranet/News"
     $itemCategory = " "
     $ZipArchivePath = "/upload/import/"
     $StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch 
     try 
        {
         foreach($content in $XmlDocument.docs.doc) 
            { 
                 $uniqID = $content.unid
                 $itemHeadLine = $content.headline
                 $itemAbstract = $content.abstract
                 $itemNewsId = $content.id
                 $itemPath = "master:" + $path + "/" + $itemNewsId
                 $searchPath = $path + "/" + $itemNewsId
                 #Check if item is already imported in sitecore
                 $getAllItems = Get-Item -Path master: -Query "/sitecore/content/Develop/Intranet/News//*[@@templatename='Intranet News']" | where {($_.Name -like $itemNewsId )}
                 if($getAllItems){
                     #If item is imported write message
                     Write-Host "Item "  $itemNewsId  " allready exists " -BackgroundColor Black -ForegroundColor Yellow
                 }
                 else{
                     #Get news language
                     $importLanguage = $content.language.ToLower()
                     if($importLanguage -eq "de" -or $importLanguage -eq "cs_de"){
                         $importLanguage = "de-DE"
                     }
                     $sitecoreImagesPath = "/sitecore/media library/intranetNewsImport/" + $itemNewsId
                     #Create new Sitecore Item from branch template
                     $item = New-Item -Path $path -Name $itemNewsId -ItemType $newsDetailsPageFeatureBranchTemplate
                     $item.Editing.BeginEdit()
                     $item["__Display name"] = $itemHeadLine
                     # Convert DateTime string To DateTime object
                     $itemCreationDate = [datetime]::ParseExact($content.date.trim(),'dd.MM.yyyy',[CultureInfo]::InvariantCulture)
                     $NewDate = Get-Date $itemCreationDate -Format 'yyyyMMddThhmmss'
                     $item["Date"] = $NewDate
                     $item["__Created"] = $NewDate
                     $item["Page Title"] = $itemHeadLine
                     $item["Headline"] = $itemHeadLine
                     $item["Navigation Title"] = $itemHeadLine
                     $item["Abstract"] = $itemAbstract
         
                     foreach($category in $content.categories){
                        $itemCategory = [string]::Join(",",$category.category)
                     }
                     $zipExtractPath = $ZipArchivePath + $itemNewsId
                     $zipFile = $ZipArchivePath + $itemNewsId + ".zip"
                     $item["Tags"] = $itemCategory
                     $children = Get-ChildItem -Path master: -ID $item.ID
                     $localDataFolder = $children[1]
                     $ldfPath = $localDataFolder.Paths.FullPath
                     $galeryItem = New-Item -Path $ldfPath -Name $itemNewsId -ItemType $imageGaleryTemplateId
                     Add-ItemVersion -Item $galeryItem -Language "en" -TargetLanguage $importLanguage -IfExist Skip
                     $galeryItem.Editing.BeginEdit()
                     $galeryItem["Headline"] = $itemHeadLine
                     $item["ID"] = $uniqID
                     $listOfImages = Get-ImagesForGalery -FileName $zipFile  -Name $itemNewsId -ExtractPath $zipExtractPath -Importlanguage $importLanguage | Out-String
                     $clearListofImages = $listOfImages.Replace(" ","").replace("`n","").replace("`r","").replace("`r`n","")
                     $galeryItem["Images"] = $clearListofImages
                     $galeryItem.Editing.EndEdit()
                     #Publish-Item -Item $galeryItem -Recurse -PublishMode SingleItem -PublishRelatedItems -Target Internet -Language $importLanguage
                     [string]$image = Get-Thumbnail -Galerypath $sitecoreImagesPath
                     $item["Picture"] = $image 
                     $item.Editing.EndEdit()
                     #Paragraph 1 rendering edit
                     $ldfId = $localDataFolder.ID
                     $ldfChildrenParagraph = Get-ChildItem -Path master: -ID $ldfId | where {($_.Name -like "Paragraph 1" )}
                     $contactTeaserRendering = Get-ChildItem -Path master: -ID $ldfId | where {($_.Name -like "Contact Teaser Wide" )}
                     Remove-Item -Path $contactTeaserRendering.Paths.Path -Permanently
                     if($ldfChildrenParagraph){
                         $ldfChildrenParagraph.Editing.BeginEdit()
                         if (![string]::IsNullOrEmpty($content.content1) -Or ![string]::IsNullOrEmpty($content.content2) -Or ![string]::IsNullOrEmpty($content.content3)){
                             $ldfChildrenParagraph["Text"] = $content.content1.InnerText + " " + $content.content2.InnerText + " " + $content.content3.InnerText
                             $ldfChildrenParagraph["Title"] = $itemHeadLine
                             $ldfChildrenParagraph["Image"] = [string]$image = Get-Thumbnail -Galerypath $sitecoreImagesPath
                             $ldfChildrenParagraph["Description"] = $itemHeadLine
                         }
                         $ldfChildrenParagraph.Editing.EndEdit()
                     }
                     
                     #Add-ItemLanguage -Item $item -Language "en" -TargetLanguage "de-DE" -IfExist Skip -IgnoredFields "Title"
                     
                     #GaleryRendering for object
                     $sitecoreImagesGalery
                     $galeryItemPath = "/sitecore/media library/intranetNewsImport/" + $itemNewsId
                     if(Test-Path $galeryItemPath){
                         $sitecoreImagesGalery = Get-ChildItem -Path $galeryItemPath 
                     }
                     if($sitecoreImagesGalery -is [System.Object[]]){
                         $sitecoreImagesGalery | Measure-Object | Select-Object -expand Count
                         if($sitecoreImagesGalery.Count -gt 1 ){
                             #Create Rendering for image galery
                             $galeryRendering = gi "/sitecore/layout/Renderings/Feature/Media/Image Library/Intranet/Image Gallery" | New-Rendering -Placeholder "news_content" 
                             $galeryRenderingPath = $galeryItem.Paths.Path
                             #Add image galery rendering
                             $addRendering = Add-Rendering -Item $item -Rendering $galeryRendering -Placeholder "news_content" -Datasource $galeryRenderingPath
                             Write-Host "Item image galery rendering: " $itemHeadLine " has been added!" -BackgroundColor Black -ForegroundColor Green
                         }
                     }
                     Add-ItemVersion -Item $item -Language "en" -TargetLanguage $importLanguage -IfExist Skip
                     Publish-Item -Item $item -Recurse -PublishMode SingleItem -PublishRelatedItems -Target Internet -Language $importLanguage 
                     ### Only for German Version
                     # Remove-ItemVersion  -Language "en"  -Item $item
                     Write-Host "Item created: " $itemHeadLine -BackgroundColor Black -ForegroundColor Green
                 }
            }
            
        }
        catch {
            Write-Warning $_ -BackgroundColor Black -ForegroundColor Red
            }
        finally
        {
         $StopWatch.Stop()
         Write-Host "Import has been successfuly finished! After " $StopWatch -BackgroundColor Black -ForegroundColor Green
         $bulk.Dispose()
        }
}

#Set thumbnail for news
function Get-Thumbnail
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Galerypath
    )
    
    [Sitecore.Data.Items.Item]$imageItem
    [Void][Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')  
    if(Test-Path $GaleryPath) {
        $galeryImages = Get-ChildItem -Path $Galerypath
        if($galeryImages -isnot [system.array]){
            $imageItem = $galeryImages}
            else{
             [Sitecore.Data.Items.Item]$imageItem = $galeryImages[0]
        }        
    }
    $itemId = $imageItem.ID
    #Create string for image filed
    [String]$imagePathInSitecoreForThumb = "<image mediaid=`"$itemId`"/>";
    return [String]$imagePathInSitecoreForThumb;
}


function Get-ImagesForGalery
{
    param
    (
		[Parameter(Mandatory = $true)]
        [String] $FileName,
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Parameter(Mandatory = $true)]
        [String] $ExtractPath,
        [Parameter(Mandatory = $true)]
        [String] $Importlanguage
    )
    $templateGuid = "{DAF085E8-602E-43A6-8299-038FF171349F}"
    $imageFolderGuid = "{FE5DD826-48C6-436D-B87A-7C4210C7413B}"
    [String]$imageItem
    
    $galeryImageIDs = " "
    $list = @()
    [Void][Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')  
    foreach($zipfile in $FileName) { 
        $ZipStream = New-Object System.IO.Memorystream
        if(Test-Path $ZipFile) {
            $itemImagePath = $ExtractPath
            Unzip -zipfile $FileName -outdir $itemImagePath
                $files = Get-ChildItem $itemImagePath
                foreach($RawFile in  $files)
                        {
                           $itemNameNoExtension = [io.path]::GetFileNameWithoutExtension($RawFile.FullName)  
                           $extension = [io.path]::GetExtension($RawFile.FullName)
                           $content = Get-Content $RawFile.FullName
                           if($extension.ToLower() -eq ".jpg" -Or $extension.ToLower() -Like ".png"){
                               if(Test-Path "/sitecore/media library/intranetNewsImport/"){
                                   $sitecoreImagePath = "/sitecore/media library/intranetNewsImport/" + $Name + "/" + $itemNameNoExtension 
                                   if(Test-Path $itemImagePath) {
                                         [String]$imageItem = New-GaleryMediaItem -filePath $RawFile.FullName -mediaPath  $sitecoreImagePath -Normalname $itemNameNoExtension -Importlanguage $Importlanguage
                                      } 
                                  $list += $imageItem
                               }else {
                                   $mediaFolderForGalery =  New-Item -Path "/sitecore/media library/" -Name "intranetNewsImport" -ItemType $imageFolderGuid
                                   $sitecoreImagePath = "/sitecore/media library/intranetNewsImport/" + $Name + "/" + $itemNameNoExtension 
                                   if(Test-Path $itemImagePath) {
                                         [String]$imageItem = New-GaleryMediaItem -filePath $RawFile.FullName -mediaPath  $sitecoreImagePath -Normalname $itemNameNoExtension -Importlanguage $Importlanguage
                                      } 
                                  $list += $imageItem
                               }
                          }
                        }
            }                   
    }
    [string]$galeryImageIDs
    if ($list.Count -gt 1){
        $galeryImageIDs = [string]::Join("|",$list)
    }
    else {
        [string]$galeryImageIDs = $list[0]
    }
    return ,[string]$galeryImageIDs
}

#Creation of galery items
function New-GaleryMediaItem{
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$filePath,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$mediaPath,
        [Parameter(Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Normalname,
        [Parameter(Position=3, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Importlanguage
    )

    $mco = New-Object Sitecore.Resources.Media.MediaCreatorOptions
    $mco.Database = [Sitecore.Configuration.Factory]::GetDatabase("master");
    #$mco.Language = [Sitecore.Globalization.Language]::Parse($Importlanguage);
    $mco.Versioned = [Sitecore.Configuration.Settings+Media]::UploadAsVersionableByDefault;
    $mco.Destination = $mediaPath;
    $altText = $Normalname
    $mco.AlternateText = $altText;
    $FilepathNormal = $filepath
    $mc = New-Object Sitecore.Resources.Media.MediaCreator;
    [Sitecore.Data.Items.Item]$item = $mc.CreateFromFile($FilepathNormal, $mco);
    $itemId = $item.ID
    return [String]$itemId;
}

#Unzip files to dir location
function Unzip($zipfile, $outdir)
{
    $elevatedUser= Get-User -Identity "sitecore\admin"

    New-UsingBlock (New-Object Sitecore.Security.Accounts.UserSwitcher $elevatedUser) {
        # Run commands that required the elevated access.
        Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zipfile)
    foreach ($entry in $archive.Entries)
    {
        $entryTargetFilePath =   [System.IO.Path]::Combine($outdir, $entry.FullName)
        $entryTargetFilePathClean = $entryTargetFilePath
        $entryDir = [System.IO.Path]::GetDirectoryName($entryTargetFilePath) 
        $b=[system.text.encoding]::UTF8.GetBytes($entryTargetFilePath)
        $c=[system.text.encoding]::convert([text.encoding]::UTF8,[text.encoding]::ASCII,$b)
        $withQuestionMark =  -join [system.text.encoding]::ASCII.GetChars($c)
        #$normal = Convert-ToFriendlyName -Text $withQuestionMark
        $normal = $withQuestionMark.Replace("?","_").Replace("~","_").Replace("@","_").Replace("*","_").Replace("&","_").Replace("%","_").Replace("$","_").Replace("!","_").Replace("£","_").Replace("=","_").Replace("#","_")
        #$entryCleanPath = $entryDir 
        #Ensure the directory of the archive entry exists
        $itemNameNoExtension = [io.path]::GetFileNameWithoutExtension($normal)  
        $extension = [io.path]::GetExtension($normal)

        [bool]$matcCheck = $itemNameNoExtension -match '^[\w\*\$][\w\s\-\$]*(\(\d{1,}\)){0,1}$'
           if($matcCheck -eq $FALSE){
             $itemNameNoExtension =  Convert-ToFriendlyName -Text $itemNameNoExtension
             $normal = $entryDir + "\" +  $itemNameNoExtension +  $extension
           }
           
        if(!(Test-Path $entryDir )){
            New-Item -ItemType Directory -Path $entryDir | Out-Null 
        }        
        #If the entry is not a directory entry, then extract entry
        if(!$normal.EndsWith("\")){
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $normal, $true);
        }
     }
    }
    
}        

function Convert-ToFriendlyName{
    param 
    ([string]$Text)
    # Unwanted characters (includes spaces and '-') converted to a regex:
    $SpecChars = '!', '"', '£', '$', '%', '&', '^', '*', '(', ')', '@', '=', '+', '¬', '`', '<', '>', '.', '?', ':', ';', '#', '~', "'", 'ö', 'Ö', 'ü', 'Ü', 'ß', 'ä', 'Ä', ' '
    $remspecchars = [string]::join('|', ($SpecChars | % {[regex]::escape($_)}))
    # Convert the text given to correct naming format (Uppercase)
    $name = (Get-Culture).TextInfo.ToTitleCase($Text.ToLower())
    # Remove unwanted characters
    $name = $name -replace $remspecchars, ""
    $name
}

RunImport { }        
