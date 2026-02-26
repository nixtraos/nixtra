{ config, pkgs, nixtraLib, ... }:

let
  post-commit-hook = pkgs.writeScript "pre-commit" ''
    #!${pkgs.bash}/bin/bash

    USER_EMAIL=$(${pkgs.git}/bin/git config user.email)
    COMMITTER_EMAIL=$(${pkgs.git}/bin/git show -s --format='%ce' HEAD)
    [ "$COMMITTER_EMAIL" != "$USER_EMAIL" ] && exit 0

    if [ -n "$GIT_REDACTING_DATE" ]; then
        exit 0
    fi

    ORIG_DATE=$(${pkgs.git}/bin/git show -s --format=%ad --date=iso-strict HEAD)
    REDACTED_DATE="''${ORIG_DATE%%T*}T00:00:00+00:00"

    export GIT_REDACTING_DATE=1
    GIT_COMMITTER_DATE="$REDACTED_DATE" ${pkgs.git}/bin/git commit --amend \
        --no-edit \
        --date="$REDACTED_DATE" \
        --quiet

    echo "Redacted commit time to midnight: $REDACTED_DATE"
  '';

  git-redact-repository = pkgs.writeScriptBin "git-redact-repository" ''
    #!${pkgs.bash}/bin/bash

    # Only run for configured user
    USER_EMAIL=$(${pkgs.git}/bin/git config user.email)
    [ -z "$USER_EMAIL" ] && exit 0

    # Prevent infinite recursion
    [ -n "$GIT_REDACTING" ] && exit 0
    export GIT_REDACTING=1

    # Function to redact dates in a commit
    redact_dates() {
      COMMIT_DATE=$(${pkgs.git}/bin/git show -s --format=%ad --date=iso-strict "$1")
      REDACTED_DATE="''${COMMIT_DATE%%T*}T00:00:00+00:00"

      ${pkgs.git}/bin/git filter-branch \
        --force \
        --env-filter \
          "if [ \$GIT_COMMIT = '$1' ]; then
             export GIT_AUTHOR_DATE='$REDACTED_DATE'
             export GIT_COMMITTER_DATE='$REDACTED_DATE'
           fi" \
        --tag-name-filter cat \
        -- --all
    }

    # Redact current commit
    CURRENT_COMMIT=$(${pkgs.git}/bin/git rev-parse HEAD)
    redact_dates "$CURRENT_COMMIT"

    # Find all commits by user that need redaction
    COMMITS_TO_REDACT=$(${pkgs.git}/bin/git log \
      --author="$USER_EMAIL" \
      --format="%H %ad" \
      --date=iso-strict \
      | awk '!($2 ~ /T00:00:00\+00:00/) {print $1}')

    # Redact historical commits
    for commit in $COMMITS_TO_REDACT; do
      redact_dates "$commit"
    done

    # Clean up references
    ${pkgs.git}/bin/git for-each-ref \
      --format="%(refname)" refs/original/ \
      | xargs -n 1 ${pkgs.git}/bin/git update-ref -d

    ${pkgs.git}/bin/git reflog expire --expire=now --all
    ${pkgs.git}/bin/git gc --prune=now

    echo "Redacted time information for $(( $(echo "$COMMITS_TO_REDACT" | wc -l) + 1 )) commits"
  '';
in {
  environment.systemPackages = with pkgs; [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.git}/bin/git";
      profile = "git";
    })
    git-filter-repo # Rewrite Git repositories;
    gh
    git-redact-repository
  ];

  programs.git.enable = true;
  programs.git.config = {
    commit = { gpgsign = config.nixtra.git.signCommits; };

    http = if config.nixtra.git.proxy.enable then {
      proxy = config.nixtra.git.proxy.address;
    } else
      { };

    https = if config.nixtra.git.proxy.enable then {
      proxy = config.nixtra.git.proxy.address;
    } else
      { };

    init = if config.nixtra.git.randomizeCommitDate then {
      templateDir = "/etc/git-templates";
    } else
      { };

    # Force ISO 8601 format for date parsing
    log.date = "iso-strict";

    # Safety checks
    receive.denyNonFastForwards = true;
    receive.denyDeletes = true;

    # Automatically create origin upstream on first push
    push.autoSetupRemote = true;
  };

  environment.etc."git-templates/hooks/post-commit" = {
    source = post-commit-hook;
    mode = "0755";
  };
}
