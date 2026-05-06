{ ... }:

{
  home.file.".cargo/config.toml".text = # toml
    ''
      [http]
      proxy = ""
      [https]
      proxy = ""

      [net]
      git-fetch-with-cli = true
    '';
}
