# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sr_mode" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  boot.extraModulePackages = [ pkgs.linuxPackages_latest.nvidiaPackages.stable ];
  boot.supportedFilesystems = [ "ext4" "ntfs" "vfat" "exfat" "btrfs" "xfs" "zfs" ];
  boot.kernel.sysctl."vm.swappiness" = "10";

  hardware.cpu.amd.updateMicrocode = true;
  hardware.nvidia.package = pkgs.linuxPackages_latest.nvidiaPackages.stable;
  hardware.bluetooth = true;
  hardware.opengl.driSupport32Bit = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    extraPackages = with pkgs; [
      pipewire
      pipewire-pulseaudio
      pipewire-alsa
      pipewire-jack
      pipewire-ffmpeg
      pipewire-gstreamer
      pipewire-v4l2
      pipewire-docs
    ];
  };
  sound.enable = true;

  #Nvidia Configuration
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Load nvidia driver for Xorg and Wayland
  services.xserver= {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  services.fail2ban.enable = true;
  #VMWARE
  virtualisation.vmware.host.enable = true;
  virtualisation.vmware = {
    enable = true;
    version = "16.1.2";
  };
  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.guest = {
    enable = true;
    version = "16.1.2";
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox = {
    enable = true;
    version = "6.1.30";
  };

  virtualisation.docker.enable = true;

  networking.firewall.enable = true;

  networking.hostName = "gpt-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.useDHCP = true; # Enable or disable DHCP.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Bahia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  security.sudo = {
    enable = true;
    configFile = ''
      root ALL=(ALL:ALL) ALL
      %wheel ALL=(ALL) ALL
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gabriel = {
    isNormalUser = true;
    description = "Gabriel Teixeira";
    #extraGroups = [ "networkmanager" "wheel" ];
    extraGroups = [ "wheel" "docker" ];

    shell = pkgs.zsh;
    #packages = with pkgs; [ ];
  };

  programs.zsh.enable = true; #enable zsh for system

  programs = {
    ssh.startAgent = true;
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "mikeh";
      };
    };
  };

  fonts.packages = with pkgs; [
    # Nerd Fonts use nerd-fonts-complete for all fonts
    fira-code fira-code-symbols fira-code-nerd-font 
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget curl neovim git asciiquarium-transparent file htop tree unzip zip vim nano tmux openssh rsync man man-pages less bash-completion htop mlocate virtualbox microsoft-edge vlc obs-studio cmake audacity dconf xboxdrv krita neofetch nmap gcc gamemode gnome.gnome-disk-utility iptables ipset linuxPackages_zen.cpupower lm_sensors lutris heroic-unwrapped mangohud microcodeAmd protonup-qt python3 vmware-workstation steam vscode-with-extensions tar rar docker docker-compose thunderbird 
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 4322 ];
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "no";
  

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
