  # shell.nix

with import <nixpkgs> {};
let
  mig-r = (pkgs.rWrapper.override {
         packages = with pkgs.rPackages; [
           sf
         ]; # Include sf inside Nix
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
    curl
    proj
    sqlite
    geos
    libssh2
    mig-r
    julia
  ];
  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
    shellHook = ''
    export R_HOME="${mig-r}/lib/R"
    export R_LIBS="${mig-r}/lib/R/library"
    export LD_LIBRARY_PATH="${mig-r}/lib/R/lib:$LD_LIBRARY_PATH"
    echo "Environment variables for R set."
    julia -e 'using Pkg; Pkg.build("RCall"); using RCall; R".libPaths()"; R"library(sf)"'
  '';

}
