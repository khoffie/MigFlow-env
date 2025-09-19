  # shell.nix

let
  pkgs =  import <nixpkgs> {};
  my-cran-r = (pkgs.rWrapper.override {
         packages = with pkgs.rPackages; [
           data_table
           sf
           readxl
         ];
  });

  helpeR = pkgs.rPackages.buildRPackage {
              name = "helpeR";
              version = "a079313";
              sha256 = "sha256-ZlExia8Gm8huN56GaHaKczZ7aJcOl0vD5nexgqE1ttE=";
              src = pkgs.fetchFromGitHub {
                owner = "khoffie";
                repo = "MigFlow-helpeR";
                rev = "a079313";
                sha256 = "sha256-ZlExia8Gm8huN56GaHaKczZ7aJcOl0vD5nexgqE1ttE=";
              };
              propagatedBuildInputs = with pkgs.rPackages; [
                data_table
                tinytex
                sf
                readxl
              ];
  };

  mig-r =
    (pkgs.rWrapper.override {
      packages = pkgs.rpkgs;
    });
  mig-quarto = [
    (pkgs.quarto.override {
      extraRPackages = pkgs.rpkgs;
    })
  ];
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    my-cran-r
    helpeR
    ## reporteR
    quarto
    julia-lts
    curl
    gdal
    proj
    sqlite
    geos
    which
    nix-ld
    librsvg ## needs quarto to render to pdf
  ];

    shellHook = ''
    export JULIA_PATH="$HOME/.julia/juliaup/julia-1.11.5+0.x64.linux.gnu/bin"

    if [ -x "$JULIA_PATH/julia" ]; then
      echo "Julia already installed at $JULIA_PATH"
    else
      echo "Installing Julia via juliaup..."
      curl -fsSL https://install.julialang.org | sh
    fi
    export PATH="$HOME/.julia/juliaup/julia-1.11.5+0.x64.linux.gnu/bin:$PATH"
    export NIX_LD_LIBRARY_PATH="$HOME/.julia/juliaup/julia-1.11.5+0.x64.linux.gnu/lib/julia"

    export JULIA_NUM_THREADS=4
    export R_HOME="${my-cran-r}/lib/R"
    ## export R_LIBS_SITE=$(R -q -e 'cat(.libPaths(), sep = ":")')
    echo "Environment variables for R set."
    export SSH_ASKPASS="" ## Otherwise can't push to github
      '';
}
