{
  config,
  lib,
  pkgs,
  ...
}:

let
  notificationScript = pkgs.writeShellScriptBin "udev-usb-notification" ''
    export DISPLAY=:0
    export XDG_RUNTIME_DIR="/run/user/${builtins.toString config.nixtra.user.uid}"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

    VENDOR_ID="$ENV{ID_VENDOR_ID}"
    MODEL_ID="$ENV{ID_MODEL_ID}"
    VENDOR_NAME="$ENV{ID_VENDOR}"
    MODEL_NAME="$ENV{ID_MODEL}"
    PRODUCT_NAME="$ENV{ID_MODEL_FROM_DATABASE}"
    SERIAL_NUMBER="$ENV{ID_SERIAL_SHORT}"

    if [ -z "$PRODUCT_NAME" ]; then
        PRODUCT_NAME="$VENDOR_NAME $MODEL_NAME"
    fi

    ${pkgs.libnotify}/bin/notify-send \
      -i "usb-flash-drive" \
      "USB Device Connected" \
      "<b>Product:</b> $PRODUCT_NAME\n<b>Vendor:</b> $VENDOR_NAME (ID: $VENDOR_ID)\n<b>Model:</b> $MODEL_NAME (ID: $MODEL_ID)\n<b>Serial:</b> $SERIAL_NUMBER"
  '';
in
{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    environment.systemPackages = with pkgs; [ notificationScript ];

    boot.initrd.services.udev.rules = ''
      SUBSYSTEM=="usb", ACTION=="add", ENV{DEVTYPE}=="usb_device", RUN+="udev-usb-notification"
    '';
  };
}
