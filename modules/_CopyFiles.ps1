 <#
.SYNOPSIS
Copies files and directories from specified source paths to corresponding destination paths.

.DESCRIPTION
The `Copy-Files` function allows you to copy one or more files or directories to specified destination paths. 
It supports recursive copying and overwrites existing files at the destination.

.PARAMETER Path
An array of source file or directory paths to be copied. This parameter is mandatory.

.PARAMETER Destination
An array of destination paths corresponding to the source paths. This parameter is mandatory.
If multiple source paths are provided, ensure the destination array has enough entries to match the source paths.

.EXAMPLE
Copy-Files -Path "C:\Folder1", "C:\File1.txt" -Destination "D:\Backup\Folder1", "D:\Backup\File1.txt"

Copies `C:\Folder1` to `D:\Backup\Folder1` and `C:\File1.txt` to `D:\Backup\File1.txt`.

.EXAMPLE
Copy-Files -Path "C:\Documents\*" -Destination "D:\Backup\Documents"

Copies all files and subdirectories from `C:\Documents` to `D:\Backup\Documents`.

.NOTES
- The function stops execution on the first error due to `$ErrorActionPreference = "Stop"`.
- Ensure that the number of destinations matches or exceeds the number of source paths if copying to multiple destinations.

.LINK
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/copy-item
#>
function Copy-Files {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string[]]$Path,

        [Parameter(Position = 1, Mandatory = $true)]
        [string[]]$Destination
    )

    begin {$ErrorActionPreference = "Stop"}
    
    process {
        $index = 0;
        foreach ($item in $Path) {
            try {Copy-Item $item -Destination $Destination[$index] -Force  -Recurse}
            catch {
                Write-Host "Item $item instalation failed`nError:`n$_" | Out-File -Append -FilePath ".\dotmgr.log"; 
                Break
            }
            if ($Destination.Count -gt 1) {$index++}
        }
    }

    end {
        if (Get-Error){Write-Host "Copy failed."}
        else {Write-Host $Path.Count" itens copied."}
    }
}
