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
  ## RCall does find base r packages with LD_LIBRARY_PATH=${mig-r}/lib/R/lib
    shellHook = ''
    export R_HOME="${mig-r}/lib/R"
    export R_LIBS="${mig-r}/lib/R/library"
    ## export LD_LIBRARY_PATH="${mig-r}/lib/R/lib:$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${mig-r}/lib/R/lib:${mig-r}/lib/R/library"
##    export R_LIBS_SITE="/nix/store/5x6z38v3py7gp53il5y0z0lr8nh77b8g-r-boot-1.3-30/library:/nix/store/k3nxxmig6jqamch7d5dg7f2wq5ifasb4-r-class-7.3-22/library:/nix/store/x0z14280a7wy5jl9xbyqrm6qwh6l5mpn-r-MASS-7.3-61/library:/nix/store/70g33hdx8can40clygri6n99h4kjhwqh-r-cluster-2.1.6/library:/nix/store/g9gw4f2qr4l4qm4c3i5f85lqppcr9v5w-r-codetools-0.2-20/library:/nix/store/kmad83djlfmyxvl1kh1lk057rzix8mm3-r-foreign-0.8-87/library:/nix/store/c2f0xcfslphrhxrbq9ch4j85qvggwf25-r-KernSmooth-2.23-24/library:/nix/store/5c0606hkk7vwsc9dyj104sdbzsnbxdsy-r-lattice-0.22-6/library:/nix/store/zwzr5fsiggjkr736n1ih6q6c2j6m3mbj-r-Matrix-1.7-0/library:/nix/store/z8li4k486rga0pnkca5riwg72h9fy92h-r-mgcv-1.9-1/library:/nix/store/8prwcjmaayg1049zghilbqh3jbkqra2k-r-nlme-3.1-166/library:/nix/store/5gk584cfyidvp30py976z4sd0l3ik21f-r-nnet-7.3-19/library:/nix/store/dx08rdhaxz9bdjf4492900dbp62d99bs-r-rpart-4.1.23/library:/nix/store/ii50yjy1gxli5nr02iv8543kwgby2902-r-spatial-7.3-17/library:/nix/store/353xs1f9dslhkdjppc6y5dd3yl73xphd-r-survival-3.7-0/library:/nix/store/39difnz4hf9n9hgsssla34fp3z3kd8k5-r-sf-1.0-16/library:/nix/store/5rqga38my4yqs1mrg5sncsmfqlcmzz8n-r-DBI-1.2.3/library:/nix/store/sci3qnzgzxq17227dqpmjr3x9z9kfvm3-r-Rcpp-1.0.13/library:/nix/store/p55mwfj5z5q2x0qiy49hhyzv4pwkjrgn-r-classInt-0.4-10/library:/nix/store/sil305nmdqmpq2y9jbmzmgdkamfgrfaf-r-e1071-1.7-14/library:/nix/store/mk3c9xyv4jxh785ifjzy1f5ssxmqvgj4-r-proxy-0.4-27/library:/nix/store/cyswy8gfn88lsqsbfqw72lbn4d92x136-r-magrittr-2.0.3/library:/nix/store/jccy3rnj0qvn3j67sk7lnsd0ln4cdx10-r-s2-1.1.7/library:/nix/store/6r6sq6dn8bixmhzlhr2jvfg6r4vb781x-r-wk-0.9.2/library:/nix/store/52sal5vgz4vkcfb4z97hpbrgp5zldp7s-r-units-0.8-5/library:/nix/store/49zb8nh5ax57rdv09d6clpas8a6nqkjb-R-4.4.1-wrapper/lib/R/site-library"
    export R_LIBS_SITE=$(R -q -e 'cat(Sys.getenv("R_LIBS_SITE"))')
    echo "Environment variables for R set."
    echo "This is LD_LIBRARY_PATH $(printenv LD_LIBRARY_PATH)"
    julia -e 'using Pkg; Pkg.build("RCall"); using RCall; R".libPaths()"; R"library(sf)"'
  '';

}
