param(
	[Parameter()][string] $ServerName,
	[Parameter()][string] $UserName,
	[Parameter()][string] $Password,
    [Parameter()][string] $ArtifactInputPath,
	[Parameter()][switch] $Help
)

Remove-Variable * -Exclude ServerName, UserName, Password, ArtifactInputPath, Help -ErrorAction SilentlyContinue



Function Invoke-Scripts
{
	param(
		[Parameter(Mandatory)] [string[]] $Scripts,
		[Parameter(Mandatory)] [string] $ServerName,
		[Parameter()][string] $UserName,
		[Parameter()][string] $Password,
		[Parameter()][string] $DatabaseName,
		[Parameter()][switch] $UseAsQuery
	)

	#prepare sqlcmd arguments
	$SqlCmdArguments = New-Object -TypeName "System.Collections.ArrayList"
	$SqlCmdArguments.Clear()

	$SqlCmdArguments.AddRange(@("-S", $ServerName)) #ServerName -> [protocol:]server[\instance_name][,port]

	if ($UserName -and $Password)
	{
		$SqlCmdArguments.AddRange(@("-U", $UserName)) #UserName
		$SqlCmdArguments.AddRange(@("-P", $Password)) #Password
	}

	if ($DatabaseName)
	{
		$SqlCmdArguments.AddRange(@("-d", $DatabaseName)) #Database
	}

	$SqlCmdArguments.AddRange(@("-f", "65001")) #Codepage: unicode
	$SqlCmdArguments.Add("-r1") | Out-Null #Output: everything redirected to stderr
	$SqlCmdArguments.Add("-X1") | Out-Null #Scripting: disable advanced scripting

	if ($UseAsQuery.IsPresent)
	{
		$ScriptCount = @($Scripts).Count
		if (!($ScriptCount -eq 1))
		{
			Write-Error "Exactly one SQL query script required with 'UseAsQuery'"
			exit
		}
		
		$Query = $Scripts | Select-Object -First 1
		$SqlCmdArguments.AddRange(@("-Q", "`"$Query`"")) #Input: use query
	}
	else
	{
		$ScriptCount = @($Scripts).Count
		if (!($ScriptCount -gt 0))
		{
			Write-Error "At least one SQL query file required"
			exit
		}

		foreach ($File in $Scripts)
		{
			$SqlCmdArguments.AddRange(@("-i", "`"$File`"")) #Input: use file(s)
		}
	}

	#invoke sqlcmd call
	Write-Verbose "sqlcmd $SqlCmdArguments"
	sqlcmd $SqlCmdArguments


}



Function Invoke-ScriptsFromPath
{
	[CmdletBinding()]
	param(
		[parameter(Mandatory)] [String] $ScriptPath,
		[parameter(Mandatory)] [String] $ServerName,
		[String] $UserName,
		[String] $Password,
		[String[]] $Excludes
	)

	if (Test-Path $ScriptPath -PathType Container) #check if script scriptpath exists
	{
		$Scripts = Get-ChildItem -Path "$ScriptPath\*" -Include *.sql -Exclude $Excludes | Foreach-Object { $_.FullName } #compile script list

		if($Scripts.Count -gt 0) #check if any script was found
		{
			Invoke-Scripts $Scripts -ServerName $ServerName -UserName $UserName -Password $Password #run scripts
		}
		else
		{
			Write-Warning "No SQL query scripts found in '$ScriptPath'"
		}
	}
}



$CurrentFolder = Get-Location
$ScriptName = $MyInvocation.MyCommand.Name



Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Running $ScriptName ..."



# Help
if($Help.IsPresent)
{
	Write-Host
    Write-Host '--------------------------------------------------------------------------------'
    Write-Host;
    Write-Host 'This script will execute the *.sql deployment files in the generator output'
	Write-Host 'on a specified Microsoft SQL Server instance.'
    Write-Host;
    Write-Host '--------------------------------------------------------------------------------'
    Write-Host;
    Write-Host 'Parameters:'
    Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ServerName "<string>"'
    Write-Host 'Specify the server instance where the deployment files should be executed.'
    Write-Host 'If parameter is not specified, a prompt will appear.'
	Write-Host 'Format: [<protocol>:]<server name>[\<instance name>][,<port>] or'
	Write-Host '[<protocol>:]<ip adress>[\<instance name>][,<port>]'
    Write-Host;
	Write-Host -ForegroundColor DarkGreen '-UserName "<string>"'
    Write-Host 'Specify the user name that will be used to connect to the server instance.'
    Write-Host 'If parameter is not specified, a prompt will appear.'
    Write-Host;
	Write-Host -ForegroundColor DarkGreen '-Password "<string>"'
    Write-Host 'Specify the password that will be used to connect to the server instance.'
    Write-Host 'If parameter is not specified, a prompt will appear.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ArtifactInputPath "<string>"'
    Write-Host 'Specify the path where the deployment files to execute are located.'
    Write-Host 'If parameter is not specified, the current folder is used.'
    Write-Host;
    Write-Host -ForegroundColor DarkGreen '-Help'
    Write-Host 'If parameter is used, this help will be displayed.'
    Write-Host;
    Write-Host '--------------------------------------------------------------------------------'
    exit
}



# ServerName
if($PSBoundParameters.ContainsKey('ServerName') -eq $false)
{
	$ServerName = Read-Host "Please specify the server or instance name"
}
if([String]::IsNullOrWhiteSpace($ServerName))
{
	$ServerName = "localhost"
}
Write-Host "-> using server name $ServerName"


# UserName and Password
if($PSBoundParameters.ContainsKey('UserName') -eq $false)
{
	$UserName = Read-Host "Please specify the user name"
}
if (-not [String]::IsNullOrWhiteSpace($UserName))
{
	
	if($PSBoundParameters.ContainsKey('Password') -eq $false)
	{
		$Password = Read-Host "Please specify the password"
	}

	Write-Host "-> using user name $UserName and password"
}
else
{
	$UserName = ""
	$Password = ""
	Write-Host "-> using no user name and password"
}
	


# ArtifactInputPath
if(-Not [String]::IsNullOrWhiteSpace($ArtifactInputPath))
{
    $ArtifactInputPath = [IO.Path]::Combine($CurrentFolder, $ArtifactInputPath)
}
else
{
    $ArtifactInputPath = $CurrentFolder
}
if(!(Test-Path $ArtifactInputPath -PathType Container))
{
    Write-Error "Input folder '$ArtifactInputPath' not found."
	exit
}
else
{
    Write-Host "-> using input folder $ArtifactInputPath"
}



Write-Host
Write-Host '--------------------------------------------------------------------------------'

#deploy load control
$ScriptPath = Join-Path $ArtifactInputPath "LoadControl"
if (Test-Path $ScriptPath -PathType Container) #check if script scriptpath exists
{
	Write-Host
	Write-Host "Processing scripts in $ScriptPath ..."
	Invoke-ScriptsFromPath -ScriptPath $ScriptPath -ServerName $ServerName -UserName $UserName -Password $Password -Excludes "LoadControl_Execution_*"
}

#deploy target structures
$ScriptPath = Join-Path $ArtifactInputPath "SQL"
if (Test-Path $ScriptPath -PathType Container) #check if script scriptpath exists
{
	Write-Host
	Write-Host "Processing scripts in $ScriptPath ..."
	Invoke-ScriptsFromPath -ScriptPath $ScriptPath -ServerName $ServerName -UserName $UserName -Password $Password
}

Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Finished"
