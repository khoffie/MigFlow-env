  # shell.nix

let
  pkgs =  import <nixpkgs> {};
  my-cran-r = (pkgs.rWrapper.override {
         packages = with pkgs.rPackages; [
           sf
           data_table
           ggplot2
           ggthemes
           ggtext
           patchwork
           knitr
           kableExtra
           latex2exp
           devtools
           readxl
           lintr ## for emacs flyspell syntax checker
           ## packages below are for thesis only
           broom
           gridExtra
           gghighlight
           GGally
           scales
           sfheaders
           kableExtra
           yaml
         ];
  });

  helpeR = pkgs.rPackages.buildRPackage {
              name = "helpeR";
              version = "9716630";
              sha256 = "sha256-F2/1IzhobtTpI5O7ZxsHopENNSJ42E22OZO8nZnjGPU=";
              src = pkgs.fetchFromGitHub {
                owner = "khoffie";
                repo = "MigFlow-helpeR";
                rev = "9716630";
                sha256 = "sha256-F2/1IzhobtTpI5O7ZxsHopENNSJ42E22OZO8nZnjGPU=";
              };
              propagatedBuildInputs = with pkgs.rPackages; [
                data_table
                ggplot2
                tinytex
                bookdown
                sf
                patchwork
                ggthemes
                ggtext
                readxl
              ];
  };

  reporteR = pkgs.rPackages.buildRPackage {
             name = "reporteR";
             version = "13f8a47";
             sha256 = "sha256-o4y0iNX3f7ZjM2ngUuenxruDYlpQAkbSvIgK4ZPXx1c=";
             src = pkgs.fetchFromGitHub {
               owner = "khoffie";
               repo = "MigFlow-reporter";
               rev = "13f8a47";
               sha256 = "sha256-o4y0iNX3f7ZjM2ngUuenxruDYlpQAkbSvIgK4ZPXx1c=";
             };
             propagatedBuildInputs = with pkgs.rPackages; [
               data_table
               ggplot2
               sf
               helpeR
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
    reporteR
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
