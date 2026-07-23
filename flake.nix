{
  description = "Home Manager configuration of kitagawa_zempei";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hunk.url = "github:modem-dev/hunk";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      hunk,
      ...
    }:
    let
      username = "kitagawa_zempei";
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        # 1Password CLI（unfree）のみ許可。他のunfreeパッケージは引き続き拒否。
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "1password-cli" ];
      };
    in
    {
      homeConfigurations."kitagawa_zempei" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit username;
          hunkPackage = hunk.packages.${system}.default;
        };
      };
    };
}
