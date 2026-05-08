{ localMachine, lib, ... }:

let
  allKnownDevices = {
    "primary-laptop" = {
      id = "DGIGIV6-OP6Y323-TJWJXJY-GBOEFYD-YT6BPIP-2KU6KPK-IU4XVTB-FNGM4A7";
    };
    "desktop" = {
      id = "MUE4IKG-XWJR5TW-MR7GL4C-RMEF2CN-QC4WJTZ-ANMYJP4-CKEA23D-PM3MFQL";
    };
  };

  otherDevices = lib.filter (name: name != localMachine) (builtins.attrNames allKnownDevices);
in
{
  services.syncthing.settings = {
    devices = builtins.removeAttrs allKnownDevices [ localMachine ];

    folders = {
      "Documents" = {
        path = "/home/user/Documents";
        devices = otherDevices;
      };
    };
  };
}
