﻿$packageName   = 'retroarch'
$url           = 'https://buildbot.libretro.com/stable/1.9.13/windows/x86/RetroArch.7z'
$url64         = 'https://buildbot.libretro.com/stable/1.9.13/windows/x86_64/RetroArch.7z'
$checksum      = '271563c7cf6b4574ce2d8cdfbfd954a783a5f157e39a53ed977ac875d0605b9c'
$checksum64    = '1e2892037469477566dd504466e3bd66d94e0aa09cd95fe4fbd8e35eee07402e'
$checksumType  = 'sha256'
$checksumType64= 'sha256'


# Get the package parameters and then back them up for the uninstaller
# This works around choco#1479 https://github.com/chocolatey/choco/issues/1479
$pp = Get-PackageParameters
$toolsPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$paramsFile = Join-Path (Split-Path -Parent $toolsPath) 'PackageParameters.xml'
Write-Debug "Writing package parameters to $paramsFile"
Export-Clixml -Path $paramsFile -InputObject $pp

if ((Get-ProcessorBits 32) -or $env:ChocolateyForceX86 -eq 'true') {
  $specificFolder = "RetroArch-Win32"
} else {
  $specificFolder = "RetroArch-Win64"
}

$installDir = $(Get-ToolsLocation)
if ($pp.InstallDir -or $pp.InstallationPath ) { $installDir = $pp.InstallDir + $pp.InstallationPath }
Write-Host "RetroArch is going to be installed in '$installDir'"

Install-ChocolateyZipPackage "$packageName" `
  -Url "$url" -Checksum "$checksum" -ChecksumType $checksumType `
  -Url64 "$url64" -Checksum64 "$checksum64" -ChecksumType64 $checksumType64 `
  -UnzipLocation "$installDir" -SpecificFolder "$specificFolder"

if ($installDir -eq $toolsPath) {
  New-Item "$installDir\$specificFolder\retroarch.exe.gui" -Type file -Force | Out-Null
  if (Test-Path "$installDir\$specificFolder\retroarch_debug.exe") {
    New-Item "$installDir\$specificFolder\retroarch_debug.exe.gui" -Type file -Force | Out-Null
  }
} else {
  Install-BinFile retroarch -path "$installDir\$specificFolder\retroarch.exe" -UseStart
  if (Test-Path "$installDir\$specificFolder\retroarch_debug.exe") {
    Install-BinFile retroarch_debug -path "$installDir\$specificFolder\retroarch_debug.exe" -UseStart
  }
}

if ($pp.DesktopShortcut) {
  $desktop = [System.Environment]::GetFolderPath("Desktop")
  Install-ChocolateyShortcut -ShortcutFilePath "$desktop\RetroArch.lnk" `
    -TargetPath "$installDir\$specificFolder\retroarch.exe" -WorkingDirectory "$installDir" `
    -WindowStyle 3
}
