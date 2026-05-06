{ ... }:

{
  nixtra.desktop.languages = [
    "en"
    "gr"
  ];

  # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000/28501/2
  services.logrotate.checkConfig = false;

  nixpkgs.config.packageOverrides = pkgs: {
    prismlauncher-unwrapped = pkgs.prismlauncher-unwrapped.overrideAttrs (attrs: {
      patches = (attrs.patches or [ ]) ++ [
        (pkgs.writeText "disable-microsoft-authentication.patch" ''
          diff --git a/launcher/minecraft/auth/AccountList.cpp b/launcher/minecraft/auth/AccountList.cpp
          index 3cbbb2a74..71f1e5a6e 100644
          --- a/launcher/minecraft/auth/AccountList.cpp
          +++ b/launcher/minecraft/auth/AccountList.cpp
          @@ -561,12 +561,7 @@ void AccountList::setListFilePath(QString path, bool autosave)

           bool AccountList::anyAccountIsValid()
           {
          -    for (auto account : m_accounts) {
          -        if (account->ownsMinecraft()) {
          -            return true;
          -        }
          -    }
          -    return false;
          +    return true;
           }

           void AccountList::fillQueue()
          diff --git a/launcher/minecraft/auth/MinecraftAccount.h b/launcher/minecraft/auth/MinecraftAccount.h
          index a82d3f134..0d9aff8a4 100644
          --- a/launcher/minecraft/auth/MinecraftAccount.h
          +++ b/launcher/minecraft/auth/MinecraftAccount.h
          @@ -116,7 +116,7 @@ class MinecraftAccount : public QObject, public Usable {

               AccountType accountType() const noexcept { return data.type; }

          -    bool ownsMinecraft() const { return data.type != AccountType::Offline && data.minecraftEntitlement.ownsMinecraft; }
          +    bool ownsMinecraft() const { return true; }

               bool hasProfile() const { return data.profileId().size() != 0; }

        '')
      ];
    });

    davinci-resolve-studio = (
      pkgs.davinci-resolve-studio.overrideAttrs (
        attrs:
        let
          searchBytes = "\\x00\\x85\\xc0\\x74\\x7b\\xe8";
          replaceBytes = "\\x00\\x85\\xc0\\xEB\\x7b\\xe8";
          patchScript = ''
            #perl -pi -e 's/${searchBytes}/${replaceBytes}/g' $out/bin/resolve
            perl -pi -e 's/\x0f\x84\x9d\x00\x00\x00\x89\xf5/\x0f\x85\x9d\x00\x00\x00\x89\xf5/g' $out/bin/resolve
          '';
        in
        {
          postInstall = (attrs.postInstall or "") + ''
            echo "Applying binary patch to resolve..."
            # Make sure the binary exists and is writable for perl -pi
            if [ -f $out/bin/resolve ]; then
              chmod +w $out/bin/resolve
              ${patchScript}
              chmod -w $out/bin/resolve # Revert permissions
              echo "Binary patch applied successfully."
            else
              echo "Error: /bin/resolve not found in $out. Patch skipped." >&2
              exit 1
            fi
          '';
        }
      )
    );
  };
}
