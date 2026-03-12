{ pkgs, lib, ... }:

let
  sys = rec {
    cmds = {
      sudo = "/usr/bin/sudo";
      sh = "/bin/sh";
      apt = "/usr/bin/apt";
      grep = "${pkgs.gnugrep}/bin/grep";
      systemctl = "/usr/bin/systemctl";
      usermod = "/usr/sbin/usermod";
      touch = "/usr/bin/touch";
      dpkg = "/usr/bin/dpkg";
      dpkgQuery = "/usr/bin/dpkg-query";
      install = "/usr/bin/install";
      cmp = "/usr/bin/cmp";
      mktemp = "/usr/bin/mktemp";
      rm = "/usr/bin/rm";
    };

    initSudoPwd = ''
      SECRET_FILE="$HOME/.config/dotfiles/secrets.nix"
      SUDO_PWD=""
      if [ -f "$SECRET_FILE" ]; then
        SUDO_PWD=$(${pkgs.gnugrep}/bin/grep -w "home\.passwd" "$SECRET_FILE" | sed -n "s/.*home\.passwd[[:space:]]*=[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1)
      fi
    '';

    esudoFn = ''
      esudo() {
        if [ -n "''${SUDO_PWD:-}" ]; then
          printf '%s\n' "$SUDO_PWD" | ${cmds.sudo} -S "$@"
        else
          ${cmds.sudo} "$@"
        fi
      }
    '';

    config = rec {
      renderers = {
        ini = attrs: lib.generators.toINI {} attrs;
        yaml = attrs: lib.generators.toYAML {} attrs;
        json = attrs: builtins.toJSON attrs;
        toml = attrs: lib.generators.toTOML {} attrs;
        plain = text: text;
        lines = values: lib.concatStringsSep "\n" values + "\n";
        kv = attrs: renderers.lines (lib.mapAttrsToList (k: v: "${k} ${toString v}") attrs);
        kvEq = attrs: renderers.lines (lib.mapAttrsToList (k: v: "${k} = ${toString v}") attrs);
      };

      renderedText = { format, data }:
        if format == "ini" then renderers.ini data
        else if format == "yaml" then renderers.yaml data
        else if format == "json" then renderers.json data
        else if format == "toml" then renderers.toml data
        else if format == "plain" then data
        else if format == "lines" then renderers.lines data
        else if format == "kv" then renderers.kv data
        else if format == "kvEq" then renderers.kvEq data
        else throw "Unsupported render format: ${format}";

      renderedFile = { name, format, data }:
        pkgs.writeText name (renderedText { inherit format data; });

      deployScript = {
        source,
        target,
        owner ? "root",
        group ? "root",
        mode ? "0644",
        postDeploy ? ""
      }: ''
        TMP_FILE="$(${cmds.mktemp})"
        cp "${source}" "$TMP_FILE"
        if [ ! -f "${target}" ] || ! ${cmds.cmp} -s "$TMP_FILE" "${target}"; then
          esudo ${cmds.install} -D -m ${mode} -o ${owner} -g ${group} "$TMP_FILE" "${target}"
          ${postDeploy}
        fi
        ${cmds.rm} -f "$TMP_FILE"
      '';

      deploy = {
        name,
        format,
        data,
        target,
        owner ? "root",
        group ? "root",
        mode ? "0644",
        post ? ""
      }:
        let src = renderedFile { inherit name format data; };
        in deployScript {
          source = src;
          postDeploy = post;
          inherit target owner group mode;
        };

      activation = {
        after ? [ "writeBoundary" ],
        pre ? "",
        name,
        format,
        data,
        target,
        owner ? "root",
        group ? "root",
        mode ? "0644",
        post ? "",
        message ? null
      }:
        sys.task.root {
          inherit after;
          script = ''
            ${lib.optionalString (message != null) "echo \"${message}\""}
            ${pre}
            ${deploy {
              inherit name format data target owner group mode post;
            }}
          '';
        };
    };

    task = rec {
      activation = {
        after ? [ "writeBoundary" ],
        asRoot ? false,
        guardDryRun ? true,
        pre ? "",
        script ? "",
        post ? "",
        message ? null
      }:
        sys.mkActivation {
          inherit after asRoot guardDryRun;
          script = ''
            ${lib.optionalString (message != null) "echo \"${message}\""}
            ${pre}
            ${script}
            ${post}
          '';
        };

      root = args: activation (args // { asRoot = true; });
    };

    mkActivation = {
      after ? [ "writeBoundary" ],
      asRoot ? false,
      guardDryRun ? true,
      script
    }:
      lib.hm.dag.entryAfter after ''
        ${lib.optionalString asRoot sys.initSudoPwd}
        ${lib.optionalString asRoot sys.esudoFn}
        ${lib.optionalString guardDryRun ''
          if [ -z "$DRY_RUN_CMD" ]; then
        ''}
        ${script}
        ${lib.optionalString guardDryRun ''
          fi
        ''}
      '';

    render = config.renderers;
    mkRenderedText = config.renderedText;
    mkRenderedFile = config.renderedFile;
    mkDeployScript = config.deployScript;
    deploy = config.deploy;
  };
in
{
  _module.args.sys = sys;
}
