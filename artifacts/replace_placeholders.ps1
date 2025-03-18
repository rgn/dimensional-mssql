#Requires -Version 7

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

	if (!(Test-Path $SourceFolder -PathType Container))
	{
		Write-Error "Source folder '$SourceFolder' not found."
	}
	if (!(Test-Path $TargetFolder -PathType Container))
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
if ($Help.IsPresent)
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
if (-Not [String]::IsNullOrWhiteSpace($ReplacementConfigPath))
{
	$ReplacementConfigPath = [IO.Path]::Combine($CurrentFolder, $ReplacementConfigPath)
}
else
{
	$ReplacementConfigPath = [IO.Path]::Combine($CurrentFolder, 'replacement_config.json')
}
if (!(Test-Path $ReplacementConfigPath -PathType Leaf))
{
	Write-Error "Replacement configuration file '$ReplacementConfigPath' not found."
}
else
{
	Write-Host "-> using replacement configuration file $ReplacementConfigPath"
}



# ArtifactInputPath
if (-Not [String]::IsNullOrWhiteSpace($ArtifactInputPath))
{
	$ArtifactInputPath = [IO.Path]::Combine($CurrentFolder, $ArtifactInputPath)
}
else
{
	$ArtifactInputPath = $CurrentFolder
}
if (!(Test-Path $ArtifactInputPath -PathType Container))
{
	Write-Error "Input folder '$ArtifactInputPath' not found."
}
else
{
	Write-Host "-> using input folder $ArtifactInputPath"
}



# ArtifactOutputPath
if (-Not [String]::IsNullOrWhiteSpace($ArtifactOutputPath))
{
	$ArtifactOutputPath = [IO.Path]::Combine($CurrentFolder, $ArtifactOutputPath)
}
else
{
	$ArtifactOutputPath = $CurrentFolder
}
if (!(Test-Path $ArtifactOutputPath -PathType Container))
{
	Write-Error "Output folder '$ArtifactOutputPath' not found."
}
else
{
	Write-Host "-> using output folder $ArtifactOutputPath"
}



# ArtifactBackupPath
$doBackup = $false
if (-Not [String]::IsNullOrWhiteSpace($ArtifactBackupPath))
{
	$ArtifactBackupPath = [IO.Path]::Combine($CurrentFolder, $ArtifactBackupPath)

	if (!(Test-Path $ArtifactBackupPath -PathType Container))
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
if (-Not [String]::IsNullOrWhiteSpace($EnvironmentName))
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
		$PreviousVariableGroup = [string]::Empty
		$IsPreviousVariableInGroupSkipped = $false
		Write-Verbose "  -> project $ProjectName"

		foreach ($Variable in $Project.variables)
		{
			$Placeholder = '{' + $Variable.name + '}'

			# split variable name into parts
			$VariableName = $Variable.name
			$VariableNameParts = $VariableName -split '#'
			if ($VariableNameParts.Length -eq 3) # three parts found?
			{
				$VariablePartProject = $VariableNameParts[0]
				$VariablePartLayer = $VariableNameParts[1]
			#	$VariablePartConfiguration = $VariableNameParts[2] #not required
			}
			else
			{
				Write-Error "Variable name '$VariableName' is not in the expected format 'project#layer#variable'"
			}
			
			# check if empty replacement variable could be skipped
			$doSkipEmptyVariable = $true
			if (($PreviousVariableGroup -ne "$VariablePartProject#$VariablePartLayer")) # current variable is first of variable group?
			{
				$PreviousVariableGroup = "$VariablePartProject#$VariablePartLayer"
				$IsPreviousVariableInGroupSkipped = $false
			}
			else
			{
				if ($IsPreviousVariableInGroupSkipped -eq $false) # previous variable was skipped?
				{
					$doSkipEmptyVariable = $false
				}
			}

			# get replacement value
			$ReplacementValue = $Variable.value

			# handle empty replacement value
			$IsPreviousVariableInGroupSkipped = $false
			if ([String]::IsNullOrWhiteSpace($ReplacementValue))
			{
				if ($doSkipEmptyVariable -eq $true) # empty variable should be skipped
				{
					$ReplacementValue = "~~~replacement_value_skipped~~~" # unconfigured values are marked and later replaced below
					$IsPreviousVariableInGroupSkipped = $true
				}
				else
				{
					$ReplacementValue = "~~~replacement_value_empty~~~" # unconfigured values are marked and later replaced below
				}
			}

			Write-Verbose "    -> search and replace $Placeholder"
			# Replace placeholder with value
			$FileContent = $FileContent -replace $Placeholder, $ReplacementValue

			# Remove empty identifier quotation
			# If a identifier part (like servername) was not configured in the replacement configuration file,
			# it should be removed from the output, together with the quotation around it.
			# For example: SQL Server uses square brackets as identifier quotation that must be removed as well.
			# If it was skipped, also the following punctuation is removed.
			# For example: If the server name is empty, a empty database and schema name can also be removed.

			$FileContent = $FileContent -replace ([regex]::Escape('[~~~replacement_value_skipped~~~].')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('"~~~replacement_value_skipped~~~".')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('`~~~replacement_value_skipped~~~`.')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('''~~~replacement_value_skipped~~~''.')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_skipped~~~.')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_skipped~~~')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('[~~~replacement_value_empty~~~].')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('"~~~replacement_value_empty~~~".')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('`~~~replacement_value_empty~~~`.')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('''~~~replacement_value_empty~~~''.')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_empty~~~.')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_empty~~~')), ''
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

# SIG # Begin signature block
# MII6ggYJKoZIhvcNAQcCoII6czCCOm8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBMsVQbkXjX4NMW
# evRApS5XpE26JKx9C0cPg4JUlCwVR6CCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
# lUgTecgRwIeZMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVu
# dGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAy
# MDAeFw0yMDA0MTYxODM2MTZaFw00NTA0MTYxODQ0NDBaMHcxCzAJBgNVBAYTAlVT
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jv
# c29mdCBJZGVudGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRo
# b3JpdHkgMjAyMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALORKgeD
# Bmf9np3gx8C3pOZCBH8Ppttf+9Va10Wg+3cL8IDzpm1aTXlT2KCGhFdFIMeiVPvH
# or+Kx24186IVxC9O40qFlkkN/76Z2BT2vCcH7kKbK/ULkgbk/WkTZaiRcvKYhOuD
# PQ7k13ESSCHLDe32R0m3m/nJxxe2hE//uKya13NnSYXjhr03QNAlhtTetcJtYmrV
# qXi8LW9J+eVsFBT9FMfTZRY33stuvF4pjf1imxUs1gXmuYkyM6Nix9fWUmcIxC70
# ViueC4fM7Ke0pqrrBc0ZV6U6CwQnHJFnni1iLS8evtrAIMsEGcoz+4m+mOJyoHI1
# vnnhnINv5G0Xb5DzPQCGdTiO0OBJmrvb0/gwytVXiGhNctO/bX9x2P29Da6SZEi3
# W295JrXNm5UhhNHvDzI9e1eM80UHTHzgXhgONXaLbZ7LNnSrBfjgc10yVpRnlyUK
# xjU9lJfnwUSLgP3B+PR0GeUw9gb7IVc+BhyLaxWGJ0l7gpPKWeh1R+g/OPTHU3mg
# trTiXFHvvV84wRPmeAyVWi7FQFkozA8kwOy6CXcjmTimthzax7ogttc32H83rwjj
# O3HbbnMbfZlysOSGM1l0tRYAe1BtxoYT2v3EOYI9JACaYNq6lMAFUSw0rFCZE4e7
# swWAsk0wAly4JoNdtGNz764jlU9gKL431VulAgMBAAGjVDBSMA4GA1UdDwEB/wQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTIftJqhSobyhmYBAcnz1AQ
# T2ioojAQBgkrBgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQwFAAOCAgEAr2rd5hnn
# LZRDGU7L6VCVZKUDkQKL4jaAOxWiUsIWGbZqWl10QzD0m/9gdAmxIR6QFm3FJI9c
# Zohj9E/MffISTEAQiwGf2qnIrvKVG8+dBetJPnSgaFvlVixlHIJ+U9pW2UYXeZJF
# xBA2CFIpF8svpvJ+1Gkkih6PsHMNzBxKq7Kq7aeRYwFkIqgyuH4yKLNncy2RtNwx
# AQv3Rwqm8ddK7VZgxCwIo3tAsLx0J1KH1r6I3TeKiW5niB31yV2g/rarOoDXGpc8
# FzYiQR6sTdWD5jw4vU8w6VSp07YEwzJ2YbuwGMUrGLPAgNW3lbBeUU0i/OxYqujY
# lLSlLu2S3ucYfCFX3VVj979tzR/SpncocMfiWzpbCNJbTsgAlrPhgzavhgplXHT2
# 6ux6anSg8Evu75SjrFDyh+3XOjCDyft9V77l4/hByuVkrrOj7FjshZrM77nq81YY
# uVxzmq/FdxeDWds3GhhyVKVB0rYjdaNDmuV3fJZ5t0GNv+zcgKCf0Xd1WF81E+Al
# GmcLfc4l+gcK5GEh2NQc5QfGNpn0ltDGFf5Ozdeui53bFv0ExpK91IjmqaOqu/dk
# ODtfzAzQNb50GQOmxapMomE2gj4d8yu8l13bS3g7LfU772Aj6PXsCyM2la+YZr9T
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAACvlVc6
# d3IN1CyKAAAAAK+VMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBFT0MgQ0EgMDIwHhcNMjQwOTA0MTMxMjQ3WhcNMjQwOTA3
# MTMxMjQ3WjBnMQswCQYDVQQGEwJDSDEZMBcGA1UECBMQQmFzZWwtTGFuZHNjaGFm
# dDERMA8GA1UEBxMIUHJhdHRlbG4xFDASBgNVBAoTC2JpR0VOSVVTIEFHMRQwEgYD
# VQQDEwtiaUdFTklVUyBBRzCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AJH+Fv3/N/XhLjIEvENsCcmea+oAr0OPWPv0pWp7D9HFa80pa8+LdVudq9lLkG80
# vANQCeF+18SoC9g2Mt6aS33Dtc2pIBjwM1RMRrBDqGLtI2J0E3eBXBSl8cKfb+uA
# ck3V6VtisGj87+AYUm+aEzHQtRo7g2evr0LZi6Qf7zUTvdgqRjhTAbdrSBysqAXF
# AdszPVJpP7A/WTQTpdfG4GD4kUUNpYHn06DjRf3kxjjQvcs6pQUheXtwB3HU/jJ4
# WWkgIq05zydDgoXnlA5K/E1FQI9Pgz+ouh9VAskb73rYONXUHAwO/2ax+m6CUHIk
# xsXGwvAR1F+p+EGf1VIWnXhCzCY9UogsNznBW7geFTBAbE0OVjmBng05l8Q/lqJ/
# u97pIzjxxCmbzea+Hv5R/28pMf/4gekx1/P46iL4CpepYrbO1c2vdYLbaUNSgR4k
# iG2Pt99fTCeiR/erkK184i5ITyQMTkEzgwF3Cc/nSYKYhBCWYlujMCNbivoe9CuZ
# cwIDAQABo4ICFzCCAhMwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOgYD
# VR0lBDMwMQYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGSsGAQQBgjdhgsaA6WLf0W6B
# 6fmZVeSkpA0wHQYDVR0OBBYEFNlGjdBx/lPvDaFu0BPWDOPlOw/uMB8GA1UdIwQY
# MBaAFGWfUc6FaH8vikWIqt2nMbseDQBeMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEVPQyUyMENBJTIwMDIuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBFT0MlMjBD
# QSUyMDAyLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBAIJbIk8cZp5v4RYd
# V4uLov+9DUBCXn0DNYWExKDSfk9K2gSE1al47UXifKc6RNetXcOJS/ABIR6th9ro
# v9EbLP+RxIFP0tn1JU3bgmHnv6/lqhfc8w3G6yzoR06rtueE///1ZjENwWffRZ12
# l181VrdUYRbvIXKhGw/zt6gmxduaNEI+Azt/2zO6/u3N5ztIqc6EflXoRWm4Z73S
# zysA43EcgKMbDrNIBG+T7J1RBkihca7rCnzpB/J5CT0FxVh7ymiVCI67Az1v51D2
# cFzuYox/qM8J3vIzj3lBrXY5YgOCGeUEQLDlB5JnnOhnMXg2Eb5Ih6RZR1i2mMPl
# ln5tsVvwnvr5l/uB7QCludWeR08ngE+O/fcy0thSMlmxUfVkltXknrnxxT3ojkmB
# zm2unOsRvA7JasXxCV8WFRbmYuGC7J9WRUxuHOmKjMf+5fYoPjpBPiZ2D4nt8g2B
# Zlt3AOiy0TDPdzzVS+wvbpkEN3oSO2RDaDqBw98hO3npPiXpFhIM53qzNwweb82r
# 0CL5WexK4lvPGWpqmjSxRGMW1ryDObVPqXEKCZAHrsSOywOtVsj7SeRLjRlhsnrl
# LkZp6TAI1yhh7kV3gO0d/H4JEM6cD9xRM3rlqFqO1d/LmxmExjdpqqTlAMhvl9m0
# Ly3NsfOrZZSecTpXY4Q77QChSEoTMIIG5zCCBM+gAwIBAgITMwAAr5VXOndyDdQs
# igAAAACvlTANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgRU9DIENBIDAyMB4XDTI0MDkwNDEzMTI0N1oXDTI0MDkwNzEzMTI0
# N1owZzELMAkGA1UEBhMCQ0gxGTAXBgNVBAgTEEJhc2VsLUxhbmRzY2hhZnQxETAP
# BgNVBAcTCFByYXR0ZWxuMRQwEgYDVQQKEwtiaUdFTklVUyBBRzEUMBIGA1UEAxML
# YmlHRU5JVVMgQUcwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCR/hb9
# /zf14S4yBLxDbAnJnmvqAK9Dj1j79KVqew/RxWvNKWvPi3VbnavZS5BvNLwDUAnh
# ftfEqAvYNjLemkt9w7XNqSAY8DNUTEawQ6hi7SNidBN3gVwUpfHCn2/rgHJN1elb
# YrBo/O/gGFJvmhMx0LUaO4Nnr69C2YukH+81E73YKkY4UwG3a0gcrKgFxQHbMz1S
# aT+wP1k0E6XXxuBg+JFFDaWB59Og40X95MY40L3LOqUFIXl7cAdx1P4yeFlpICKt
# Oc8nQ4KF55QOSvxNRUCPT4M/qLofVQLJG+962DjV1BwMDv9msfpuglByJMbFxsLw
# EdRfqfhBn9VSFp14QswmPVKILDc5wVu4HhUwQGxNDlY5gZ4NOZfEP5aif7ve6SM4
# 8cQpm83mvh7+Uf9vKTH/+IHpMdfz+Ooi+AqXqWK2ztXNr3WC22lDUoEeJIhtj7ff
# X0wnokf3q5CtfOIuSE8kDE5BM4MBdwnP50mCmIQQlmJbozAjW4r6HvQrmXMCAwEA
# AaOCAhcwggITMAwGA1UdEwEB/wQCMAAwDgYDVR0PAQH/BAQDAgeAMDoGA1UdJQQz
# MDEGCisGAQQBgjdhAQAGCCsGAQUFBwMDBhkrBgEEAYI3YYLGgOli39Fugen5mVXk
# pKQNMB0GA1UdDgQWBBTZRo3Qcf5T7w2hbtAT1gzj5TsP7jAfBgNVHSMEGDAWgBRl
# n1HOhWh/L4pFiKrdpzG7Hg0AXjBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBFT0MlMjBDQSUyMDAyLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwRU9DJTIwQ0ElMjAw
# Mi5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQCCWyJPHGaeb+EWHVeLi6L/
# vQ1AQl59AzWFhMSg0n5PStoEhNWpeO1F4nynOkTXrV3DiUvwASEerYfa6L/RGyz/
# kcSBT9LZ9SVN24Jh57+v5aoX3PMNxuss6EdOq7bnhP//9WYxDcFn30WddpdfNVa3
# VGEW7yFyoRsP87eoJsXbmjRCPgM7f9szuv7tzec7SKnOhH5V6EVpuGe90s8rAONx
# HICjGw6zSARvk+ydUQZIoXGu6wp86QfyeQk9BcVYe8polQiOuwM9b+dQ9nBc7mKM
# f6jPCd7yM495Qa12OWIDghnlBECw5QeSZ5zoZzF4NhG+SIekWUdYtpjD5ZZ+bbFb
# 8J76+Zf7ge0ApbnVnkdPJ4BPjv33MtLYUjJZsVH1ZJbV5J658cU96I5Jgc5trpzr
# EbwOyWrF8QlfFhUW5mLhguyfVkVMbhzpiozH/uX2KD46QT4mdg+J7fINgWZbdwDo
# stEwz3c81UvsL26ZBDd6EjtkQ2g6gcPfITt56T4l6RYSDOd6szcMHm/Nq9Ai+Vns
# SuJbzxlqapo0sURjFta8gzm1T6lxCgmQB67EjssDrVbI+0nkS40ZYbJ65S5Gaekw
# CNcoYe5Fd4DtHfx+CRDOnA/cUTN65ahajtXfy5sZhMY3aaqk5QDIb5fZtC8tzbHz
# q2WUnnE6V2OEO+0AoUhKEzCCB1owggVCoAMCAQICEzMAAAAF+3pcMhNh310AAAAA
# AAUwDQYJKoZIhvcNAQEMBQAwYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVk
# IENvZGUgU2lnbmluZyBQQ0EgMjAyMTAeFw0yMTA0MTMxNzMxNTNaFw0yNjA0MTMx
# NzMxNTNaMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBFT0MgQ0Eg
# MDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDSGpl8PzKQpMDoINta
# +yGYGkOgF/su/XfZFW5KpXBA7doAsuS5GedMihGYwajR8gxCu3BHpQcHTrF2o6QB
# +oHp7G5tdMe7jj524dQJ0TieCMQsFDKW4y5I6cdoR294hu3fU6EwRf/idCSmHj4C
# HR5HgfaxNGtUqYquU6hCWGJrvdCDZ0eiK1xfW5PW9bcqem30y3voftkdss2ykxku
# RYFpsoyXoF1pZldik8Z1L6pjzSANo0K8WrR3XRQy7vEd6wipelMNPdDcB47FLKVJ
# Nz/vg/eiD2Pc656YQVq4XMvnm3Uy+lp0SFCYPy4UzEW/+Jk6PC9x1jXOFqdUsvKm
# XPXf83NKhTdCOE92oAaFEjCH9gPOjeMJ1UmBZBGtbzc/epYUWTE2IwTaI7gi5iCP
# tHCx4bC/sj1zE7JoeKEox1P016hKOlI3NWcooZxgy050y0oWqhXsKKbabzgaYhhl
# MGitH8+j2LCVqxNgoWkZmp1YrJick7YVXygyZaQgrWJqAsuAS3plpHSuT/WNRiyz
# JOJGpavzhCzdcv9XkpQES1QRB9D/hG2cjT24UVQgYllX2YP/E5SSxah0asJBJ6bo
# fLbrXEwkAepOoy4MqDCLzGT+Z+WvvKFc8vvdI5Qua7UCq7gjsal7pDA1bZO1AHEz
# e+1JOZ09bqsrnLSAQPnVGOzIrQIDAQABo4ICDjCCAgowDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRln1HOhWh/L4pFiKrdpzG7Hg0A
# XjBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgw
# FoAU2UEpsA8PY2zvadf1zSmepEhqMOYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBW
# ZXJpZmllZCUyMENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyMS5jcmwwga4GCCsG
# AQUFBwEBBIGhMIGeMG0GCCsGAQUFBzAChmFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2Rl
# JTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwDQYJKoZIhvcNAQEMBQADggIBAEVJ
# YNR3TxfiDkfO9V+sHVKJXymTpc8dP2M+QKa9T+68HOZlECNiTaAphHelehK1Elon
# +WGMLkOr/ZHs/VhFkcINjIrTO9JEx0TphC2AaOax2HMPScJLqFVVyB+Y1Cxw8nVY
# fFu8bkRCBhDRkQPUU3Qw49DNZ7XNsflVrR1LG2eh0FVGOfINgSbuw0Ry8kdMbd5f
# MDJ3TQTkoMKwSXjPk7Sa9erBofY9LTbTQTo/haovCCz82ZS7n4BrwvD/YSfZWQhb
# s+SKvhSfWMbr62P96G6qAXJQ88KHqRue+TjxuKyL/M+MBWSPuoSuvt9JggILMniz
# hhQ1VUeB2gWfbFtbtl8FPdAD3N+Gr27gTFdutUPmvFdJMURSDaDNCr0kfGx0fIx9
# wIosVA5c4NLNxh4ukJ36voZygMFOjI90pxyMLqYCrr7+GIwOem8pQgenJgTNZR5q
# 23Ipe0x/5Csl5D6fLmMEv7Gp0448TPd2Duqfz+imtStRsYsG/19abXx9Zd0C/U8K
# 0sv9pwwu0ejJ5JUwpBioMdvdCbS5D41DRgTiRTFJBr5b9wLNgAjfa43Sdv0zgyvW
# mPhslmJ02QzgnJip7OiEgvFiSAdtuglAhKtBaublFh3KEoGmm0n0kmfRnrcuN2fO
# U5TGOWwBtCKvZabP84kTvTcFseZBlHDM/HW+7tLnMIIHnjCCBYagAwIBAgITMwAA
# AAeHozSje6WOHAAAAAAABzANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQGEwJVUzEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9NaWNyb3Nv
# ZnQgSWRlbnRpdHkgVmVyaWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
# aXR5IDIwMjAwHhcNMjEwNDAxMjAwNTIwWhcNMzYwNDAxMjAxNTIwWjBjMQswCQYD
# VQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTQwMgYDVQQD
# EytNaWNyb3NvZnQgSUQgVmVyaWZpZWQgQ29kZSBTaWduaW5nIFBDQSAyMDIxMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAsvDArxmIKOLdVHpMSWxpCFUJ
# tFL/ekr4weslKPdnF3cpTeuV8veqtmKVgok2rO0D05BpyvUDCg1wdsoEtuxACEGc
# gHfjPF/nZsOkg7c0mV8hpMT/GvB4uhDvWXMIeQPsDgCzUGzTvoi76YDpxDOxhgf8
# JuXWJzBDoLrmtThX01CE1TCCvH2sZD/+Hz3RDwl2MsvDSdX5rJDYVuR3bjaj2Qfz
# ZFmwfccTKqMAHlrz4B7ac8g9zyxlTpkTuJGtFnLBGasoOnn5NyYlf0xF9/bjVRo4
# Gzg2Yc7KR7yhTVNiuTGH5h4eB9ajm1OCShIyhrKqgOkc4smz6obxO+HxKeJ9bYmP
# f6KLXVNLz8UaeARo0BatvJ82sLr2gqlFBdj1sYfqOf00Qm/3B4XGFPDK/H04kteZ
# EZsBRc3VT2d/iVd7OTLpSH9yCORV3oIZQB/Qr4nD4YT/lWkhVtw2v2s0TnRJubL/
# hFMIQa86rcaGMhNsJrhysLNNMeBhiMezU1s5zpusf54qlYu2v5sZ5zL0KvBDLHtL
# 8F9gn6jOy3v7Jm0bbBHjrW5yQW7S36ALAt03QDpwW1JG1Hxu/FUXJbBO2AwwVG4F
# re+ZQ5Od8ouwt59FpBxVOBGfN4vN2m3fZx1gqn52GvaiBz6ozorgIEjn+PhUXILh
# AV5Q/ZgCJ0u2+ldFGjcCAwEAAaOCAjUwggIxMA4GA1UdDwEB/wQEAwIBhjAQBgkr
# BgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU2UEpsA8PY2zvadf1zSmepEhqMOYwVAYD
# VR0gBE0wSzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3FAIE
# DB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFMh+0mqF
# KhvKGZgEByfPUBBPaKiiMIGEBgNVHR8EfTB7MHmgd6B1hnNodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJZGVudGl0eSUyMFZl
# cmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhvcml0eSUyMDIw
# MjAuY3JsMIHDBggrBgEFBQcBAQSBtjCBszCBgQYIKwYBBQUHMAKGdWh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwSWRlbnRp
# dHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRob3Jp
# dHklMjAyMDIwLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9z
# b2Z0LmNvbS9vY3NwMA0GCSqGSIb3DQEBDAUAA4ICAQB/JSqe/tSr6t1mCttXI0y6
# XmyQ41uGWzl9xw+WYhvOL47BV09Dgfnm/tU4ieeZ7NAR5bguorTCNr58HOcA1tcs
# HQqt0wJsdClsu8bpQD9e/al+lUgTUJEV80Xhco7xdgRrehbyhUf4pkeAhBEjABvI
# UpD2LKPho5Z4DPCT5/0TlK02nlPwUbv9URREhVYCtsDM+31OFU3fDV8BmQXv5hT2
# RurVsJHZgP4y26dJDVF+3pcbtvh7R6NEDuYHYihfmE2HdQRq5jRvLE1Eb59PYwIS
# FCX2DaLZ+zpU4bX0I16ntKq4poGOFaaKtjIA1vRElItaOKcwtc04CBrXSfyL2Op6
# mvNIxTk4OaswIkTXbFL81ZKGD+24uMCwo/pLNhn7VHLfnxlMVzHQVL+bHa9KhTyz
# wdG/L6uderJQn0cGpLQMStUuNDArxW2wF16QGZ1NtBWgKA8Kqv48M8HfFqNifN6+
# zt6J0GwzvU8g0rYGgTZR8zDEIJfeZxwWDHpSxB5FJ1VVU1LIAtB7o9PXbjXzGifa
# IMYTzU4YKt4vMNwwBmetQDHhdAtTPplOXrnI9SI6HeTtjDD3iUN/7ygbahmYOHk7
# VB7fwT4ze+ErCbMh6gHV1UuXPiLciloNxH6K4aMfZN1oLVk6YFeIJEokuPgNPa6E
# nTiOL60cPqfny+Fq8UiuZzGCFzIwghcuAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEVPQyBDQSAwMgITMwAAr5VXOndyDdQsigAAAACvlTAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCAhVPdVyNflzDldOLpbXp09+GGD
# Jla1YPY3PKyx1WA4JTANBgkqhkiG9w0BAQEFAASCAYCHZeZbC5PVGf6vyXnyuSWR
# KEQYwpzwBzdHAN+tWxk92iK6vhu+LmZjQ4f8FdnthW4k92yJ3ViOhrrseHzoNieE
# dsVqY7MTI8V7NZ+9hCN0Ypzhc8saJ9Qo6yClpp76amK4pZuTI/yCu5oo8pMuikGX
# +XYmn483aLPNzGBuy+RGunyM/Z2gKM900ac1xC0nXTENcoJ6lRyRb4ywkjMYcaGq
# dwwHAy28tVwCCWbreAQ8csG73adALtztfPru4e9a/Zbp0hftIILsnw7XbgNRCzi4
# 5iAdNiRmNgTYUUO8Zf6y+l4pshrRySZ0C2Q1GB99xpV5Y2ny1AJYovJ5kmiT2r+V
# X755oaMa+v1dxVq19+pquNtF+4k1y3k9mjgxengXLb1jk22Th8ngwjWnw70FTdJO
# KKv+gfhBEQz8b2aNKVn4JWqAM2vNR0cRfvdqxI895M1N2E6fUhxk9i+Zcu1emiz9
# aKfJ9RDpyzeiUrqQzJUnSgkc9QOxhMHSK4oDWdxVu8+hghSyMIIUrgYKKwYBBAGC
# NwMDATGCFJ4wghSaBgkqhkiG9w0BBwKgghSLMIIUhwIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBagYLKoZIhvcNAQkQAQSgggFZBIIBVTCCAVECAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgW9/ey8RaiL3rovxXTC17UUhVFn/DuGCDlVxGmcZa
# 8wsCBmbHOViR7xgTMjAyNDA5MDUwODE5MTQuMjc4WjAEgAIB9KCB6aSB5jCB4zEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWlj
# cm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hp
# ZWxkIFRTUyBFU046NDUxQS0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9yaXR5oIIPKTCCB4IwggVqoAMC
# AQICEzMAAAAF5c8P/2YuyYcAAAAAAAUwDQYJKoZIhvcNAQEMBQAwdzELMAkGA1UE
# BhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjFIMEYGA1UEAxM/
# TWljcm9zb2Z0IElkZW50aXR5IFZlcmlmaWNhdGlvbiBSb290IENlcnRpZmljYXRl
# IEF1dGhvcml0eSAyMDIwMB4XDTIwMTExOTIwMzIzMVoXDTM1MTExOTIwNDIzMVow
# YTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
# MDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIw
# MjAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCefOdSY/3gxZ8FfWO1
# BiKjHB7X55cz0RMFvWVGR3eRwV1wb3+yq0OXDEqhUhxqoNv6iYWKjkMcLhEFxvJA
# eNcLAyT+XdM5i2CgGPGcb95WJLiw7HzLiBKrxmDj1EQB/mG5eEiRBEp7dDGzxKCn
# TYocDOcRr9KxqHydajmEkzXHOeRGwU+7qt8Md5l4bVZrXAhK+WSk5CihNQsWbzT1
# nRliVDwunuLkX1hyIWXIArCfrKM3+RHh+Sq5RZ8aYyik2r8HxT+l2hmRllBvE2Wo
# k6IEaAJanHr24qoqFM9WLeBUSudz+qL51HwDYyIDPSQ3SeHtKog0ZubDk4hELQSx
# nfVYXdTGncaBnB60QrEuazvcob9n4yR65pUNBCF5qeA4QwYnilBkfnmeAjRN3LVu
# Lr0g0FXkqfYdUmj1fFFhH8k8YBozrEaXnsSL3kdTD01X+4LfIWOuFzTzuoslBrBI
# LfHNj8RfOxPgjuwNvE6YzauXi4orp4Sm6tF245DaFOSYbWFK5ZgG6cUY2/bUq3g3
# bQAqZt65KcaewEJ3ZyNEobv35Nf6xN6FrA6jF9447+NHvCjeWLCQZ3M8lgeCcnnh
# TFtyQX3XgCoc6IRXvFOcPVrr3D9RPHCMS6Ckg8wggTrtIVnY8yjbvGOUsAdZbeXU
# IQAWMs0d3cRDv09SvwVRd61evQIDAQABo4ICGzCCAhcwDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRraSg6NS9IY0DPe9ivSek+2T3b
# ITBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQM
# MAoGCCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMA8GA1UdEwEB
# /wQFMAMBAf8wHwYDVR0jBBgwFoAUyH7SaoUqG8oZmAQHJ89QEE9oqKIwgYQGA1Ud
# HwR9MHsweaB3oHWGc2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3Js
# L01pY3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENl
# cnRpZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5jcmwwgZQGCCsGAQUFBwEBBIGH
# MIGEMIGBBggrBgEFBQcwAoZ1aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJZGVudGl0eSUyMFZlcmlmaWNhdGlvbiUyMFJv
# b3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhvcml0eSUyMDIwMjAuY3J0MA0GCSqGSIb3
# DQEBDAUAA4ICAQBfiHbHfm21WhV150x4aPpO4dhEmSUVpbixNDmv6TvuIHv1xIs1
# 74bNGO/ilWMm+Jx5boAXrJxagRhHQtiFprSjMktTliL4sKZyt2i+SXncM23gRezz
# soOiBhv14YSd1Klnlkzvgs29XNjT+c8hIfPRe9rvVCMPiH7zPZcw5nNjthDQ+zD5
# 63I1nUJ6y59TbXWsuyUsqw7wXZoGzZwijWT5oc6GvD3HDokJY401uhnj3ubBhbkR
# 83RbfMvmzdp3he2bvIUztSOuFzRqrLfEvsPkVHYnvH1wtYyrt5vShiKheGpXa2AW
# psod4OJyT4/y0dggWi8g/tgbhmQlZqDUf3UqUQsZaLdIu/XSjgoZqDjamzCPJtOL
# i2hBwL+KsCh0Nbwc21f5xvPSwym0Ukr4o5sCcMUcSy6TEP7uMV8RX0eH/4JLEpGy
# ae6Ki8JYg5v4fsNGif1OXHJ2IWG+7zyjTDfkmQ1snFOTgyEX8qBpefQbF0fx6URr
# YiarjmBprwP6ZObwtZXJ23jK3Fg/9uqM3j0P01nzVygTppBabzxPAh/hHhhls6kw
# o3QLJ6No803jUsZcd4JQxiYHHc+Q/wAMcPUnYKv/q2O444LO1+n6j01z5mggCSlR
# wD9faBIySAcA9S8h22hIAcRQqIGEjolCK9F6nK9ZyX4lhthsGHumaABdWzCCB58w
# ggWHoAMCAQICEzMAAABCmshvpRumfQYAAAAAAEIwDQYJKoZIhvcNAQEMBQAwYTEL
# MAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAG
# A1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAw
# HhcNMjQwNDE4MTc1OTE3WhcNMjUwNDE3MTc1OTE3WjCB4zELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
# bmQgT3BlcmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046
# NDUxQS0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRp
# bWUgU3RhbXBpbmcgQXV0aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEA2twOzEyo1PCxyO4bhS8Z2L4leL3IOcD3HdEi52b+w/wmSrr+gksTBMfW
# 8o6+ptz3lA25CHfTEqfjTp2m6XsklrQ8n65HBDKO5tyWr+58Qw36jnxSZUIuA3+l
# dPfhrOgNTEIGF/Qu+ysg6AYBXXTG07HZ+ja2MEABgVrrPfVOJfWz4hpnzWDWn6uM
# K/VxaaMYU1U1Hszn/TYxjMEKYnn0lNDICQqWnigmW2syE9yANxcvqAc6cijRxEy4
# QBeS/x3d1yqj6Q8PVk+jViUB34eYSt6DEkKcMlpf3BU+i2NPD2uSuQUiZ9wNwjx4
# ewlvbNABTwbpLp4kngqE9mBeExgWi75HpmXaNKwwuHWZf/C9EpaQuUhGgSMjiIKb
# EaNcoIVKzv3cf0cW8bcK94vYA32QIgdJwvYVQkK5aHcn3zjIfn8wRZmVUExlxdHr
# ydtxxQiAfnYvuWdMUarXfwwE79hcFrPnMiBRHP/iq4yaxIXzRO/nDoWOEZDLJXql
# 5QBtu6ifriXwPhE0sRMu6Ry5tNMKXiQvjcT+M+zJdGIbCQT46hY1tmvilDKSSANc
# SIDx51FxI55HBArNvSDMiu2wj5X/akt0A/oHHE9Q8yfghV7fKZzpHQylrnFNjzjc
# Xj+XJEcJAhs8vuqdGNOvsIrNs/lbKPJn7RUjnSKDU1AHtbkA3TsCAwEAAaOCAcsw
# ggHHMB0GA1UdDgQWBBQWZTL01RLFsDojzhz0iS+hUWbxWTAfBgNVHSMEGDAWgBRr
# aSg6NS9IY0DPe9ivSek+2T3bITBsBgNVHR8EZTBjMGGgX6BdhltodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBS
# U0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0w
# azBpBggrBgEFBQcwAoZdaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# ZXJ0cy9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBD
# QSUyMDIwMjAuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEw
# PwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9j
# cy9SZXBvc2l0b3J5Lmh0bTAIBgZngQwBBAIwDQYJKoZIhvcNAQEMBQADggIBAGzy
# +mEn+SNj81hNpgWnhhNr9e4ZwB1llRy/ljj0wN1JIrXa0tUBzlflRNZq4WQVM5BK
# DzoIXSsoUgbCN2QTCzM4Q0PcoKJiJ0tCuZp6foJQpNpdAc/zuK90XGosALsCJlUu
# FfJkL3WTjWFt8Mz6t2JZZtdis2yCHUuGIAfBl/gUl8EtbGCIfDGEsHyvgVSRJGOV
# ApV3OVMPAaUsQQ3jqp28tIR9OOd+jOEtROc21mJfwhcpqqLsmUV2WvJXEaRXylXG
# DRqibW/hhErfv8wXpAloo8fxG7ONVxk1HTm9M9JbFpw2ICCQkRbnzQxKW6KOwtRn
# xrunx7Cze11eIv0JMYubjnKSSMzOWuqnLnA0a86b1wVU/1lKjB0SaVz6IJKKyC+U
# H6T0pmEVNDE3cem/mbB6g6Qp5VDmOLqA3vFWS3lFiu/KpEPc/RrJ0Kxyr449MHVj
# O4UtUOqlsYSJhU48nJ9hZVHGSamrgb1FKtBVVCrCRYxyaeg9whS7WfmwXME53y8M
# eZTqfbQK6VFTYWdKt/He3kVu16K3mkVHaohbd4FMMz9fT0tykS1HN51Zg7SBLcNH
# 58dvOoDg6S79yNa3e53gzTjQ6tNNZypQ5HrsHrJaEgUszFqvC+1S4DYZGx5TzyHq
# bX3yv0H3tNPRhR8xXPlGXKTaAX1kGlslVzQAxG7qMYID1DCCA9ACAQEweDBhMQsw
# CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
# VQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAIT
# MwAAAEKayG+lG6Z9BgAAAAAAQjANBglghkgBZQMEAgEFAKCCAS0wGgYJKoZIhvcN
# AQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAgRpiOeBzK1cyq/gvX
# Rdwa4QtQzzJE/lSS4uGW5bdB1jCB3QYLKoZIhvcNAQkQAi8xgc0wgcowgccwgaAE
# IK9+c1C+wP2H74bAFJeodjGjQTspUszYeQw+AkLteuKqMHwwZaRjMGExCzAJBgNV
# BAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMT
# KU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAA
# QprIb6Ubpn0GAAAAAABCMCIEIF7/QHeZlVR7IUffPgpp3pq3Er/xGCLgT2ZphR7C
# bWZ8MA0GCSqGSIb3DQEBCwUABIICAB5ft/aoeaDu/lQ8NSQ/wTdsDSTcEZMviQk1
# 7mhkEPZuLAucwmD11vPaCgsuqlBI1GI67BsKE5aQskYluJFUht9/CkLX/ZXEIhLD
# b9yu0gdpElyrUvsztITEV3sLlKx/XSmuG3/pJLChvK75XkostLwNBCh8KjBdUt48
# ydbaZnKtHj5znEg6BxRcuYdOT8tgpXga7ECd+5523K2EgsGaTM8qG+f7+a7hPASh
# LLUAHVBNYGOpJ5O7vJgEGXiWFgeBOtqQIZ0HBETw5+ZT33W1twbjTnycSg1xEcRK
# qCD9oeECQnxGqV+65z9W/LnGPBVxO+ziHjsRpFFN45fDZ+HMkcGbjanvBoB0XCeZ
# pXii8kV3jRHV8wwMulSq7jJApas/bKujP7jEvaq9UREIjeRKqS9UjC9a5RyjHVZU
# 7zetYcyNOKCsPHz61KlTozXu25ckPZCWbCRNRYw4B8cPfJrdN2KkFiQB1NJl8eln
# /ycsrfKe6ZPJsDIi+fo05hNHn+hYkX4j9x6px9DTeirMBKowoc9VzT6m9qBziZza
# 9FWEDsBV0r1YjK+/2yUT9ealGdA/8LQwqEGBbzh/IqG7jaoAPr7m4eajRXN75MDm
# CpkReGI530fr8zYal6f3T9vUh+UpuapxXQTHtTKKE+A2KbEG2h51TWtCRM9F/jjQ
# cW/UsCXr
# SIG # End signature block
