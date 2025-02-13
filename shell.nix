  # shell.nix

with import <nixpkgs> {};
let
  my-r = (pkgs.rWrapper.override {
         packages = with pkgs.rPackages; [
           sf
           quarto
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
            (buildRPackage {
              name = "mig-helper"; # The package is stil called helpeR
              version = "b2f36eb";
              sha256 = "sha256-uGp92HJ5g8HpvIMyV6zWrED1dQaqWBICtWQ0vCKY9CY=";
              src = fetchFromGitHub {
                owner = "khoffie";
                repo = "MigFlow-helpeR";
                rev = "b2f36eb";
                sha256 = "sha256-uGp92HJ5g8HpvIMyV6zWrED1dQaqWBICtWQ0vCKY9CY=";
              };
              propagatedBuildInputs = [
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
            })
           (buildRPackage {
             name = "mig-reporter"; # The package is stil called helpeR
             version = "564f674";
             sha256 = "sha256-VGES71j+/7ntHvrtSrDsHC6Gm10NwIguJfNhgOt9pcE=";
             src = fetchFromGitHub {
               owner = "khoffie";
               repo = "MigFlow-reporter";
               rev = "564f674";
               sha256 = "sha256-VGES71j+/7ntHvrtSrDsHC6Gm10NwIguJfNhgOt9pcE=";
             };
             propagatedBuildInputs = [
               data_table
               ggplot2
             ];
           })
         ];
  });
  mig-r =
    (rWrapper.override {
      packages = rpkgs;
    });
  mig-quarto = [
    (quarto.override {
      extraRPackages = rpkgs;
    })
  ];
in
pkgs.mkShell {
  buildInputs = [
    my-r
    quarto
    julia-lts
    curl
    gdal
    proj
    sqlite
    geos
    which
    nix-ld
  ];
  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    gcc  # ...
    gfortran
    stdenv
    openspecfun
    libtiff
    proj
    sqlite
    geos
    libssh2
    curl # sf and RCall use same then, but ArchGDAL then won't work
    julia
    gdal
    hdf5
  ];
  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
  ## RCall does find base r packages with LD_LIBRARY_PATH=${my-r}/lib/R/lib
  ## Then NIX_LD_LIBRARY_PATH needs to follow so that the currect libcurl version is used
  ##
    shellHook = ''
    export R_HOME="${my-r}/lib/R"
    export LD_LIBRARY_PATH="${my-r}/lib/R/lib":$NIX_LD_LIBRARY_PATH
    export R_LIBS_SITE=$(R -q -e 'cat(.libPaths(), sep = ":")')
    echo "Environment variables for R set."
      '';
}
