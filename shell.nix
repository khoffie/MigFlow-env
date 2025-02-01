  # shell.nix

with import <nixpkgs> {};
let
  mig-r = (pkgs.rWrapper.override {
         packages = with pkgs.rPackages; [
            (buildRPackage {
              src = fetchFromGitHub {
                owner = "khoffie";
                name = "MigFlow-helpeR";
                rev = "61b1cbd";
                hash = "sha256-FMXCTpoGdflhdvgbjd8iWGtgLzzYSd7zndiIlS1cqTc=";
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
    mig-r
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
    proj
    sqlite
    geos
    libssh2
    curl
    julia
    mig-r
  ];
  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
  ## RCall does find base r packages with LD_LIBRARY_PATH=${mig-r}/lib/R/lib
  ## Then NIX_LD_LIBRARY_PATH needs to follow so that the currect libcurl version is used
  ##
    shellHook = ''
    export R_HOME="${mig-r}/lib/R"
    export LD_LIBRARY_PATH="${mig-r}/lib/R/lib":$NIX_LD_LIBRARY_PATH
    export R_LIBS_SITE=$(R -q -e 'cat(.libPaths(), sep = ":")')
    echo "Environment variables for R set."
    cd ../mig-code
    julia -e 'using Pkg; Pkg.activate(".")'
  '';

}
