{
  description = "Steiner trees — Graphentheorie SS2026";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      treefmtEval = builtins.mapAttrs (
        system: pkgs:
        inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs.nixfmt.enable = true;
          programs.ruff-check.enable = true;
          programs.ruff-format.enable = true;
          programs.prettier.enable = true;

          settings.global.excludes = [ "michi/**" ];
        }
      ) inputs.nixpkgs.legacyPackages;
    in
    {
      devShells = builtins.mapAttrs (
        system: pkgs:
        let
          python = pkgs.python3.withPackages (
            ps: with ps; [
              networkx
              plotly
              kaleido
              numpy
              pandas
              pytest
            ]
          );
        in
        {
          default = pkgs.mkShell {
            packages = [
              python
              pkgs.ruff
              treefmtEval.${system}.config.build.wrapper
            ];

            shellHook = ''
              export PYTHONPATH="$PWD/src''${PYTHONPATH:+:$PYTHONPATH}"
            '';
          };
        }
      ) inputs.nixpkgs.legacyPackages;

      # for `nix fmt`
      formatter = builtins.mapAttrs (system: eval: eval.config.build.wrapper) treefmtEval;

      # for `nix flake check`
      checks = builtins.mapAttrs (system: eval: {
        formatting = eval.config.build.check inputs.self;
      }) treefmtEval;
    };
}
