
#region Functions
#==============================
function Log([string]$level, [string]$logstring)
{
    $date = Get-Date -Format g
    $logEntry = [string]::join("	", ($date, $level, $logstring)) 
    Add-Content $Logfile -value $logEntry
}

function GetCpuArchitecture()
{
    #Enum for CPU Architecture
    $CPUHash = @{0="x86";1="MIPS";2="Alpha";3="PowerPC";5="ARM";6="Itanium-based systems";9="x64"} 

	try 
	{ 
		$dependenciesArchitecture ="x86";
		
		#Default to X86
		$CPUArchitecture = 0;
		
		$CPUObj = Get-WMIObject -Class Win32_Processor -EA Stop 
		
		if ($CPUObj -is [system.array])
		{
			Log "INFO" "MultiSocket System. Fetch first index element for identifying Architecture"
			$CPUArchitecture = $CPUHash[[int]$CPUObj[0].Architecture] 
		}
		else
		{
			Log "INFO" "Single Socket system."
			$CPUArchitecture = $CPUHash[[int]$CPUObj.Architecture] 
		}
		
		if ($CPUArchitecture) 
		{ 
			$dependenciesArchitecture = $CPUArchitecture 
		} 
		else 
		{ 
			$dependenciesArchitecture= ("Unknown({0})" -f $CPUObj.Architecture)         
		} 
		
		$osArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
		
		if ($osArchitecture -eq "32-bit")
		{
			Log "INFO" "Operating System is 32Bit";
			$dependenciesArchitecture = "x86";			
		}
	} 
	catch [Exception]
    { 
		Log "ERROR" $_.Exception;
		Log "ERROR" "Failed to get CPU Architecture. Using X86 Architecture.";
	} 

    Write-Output $dependenciesArchitecture
}

function CheckDotNetVersion([string] $installerPath)
{
    [bool] $returnValue = $true

    $Lookup = @{
        378389 = [version]'4.5'
        378675 = [version]'4.5.1'
        378758 = [version]'4.5.1'
        379893 = [version]'4.5.2'
        393295 = [version]'4.6'
        393297 = [version]'4.6'
        394254 = [version]'4.6.1'
        394271 = [version]'4.6.1'
        394802 = [version]'4.6.2'
        394806 = [version]'4.6.2'
        460798 = [version]'4.7'
        460805 = [version]'4.7'
        461308 = [version]'4.7.1'
        461310 = [version]'4.7.1'
        461808 = [version]'4.7.2'
        461814 = [version]'4.7.2'
    }

    $dotNetVersionsInstalled = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | 
        Get-ItemProperty -name Version, Release -EA 0 |
        Where-Object { $_.PSChildName -eq "Full"} | 
        Select-Object @{name = ".NET Framework"; expression = {$_.PSChildName}}, @{name = "Product"; expression = {$Lookup[$_.Release]}}, Version, Release

    $maxversion = "378389"
    foreach ($dotNetInstalled in $dotNetVersionsInstalled)
    {
        Write-Host $dotNetInstalled
        if ($maxversion -lt $dotNetInstalled.Release)
        {
            $maxversion = $dotNetInstalled.Release
        }
    }

    # See: https://docs.microsoft.com/en-us/dotnet/framework/deployment/deployment-guide-for-developers#command-line-options

    if ($maxversion -le 393295)
    {
        Log "INFO" "Need to install .NET framework 4.6.1"

        $dotNetInstaller = Join-Path -Path $installerPath -ChildPath "NDP461-KB3102438-Web.exe"
        if (!(Test-Path $dotNetInstaller))
        {
            Write-Error "Installer is Missing $dotNetInstaller"
            return;
        }
        else
        {
            try
            {
                $p = New-Object System.Diagnostics.Process
                $pinfo = New-Object System.Diagnostics.ProcessStartInfo($dotNetInstaller);
                $pinfo.Arguments = "" # "/passive /norestart /showrmui /showfinalerror";
                $p.StartInfo = $pinfo;
                $p.Start();
                $p.WaitForExit();

                switch($p.ExitCode)
                {
                    0 
                    { 
                        Log "INFO" "Installed .NET Framework"; 
                        $returnValue = $true;
                        break;
                    }

                    1602 
                    { 
                        Log "ERROR" "The user canceled installation.";
                        break;
                    }

                    1603
                    { 
                        Log "ERROR" "A fatal error occurred during installation.";
                        break;
                    }

                    1641
                    { 
                        Log "INFO" "A restart is required to complete the installation. This message indicates success."; 
                        $returnValue = $true;
                        break;
                    }

                    3010
                    { 
                        Log "INFO" "A restart is required to complete the installation. This message indicates success."; 
                        $returnValue = $true;
                        break;
                    }

                    5100
                    { 
                        Log "ERROR" "The user's computer does not meet system requirements.";
                        break; 
                    }
                }
            } 
            catch [Exception]
            { 
                Log "ERROR" $_.Exception
                Log "ERROR" "WorkSpaceOne Installation failed. Manual Setup may be required."
                $returnValue = $false
            } 
        }
    }
    else
    {
        Log "Info" "Good on .NET Framework"
    }

    Write-Output $returnValue
}



