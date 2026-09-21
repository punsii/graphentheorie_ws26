{
  description = "Steiner trees — Graphentheorie SS2026";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs = inputs: {
    devShells = builtins.mapAttrs (system: pkgs:
      let
        python = pkgs.python3.withPackages (ps: with ps; [
          networkx
          matplotlib
          numpy
          pandas
          pytest
        ]);
      in
      {
        default = pkgs.mkShell {
          packages = [ python pkgs.ruff ];

          shellHook = ''
            export PYTHONPATH="$PWD/src''${PYTHONPATH:+:$PYTHONPATH}"
          '';
        };
      }) inputs.nixpkgs.legacyPackages;
  };
}
