{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  pwq = pkgs.libpwquality;
in
{
  # make sure pam_pwquality is available on the system
  environment.systemPackages = with pkgs; [ pwq ];

  # add/ensure the password stack for 'passwd' includes pwquality + pam_unix
  security.pam.services.passwd.text = lib.mkDefault (
    lib.mkBefore ''
      # password quality + rules
      #password required ${pwq}/lib/security/pam_pwquality.so retry=2 minlen=16 difok=6 dcredit=-3 ucredit=-2 lcredit=-2 ocredit=-3 enforce_for_root
      password required ${pwq}/lib/security/pam_pwquality.so retry=2 difok=6 dcredit=-3 ucredit=-2 lcredit=-2 ocredit=-3 enforce_for_root
      # use the token provided by pam_pwquality and store hashed passwd in shadow
      password required pam_unix.so use_authtok sha512 shadow
      # use more rounds for more secure hashing
      password required pam_unix.so sha512 shadow nullok rounds=65536
    ''
  );

  # add the faildelay for the system-login service
  security.pam.services."system-login".text = lib.mkDefault (
    lib.mkBefore ''
      auth optional pam_faildelay.so delay=4000000
    ''
  );

  #security.pam.services.su.text = lib.mkDefault (lib.mkBefore ''
  #  # require membership in wheel group to use su
  #  #auth required ${pkgs.pam}/lib/security/pam_wheel.so use_uid
  #'');

  #security.pam.services."su-l".text = lib.mkDefault (lib.mkBefore ''
  #  # require membership in wheel group to use su -l
  #  #auth required ${pkgs.pam}/lib/security/pam_wheel.so use_uid
  #'');
}
