# 
# Adapted from I cant remember, for Ruben D. Lopez
# Current issues : ... Hangs after finishe in large directories.
# LAtest version from : 27-07-2019
<#
.SYNOPSIS
    Script to merge files from one folder SOURCE to another DESTINATION.
    This is NOT a detailed merge tool (yet). Everything on the dest directory would be overwrited with the source directory if files are different.
.DESCRIPTION
    Script to merge files from one folder SOURCE to another DESTINATION.
    Use paramenters to specify if want to compare by name only, or also by content.
    If using default, it will only search and compare using names and extensions. 
TODO
  - As a user, I want to have an option to merge by date, so I can keep the most recent file on the destination directory.
  - As a user, I want to have an option to create a file with a log, so I can check what was copied and what not.

.NOTES
    Author         : Ruben D. Lopez  (dev.ruben.lopez@outlook.com)
    Prerequisite   : PowerShell V2 (tested on W10 only).
    Parameters     : origin:string destination:string (opt)compare-content:true/false (opt)compare-content:true/false 
.LINK

.EXAMPLE
    .\Merge-Folders.ps1 "C:\temp\source" "C:\temp\dest" 1  #this will execute a compare on contents to check if files are the same.
.EXAMPLE
    .\Merge-Folders.ps1 "C:\temp\source" "C:\temp\dest"  #this will only compare file names
#>



Param(  
[Parameter(Mandatory=$true)]  
[string]$sourcePath,  
[Parameter(Mandatory=$true)]  
[string]$destinationPath,
[Parameter(Mandatory=$false)]
[bool]$compareContents
)  

"`n`r Begin Merging files: `n`r";
  
$files = Get-ChildItem -Path $sourcePath -Recurse -Filter "*.*"  
  
foreach($file in $files)
{  
    $sourcePathFile = $file.FullName  
    $destinationPathFile = $file.FullName.Replace($sourcePath,  $destinationPath)  
  
    $exists = Test-Path $destinationPathFile  
  
    if(!$exists)
    {  
        $dir = Split-Path -parent $destinationPathFile  
        if (!(Test-Path($dir))) { New-Item -ItemType directory -Path $dir }  
        "`n Copying file : $sourcePathFile `r"
        Copy-Item -Path $sourcePathFile -Destination $destinationPathFile -Recurse -Force  
        
    }  
    else
    {  
        if($compareContents)
        {
            $isFile = Test-Path -Path $destinationPathFile -PathType Leaf  
         
            if($isFile)
            {  
                
                if(  $null -eq (Get-Content $sourcePathFile) -or $null -eq (Get-Content $destinationPathFile))
                {
                    "`n File : $sourcePathFile or $destinationPathFile is/are empty. No merge. `r"
                }
                else 
                {
                    $different = Compare-Object -ReferenceObject $(Get-Content $sourcePathFile) -DifferenceObject $(Get-Content $destinationPathFile)  
                    if($different)
                    {  
                        $dir = Split-Path -parent $destinationPathFile  
                        if (!(Test-Path($dir))) { New-Item -ItemType directory -Path $dir }  
            
                        "`n Copying file : $sourcePathFile `r"    
                        Copy-Item -Path $sourcePathFile -Destination $destinationPathFile -Recurse -Force  
                    }  
                }
    
            }  
        }

    }  
}

"`n`r Process completed. `n`r";  
