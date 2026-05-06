{ pkgs, lib, ... }:

let
  inherit (pkgs) fetchFromGitHub;
  inherit (pkgs.vimUtils) buildVimPlugin;
in
{
  eregex = buildVimPlugin rec {
    pname = "eregex.vim";
    version = "2.6";
    src = fetchFromGitHub {
      owner = "othree";
      repo = "eregex.vim";
      rev = "v${version}";
      hash = "sha256-2mHWIYmXZG/jJIcQFFZ/Aua2LTkmWydSCv7x5SPfzfA=";
    };
    meta.homepage = "https://github.com/othree/eregex.vim/";
  };

  editorconfig = buildVimPlugin rec {
    pname = "editorconfig-vim";
    version = "1.2.1";
    src = fetchFromGitHub {
      owner = "editorconfig";
      repo = "editorconfig-vim";
      rev = "v${version}";
      hash = "sha256-YgXVGjP5hxsAHFxE5jmsYvYZbATqLJZ2C6TKizB1rBA=";
    };
    meta.homepage = "https://github.com/editorconfig/editorconfig-vim";
  };

  regex-syntax = buildVimPlugin {
    pname = "vim-regex-syntax";
    version = "0.1";
    src = fetchFromGitHub {
      owner = "Galicarnax";
      repo = "vim-regex-syntax";
      rev = "4e36eff79aa40956ae17ee143e518556865ce818";
      hash = "sha256-3QaZWm7J5KRQ/nS5YNPSLGS9RgozjRe/fN07q1ONFY0=";
    };
    meta.homepage = "https://github.com/Galicarnax/vim-regex-syntax";
  };

  tabular = buildVimPlugin rec {
    pname = "tabular";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "godlygeek";
      repo = "tabular";
      rev = version;
      hash = "sha256-/vTE4c15pp1mXMOL6Ob0/qu8CricQWTDx3L8JRnm8kw=";
    };
    meta.homepage = "https://github.com/godlygeek/tabular";
  };

  plenary = buildVimPlugin rec {
    pname = "plenary.nvim";
    version = "0.1.4";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "v${version}";
      hash = "sha256-zR44d9MowLG1lIbvrRaFTpO/HXKKrO6lbtZfvvTdx+o=";
    };
    doCheck = false;
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim";
  };

  # <c-cr> (Ctrl+Enter): Accept and replace the original selection.
  # <c-r>: Retry generation.
  # q: Close/dismiss without changes.
  gen = buildVimPlugin {
    pname = "gen.nvim";
    version = "0.1";
    src = fetchFromGitHub {
      owner = "David-Kunz";
      repo = "gen.nvim";
      rev = "c8e1f574d4a3a839dde73a87bdc319a62ee1e559";
      hash = "sha256-s12r8dvva0O2VvEPjOQvpjVpEehxsa4AWoGHXFYxQlI=";
    };
  };
}
