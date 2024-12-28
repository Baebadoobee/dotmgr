<#
.SYNOPSIS
Imports repositories or raw files from specified paths to a destination folder.

.DESCRIPTION
The `Import-Dotfiles` function is designed to clone repositories or fetch raw files from given URLs into a specified local destination directory. It offers error handling, directory creation, and the option to toggle between raw file downloads and repository cloning.

.PARAMETER Path
Specifies one or more paths to repositories or files to be imported. This parameter is mandatory.

.PARAMETER Destination
Specifies the local directory where the repositories or files will be imported. The default is the current directory (`.\`).

.PARAMETER Raw
Indicates whether the paths point to raw files (instead of repositories). If set, raw files are downloaded using `wget`. Otherwise, repositories are cloned using `git clone`.

.EXAMPLE
Import-Dotfiles -Path "https://github.com/user/dotfiles.git" -Destination "C:\Dotfiles"

Clones the repository at `https://github.com/user/dotfiles.git` into the folder `C:\Dotfiles`.

.EXAMPLE
Import-Dotfiles -Path "https://raw.githubusercontent.com/user/repo/main/file.txt" -Destination "C:\Files" -Raw

Downloads the raw file `file.txt` from the specified URL into the folder `C:\Files`.

.EXAMPLE
Import-Dotfiles -Path "https://github.com/user/repo1.git", "https://github.com/user/repo2.git"

Clones multiple repositories into the current directory.

.NOTES
- Ensure that `git` and `wget` are available in your system's PATH if using this function.
- This function includes basic error handling and will display an error message if an import fails.
- The `$Destination` directory is created automatically if it does not exist.
#>
function Import-Dotfiles {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = 1)]
        [string[]]$Path, # Repository path or raw file to be imported

        [Parameter(Position = 1, Mandatory = 0)]
        [string]$Destination = ".\", # Repository folder to import

        [Parameter(Position = 2, Mandatory = 0)]
        [switch]$Raw = 1 # Switch for RAW file import
    )

    begin {
        $ErrorActionPreference = "Stop";
        if (-not (Test-Path "$Destination")) {# Verify repository folder on computer.
            Write-Host "Creating directory: $Destination.";
            New-Item -Path "$Destination" -ItemType Directory -Force;
        }
    }

    process {
        Push-Location; # For some reason, Push-Location "$Destination" wasnt working. '-'
        Set-Location "$Destination";
        foreach ($item in $Path) { # Import loop and error handling.
                if ($Raw) {wget "$item"}
                else {git clone "$item"}
            }
            catch {Write-Host "Import Failed.`nErro:`n$_" -BackgroundColor DarkRed | Out-File -Append -FilePath ".\dotmgr.log";}
        Pop-Location
        }

    end {Write-Host $Path.Count" itens were imported"}
}