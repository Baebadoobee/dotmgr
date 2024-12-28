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
        [string[]]$Path = (".\.config\alacritty", ".\.config\hypr", ".\.config\neofetch", ".\.config\wal", ".\.config\waybar", ".\.config\waypaper", ".\.config\wofi"),

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
            $AdditionalPath = "\usr\lib\sddm\sddm.conf.d", "\usr\share\sddm\themes", ".\.bashrc"; "\bin\neofetch";
            $AdditionalDestination = "$Referenced_Destination\sddm\", "$Referenced_Destination\sddm\", "$Referenced_Destination", "$Referenced_Destination\bin\";
        }
    }

    process {
        $action = "Config files export";
        if ($Name) {$Referenced_Destination = "$RepositoryPath\$Name"}
        try {
            # Config files (default) installation.
            Write-Host "$action`n" -BackgroundColor DarkGray;
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