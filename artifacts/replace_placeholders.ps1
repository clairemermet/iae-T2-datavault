param (
    [Parameter()][string] $ReplacementConfigPath,
    [Parameter()][string] $ArtifactInputPath,
    [Parameter()][string] $ArtifactOutputPath,
    [Parameter()][string] $ArtifactBackupPath,
    [Parameter()][string] $EnvironmentName,
    [Parameter()][switch] $Help
)

Remove-Variable * -Exclude ReplacementConfigPath, ArtifactInputPath, ArtifactOutputPath, ArtifactBackupPath, EnvironmentName, Help -ErrorAction SilentlyContinue



function Copy-Folder
{
    param (
        [Parameter()][string] $SourceFolder,
        [Parameter()][string] $TargetFolder,
        [Parameter()][string[]] $ExcludeFolders
    )

    if(!(Test-Path $SourceFolder -PathType Container))
    {
        Write-Error "Source folder '$SourceFolder' not found."
    }
    if(!(Test-Path $TargetFolder -PathType Container))
    {
        Write-Error "Target folder '$TargetFolder' not found."
    }
    
    $ChildItems = Get-ChildItem -Path $SourceFolder -Recurse
    foreach ($Item in $ChildItems)
    {
        # ignore subfolders (but not the included files)
        if ($Item.PSIsContainer -eq $true)
        {
            continue
        }

        # ignore if in $ExcludeFolders
        $IsExcluded = $false
        foreach ($Exclude in $ExcludeFolders)
        {
            if ($Item.FullName.Contains($Exclude))
            {
                $IsExcluded = $true
                break
            }
        }
        if ($IsExcluded -eq $true)
        {
            continue
        }

        # calculate destination path
        $Destination = Join-Path $TargetFolder $Item.FullName.Substring($SourceFolder.length)

        # touch the file to create it within it's subfolder
        New-Item -ItemType File -Path $Destination -Force | out-null

        # actually copy the file
        Copy-Item -Path $Item -Destination $Destination -Force | out-null
    }
}



$ErrorActionPreference = 'stop'
$CurrentFolder = Get-Location
$ScriptName = $MyInvocation.MyCommand.Name
$ExcludeFolders = @()



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
    Write-Host 'This script will replace placeholders within the deployment files in the folder'
    Write-Host 'and subfolders of the generator output with values provided by a replacement'
    Write-Host 'configuration file.'
    Write-Host 'Only placeholders in *.sql, *.txt, *.py, *.json, *.ipynb files are replaced.'
    Write-Host;
    Write-Host '--------------------------------------------------------------------------------'
    Write-Host;
    Write-Host 'Parameters:'
    Write-Host;
    Write-Host -ForegroundColor DarkGreen '-ReplacementConfigPath "<string>"'
    Write-Host 'Specify the path and name for the replacement configuration file.'
    Write-Host 'If parameter is not specified, the current folder is used and a file named'
    Write-Host '"replacement_config.json" is expected.';
    Write-Host;
    Write-Host -ForegroundColor DarkGreen '-ArtifactInputPath "<string>"'
    Write-Host 'Specify the path where the deployment files to modify are located.'
    Write-Host 'If parameter is not specified, the current folder is used.'
    Write-Host;
    Write-Host -ForegroundColor DarkGreen '-ArtifactOutputPath "<string>"'
    Write-Host 'Specify the path where the deployment files should be stored after modification.'
    Write-Host 'If parameter is not specified, the current folder is used and files will be'
    Write-Host 'overwritten.'
    Write-Host;
    Write-Host -ForegroundColor DarkGreen '-ArtifactBackupPath "<string>"'
    Write-Host 'Specify the path where the backup with the untouched original deployment files'
    Write-Host 'should be stored. For each backup a dedicated subfolder will be created.'
    Write-Host 'If parameter is not specified, no backup will be created.'
    Write-Host;
    Write-Host -ForegroundColor DarkGreen '-EnvironmentName "<string>"'
    Write-Host 'Specify the environment name for which the replacement configuration should be'
    Write-Host 'applied. This environement must be configured in the configuration file.'
    Write-Host 'If parameter is not specified, the first environment specified in the'
    Write-Host 'replacement configuration file is used.'
    Write-Host;
    Write-Host -ForegroundColor DarkGreen '-Help'
    Write-Host 'If parameter is used, this help will be displayed.'
    Write-Host;
    Write-Host '--------------------------------------------------------------------------------'
    exit
}



# ReplacementConfigPath
if(-Not [String]::IsNullOrWhiteSpace($ReplacementConfigPath))
{
    $ReplacementConfigPath = [IO.Path]::Combine($CurrentFolder, $ReplacementConfigPath)
}
else
{
    $ReplacementConfigPath = [IO.Path]::Combine($CurrentFolder, 'replacement_config.json')
}
if(!(Test-Path $ReplacementConfigPath -PathType Leaf))
{
    Write-Error "Replacement configuration file '$ReplacementConfigPath' not found."
}
else
{
    Write-Host "-> using replacement configuration file $ReplacementConfigPath"
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
}
else
{
    Write-Host "-> using input folder $ArtifactInputPath"
}



# ArtifactOutputPath
if(-Not [String]::IsNullOrWhiteSpace($ArtifactOutputPath))
{
    $ArtifactOutputPath = [IO.Path]::Combine($CurrentFolder, $ArtifactOutputPath)
}
else
{
    $ArtifactOutputPath = $CurrentFolder
}
if(!(Test-Path $ArtifactOutputPath -PathType Container))
{
    Write-Error "Output folder '$ArtifactOutputPath' not found."
}
else
{
    Write-Host "-> using output folder $ArtifactOutputPath"
}



# ArtifactBackupPath
$doBackup = $false
if(-Not [String]::IsNullOrWhiteSpace($ArtifactBackupPath))
{
    $ArtifactBackupPath = [IO.Path]::Combine($CurrentFolder, $ArtifactBackupPath)

    if(!(Test-Path $ArtifactBackupPath -PathType Container))
    {
        Write-Error "Backup folder '$ArtifactBackupPath' not found."
    }

    Write-Host "-> using backup folder $ArtifactBackupPath"
if ($ArtifactInputPath -ne $ArtifactBackupPath)
    {
        $ExcludeFolders += $ArtifactBackupPath
    }
    $doBackup = $true
}
else
{
    Write-Host "-> not creating backup"
}



# EnvironmentName
$ReplacementConfigContent = Get-Content $ReplacementConfigPath | ConvertFrom-Json
$Environments = $ReplacementConfigContent.environments
$EnvironmentIndex = -1
if(-Not [String]::IsNullOrWhiteSpace($EnvironmentName))
{
    $index = 0

    foreach ($Environment in $Environments)
    {
        if ($EnvironmentName -eq $Environment.name)
        {
            $EnvironmentIndex = $index;
            $EnvironmentName = $Environment.name
            break;
        }
        $index++
    }

    if ($EnvironmentIndex -eq -1)
    {
        Write-Error "Environment '$EnvironmentName' not found in replacement configuration file."
    }
}
else {
    $EnvironmentIndex = 0
    $EnvironmentName = $Environments[$EnvironmentIndex].name
}
Write-Host "-> using environment '$EnvironmentName'"



# Copy files to backup folder
if ($doBackup -eq $true)
{
    Write-Host
    Write-Host '--------------------------------------------------------------------------------'
    Write-Host

    # Create new subfolder (Format:yyyyMMddHHmmssfff)
    $ArtifactBackupPath = Join-Path $ArtifactBackupPath $(get-date -Format yyyyMMddHHmmssfff)
    New-Item $ArtifactBackupPath -ItemType Directory | out-null

    Write-Host "Copy backup files to $ArtifactBackupPath"

    # Copy all folders, subfolders and included files to backup folder
    $ExcludeFolders += $ArtifactBackupPath
    $ExcludeFoldersForBackup = $ExcludeFolders
    Copy-Folder -SourceFolder $ArtifactInputPath -TargetFolder $ArtifactBackupPath -ExcludeFolders $ExcludeFoldersForBackup
}



# Copy files to output folder
if ($ArtifactOutputPath -ne $ArtifactInputPath)
{
    Write-Host
    Write-Host '--------------------------------------------------------------------------------'
    Write-Host
    Write-Host "Copy output files to $ArtifactOutputPath"

    # Copy all folders, subfolders and included files to output folder
    $ExcludeFoldersForOutput = $ExcludeFolders
    if ($ArtifactOutputPath -ne $ArtifactInputPath)
    {
        $ExcludeFoldersForOutput += $ArtifactOutputPath
    }
    Copy-Folder -SourceFolder $ArtifactInputPath -TargetFolder $ArtifactOutputPath -ExcludeFolders $ExcludeFoldersForOutput
}



# Process all files in output folder and subfolders
Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Processing files in $ArtifactOutputPath ..."

$ExcludeFoldersForProcessing += $ExcludeFolders
$ExcludeFoldersForProcessing += Join-Path $CurrentFolder $ScriptName
$ExcludeFoldersForProcessing += Join-Path $ArtifactOutputPath $ScriptName
$ExcludeFoldersForProcessing += $ReplacementConfigPath
$ExcludeFoldersForProcessing += Join-Path $ArtifactOutputPath "replacement_config.json"

$FileCount = 0

# Loop through all relevant files
$ChildItems = Get-ChildItem $ArtifactOutputPath -Recurse -Include *.sql, *.txt, *.py, *.json, *.ipynb
foreach ($Item in $ChildItems)
{
    # ignore subfolders (but not the included files)
    if ($Item.PSIsContainer -eq $true)
    {
        continue
    }

    # ignore if in $ExcludeFoldersForProcessing
    $IsExcluded = $false
    foreach ($Exclude in $ExcludeFoldersForProcessing)
    {
        if ($Item.FullName.Contains($Exclude))
        {
            $IsExcluded = $true
            break
        }
    }
    if ($IsExcluded -eq $true)
    {
        continue
    }

    Write-Host
    Write-Host "-> working on file $Item"

    $FileContent = Get-Content $Item

    # Replace placeholders in variable $FileContent with concrete values from JSON file
    foreach ($Project in $Environments[$EnvironmentIndex].projects)
    {
        $ProjectName = $Project.name
        Write-Verbose "  -> project $ProjectName"

        foreach ($Variable in $Project.variables)
        {
            $Placeholder = '{' + $Variable.name + '}'
            $ReplacementValue = $Variable.value

            if([String]::IsNullOrWhiteSpace($ReplacementValue))
            {
                $ReplacementValue = "~~~replacement_value_not_specified~~~" # unconfigured values are marked and later replaced below
            }

            Write-Verbose "    -> search and replace $Placeholder"
            # Replace placeholder with value
            $FileContent = $FileContent -replace $Placeholder, $ReplacementValue

            # Remove empty identifier quotation
            # For example: SQL Server uses square brackets as identifier quotation. 
            # If a identifier part (like servername) was not configured in the replacement configuration file,
            # it should be removed from the output, together with the quotation and punctuation around it.
            $FileContent = $FileContent -replace '\[~~~replacement_value_not_specified~~~\]\.', ''
            $FileContent = $FileContent -replace '"~~~replacement_value_not_specified~~~"\.', ''
            $FileContent = $FileContent -replace '`~~~replacement_value_not_specified~~~`\.', ''
            $FileContent = $FileContent -replace '''~~~replacement_value_not_specified~~~''\.', ''
            $FileContent = $FileContent -replace '~~~replacement_value_not_specified~~~\.', ''
            $FileContent = $FileContent -replace '~~~replacement_value_not_specified~~~', ''
        }
    }

    # write the processed content back to the file
    Set-Content -Path $Item -Value $FileContent
    
    $FileCount++
}

Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Finished - $FileCount files processed"
