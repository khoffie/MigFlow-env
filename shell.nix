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

  NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.gcc  # ...
    pkgs.gfortran
    pkgs.stdenv
    pkgs.openspecfun
    pkgs.libtiff
    pkgs.proj
    pkgs.sqlite
    pkgs.geos
    pkgs.libssh2
    pkgs.curl # sf and RCall use same then, but ArchGDAL then won't work
    pkgs.julia
    pkgs.gdal
    pkgs.hdf5
    pkgs.librsvg
  ];
  NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  ## RCall does find base r packages with LD_LIBRARY_PATH=${my-r}/lib/R/lib
  ## Then NIX_LD_LIBRARY_PATH needs to follow so that the currect libcurl version is used
  ##
    shellHook = ''
    export R_HOME="${my-cran-r}/lib/R"
    export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:"${my-cran-r}/lib/R/lib"
    export R_LIBS_SITE=$(R -q -e 'cat(.libPaths(), sep = ":")')
    export JULIA_NUM_THREADS=4
    export SSH_ASKPASS=""
    echo "Environment variables for R set."
      '';
}
