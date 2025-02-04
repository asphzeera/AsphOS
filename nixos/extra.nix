{ config, input, pkgs, ... }:


{
# Define a user account. Don't forget to set a password with ‘passwd’.
networking.hostName = "nixos"; # Define your hostname.
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.


# Enable networking
networking.networkmanager.enable = true;
#networking.wireless.enable = true;

# Set your time zone.
time.timeZone = "America/Bahia";

# Select internationalisation properties.
i18n.defaultLocale = "pt_BR.UTF-8";

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

}
