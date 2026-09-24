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

      pythonFor =
        pkgs:
        pkgs.python3.withPackages (
          ps: with ps; [
            networkx
            plotly
            kaleido
            numpy
            pandas
            pytest
          ]
        );

      # The paper imports packages from the Typst registry, which a sandboxed build cannot
      # download. They are fetched with pinned hashes and laid out as a local package tree
      # instead, which `typst --package-path` reads.
      typstPackages = [
        {
          name = "supercharged-hm";
          version = "1.1.0";
          hash = "sha256-DkHxqJkm5f4mtbA/vJ0lxZzccUyIF12Xag4Ov5RwQQk=";
        }
        {
          name = "linguify";
          version = "0.5.0";
          hash = "sha256-Tgw1n6o0KNqVY2KQRV5ll+F2kRp6gCXRaUVMQ2vo7hg=";
        }
        {
          name = "glossarium";
          version = "0.5.10";
          hash = "sha256-+djwDgdFPxPpLQtytLwlmeQENyzV46J8xbOXxGoHnYY=";
        }
        {
          name = "drafting";
          version = "0.2.2";
          hash = "sha256-xJ3FdEiM1qPEhzZ4QkNdsysmMQ0GbY5l+EoWo2sbFdk=";
        }
        {
          name = "codelst";
          version = "2.0.2";
          hash = "sha256-nroAmdKRY2YqxCC+/E+Ql/FxxFugPjjbOW3BwPBZLVU=";
        }
      ];

      typstPackagePath =
        pkgs:
        pkgs.linkFarm "typst-packages" (
          map (package: {
            name = "preview/${package.name}/${package.version}";
            path = pkgs.fetchzip {
              url = "https://packages.typst.org/preview/${package.name}-${package.version}.tar.gz";
              stripRoot = false;
              inherit (package) hash;
            };
          }) typstPackages
        );

      paperFor =
        pkgs:
        pkgs.runCommand "steinerbaeume.pdf"
          {
            nativeBuildInputs = [ pkgs.typst ];
            # the template asks for Roboto; without it typst falls back and warns
            TYPST_FONT_PATHS = "${pkgs.roboto}/share/fonts";
          }
          ''
            typst compile \
              --package-path ${typstPackagePath pkgs} \
              --root ${inputs.self}/paper_sync \
              ${inputs.self}/paper_sync/main.typ \
              "$out"
          '';
    in
    {
      devShells = builtins.mapAttrs (system: pkgs: {
        default = pkgs.mkShell {
          packages = [
            (pythonFor pkgs)
            pkgs.ruff
            treefmtEval.${system}.config.build.wrapper
          ];

          shellHook = ''
            export PYTHONPATH="$PWD/src''${PYTHONPATH:+:$PYTHONPATH}"
          '';
        };
      }) inputs.nixpkgs.legacyPackages;

      packages = builtins.mapAttrs (system: pkgs: rec {
        paper = paperFor pkgs;
        default = paper;
      }) inputs.nixpkgs.legacyPackages;

      # for `nix fmt`
      formatter = builtins.mapAttrs (system: eval: eval.config.build.wrapper) treefmtEval;

      # for `nix flake check`
      checks = builtins.mapAttrs (system: pkgs: {
        formatting = treefmtEval.${system}.config.build.check inputs.self;

        tests = pkgs.runCommand "steiner-graph-tests" { nativeBuildInputs = [ (pythonFor pkgs) ]; } ''
          cp -r ${inputs.self} source
          chmod -R u+w source
          cd source
          export HOME="$TMPDIR"
          pytest
          touch "$out"
        '';
      }) inputs.nixpkgs.legacyPackages;
    };
}
