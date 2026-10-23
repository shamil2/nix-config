{ myvars, ... }:
{
  # CUPS printing
  services.printing.enable = true;

  # Bluetooth & GUI applet
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Keyboard configuration
  services.xserver.xkb = {
    layout = myvars.keyboardLayout;
    variant = "";
  };
}
