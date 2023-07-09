$folderPath = "c:\Users\adamr\Downloads\DCIM\";
$fileExt = ".mov";
$attributeName = "Media created";

(Get-ChildItem -Path "$folderPath\*" -Include "*$fileExt").FullName | % { 
    $filePath = $_;
    $folder = Split-Path $filePath;
    $file = Split-Path $filePath -Leaf;
	$fileExtension = [System.IO.Path]::GetExtension($filePath);
	
    $shell = New-Object -COMObject Shell.Application;
    $shellFolder = $shell.Namespace($folder);
    $shellFile = $shellFolder.ParseName($file);
	
    $attributes = 0..500 | % { Process { $x = '{0} = {1}' -f $_, $shellFolder.GetDetailsOf($null, $_); If ( $x.split("=")[1].Trim() ) { $x } } };
    [int]$attributeIndex = $attributes | % { Process { If ($_ -like "*$attributeName*") { $_.Split("=")[0].trim() } } };
    $mediaCreatedString = $shellFolder.GetDetailsOf($shellFile, $attributeIndex);
	
    $mediaCreatedString = $mediaCreatedString -creplace '\P{IsBasicLatin}';
    $mediaCreated = [Datetime]::Parse($mediaCreatedString);
    $newFileName = $mediaCreated.ToString("yyyy-dd-MM_HH-mm-ss");
	
	$newFilePath = Join-Path -Path $folder -ChildPath $newFileName$fileExtension;
    Write-Host Renaming $filePath -> $newFilePath;
	
    Rename-Item -Path $filePath -NewName $newFilePath;
};