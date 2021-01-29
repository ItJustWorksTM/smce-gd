$MSVC_VER = $args[0]
$BOOST_VER = $args[1]
$BOOST_SLUG = $args[2]

New-Item -Path . -Name "boost-msvc-$MSVC_VER" -ItemType 'directory'

Push-Location "boost-msvc-$MSVC_VER"

Set-Content -Path "boost-msvc-$MSVC_VER.nuspec" -Value @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>boost-msvc-$MSVC_VER</id>
    <version>$BOOST_VER</version>
    <title>Boost for MSVC $MSVC_VER</title>
    <authors>Jeff Garland, Beman Dawes, Carl Daniel, Dave Abrahams, Douglas Gregor, John Maddock</authors>
    <owners>Jerome Bell</owners>
    <licenseUrl>http://www.boost.org/LICENSE_1_0.txt</licenseUrl>
	<projectUrl>http://www.boost.org</projectUrl>
    <projectSourceUrl>https://github.com/boostorg/boost</projectSourceUrl>
	<docsUrl>https://www.boost.org/doc/</docsUrl>
	<mailingListUrl>https://www.boost.org/community/groups.html</mailingListUrl>
	<bugTrackerUrl>https://www.boost.org/development/bugs.html</bugTrackerUrl>
	<packageSourceUrl>https://github.com/Heteroculturalism/chocolatey-packages</packageSourceUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>Boost provides free portable peer-reviewed C++ libraries. The emphasis is on portable libraries which work well with the C++ Standard Library. This package includes Boost headers and libs compiled with Visual Studio for 32bit and 64bit Windows.</description>
    <summary>Boost headers and libs compiled with Visual Studio 2019 for 32bit and 64bit Windows.</summary>
    <releaseNotes>http://www.boost.org/users/history/version_$BOOST_SLUG.html</releaseNotes>
    <copyright>Copyright 2019</copyright>
    <tags>boost c++ msvc msvc-$MSVC_VER</tags>
  </metadata>
</package>
"@

New-Item -Path . -Name "tools" -ItemType 'directory'

Set-Content -Path "tools/chocolateyInstall.ps1" -Value @"
# Install 32 bit binaries
Install-ChocolateyPackage ``
    -packageName 'boost-msvc-$MSVC_VER' ``
    -installerType 'exe' ``
    -silentArgs '/VERYSILENT' ``
    -url 'https://downloads.sourceforge.net/project/boost/boost-binaries/$BOOST_VER/boost_$BOOST_SLUG-msvc-$MSVC_VER-32.exe'

# Install 64 bit binaries
Install-ChocolateyPackage ``
    -packageName 'boost-msvc-$MSVC_VER' ``
    -installerType 'exe' ``
    -silentArgs '/VERYSILENT' ``
    -url64bit 'https://downloads.sourceforge.net/project/boost/boost-binaries/$BOOST_VER/boost_$BOOST_SLUG-msvc-$MSVC_VER-64.exe'
"@

Set-Content -Path "tools/chocolateyUninstall.ps1" -Value @"
`$ErrorActionPreference = 'Stop';

`$installDirRoot = "c:\local\boost_$BOOST_SLUG"
`$binaryDirs = "`$installDirRoot\lib32-msvc-$MSVC_VER", "`$installDirRoot\lib64-msvc-$MSVC_VER"

# remove binary directories
foreach(`$binaryDir in $`binaryDirs)
{
	write-host "Uninstalling boost will remove `$binaryDir." -ForegroundColor Yellow
	if (Test-Path "`$binaryDir") { rm -Recurse -Force "`$binaryDir" }
}

# remove root directory if there are no binary directories
if (-not (Test-Path "`$installDirRoot\lib32*") -and -not (Test-Path "`$installDirRoot\lib64*")) { rm -Recurse -Force "`$installDirRoot" }
"@

choco install "boost-msvc-$MSVC_VER.nuspec"
Pop-Location
Remove-Item -Recurse -Force "boost-msvc-$MSVC_VER"
