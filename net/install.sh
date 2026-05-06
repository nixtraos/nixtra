#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash systemd coreutils coreutils-full git e2fsprogs util-linux parted gnused btrfs-progs zfs cryptsetup

set -e  # Exit immediately if a command exits with a non-zero status

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root or with sudo" >&2
  exit 1
fi

log_file="/var/log/nixtra.log"
default_partition_scheme="gpt"
default_boot="512MB"
default_use_swap="no"
default_swap="8GB"
default_filesystem="ext4"

EDITOR=${EDITOR:-nano}

trap "echo \"The installation failed because an error was received. Please check \\\"${log_file}\\\" for a detailed log.\"; umount -q -R /mnt; exit 1" ERR
trap "umount -q -R /mnt" EXIT

memory_size_is_valid() {
  [[ $1 =~ ^[0-9]+(KB|MB|GB|TB)$ ]]
}

parse_size_in_mb() {
  local size=$1
  local unit=${size//[0-9]/}
  local num=${size%$unit}
  case $unit in
    KB) echo $((num / 1024)) ;;
    MB) echo $num ;;
    GB) echo $((num * 1024)) ;;
    TB) echo $((num * 1024 * 1024)) ;;
    *) return 1 ;;
  esac
}

write_property() {
  local filename=$1
  local property=$2
  local value=$3
  # Escape both the property and value for sed
  local escaped_property=$(printf '%s\n' "$property" | sed -e 's/[\/&]/\\&/g')
  local escaped_value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')
  # Handle both with and without semicolons
  sed -i -E "s/(^[[:space:]]*${escaped_property}[[:space:]]*=)[^;]*(;?)/\1 \"${escaped_value}\"\2/" "$filename"
}

prompt_with_default() {
  local prompt="$1"
  local default="$2"
  local var_name="$3"
  read -p "$prompt [$default] " "$var_name"
  eval "$var_name=\${$var_name:-$default}"
}

prompt_with_validation() {
  local prompt="$1"
  local default="$2"
  local var_name="$3"
  local validation_func="$4"
  local error_msg="$5"
  while true; do
    prompt_with_default "$prompt" "$default" "$var_name"
    if "$validation_func" "${!var_name}"; then
      break
    else
      echo "$error_msg"
    fi
  done
}

wait_for_partitions() {
  local device=$1
  local partitions=$2
  local tries=0
  local max_tries=5

  while [[ $tries -lt $max_tries ]]; do
    local found=0
    for ((i=1; i<=partitions; i++)); do
      if [[ $device == nvme* || $device == mmcblk* ]]; then
        [[ -e "/dev/${device}p${i}" ]] && ((found++))
      else
        [[ -e "/dev/${device}${i}" ]] && ((found++))
      fi
    done

    if [[ $found -eq $partitions ]]; then
      return 0
    fi

    ((tries++))
    sleep 1
  done

  return 1
}

get_disk_uuid() {
  blkid -s UUID -o value "$1" 2>>"$log_file"
}

log_header() {
  echo -e "\n$1" >> "$log_file"
}

echo -n "" > "$log_file"
log_header "System Info:"
uname -a >> "$log_file"
date >> "$log_file"

echo "- Nixtra Installation Script -"
echo "- by quarterstar -"
echo "- https://github.com/quarterstar/nixtra -"
echo ""

echo "Welcome to the Nixtra installation script."
echo "Available devices:"
lsblk
echo ""

validate_device() {
  [ -e "/dev/$1" ]
}

prompt_with_validation "Enter installation device (e.g. sda, nvme0n1)" "" device \
  "validate_device" "Device does not exist."

validate_partition() {
  [[ "$1" =~ ^(gpt|mbr)$ ]]
}

prompt_with_validation "Choose partition scheme (gpt/mbr)" "$default_partition_scheme" scheme \
  "validate_partition" "Invalid partition scheme"

validate_filesystem() {
  [[ "$1" =~ ^(ext4|btrfs|zfs)$ ]]
}

prompt_with_validation "Select filesystem (ext4/btrfs/zfs)" "$default_filesystem" filesystem \
  "validate_filesystem" "Invalid filesystem"

validate_encryption() {
  [[ "$1" =~ ^(yes|no)$ ]]
}

prompt_with_validation "Encrypt drive? (yes/no)" "no" encrypt_drive \
  "validate_encryption" "Invalid encryption choice"

prompt_with_validation "Enter boot partition size" "$default_boot" boot \
  "memory_size_is_valid" "Invalid size format"

validate_swap() {
  [[ "$1" =~ ^(yes|no)$ ]]
}

prompt_with_validation "Set up swap? (yes/no)" "$default_use_swap" use_swap \
  "validate_swap" "Invalid swap choice"

swap=""
if [ "$use_swap" = "yes" ]; then
  prompt_with_validation "Enter swap size" "$default_swap" swap \
    "memory_size_is_valid" "Invalid size format"
fi

validate_gpu() {
  [[ "$1" =~ ^(amd|nvidia|none)$ ]]
}

prompt_with_validation "Select GPU drivers (amd/nvidia/none)" "" gpu \
  "validate_gpu" "Unsupported GPU"

validate_profile() {
  [[ "$1" =~ ^(personal|program|exploit|math|untrusted)$ ]]
}

prompt_with_validation "Select profile (personal/program/exploit/math/untrusted)" "" profile \
  "validate_profile" "Invalid profile"

while true; do
  read -p "Enter username: " username
  if [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    break
  fi
  echo "Invalid username. Use lowercase letters, digits, hyphens, and underscores."
done

while true; do
  read -s -p "Enter password: " password
  echo
  read -s -p "Confirm password: " password_confirm
  echo
  [ "$password" = "$password_confirm" ] && break
  echo "Passwords do not match."
done

while true; do
  read -p "Enter timezone (e.g. America/New_York): " timezone
  if timedatectl list-timezones | grep -qxF "$timezone"; then
    break
  fi
  echo "Invalid timezone."
done

echo -e "\n- Selected Options -"
echo "Device: $device | FS: $filesystem | Encryption: $encrypt_drive"
echo "Boot: $boot | Swap: ${swap:-none} | GPU: $gpu"
echo "Profile: $profile | User: $username | Timezone: $timezone"
read -p "Type 'continue' to proceed: " consent
[ "$consent" != "continue" ] && exit 0

echo "Starting installation..."
log_header "Installation Parameters:"
set >> "$log_file"

echo -n "Partitioning..."
parted "/dev/$device" -s -- mklabel ${scheme^^}

storage_idx=1; boot_idx=2

if [ "$scheme" = "gpt" ]; then
  parted "/dev/$device" -s -- mkpart root ${filesystem} "$boot" 100%
  parted "/dev/$device" -s -- mkpart ESP fat32 1MB "$boot"
  parted "/dev/$device" -s -- set $boot_idx esp on
else
  parted "/dev/$device" -s -- mkpart primary ${filesystem} "$boot" 100%
  parted "/dev/$device" -s -- mkpart primary ext4 1MB "$boot"
  parted "/dev/$device" -s -- set $boot_idx boot on
fi

# Notify kernel of partition table changes
partprobe "/dev/$device"

# Await both created partitions
if ! wait_for_partitions "$device" 2; then
  echo "Failed to detect partitions after creation" >&2
  exit 1
fi
echo "done"

# NVMe and MMC devices have different naming (they have a 'p' before partition number)
if [[ $device == nvme* || $device == mmcblk* ]]; then
  storage_device="/dev/${device}p${storage_idx}"
  boot_device="/dev/${device}p${boot_idx}"
else
  storage_device="/dev/${device}${storage_idx}"
  boot_device="/dev/${device}${boot_idx}"
fi

if [ "$encrypt_drive" = "yes" ]; then
  decrypted_partition_device="cryptroot"
  echo -n "Encrypting storage..."
  cryptsetup luksFormat -q --type luks2 --pbkdf argon2id -i 5000 "$storage_device"
  cryptsetup open "$storage_device" "$decrypted_partition_device"
  storage_device="/dev/mapper/$decrypted_partition_device"
  echo "done"
fi

echo -n "Formatting partitions..."
case "$filesystem" in
  ext4) mkfs.ext4 -F -L nixos "$storage_device" >> "$log_file" 2>&1 ;;
  btrfs) mkfs.btrfs -f -L nixos "$storage_device" >> "$log_file" 2>&1 ;;
  zfs)
    zpool create -f rpool "$storage_device" >> "$log_file" 2>&1
    zfs create -o mountpoint=legacy rpool/root >> "$log_file" 2>&1
    ;;
esac

if [ "$scheme" = "gpt" ]; then
  mkfs.fat -F 32 -n boot "$boot_device" >> "$log_file" 2>&1
else
  mkfs.ext4 -F -L boot "$boot_device" >> "$log_file" 2>&1
fi
echo "done"

echo -n "Mounting partitions..."
if [ "$filesystem" = "zfs" ]; then
  mount -t zfs rpool/root /mnt
else
  mount "$storage_device" /mnt
fi

mkdir -p /mnt/boot
mount -o umask=077 "$boot_device" /mnt/boot
echo "done"

echo -n "Cloning repository..."
git clone -q https://github.com/quarterstar/nixtra /mnt/etc/nixos
cd /mnt/etc/nixos && git submodule update -q --init --recursive
cd - >/dev/null
echo "done"

echo -n "Configuring user profile structure..."
# Transition from profiles/PROFILE to profiles/USER/PROFILE
mkdir -p "/mnt/etc/nixos/profiles/$username"
if [ -d "/mnt/etc/nixos/profiles/$profile" ]; then
  mv "/mnt/etc/nixos/profiles/$profile" "/mnt/etc/nixos/profiles/$username/$profile"
fi
echo "done"

echo -n "Writing configuration..."
boot_disk_uuid=$(get_disk_uuid "$boot_device")
storage_disk_uuid=$(get_disk_uuid "$storage_device")
profile_settings_path="/mnt/etc/nixos/profiles/$username/$profile/profile-settings.nix"

write_property "/mnt/etc/nixos/settings.nix" "disk.partitions.boot" "/dev/disk/by-uuid/$boot_disk_uuid"
write_property "/mnt/etc/nixos/settings.nix" "disk.partitions.storage" "/dev/disk/by-uuid/$storage_disk_uuid"

if [ "$encrypt_drive" = "yes" ]; then
  decrypted_root_uuid=$(get_disk_uuid "/dev/mapper/$decrypted_partition_device")
  write_property "/mnt/etc/nixos/settings.nix" "disk.encryption.enable" "true"
  write_property "/mnt/etc/nixos/settings.nix" "disk.encryption.decryptedRootDevice" "/dev/disk/by-uuid/$decrypted_root_uuid"
fi

if [ "$use_swap" = "yes" ]; then
  write_property "/mnt/etc/nixos/settings.nix" "disk.swap.size" $(parse_size_in_mb "$swap")
  write_property "/mnt/etc/nixos/settings.nix" "disk.swap.enable" "true"
fi

write_property "/mnt/etc/nixos/settings.nix" "system.timezone" "$timezone"
write_property "/mnt/etc/nixos/settings.nix" "system.filesystem" "$filesystem"
write_property "/mnt/etc/nixos/settings.nix" "hardware.gpu" "$gpu"
write_property "$profile_settings_path" "user.username" "$username"
echo "done"

echo -n "Generating hardware config..."
nixos-generate-config --show-hardware-config > /mnt/etc/nixos/modules/system/hardware-configuration.nix 2>>"$log_file"
echo "done"

echo -n "Installing system..."
nixos-install --root /mnt --flake /mnt/etc/nixos#default --no-root-passwd >> "$log_file" 2>&1
echo "done"

echo -n "Setting user password..."
nixos-enter --root /mnt --command "echo '$username:$password' | chpasswd" >> "$log_file" 2>&1
echo "done"

read -p "Edit settings.nix? [y/N] " edit_settings
[[ $edit_settings =~ ^[Yy] ]] && $EDITOR /mnt/etc/nixos/settings.nix

read -p "Edit selected profile configuration? [y/N] " edit_profile
[[ $edit_profile =~ ^[Yy] ]] && $EDITOR "$profile_settings_path"

read -p "Download additional static and animated wallpapers curated by Nixtra project? (This operation may take a long time.) [y/N] " download_wallpapers
if [[ $download_wallpapers =~ ^[Yy] ]]; then
  echo "Downloading wallpapers..."
  git clone https://github.com/quarterstar/nixtra-wallpapers "/mnt/home/$username/Wallpapers" >> "$log_file" 2>&1
  # Ensure the cloned wallpapers belong to the user
  nixos-enter --root /mnt --command "chown -R $username:users /home/$username/Wallpapers" >> "$log_file" 2>&1
fi

read -p "Installation complete! Reboot? [Y/n] " reboot_system
[[ ! $reboot_system =~ ^[Nn] ]] && reboot
