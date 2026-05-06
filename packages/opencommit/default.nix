{
  pkgs,
  ...
}:

pkgs.buildNpmPackage rec {
  src = pkgs.fetchFromGitHub {
    owner = "di-sukharev";
    repo = "opencommit.git";
    rev = "eaa60fdfb18b41945d60ad73ab63bc43a395ed12";
    hash = "sha256-P8Co02gLuVRTEofuqjoGBYz3k7QoMOAo85KbgNnznfw=";
  };

  pname = "opencommit";
  version = "eaa60fdfb18b41945d60ad73ab63bc43a395ed12";
  npmDepsHash = "sha256-VT0OJGVb03lsPe1oqNU/hgX+U2wWxqcQ+8+3wnn3o9E=";
  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  forceGitDeps = true;
}
