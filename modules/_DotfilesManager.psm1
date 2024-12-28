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
            Write-Host "`nCreating directory: $Destination.";
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

<#
.SYNOPSIS
Exports specified configuration files and directories to a destination folder or a git repository.

.DESCRIPTION
The `Export-Dotfiles` function automates the process of exporting configuration files and directories to a specified destination. It also supports additional paths for a full export and integrates with Git for repository management.

.PARAMETER Path
Specifies the files and/or folders to export. Defaults to a set of commonly used configuration directories such as `alacritty`, `hypr`, `neofetch`, etc.

.PARAMETER Destination
Specifies the destination directory where the files and folders will be copied. The default is `.\git\dotfiles\hypr`.

.PARAMETER Name
Specifies the name of the repository. If provided, it will be appended to the `RepositoryPath`.

.PARAMETER RepositoryPath
Specifies the base path for the repository. Defaults to `.\git\dotfiles\$Name`.

.PARAMETER Full
Switch to enable exporting additional files, including SDDM themes, `.bashrc`, and custom binaries.

.PARAMETER Git
Switch to enable exporting the copied files to a Git repository. This includes staging, committing, and pushing changes to the repository.

.EXAMPLE
Export-Dotfiles -Path ".\.config\vim" -Destination "C:\Backups\Dotfiles"

Exports the Vim configuration directory to the specified destination folder.

.EXAMPLE
Export-Dotfiles -Name "MyDotfiles" -Git

Exports the default configuration files to a repository named `MyDotfiles` and pushes the changes to Git.

.EXAMPLE
Export-Dotfiles -Full -Git

Performs a full export (default and additional paths) and commits the changes to a Git repository.

.NOTES
- Ensure you have write permissions for the destination directory and the necessary permissions to interact with Git.
- The `Copy-Files` function must be defined in your environment for file copying.
- Logs errors to a local file named `dotmgr.log`.
#>
function Export-Dotfiles {    
    param (
        [Parameter(Position = 0, Mandatory = $false)] # Files and/or folders to copy
        [string[]]$Path = (".\.config\alacritty", ".\.config\hypr", ".\.config\neofetch", ".\.config\wal", ".\.config\waybar", ".\.config\waypaper", ".\.config\wofi", ".\.config\btop", ".\.config\cava"),

        [Parameter(Position = 1, Mandatory = $false)]  # You may change the default repository name.
        [string[]]$Destination = ".\git\dotfiles\hypr",

        [Parameter(Position = 2, Mandatory = $false)] # Repository name
        [string]$Name,

        [Parameter(Position = 3, Mandatory = $false)] # Repository path
        [string]$RepositoryPath = ".\git\dotfiles\$Name",

        [Parameter(Position = 4, Mandatory = $false)] # Full installation switch
        [switch]$Full,

        [Parameter(Position = 5, Mandatory = $false)] # Full installation switch
        [switch]$Git
    )

    begin {
        $ErrorActionPreference = "Stop";
        $date = Get-Date -Format "yyyy-MM-dd";
        $Referenced_Destination = "$Destination";
        if ($Full) { # Variables for a full export. You can set that as you want.
            $AdditionalPath = "\usr\lib\sddm\sddm.conf.d", "\usr\share\sddm\themes", ".\.bashrc", "\bin\neofetch";
            $AdditionalDestination = "$Referenced_Destination\sddm\", "$Referenced_Destination\sddm\", "$Referenced_Destination", "$Referenced_Destination\bin\";
        }
    }

    process {
        $action = "Config files export";
        if ($Name) {$Referenced_Destination = "$RepositoryPath\$Name"}
        try {
            # Config files (default) installation.
            Write-Host "`n$action`n" -BackgroundColor DarkGray;
            Copy-Files -Path $Path -Destination $Referenced_Destination;
            if ($Full) { # Adds sddm, bashrc and neofetch (bin) to the installation.
                $action = "Additional files export";
                Write-Host "$action`n" -BackgroundColor DarkGray;
                Copy-Files -Path $AdditionalPath -Destination $AdditionalDestination;
            }

            # Git actions
            if ($Git) {
                $action = "Export to repository";
                Write-Host "$action`n" -BackgroundColor DarkGray;
                Push-Location $Referenced_Destination;    
                git add .;
                git commit -m "Dotfiles from $date";
                git push -u origin main;
                Pop-Location;
            }
        }
        catch {
            Write-Host "$action failed.`n$_" | Out-File -Append -FilePath ".\dotmgr.log";
            Break;
        }
    }

    end {
        $endMsg = Write-Host $Path.Count" itens exported.";
        if (Get-Error){ $endMsg = Write-Host $Path.Count" itens exported." }
        $endMsg
    }      
}

<#
.SYNOPSIS
Automates the installation of dotfiles (configuration files) for various applications.

.DESCRIPTION
The `Install-Dotfiles` function copies specified configuration files or directories 
to designated destinations. It supports a default mode for common configuration directories 
and a full installation mode, which includes additional system-level files such as 
sddm themes, bash configurations, and neofetch binaries. 

.PARAMETER Path
Specifies the files or directories to copy. Defaults to a predefined set of common 
configuration directories: "alacritty", "hypr", "neofetch", "wal", "waybar", "waypaper", "wofi".

.PARAMETER Destination
Specifies the destination directory where the files and directories will be copied. 
Defaults to `.\.config`.

.PARAMETER Name
The name of the dotfiles repository. If provided, the function constructs a source 
path based on this repository name.

.PARAMETER RepositoryPath
Specifies the full path to the dotfiles repository. If not explicitly provided, 
it defaults to `.\git\dotfiles\$Name`.

.PARAMETER Full
Enables full installation mode, which includes additional files and directories:
- `sddm` configuration and themes
- `.bashrc`
- Neofetch binaries in the `bin` directory

.EXAMPLE
Install-Dotfiles
Performs a default installation of predefined configuration files to `.\.config`.

.EXAMPLE
Install-Dotfiles -Path "neofetch", "waybar" -Destination ".\.config\custom"
Copies only the specified configuration files ("neofetch" and "waybar") to a custom 
destination directory.

.EXAMPLE
Install-Dotfiles -Full
Performs a full installation, including additional system files such as sddm configurations.

.EXAMPLE
Install-Dotfiles -Name "custom-dotfiles"
Uses the repository name "custom-dotfiles" to construct the source path and install 
the configuration files.

.NOTES
- This function requires the `Copy-Files` cmdlet or function to perform file copy operations.
- Error logs are written to `.\dotmgr.log` if any operation fails.
- The function is designed to be robust and stops execution upon encountering errors.
#>
function Install-Dotfiles {    
    param (
        [Parameter(Position = 0, Mandatory = $false)] # Files and/or folders to copy
        [string[]]$Path = ("alacritty", "hypr", "neofetch", "wal", "waybar", "waypaper", "wofi", "btop", "cava"),

        [Parameter(Position = 1, Mandatory = $false)]  # Where to send those files and/or.
        [string[]]$Destination = (".\.config"),

        [Parameter(Position = 2, Mandatory = $false)] # Repository name
        [string]$Name,

        [Parameter(Position = 3, Mandatory = $false)] # Repository path
        [string]$RepositoryPath = ".\git\dotfiles\$Name",

        [Parameter(Position = 4, Mandatory = $false)] # Full installation switch
        [switch]$Full
    )

    begin {
        $ErrorActionPreference = "Stop";
        $Referenced_Path = "$Path";
        if ($Full) { # Variables for a full installation. You can set that as you want.
            $AditionalDestination = "\usr\lib\sddm\", "\usr\share\sddm\", ".", "\bin\";
            $AditionalPath = "$Referenced_Path\sddm\sddm.conf.d", "$Referenced_Path\sddm\themes", "$Referenced_Path\.bashrc"; "$Referenced_Path\bin\neofetch";
        }
    }

    process {
        $action = "Config files installation";
        if ($Name) { $Referenced_Path = "$RepositoryPath\$Path" }
        try {
            # Config files (default) installation.
            Write-Host "`n$action`n" -BackgroundColor DarkGray;
            Copy-Files -Path $Referenced_Path -Destination $Destination;
            if ($Full) { # Adds sddm, bashrc and neofetch (bin) to the installation.
                $action = "Additional files installation";
                Write-Host "$action`n" -BackgroundColor DarkGray;
                Copy-Files -Path $AditionalPath -Destination $AditionalDestination;
            }
        }
        catch {
            Write-Host "$action failed.`n$_" | Out-File -Append -FilePath ".\dotmgr.log";
            Break;
        }
    }

    end {
        $endMsg = Write-Host $Path.Count" itens installed.";
        if (Get-Error){ $endMsg = Write-Host $Path.Count" itens copied." }
        $endMsg
    }
}