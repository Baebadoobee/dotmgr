# install-module Microsoft.PowerShell.ConsoleGuiTools
Import-Module ".\code\dotmgr\modules\_DotfilesManager.psm1";
do {
    Clear-Host;
    Write-Host "
+-----------------------------------------------------------------------------------------+
|                                   DOTFILES MANAGER                                 .ps1 |
+-----------------------------------------------------------------------------------------+
|                                                                                         |
| 1. Export files                                                                         |
| 2. Import files                                                                         |
| 3. Install files                                                                        |
|                                                                                         |
+-----------------------------------------------------------------------------------------+";
    $option = if ($option) {Read-Host "`n ╚[$option]"} else {Read-Host "`n ╚[ ]"};
    switch ($option) {
        "1" {
            try {Export-Dotfiles -Full -Git}
            catch {Write-Host $_}  
        }
        "2" { 
            $action = (Read-Host "Insert the URL to the repository/raw file to import")
            try {Import-Dotfiles $action}
            catch {Write-Host $_}
        }
        "3" { 
            $action = (Read-Host "Insert the URL to the repository/raw file to install")
            try {
                Import-Dotfiles $action; 
                Install-Dotfiles -Full
            }
            catch {Write-Host $_ }
        }
        Default {Write-Host "Invalid option"}
    }
    Pause;
} while ($true)