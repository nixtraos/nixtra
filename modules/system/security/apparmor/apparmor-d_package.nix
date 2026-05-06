{
  buildGoModule,
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  writeText,
}:
buildGoModule {
  pname = "apparmor-d";
  version = "unstable-2025-05-27";

  src = fetchFromGitHub {
    rev = "bf22a7786c39d3b56b87095bfd4479769b88ec1a";
    owner = "roddhjav";
    repo = "apparmor.d";
    hash = "sha256-J8h9LcZRxhTaZg7OU2m75upSoeD1i/abSCJQtX1WRsQ=";
  };

  vendorHash = null;

  doCheck = false;
  dontCheckForBrokenSymlinks = true;

  patches = [
    (writeText "prebuild.patch" ''
      diff --git a/apparmor.d/tunables/multiarch.d/system b/apparmor.d/tunables/multiarch.d/system
      index 6f7995c0..c0d271e4 100644
      --- a/apparmor.d/tunables/multiarch.d/system
      +++ b/apparmor.d/tunables/multiarch.d/system
      @@ -14,10 +14,9 @@
       @{MOUNTS}=@{MOUNTDIRS}/*/ @{run}/user/@{uid}/gvfs/
       
       # Common places for binaries and libraries across distributions
      -@{bin}=/{,usr/}bin
      -@{sbin}=/{,usr/}sbin     #aa:only apt zypper
      -@{sbin}=/{,usr/}{,s}bin  #aa:only pacman
      -@{lib}=/{,usr/}lib{,exec,32,64}
      +@{bin}=/{nix/store/*/,}{,usr/}bin
      +@{sbin}=/{nix/store/*/,}{,usr/}{,s}bin
      +@{lib}=/{nix/store/*/,/run/wrappers,}{,usr/}lib{,exec,32,64}
       
       # Common places for temporary files
       @{tmp}=/tmp/ /tmp/user/@{uid}/
      diff --git a/cmd/prebuild/main.go b/cmd/prebuild/main.go
      index 62685202..f7d89759 100644
      --- a/cmd/prebuild/main.go
      +++ b/cmd/prebuild/main.go
      @@ -38,7 +38,7 @@ func init() {
       
       	// Matrix of ABI/Apparmor version to integrate with
       	switch prebuild.Distribution {
      -	case "arch":
      +	case "arch", "nixos":
       
       	case "ubuntu":
       		switch prebuild.Release["VERSION_CODENAME"] {
      diff --git a/pkg/aa/apparmor.go b/pkg/aa/apparmor.go
      index 6119a0c9..7a0a7271 100644
      --- a/pkg/aa/apparmor.go
      +++ b/pkg/aa/apparmor.go
      @@ -33,14 +33,14 @@ func DefaultTunables() *AppArmorProfileFile {
       	return &AppArmorProfileFile{
       		Preamble: Rules{
       			&Variable{Name: "arch", Values: []string{"x86_64", "amd64", "i386"}, Define: true},
      -			&Variable{Name: "bin", Values: []string{"/{,usr/}bin"}, Define: true},
      +			&Variable{Name: "bin", Values: []string{"/{nix/store/*/,/run/wrappers,}{,usr/}{,s}bin"}, Define: true},
       			&Variable{Name: "c", Values: []string{"[0-9a-zA-Z]"}, Define: true},
       			&Variable{Name: "dpkg_script_ext", Values: []string{"config", "templates", "preinst", "postinst", "prerm", "postrm"}, Define: true},
       			&Variable{Name: "etc_ro", Values: []string{"/{,usr/}etc/"}, Define: true},
       			&Variable{Name: "HOME", Values: []string{"/home/*"}, Define: true},
       			&Variable{Name: "int", Values: []string{"[0-9]{[0-9],}{[0-9],}{[0-9],}{[0-9],}{[0-9],}{[0-9],}{[0-9],}{[0-9],}{[0-9],}"}, Define: true},
       			&Variable{Name: "int2", Values: []string{"[0-9][0-9]"}, Define: true},
      -			&Variable{Name: "lib", Values: []string{"/{,usr/}lib{,exec,32,64}"}, Define: true},
      +			&Variable{Name: "lib", Values: []string{"/{nix/store/*/,}{,usr/}lib{,exec,32,64}"}, Define: true},
       			&Variable{Name: "MOUNTS", Values: []string{"/media/*/", "/run/media/*/*/", "/mnt/*/"}, Define: true},
       			&Variable{Name: "multiarch", Values: []string{"*-linux-gnu*"}, Define: true},
       			&Variable{Name: "rand", Values: []string{"@{c}{@{c},}{@{c},}{@{c},}{@{c},}{@{c},}{@{c},}{@{c},}{@{c},}{@{c},}"}, Define: true}, // Up to 10 characters
      diff --git a/pkg/prebuild/prepare/configure.go b/pkg/prebuild/prepare/configure.go
      index a6e95448..2b03c4ec 100644
      --- a/pkg/prebuild/prepare/configure.go
      +++ b/pkg/prebuild/prepare/configure.go
      @@ -27,7 +27,7 @@ func (p Configure) Apply() ([]string, error) {
       	res := []string{}
       
       	switch prebuild.Distribution {
      -	case "arch", "opensuse":
      +	case "arch", "opensuse", "nixos":
       
       	case "ubuntu":
       		if err := prebuild.DebianHide.Init(); err != nil {
    '')
  ];

  subPackages = [
    "cmd/prebuild"
    "cmd/aa-log"
  ];

  passthru.updateScript = unstableGitUpdater { };

  postInstall = ''
    mkdir -p $out/etc

    DISTRIBUTION=nixos $out/bin/prebuild --abi 4 # fixme: replace with nixos support once available

    mv .build/apparmor.d $out/etc
    rm $out/bin/prebuild
  '';

  meta = {
    description = "Full set of AppArmor profiles (~ 1500 profiles) ";
    homepage = "https://github.com/roddhjav/apparmor.d";
    license = lib.licenses.gpl2Only;
    mainProgram = "aa-log";
    maintainers = with lib.maintainers; [ grimmauld ];
    platforms = lib.platforms.linux;
  };
}
