<#
+-----------------------------------------------------------------------------------------+
| Note. Para executar este script é necessário:                                           |
| 1. Estar connectado a um repositório git.                                               |
| 2. Ter o PowerShell instalado.                                                          |
| 3. Permissões de root.                                                                  |
+-----------------------------------------------------------------------------------------+
#>

<#
+-----------------------------------------------------------------------------------------+
| Pacstrap package list                                                                   |
+-----------------------------------------------------------------------------------------+
| grub                                                                                    |
| efibootmgr (UEFI boot)                                                                  |
| linux                                                                                   |
| linux-firmware                                                                          |
| sof-firmware                                                                            |
| nano                                                                                    |
| networkmanager                                                                          |
+-----------------------------------------------------------------------------------------+

pacstrap /mnt grub linux linux-firmware sof-firmware nano networkmanager 

+-----------------------------------------------------------------------------------------+
| First boot install package list                                                         |
+-----------------------------------------------------------------------------------------+
| alacritty                                                                               |
| firefox                                                                                 |
| git                                                                                     |
| gtk3                                                                                    |
| sddm                                                                                    |
| thunar                                                                                  |
| wget                                                                                    |
+-----------------------------------------------------------------------------------------+
| yay-bin (https://aur.archlinux.org/yay-bin.git)                                         |
+-----------------------------------------------------------------------------------------+
| xf86-video-intel                                                                        |
| xorg-server                                                                             |
| xorg-xinit                                                                              |
| xorg-apps                                                                               |
+-----------------------------------------------------------------------------------------+
| alsa-utils                                                                              |
| pulseaudio                                                                              |
| moc-pulse                                                                               |
| mkinitcpio                                                                              |
| pipewire                                                                                |
| polkit                                                                                  |
| slurp                                                                                   |
| vulkan-headers                                                                          |
| vulkan-icd-loader                                                                       |
+-----------------------------------------------------------------------------------------+

sudo pacman -S alacritty firefox git gtk3 sddm thunar wget 
sudo pacman -S xorg-server xorg-xinit xorg-apps xf86-video-intel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin; makepkg -si; cd

+-----------------------------------------------------------------------------------------+
| Yay install packs                                                                       |
+-----------------------------------------------------------------------------------------+
| powershell-bin                                                                          |
| ttf-firacode                                                                            |
| ttf-font-awesome                                                                        |
| nerd-fonts                                                                              |
| noto-fonts-emoji                                                                        |
| sddm-astronaut-theme                                                                    |
+-----------------------------------------------------------------------------------------+

yay -S powershell-bin ttf-firacode ttf-font-awesome nerd-fonts noto-fonts-emoji sddm-astronaut-theme

+-----------------------------------------------------------------------------------------+
| Hyprland                                                                                |
+-----------------------------------------------------------------------------------------+
| hyprland                                                                                |
| hyprpaper                                                                               |
| hyprshot                                                                                |
| swww                                                                                    |
| waybar                                                                                  |
| waypaper                                                                                |
| wireplumber                                                                             |
| wofi                                                                                    |
| xwaylandvideobridge-git                                                                 |
| xdg-desktop-portal-hyprland                                                             |
+-----------------------------------------------------------------------------------------+

sudo pacman -S hyprland hyprpaper hyprshot swww waybar waypaper wireplumber wofi
yay -S xwaylandvideobridge-git xdg-desktop-portal-hyprland

+-----------------------------------------------------------------------------------------+
| Additionals                                                                             |
+-----------------------------------------------------------------------------------------+
| codeblocks                                                                              |
| discord (yay)                                                                           |
| firewalld                                                                               |
| freetube                                                                                |
| imagemagick                                                                             |
| neofetch                                                                                |
| neovim                                                                                  |
| obs-studio-git (yay)                                                                    |
| obs-vaapi (yay)                                                                         |
| python (yay)                                                                            |
| python2 (yay)                                                                           |
| vim                                                                                     |
| visual-studio-code-bin (yay)                                                            |
| w3m                                                                                     |
| xlayoutdisplay
| xpdf
+-----------------------------------------------------------------------------------------+
#>
