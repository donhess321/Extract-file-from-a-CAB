
Set-StrictMode -Version 2 -Verbose
$ErrorActionPreference = 'Stop'

function funcValidateFilenameStringInput( [string] $sIn ) {
    # Check for illegal characters / ? < > * | ' " { } [] = ;
    $sTemp = @('\/','\?','\<','\>','\*','\|',"\'",'\"','\{','\}','\[','\]','\=','\;') -join '|'
    $regex1 = [regex] $sTemp
    if ( $sIn -match $regex1 ) {
        $sError = "Input '{0}' has invlid character(s)" -f @($sIn)
        throw [System.ArgumentException] $sError  
    }
}
function funcExtractFilesFromCab( `
    [System.IO.FileInfo] $oCabFile, 
    [array] $aFileNames, 
    [System.IO.DirectoryInfo] $oDestDir ) {
    <#  .DESCRIPTION
            Extract file(s) from a CAB file.  Tested on Win 7 and 2012R2
        .PARAMETER oCabFile
            File object, Source CAB file.  Must be pre-existing
        .PARAMETER aFileNames
            Array, Short file name(s) to be extracted from the cab file
        .PARAMETER oDestDir
            Directory object, Destination directory.  Must be pre-existing.
        .OUTPUTS
            Nothing
        .NOTES
            Requires funcValidateFilenameStringInput function be available
    #>
    funcValidateFilenameStringInput $oCabFile.FullName
    $aFileNames | ForEach-Object {
        $sFileName = [string] $_
        # FIX ME:  Need same validation input as the log file
        funcValidateFilenameStringInput $sFileName
        if ( Test-Path -PathType Leaf (Join-Path $oDestDir $sFileName) ) {
            Get-Item (Join-Path $oDestDir $sFileName) | Remove-Item -Force
        }
    }
    funcValidateFilenameStringInput $oDestDir.FullName
    if ( -not (Test-Path -PathType Leaf $oCabFile) ) {
        throw 'oCabFile needs to be an existing cab file object'
    }
    if ( -not (Test-Path -PathType Container $oDestDir) ) {
        throw 'oDestDir needs to be an existing directory object'
    }
    # expand.exe source.cab -F:Filename Destination
    $aFileNames | ForEach-Object {
        $sFileName = [string] $_
        $sExeTemp = @("expand.exe"," ",$oCabFile.FullName," ","-F:'",$sFileName,"' ",$oDestDir.FullName) -join ''
        $oResult = Invoke-Expression $sExeTemp
    }
}

$oCabFileOut = Get-Item "C:\Path\to\wsusscn2.cab"
$oDestDirOut = Get-Item "C:\My\temp\extract\dir"
$sTestFile = 'index.xml'  # Filename inside cab to check the date
$iDaysAgo = 25  # File must be newer than this many days
$aFileNamesOut = @($sTestFile)
funcExtractFilesFromCab $oCabFileOut $aFileNamesOut $oDestDirOut

$oTestFile = Get-Item (Join-Path $oDestDirOut $sTestFile)
if ( $oTestFile.LastWriteTime -lt (Get-Date).AddDays(0-$iDaysAgo) ) {
    $sError = "Downloaded file is older than {0} days ago.  Has MS delayed releasing a new file?" -f @($iDaysAgo)
    throw $sError
}