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
        [string[]]$Path = ("alacritty", "hypr", "neofetch", "wal", "waybar", "waypaper", "wofi"),

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
            Write-Host "$action`n" -BackgroundColor DarkGray;
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