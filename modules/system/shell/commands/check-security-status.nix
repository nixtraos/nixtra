{ config, createCommand, pkgs, ... }:

createCommand {
  name = "check-security-status";
  buildInputs = with pkgs; [
    kernel-hardening-checker
    lynis
    clamav
    aide
    # TODO: wait for rkhunter support to be merged to upstream nixpkgs
    #rkhunter
    vulnix
    spectre-meltdown-checker
    sudo
    coreutils
    gnugrep
  ];

  command = ''
    LOGFILE="/tmp/security_check_$(date +'%Y%m%d_%H%M%S').log"
    echo "Starting security checks. Logging to: $LOGFILE"
    exec > >(tee "$LOGFILE") 2>&1

    echo "=== Kernel Security Check ==="
    if [ -f /proc/cmdline ]; then
      if [ -f /etc/kernel/kernel-config ]; then
        echo "Using NixOS kernel config"
        kernel-hardening-checker -l /proc/cmdline -c /etc/kernel/kernel-config
      elif [ -f /proc/config.gz ]; then
        echo "Using runtime kernel config"
        zcat /proc/config.gz | kernel-hardening-checker -l /proc/cmdline -c -
      else
        echo "ERROR: No kernel config found"
      fi
    else
      echo "ERROR: /proc/cmdline not found"
    fi

    echo -e "\n=== Systemd Security Analysis ==="
    systemd-analyze security

    echo -e "\n=== Rootkit Checks ==="
    {
      echo "Lynis:"
      lynis audit system --quick
      cat /sys/devices/system/cpu/vulnerabilities/*

      #echo -e "\nrkhunter:"
      #rkhunter
    } | grep -v 'not found'

    echo -e "\n=== Malware Scan ==="
    if [ -d /var/lib/clamav ]; then
      echo "Updating ClamAV signatures..."
      freshclam --quiet
      clamscan --infected --recursive --scan-swf=yes --scan-archive=yes / 2>/dev/null | head -n 20
      echo "(Full output in log file)"
    else
      echo "WARNING: ClamAV database not initialized. Run 'sudo freshclam' first."
    fi

    echo -e "\n=== File Integrity Check ==="
    if [ -f /var/lib/aide/aide.db.gz ]; then
      aide --check
    else
      echo "WARNING: AIDE database not initialized. Run 'sudo aide --init' first."
    fi

    echo -e "\n=== Nixpkgs Scan ==="
    vulnix --system

    echo -e "\n=== Firewall Status ==="
    sudo nft list ruleset 2>/dev/null || sudo iptables -L -v -n

    echo -e "\n=== SSH Security ==="
    grep -E "^(PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config
    check_ssh_banner() {
      [ -f "/etc/issue.net" ] && grep -q "USG" "/etc/issue.net" && \
      echo "SSH banner: COMPLIANT" || echo "SSH banner: NON-COMPLIANT :cite[8]"
    }
    check_ssh_banner

    echo -e "\n=== Boot Integrity ==="
    sudo dmesg | grep -i "secure boot\|tpm"
    [ -d /sys/firmware/efi ] && echo "UEFI Boot: Enabled" || echo "UEFI Boot: Disabled"
    if [ -f /etc/kernel/kernel-config ]; then
      grep -E "CONFIG_(SECURITY|SELINUX|APPARMOR|LOCK_DOWN)" /etc/kernel/kernel-config
    fi

    echo -e "\n=== Hardware Vulnerabilities ==="
    spectre-meltdown-checker --batch
    lsmod | grep -E "(kvm_intel|kvm_amd)" && echo "Virtualization: Enabled"

    echo -e "\n=== MAC Systems ==="
    sestatus 2>/dev/null || echo "SELinux: Not configured"
    aa-status 2>/dev/null || echo "AppArmor: Not active"

    echo -e "\nSecurity check completed. Full output in: $LOGFILE"
  '';
}
