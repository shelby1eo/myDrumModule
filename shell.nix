# nixsAhell to open this shell
# https://fasterthanli.me/series/building-a-rust-service-with-nix/part-10

# enter a shell with a package
# nix-shell -p nodejs

# enter a shell with a package (nix-command)
# nix shell nixpkgs#nodejs

# warning!!! this flake is not self contained, it contains only the dependencies to rust, ther rest of the system dependencis are set by the system flake

{ pkgs ? import <nixpkgs> {} }:
  let
    overrides = (builtins.fromTOML (builtins.readFile ./rust-toolchain.toml));
    libPath = with pkgs; lib.makeLibraryPath [
      # load external libraries that you need in your rust project here
    ];
in
  pkgs.mkShell rec {
    # inputsFrom = [ pkgs.bat ]; # should import dependencies of specified packages

    buildInputs = with pkgs; [
      clang
      # Replace llvmPackages with llvmPackages_X, where X is the latest LLVM version (at the time of writing, 16)
      llvmPackages.bintools
      rustup
      lldb
      graphviz
      godot
      # nixgl.nixGLNvidia
      # nixgl.Default
      # nixgl.nixGLIntel

    ];
    RUSTC_VERSION = overrides.toolchain.channel;
    # https://github.com/rust-lang/rust-bindgen#environment-variables
    LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
    shellHook = ''
      export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
      export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
      zsh
      '';
    # Add precompiled library to rustc search path
    RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
      # add libraries here (e.g. pkgs.libvmi)
    ]);
    LD_LIBRARY_PATH = libPath;
    # Add glibc, clang, glib, and other headers to bindgen search path
    BINDGEN_EXTRA_CLANG_ARGS =
    # Includes normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      # add dev libraries here (e.g. pkgs.libvmi.dev)
      pkgs.glibc.dev
    ])
    # Includes with special directory paths
    ++ [
      ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
    ];
  }
