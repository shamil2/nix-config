{ myvars, ... }:
{
  # CUPS printing
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Keyboard configuration
  services.xserver.xkb = {
    layout = myvars.keyboardLayout;
    variant = "";
  };
}
