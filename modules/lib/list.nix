{ lib, ... }:

{
  indexedMapAttrsToList0 =
    f: attrs:
    let
      names = lib.attrNames attrs;
    in
    lib.lists.imap0 (i: name: f i name (attrs.${name})) names;

  indexedMapAttrsToList1 =
    f: attrs:
    let
      names = lib.attrNames attrs;
    in
    lib.lists.imap1 (i: name: f i name (attrs.${name})) names;
}
