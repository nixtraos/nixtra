{ ... }:

if config.nixtra.security.impermanence && config.nixtra.system.filesystem == "btrfs" then
  {
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      echo "Rollback running" > /mnt/rollback.log
      mkdir -p /mnt
      mount -t btrfs /dev/mapper/cryptroot /mnt

      # Recursively delete all nested subvolumes inside /mnt/root
      btrfs subvolume list -o /mnt/root | cut -f9 -d' ' | while read subvolume; do
        echo "Deleting /$subvolume subvolume..." >> /mnt/rollback.log
        btrfs subvolume delete "/mnt/$subvolume"
      done

      echo "Deleting /root subvolume..." >> /mnt/rollback.log
      btrfs subvolume delete /mnt/root

      echo "Restoring blank /root subvolume..." >> /mnt/rollback.log
      btrfs subvolume snapshot /mnt/root-blank /mnt/root

      umount /mnt
    '';

    environment = {
      persistence."/nix/persist" = {
        directories = [
          "/etc/nixos" # configuration files
          "/srv" # service data

          "/var/log" # where journald dumps logs

          # system service persistent data
          #"/var/lib"
          "/var/lib/nixos"
          "/var/lib/sbctl" # secure boot keys
          "/var/lib/btrfs"
          "/var/lib/docker"
          "/var/lib/systemd"
          "/var/lib/libvirt"
          "/var/lib/ollama"
          "/var/lib/private/ollama"

          "/var/db/sudo"
          "/var/cache/mullvad-vpn" # improve mullvad connection performance
          "/var/spool" # Mail queues, cron jobs

          # TODO: define these configurations in their respective Nix modules
          "/etc"
          "/etc/network"
          "/etc/NetworkManager/system-connections"
          "/etc/ssh"
          "/etc/pam.d"
          "/etc/systemd"
          "/etc/systemd/system"
          "/etc/ssl"
          "/etc/ssh"

          "/root"

          "/srv"
        ];
        files = [
          "/etc/machine-id" # ensures logs are retained after reboot
          "/etc/adjtime"
          "/etc/passwd"
          "/etc/shadow"
          "/etc/group"
          "/etc/sddm.conf.d/"
          "/etc/fstab"
          "/users/admin" # directory where I store passwordFile for user
          "/etc/zshrc"
          "/etc/bashrc"
        ];
      };
      etc = {
        # ensures SSH keys can be correctly generated
        "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
        "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
        "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
        "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
      };

      users.${config.nixtra.user.username} = {
        directories = [ "path/relative/to/home" ];
        files = [ "filename" ];
      };
    };

    # optional quality of life setting
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';
  }
else
  { }
