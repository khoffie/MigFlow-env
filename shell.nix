  # shell.nix

with import <nixpkgs> {};
let
  my-r = (pkgs.rWrapper.override {
         packages = with pkgs.rPackages; [
           sf
            (buildRPackage {
              name = "mig-helper"; # The package is stil called helpeR
              version = "61b1cbd";
              sha256 = "sha256-FMXCTpoGdflhdvgbjd8iWGtgLzzYSd7zndiIlS1cqTc=";
              src = fetchFromGitHub {
                owner = "khoffie";
                repo = "MigFlow-helpeR";
                rev = "61b1cbd";
                sha256 = "sha256-FMXCTpoGdflhdvgbjd8iWGtgLzzYSd7zndiIlS1cqTc=";
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
         ];
  });
in
pkgs.mkShell {
  buildInputs = [
    my-r
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
    my-r
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
    cd ../mig-code
    julia -e 'using Pkg; Pkg.activate(".")'
  '';
}
