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
    # export R_LIBS="${mig-r}/lib/R/library"
    ## export LD_LIBRARY_PATH="${mig-r}/lib/R/lib:$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH"

    export LD_LIBRARY_PATH="${mig-r}/lib/R/lib":$NIX_LD_LIBRARY_PATH
    export R_LIBS_SITE=$(R -q -e 'cat(.libPaths(), sep = ":")')
    echo "Environment variables for R set."

    echo "This is LD_LIBRARY_PATH $(printenv LD_LIBRARY_PATH)"
    julia -e 'using Pkg; Pkg.build("RCall"); using RCall; R".libPaths()"; R"library(sf)"'
  '';

}
