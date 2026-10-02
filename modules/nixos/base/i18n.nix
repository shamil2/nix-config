{ myvars, ... }:
{
  # Set your time zone.
  time.timeZone = myvars.timeZone;

  # Select internationalisation properties.
  i18n.defaultLocale = myvars.defaultLocale;
  i18n.extraLocaleSettings = myvars.extraLocales;

  # Configure console keymap
  console.keyMap = myvars.keyboardLayout;
}
