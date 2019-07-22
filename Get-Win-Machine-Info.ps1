#Get all the information of local machine, with programs installed and version. Results are printed and saved into a file on c:\temp\
#DXC Migration Testing - GEt Info helper
#Tested on Windows 10 and Windows 7 64
#Created by Ruben D Lopez on 10/07/2019
$obj = Get-WMIObject Win32_BIOS;
$concatInformationForFile = "`r`n`r`n********************** MACHINE INFORMATION **************************";
$concatInformationForFile += "`r`n" + $env:computername;
$concatInformationForFile += "`r`nBIOS Version : " + $obj.Manufacturer + " " + $obj.SMBIOSBIOSVersion;
$concatInformationForFile += "`r`nBIOS Release Date : " + $obj.ConvertToDateTime($obj.ReleaseDate);
$concatInformationForFile += "`r`nSN: " + $obj.SerialNumber;
$concatInformationForFile += "`r`n";
$concatInformationForFile += "`r`n **************** WINDOWS DETAILS **************** ";
$concatInformationForFile += "`r`n" + (Get-WmiObject -class Win32_OperatingSystem).Caption;
$concatInformationForFile += "`r`n" + (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
$concatInformationForFile += "`r`n" + [System.Environment]::OSVersion.Version
$concatInformationForFile += "`r`n";
$concatInformationForFile += "`r`n **************** CURRENT PROGRAMS/APPS ******************";
$concatInformationForFile += "`r`n";
$concatInformationForFile += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize | Out-String

$concatInformationForFile;
$stringDateTime = Get-Date -Format "-dd-MM-yyyy-HHmm"
$concatInformationForFile > "c:\temp\$env:computername-Information$stringDateTime.txt";

