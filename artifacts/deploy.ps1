#Requires -Version 7

param (
	[Parameter()][string] $ServerName,
	[Parameter()][string] $UserName,
	[Parameter()][string] $Password,
	[Parameter()][string] $ArtifactInputPath,
	[Parameter()][switch] $Help
)

Remove-Variable * -Exclude ServerName, UserName, Password, ArtifactInputPath, Help -ErrorAction SilentlyContinue



Function Invoke-Scripts
{
	param (
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



$CurrentFolder = Get-Location
$ScriptName = $MyInvocation.MyCommand.Name



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
	Write-Host 'This script will run the deploy.sql script in the generator output on a'
	Write-Host 'specified Microsoft SQL Server instance.'
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
if ($PSBoundParameters.ContainsKey('ServerName') -eq $false)
{
	$ServerName = Read-Host "Please specify the server or instance name"
}
if ([String]::IsNullOrWhiteSpace($ServerName))
{
	$ServerName = "localhost"
}
Write-Host "-> using server name $ServerName"



# UserName and Password
if ($PSBoundParameters.ContainsKey('UserName') -eq $false)
{
	$UserName = Read-Host "Please specify the user name"
}
if (-not [String]::IsNullOrWhiteSpace($UserName))
{
	
	if ($PSBoundParameters.ContainsKey('Password') -eq $false)
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
	exit
}
else
{
	Write-Host "-> using input folder $ArtifactInputPath"
}



Write-Host
Write-Host '--------------------------------------------------------------------------------'

#deploy
$ScriptPath = $ArtifactInputPath
if (Test-Path $ScriptPath -PathType Container) #check if script scriptpath exists
{
	Write-Host
	Write-Host "Processing deployment script in $ScriptPath ..."

	$Scripts = Get-ChildItem -Path "$ScriptPath\*" -Include deploy.sql | Foreach-Object { $_.FullName } #compile script list
	if ($Scripts.Count -gt 0) #check if any script was found
	{
		Invoke-Scripts $Scripts -ServerName $ServerName -UserName $UserName -Password $Password #run scripts
	}
	else
	{
		Write-Warning "No deployment script found in '$ScriptPath'"
	}
}

Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Finished"

# SIG # Begin signature block
# MII9eAYJKoZIhvcNAQcCoII9aTCCPWUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCfdKBLsZxq02s0
# A0cgBeRKv/4TVhuQO4rbwGoRFZyE46CCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAAJGMlAf
# YYLL6YGqAAAAAkYyMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDIwHhcNMjUwMTA3MDI0NDE2WhcNMjUwMTEw
# MDI0NDE2WjBnMQswCQYDVQQGEwJDSDEZMBcGA1UECBMQQmFzZWwtTGFuZHNjaGFm
# dDERMA8GA1UEBxMIUHJhdHRlbG4xFDASBgNVBAoTC2JpR0VOSVVTIEFHMRQwEgYD
# VQQDEwtiaUdFTklVUyBBRzCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AKaN+7+4xZieV1ydCug/wxHyFfLBpceEewIuxMn2ey4dwpFQo3mofD6GtsRh4YDf
# NxvxWk7GiJe7GF3luKlAb0EX8uA7XYushSIbMsAw9yXGLCvr6FuY1n1EQeHYfGOj
# JxU1RmAwPehCIv6HB0/0H/OM/OGYmqfyeGsDzMmHLUm4UFnVAI+qxqDIy5ZwlfyB
# AJeI6Cbd1O77BCh/QO6ruKzhf+SrZelqSSiXM8BjtDFSd4cHEyWUjzG7RP66KEW8
# l3P0jU74TZaPr1oyWIFmi0dJGpUjxuy5wu9z3AfRfLrX/knvX2j1W4K3l2cVhTCW
# /BV+kYzotsLJ2XoefipuafCB/7+TG61mCOBK4mW1vgDIFxVch9k9TTRTZKZBrYtp
# VZuxdKp/ithSMuSFYR/UJx/JtkgEDxnhyI5N5KpZFJ77uuzBtuwqK/lv7vOuE7H0
# 7C+wp87iLEsj4hLuIdP59t8ERhBE9KvcaZKqulMvM0EkvMhm7Ji82I5TddspcTne
# 3QIDAQABo4ICFzCCAhMwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOgYD
# VR0lBDMwMQYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGSsGAQQBgjdhgsaA6WLf0W6B
# 6fmZVeSkpA0wHQYDVR0OBBYEFBUMA0wDWjOIRpeBuuIa7a7jxWdBMB8GA1UdIwQY
# MBaAFCRFmaF3kCp8w8qDsG5kFoQq+CxnMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDIuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBBT0MlMjBD
# QSUyMDAyLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBAFU00nwbfd9IvO2+
# NxdTcJCpmY8bR+3LJM7Ime5pQgCrvXEnUOweW1Il+AmePKCBRN3i+f6WGmu+tRp2
# 6/Gcwu0zrt51pmKYRg4Q1IxZe8qQkBiSVtKy8wK/+HkSJy2AB5+l4ScMTyTe0IpS
# dJfySZXowfy8yEEyaY5DN9yWIY3saTXt8Yj1EwcYfipLXzFEa2pXeyVDey/n2udB
# toeZht4ezZ6EMHUx+Ze/DSbN86OKxbfpE0CmjCLdTGEnGEAj2NR7zGiJiz70hxLC
# AzvNNUyyFTWeXGSAmI+yONzsTbyv0fZHOyZgcZmfO8zoWaCe8Oa/ZMF9Hm5ncQ16
# L8mu9pU5avzuAC8hhWyQ0JY6FUKCsZpEqCasBMjwkqBzsLWsFYdWg2rRNIiY9P1X
# +okTyx5CjTbqAtSa5mbht3D3x9d+zxpNekhK2UNLrHry34pEyCJs4pxc5gHDnn8A
# a5l6xW1ZUZGyOych5Z7Xgp5JQiuzTHguGY1aJVYf4SFeRhBXqN1kQdRiQB6l6R3G
# 3Vhx6Eg4lFtF/gN0tg6UbSNXNtX4ha0ck8XVe5Dt0DaPNPYk/Fm0rG2C6gEj070F
# 5ebECXxf5CsvfzYjtBLrYpoAIsEOBO5+UAsTy/QlCnrFvqCKvvFByki26BnZ43tc
# q2gTg6tpYdKH/S2r0oyvxDVoTtqRMIIG5zCCBM+gAwIBAgITMwACRjJQH2GCy+mB
# qgAAAAJGMjANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgQU9DIENBIDAyMB4XDTI1MDEwNzAyNDQxNloXDTI1MDExMDAyNDQx
# NlowZzELMAkGA1UEBhMCQ0gxGTAXBgNVBAgTEEJhc2VsLUxhbmRzY2hhZnQxETAP
# BgNVBAcTCFByYXR0ZWxuMRQwEgYDVQQKEwtiaUdFTklVUyBBRzEUMBIGA1UEAxML
# YmlHRU5JVVMgQUcwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCmjfu/
# uMWYnldcnQroP8MR8hXywaXHhHsCLsTJ9nsuHcKRUKN5qHw+hrbEYeGA3zcb8VpO
# xoiXuxhd5bipQG9BF/LgO12LrIUiGzLAMPclxiwr6+hbmNZ9REHh2HxjoycVNUZg
# MD3oQiL+hwdP9B/zjPzhmJqn8nhrA8zJhy1JuFBZ1QCPqsagyMuWcJX8gQCXiOgm
# 3dTu+wQof0Duq7is4X/kq2XpakkolzPAY7QxUneHBxMllI8xu0T+uihFvJdz9I1O
# +E2Wj69aMliBZotHSRqVI8bsucLvc9wH0Xy61/5J719o9VuCt5dnFYUwlvwVfpGM
# 6LbCydl6Hn4qbmnwgf+/kxutZgjgSuJltb4AyBcVXIfZPU00U2SmQa2LaVWbsXSq
# f4rYUjLkhWEf1CcfybZIBA8Z4ciOTeSqWRSe+7rswbbsKiv5b+7zrhOx9OwvsKfO
# 4ixLI+IS7iHT+fbfBEYQRPSr3GmSqrpTLzNBJLzIZuyYvNiOU3XbKXE53t0CAwEA
# AaOCAhcwggITMAwGA1UdEwEB/wQCMAAwDgYDVR0PAQH/BAQDAgeAMDoGA1UdJQQz
# MDEGCisGAQQBgjdhAQAGCCsGAQUFBwMDBhkrBgEEAYI3YYLGgOli39Fugen5mVXk
# pKQNMB0GA1UdDgQWBBQVDANMA1oziEaXgbriGu2u48VnQTAfBgNVHSMEGDAWgBQk
# RZmhd5AqfMPKg7BuZBaEKvgsZzBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBBT0MlMjBDQSUyMDAyLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAw
# Mi5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQBVNNJ8G33fSLztvjcXU3CQ
# qZmPG0ftyyTOyJnuaUIAq71xJ1DsHltSJfgJnjyggUTd4vn+lhprvrUaduvxnMLt
# M67edaZimEYOENSMWXvKkJAYklbSsvMCv/h5EictgAefpeEnDE8k3tCKUnSX8kmV
# 6MH8vMhBMmmOQzfcliGN7Gk17fGI9RMHGH4qS18xRGtqV3slQ3sv59rnQbaHmYbe
# Hs2ehDB1MfmXvw0mzfOjisW36RNApowi3UxhJxhAI9jUe8xoiYs+9IcSwgM7zTVM
# shU1nlxkgJiPsjjc7E28r9H2RzsmYHGZnzvM6FmgnvDmv2TBfR5uZ3ENei/JrvaV
# OWr87gAvIYVskNCWOhVCgrGaRKgmrATI8JKgc7C1rBWHVoNq0TSImPT9V/qJE8se
# Qo026gLUmuZm4bdw98fXfs8aTXpIStlDS6x68t+KRMgibOKcXOYBw55/AGuZesVt
# WVGRsjsnIeWe14KeSUIrs0x4LhmNWiVWH+EhXkYQV6jdZEHUYkAepekdxt1YcehI
# OJRbRf4DdLYOlG0jVzbV+IWtHJPF1XuQ7dA2jzT2JPxZtKxtguoBI9O9BeXmxAl8
# X+QrL382I7QS62KaACLBDgTuflALE8v0JQp6xb6gir7xQcpItugZ2eN7XKtoE4Or
# aWHSh/0tq9KMr8Q1aE7akTCCB1owggVCoAMCAQICEzMAAAAEllBL0tvuy4gAAAAA
# AAQwDQYJKoZIhvcNAQEMBQAwYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVk
# IENvZGUgU2lnbmluZyBQQ0EgMjAyMTAeFw0yMTA0MTMxNzMxNTJaFw0yNjA0MTMx
# NzMxNTJaMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBBT0MgQ0Eg
# MDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDhzqDoM6JjpsA7AI9s
# GVAXa2OjdyRRm5pvlmisydGnis6bBkOJNsinMWRn+TyTiK8ElXXDn9v+jKQj55cC
# pprEx3IA7Qyh2cRbsid9D6tOTKQTMfFFsI2DooOxOdhz9h0vsgiImWLyTnW6locs
# vsJib1g1zRIVi+VoWPY7QeM73L81GZxY2NqZk6VGPFbZxaBSxR1rNIeBEJ6TztXZ
# sz/Xtv6jxZdRb3UimCBFqyaJnrlYQUdcpvKGbYtuEErplaZCgV4T4ZaspYIYr+r/
# hGJNow2Edda9a/7/8jnxS07FWLcNorV9DpgvIggYfMPgKa1ysaK/G6mr9yuse6cY
# 0Hv/9Ca6XZk/0dw6Zj9qm2BSfBP7bSD8DfuIN+65XDrJLYujT+Sn+Nv4ny8TgUyo
# iLDEYHIvjzY8xUELep381sVBrwyaPp6exT4cSq/1qv4BtwrC6ZtmokkqZCsZpI11
# Z+TY2h2BxY6aruPKFvHBk6OcuPT9vCexQ1w0B7T2/6qKjPJBB6zwDdRc9xFBvwb5
# zTJo7YgKJ9ZMrvJK7JQnzyTWa03bYI1+1uOK2IB5p+hn1WaGflF9v5L8rlqtW9Nw
# u6S3k91MNDGXnnsQgToD7pcUGl2yM7OQvN0SHsQuTw9U8yNB88KAq0nzhzXt93YL
# 36nEXWURBQVdj9i0Iv42az1xZQIDAQABo4ICDjCCAgowDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBQkRZmhd5AqfMPKg7BuZBaEKvgs
# ZzBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgw
# FoAU2UEpsA8PY2zvadf1zSmepEhqMOYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBW
# ZXJpZmllZCUyMENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyMS5jcmwwga4GCCsG
# AQUFBwEBBIGhMIGeMG0GCCsGAQUFBzAChmFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2Rl
# JTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwDQYJKoZIhvcNAQEMBQADggIBAGct
# OF2Vsw0iiR0q3NJryKj6kQ73kJzdU7Jj+FCwghx0zKTaEk7Mu38zVZd9DISUOT9C
# 3IvNfrdN05vkn6c7y3SnPPCLtli8yI2oq8BA7nSww4mfdPeEI+mnE02GgYVXHPZT
# KJDhva86tywsr1M4QVdZtQwk5tH08zTBmwAEiG7iTpVUvEQN7QZJ5Bf9kTs8d9OD
# jgu5+3ggqpiae/UK6iyneCUVixV6AucxZlRnxS070XxAKICi4liEvk6UKSyANv29
# 78dCEsWd6V+Dp1C5sgWyoH0iUKidgoln8doxm9i0DvL0Q5ErhzGW9N60JcAdrKJJ
# cfS54T9P3bBUbRyy/lV1TKPrJWubba+UpgCRcg0q8M4Hz6ziH5OBKGVRrYAK7YVa
# fsnOVNJumTQgTxES5iaS7IT8FOST3dYMzHs/Auefgn7l+S9uONDTw57B+kyGHxK4
# 91AqqZnjQjhbZTIkowxNt63XokWKZKoMKGCcIHqXCWl7SB9uj3tTumult8EqnoHa
# TZ/tj5ONatBg3451w87JAB3EYY8HAlJokbeiF2SULGAAnlqcLF5iXtKNDkS5rpq2
# Mh5WE3Qp88sU+ljPkJBT4kLYfv3Hh387pg4VH1ph7nj8Ia6nt1FQh8tK/X+PQM9z
# oSV/djJbGWhaPzJ5jeQetkVoCVEzCEBfI9DesRf3MIIHnjCCBYagAwIBAgITMwAA
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
# nTiOL60cPqfny+Fq8UiuZzGCGigwghokAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMgITMwACRjJQH2GCy+mBqgAAAAJGMjAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCA/24+qO+amhzW5TyfaaSJXCDCK
# i0yetanQSSaLVrKZaDANBgkqhkiG9w0BAQEFAASCAYAGptE+m1MKFOzFybSEBzyW
# 8pqbT48NnaKQWiNKZGGjnrRVM1zdI5kj1I7ZuYBJObEaSfyLEzy2ck279ufp4ofH
# m/QzEoFvn8QNVqi2Xkh0DxX4ZmnaZ4tzFIltt27AGVtvqCKxbQUfQ6A1bWFUn9DI
# 0dnvdnDOyvzgskuaZTo+wRu66lyLlNLm3NhwWCvq6lQaMC9zhTtghD5021niwZaw
# 7ehXCVh+hgCrCCIAFOQkfWbTGELnV2LGmWOcKoag3uup6iVLx9TRFiJMzJWu+sEJ
# wePhH2O4MabZ5yznLlaZn4vgIk+4/DaTAqjkJGY1AgHvpfglm4lxN5KkHxku3kSt
# xZZtMbUSKLEdMUBNu9S785K5qwkTBvhuJlFBCD511Nl4TQjg48MACFrWmv+TCIaj
# w813XAJhdorKqqRoQ0Ro4bHDCmkCCiqPD77Y4q/Dn99GkUuw6yvAVsA01uI4Luqs
# 274MHc53HhCXCpYdGsWElOJMhV1kV3svcTsmtqzmFVKhgheoMIIXpAYKKwYBBAGC
# NwMDATGCF5QwgheQBgkqhkiG9w0BBwKggheBMIIXfQIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBaQYLKoZIhvcNAQkQAQSgggFYBIIBVDCCAVACAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgcQH2/gK0/eRo769poHRa9U8c/Q+AZyMrXWkCBLy7
# sKECBmdkBEvGjBgTMjAyNTAxMDcxNDE2MzEuNDM2WjAEgAIB9KCB6KSB5TCB4jEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWlj
# cm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFs
# ZXMgVFNTIEVTTjo0RTg5LTk2NjYtRkZFNzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHmggg8oMIIHgjCCBWqgAwIB
# AgITMwAAAAXlzw//Zi7JhwAAAAAABTANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQG
# EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9N
# aWNyb3NvZnQgSWRlbnRpdHkgVmVyaWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUg
# QXV0aG9yaXR5IDIwMjAwHhcNMjAxMTE5MjAzMjMxWhcNMzUxMTE5MjA0MjMxWjBh
# MQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIw
# MAYDVQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAy
# MDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJ5851Jj/eDFnwV9Y7UG
# IqMcHtfnlzPREwW9ZUZHd5HBXXBvf7KrQ5cMSqFSHGqg2/qJhYqOQxwuEQXG8kB4
# 1wsDJP5d0zmLYKAY8Zxv3lYkuLDsfMuIEqvGYOPURAH+Ybl4SJEESnt0MbPEoKdN
# ihwM5xGv0rGofJ1qOYSTNcc55EbBT7uq3wx3mXhtVmtcCEr5ZKTkKKE1CxZvNPWd
# GWJUPC6e4uRfWHIhZcgCsJ+sozf5EeH5KrlFnxpjKKTavwfFP6XaGZGWUG8TZaiT
# ogRoAlqcevbiqioUz1Yt4FRK53P6ovnUfANjIgM9JDdJ4e0qiDRm5sOTiEQtBLGd
# 9Vhd1MadxoGcHrRCsS5rO9yhv2fjJHrmlQ0EIXmp4DhDBieKUGR+eZ4CNE3ctW4u
# vSDQVeSp9h1SaPV8UWEfyTxgGjOsRpeexIveR1MPTVf7gt8hY64XNPO6iyUGsEgt
# 8c2PxF87E+CO7A28TpjNq5eLiiunhKbq0XbjkNoU5JhtYUrlmAbpxRjb9tSreDdt
# ACpm3rkpxp7AQndnI0Shu/fk1/rE3oWsDqMX3jjv40e8KN5YsJBnczyWB4JyeeFM
# W3JBfdeAKhzohFe8U5w9WuvcP1E8cIxLoKSDzCCBOu0hWdjzKNu8Y5SwB1lt5dQh
# ABYyzR3dxEO/T1K/BVF3rV69AgMBAAGjggIbMIICFzAOBgNVHQ8BAf8EBAMCAYYw
# EAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFGtpKDo1L0hjQM972K9J6T7ZPdsh
# MFQGA1UdIARNMEswSQYEVR0gADBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAww
# CgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwDwYDVR0TAQH/
# BAUwAwEB/zAfBgNVHSMEGDAWgBTIftJqhSobyhmYBAcnz1AQT2ioojCBhAYDVR0f
# BH0wezB5oHegdYZzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwv
# TWljcm9zb2Z0JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2Vy
# dGlmaWNhdGUlMjBBdXRob3JpdHklMjAyMDIwLmNybDCBlAYIKwYBBQUHAQEEgYcw
# gYQwgYEGCCsGAQUFBzAChnVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L2NlcnRzL01pY3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9v
# dCUyMENlcnRpZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5jcnQwDQYJKoZIhvcN
# AQEMBQADggIBAF+Idsd+bbVaFXXnTHho+k7h2ESZJRWluLE0Oa/pO+4ge/XEizXv
# hs0Y7+KVYyb4nHlugBesnFqBGEdC2IWmtKMyS1OWIviwpnK3aL5JedwzbeBF7POy
# g6IGG/XhhJ3UqWeWTO+Czb1c2NP5zyEh89F72u9UIw+IfvM9lzDmc2O2END7MPnr
# cjWdQnrLn1Ntday7JSyrDvBdmgbNnCKNZPmhzoa8PccOiQljjTW6GePe5sGFuRHz
# dFt8y+bN2neF7Zu8hTO1I64XNGqst8S+w+RUdie8fXC1jKu3m9KGIqF4aldrYBam
# yh3g4nJPj/LR2CBaLyD+2BuGZCVmoNR/dSpRCxlot0i79dKOChmoONqbMI8m04uL
# aEHAv4qwKHQ1vBzbV/nG89LDKbRSSvijmwJwxRxLLpMQ/u4xXxFfR4f/gksSkbJp
# 7oqLwliDm/h+w0aJ/U5ccnYhYb7vPKNMN+SZDWycU5ODIRfyoGl59BsXR/HpRGti
# JquOYGmvA/pk5vC1lcnbeMrcWD/26ozePQ/TWfNXKBOmkFpvPE8CH+EeGGWzqTCj
# dAsno2jzTeNSxlx3glDGJgcdz5D/AAxw9Sdgq/+rY7jjgs7X6fqPTXPmaCAJKVHA
# P19oEjJIBwD1LyHbaEgBxFCogYSOiUIr0Xqcr1nJfiWG2GwYe6ZoAF1bMIIHnjCC
# BYagAwIBAgITMwAAAEF2EbJNqqmrPwAAAAAAQTANBgkqhkiG9w0BAQwFADBhMQsw
# CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
# VQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDAe
# Fw0yNDA0MTgxNzU5MTVaFw0yNTA0MTcxNzU5MTVaMIHiMQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFu
# ZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjRF
# ODktOTY2Ni1GRkU3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1l
# IFN0YW1waW5nIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBANnQDX7XfgF+vmOg2hU5bVrbGY/59ZKqnvgVHqwS3g8Jjx5snov8HM3d4CC4
# KZFbfMjDnPDuxFPTtuYcrtFkky+e3X4cVa7bjNEhiRwT4G11eBO7ng93ccm8/Xee
# dEpGMPbSNPIibys9DHow73CcARnoH6hOVUVS61f4l15Xh5JSXnI7FirIVbnYSciF
# RZjB91BjQCofrd12ZjSowYbK9w6ZZVCMK7kTOOaqapGAF4tYCnaZb+Jpa6oBgv//
# QWSFPWUhcVxJdR8gAZVCGTc/6Ug2VOwVLtqFoHsUPj01a2Nz9Nj/1myPYVCEoh7W
# QjEmtJKZE5XGvzqr181zQNZYyoaxGjKcM1+/+Ew/eFuOgVsxPDrnzK5Bbpce3poz
# Rmlr1dZ8FZJh7lfwScmczT/PhfHn9jIsSV37618har/dNck2B/gtbOTWeJZoLoBh
# Zrp2ar/inzcKsQeLXT1qQmhcVaWOIMBy1jM1zGioFkkaxPFi+TlfaWQVPayrLC3r
# wVFarqndtkhsPLmJzSVzrtYbomBhWpgHUWztxXi2i30t5Ft4NLR7FVCuukw/ogVn
# OwY7BZNBxfue06gOZWlCtqsfsv8fKuOzQ9fytXHnFLLpYb05YN9BBQ7zbN5o9Mxt
# /zw/tTxi6KGpLO1LXg+NXtkQeVsCb9SsT5R24wgnsuM4M0ifAgMBAAGjggHLMIIB
# xzAdBgNVHQ4EFgQUJfHwo+kTcpYxJPeJ3GIeJ4CYyIowHwYDVR0jBBgwFoAUa2ko
# OjUvSGNAz3vYr0npPtk92yEwbAYDVR0fBGUwYzBhoF+gXYZbaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwUHVibGljJTIwUlNB
# JTIwVGltZXN0YW1waW5nJTIwQ0ElMjAyMDIwLmNybDB5BggrBgEFBQcBAQRtMGsw
# aQYIKwYBBQUHMAKGXWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5nJTIwQ0El
# MjAyMDIwLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MA4GA1UdDwEB/wQEAwIHgDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8G
# CCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3Mv
# UmVwb3NpdG9yeS5odG0wCAYGZ4EMAQQCMA0GCSqGSIb3DQEBDAUAA4ICAQBeJyJn
# AuTqA2fMbfPWaYTZkJyZdJ7+luhIw5TzBkH7WhPU9M9eHoc9cm1qOJL/AkL/m7kn
# s7Ei2M0uWGndiSKoYz0EOuFCPT/wdtNFnxdvpb9A5RJAAJAU2Vj5kj4MivwSOtFe
# ZbJMXBSAD9OxEwq/TSAK2t0IrI4OsYBVpmPGX1z9On6FVwaCCBFG7+5X4+3Y0SFR
# 8tvsZXx7qZqThdntxlC4HCYuEDSgDftSmKDwqkmfxZLggZuF+xV8t/7sTOjWsVK3
# evkiu4uWdRhlGzRtzXa9B+wVHzx9kCE1w/2KF+B5W8IE70kJXxUn1ZH2MIQK5OAu
# ZsLeeHn/RfOOMh2cF+DEQbNNcYA8iFzmrC+rkGhXmmLpcv3H4RC5mlV0pEw0Fl33
# kZx3fYOS9xq7T1XN1RDWfuj4zKWKEj6MYFCIUEszHsRgSlUoIepbLkoceWJcbySB
# JbTkiK5xzT+swFIumiEXKCp2X98fj/35x2TMt/zu03m1xyjdbF0W7WuleXzZNT27
# 07k6fYujcJBcjA0F1oPSUDQtfZgT8ZuxzjbSBVJ+26Es5kjWCR1qNwpDwxVYCI80
# TnQmdaNk7qXnqcryQ36h7I52k5AzgdLYvwqeDIzOtKCHh03wUwQj7Q+0HwlKt7z9
# uwKExhKcwG8HkGJbYxW00ypErCGbaTRh6y3ThDGCBswwggbIAgEBMHgwYTELMAkG
# A1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UE
# AxMpTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMA
# AABBdhGyTaqpqz8AAAAAAEEwDQYJYIZIAWUDBAIBBQCgggQlMBEGCyqGSIb3DQEJ
# EAIPMQIFADAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkF
# MQ8XDTI1MDEwNzE0MTYzMVowLwYJKoZIhvcNAQkEMSIEIOVnZMsRWoEV6K80wRtr
# Bb4icjwJFzweY39u3NwXTSdnMIG5BgsqhkiG9w0BCRACLzGBqTCBpjCBozCBoAQg
# zYyv3iKy9GAmWwU3uRFfX4XFhdM/QUANop3sUSKvDZswfDBlpGMwYTELMAkGA1UE
# BhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMp
# TWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAABB
# dhGyTaqpqz8AAAAAAEEwggLnBgsqhkiG9w0BCRACEjGCAtYwggLSoYICzjCCAsow
# ggIzAgEBMIIBEKGB6KSB5TCB4jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBM
# aW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo0RTg5LTk2NjYtRkZFNzE1
# MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRo
# b3JpdHmiIwoBATAHBgUrDgMCGgMVAOLFr7AvgDRUWdGSNOLtRTA3WMSCoGcwZaRj
# MGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAy
# MDIwMA0GCSqGSIb3DQEBBQUAAgUA6yePDjAiGA8yMDI1MDEwNzExMzEyNloYDzIw
# MjUwMTA4MTEzMTI2WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDrJ48OAgEAMAoC
# AQACAhgbAgH/MAcCAQACAhE0MAoCBQDrKOCOAgEAMDYGCisGAQQBhFkKBAIxKDAm
# MAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcN
# AQEFBQADgYEAcX2jNrBvX1YYqHQsJCZ6pB1GKN8Oio5QYt4ZRK0DlTk9nzIdAUOY
# m531+LBYhtHy092eRxBKYll1FmPCpvMnTgiHIbyxxPMbZ2X/ySMlwNvwO11kjGB4
# V0v1RZYkPbJz129ddR5oN9llqdZfiSdecpw6Bnyxz3yA0YAPARwwamYwDQYJKoZI
# hvcNAQEBBQAEggIAg4OiuKlqrDs0js2lfu9fITJT1DNMolZfcnXbZJ8NIBFtOAEW
# VumIN4FR7GIXUZOeAkCNb94LThnXkOtk9n2UrKxKdl5j+7eilCTlPhEfTAe3drPr
# Pss6Cjw9XS3LIsEuffhqyIjQjrvM3cxDZiyS2bkcdTE9qtxZ8phbNblrj1WmkYeJ
# Hyo9Y3UuG99zQ0DI5K+e2lkLxMao24ue17IykS+jJ5lk3zPR0Ux0WTlQQ6Fk8yEQ
# PZ9oAFW4SwgUjpIeyKe4eIIDHDDszPOloj8n2JGOoOYp6IEK4CtdPlhpZedg+ZEt
# m+JviT1jRj3RdNLpYii+YzY9L/gGnlg7DrpJl5v9eOFtKgxI7p9HUtunUE34yjSa
# mZY0sJ+ODSObdUA1zF93RK6F7WBHH8Nk0lFjsMOrryCQsj1HlNApxooKlnb4fdJd
# kAcNnMNL0MMjuWl1VzwWdce0bei5rA+nkiAIW7wNbsjTCLQvnOiy2++egx2W+bIP
# pJ67qlvagbsK1vXNaqzVjljduA/Y1s88f6zvCFgK0c65f+ozi2RvDuS/8exGBx2J
# 5NAeQcdkT2xVZgdx/LO/ObYr8LrAcwQ7+XLMp2hCzbnkylxXuSqBn+RQmjMvXMK4
# eYpM2E6MRmY5OYcZAkIrnesHCSDInkAERhsqQ9GkewwxQdSumGeTcjCreh8=
# SIG # End signature block
