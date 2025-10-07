{
  description = "nix-darwin system configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };
  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
    }:
    {
      darwinConfigurations."sphealbook" = nix-darwin.lib.darwinSystem {
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "spheal";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };
            };
          }
          (
            { config, ... }:
            {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            }
          )

          (
            { pkgs, ... }:
            {
              nixpkgs.hostPlatform = "aarch64-darwin";
              environment.systemPackages = with pkgs; [
                yabai
                fish
              ];
              homebrew = {
                enable = true;
                casks = [
                  "visual-studio-code"
                  "docker-desktop"
                  "ghostty"
                  "discord"
                  "sol"
                  "arc"
                  "spotify"
                ];

                brews = [
                ];

                onActivation = {
                  cleanup = "zap";
                  autoUpdate = true;
                  upgrade = true;
                };
              };
              nix.package = pkgs.nix;
              nix.settings.experimental-features = "nix-command flakes";
              environment.shells = [ pkgs.fish ];
              system.primaryUser = "spheal";
              system.configurationRevision = self.rev or self.dirtyRev or null;
              system.stateVersion = 5;
              system.defaults = {
                dock.autohide = true;
		NSGlobalDomain.InitialKeyRepeat=6;
		NSGlobalDomain.KeyRepeat=1;
		NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
		NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
		NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
		NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
		dock.orientation = "right";
		dock.persistent-apps = [];
		dock.mru-spaces = true;
                finder.AppleShowAllExtensions = true;
                NSGlobalDomain.AppleShowAllExtensions = true;
              };
              security.pam.services.sudo_local.touchIdAuth = true;
              fonts.packages = with pkgs; [
                nerd-fonts.fira-code
              ];
              programs.fish.enable = true;
              users.users.spheal = {
                name = "spheal";
                home = "/Users/spheal";
                shell = pkgs.fish;
              };
            }
          )
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."spheal" =
              { pkgs, ... }:
              {
                home.stateVersion = "24.05";
                home.username = "spheal";

                home.packages = with pkgs; [
                  jq
                  nixfmt-rfc-style
                  skhd
                  zoxide
                  tree
                  bat
                  lsd
                  alejandra
                  fzf
                  tldr
                  nodejs_22
                  python3
                  rustup
                  neovim
                  chezmoi
                ];

                programs.git = {
                  enable = true;
                  userName = "ByronLi8565";
                  userEmail = "byronli8565@gmail.com";

                  aliases = {
                    co = "checkout";
                    br = "branch";
                    ci = "commit";
                    st = "status";
                  };
                };
                programs.fish = {
                  enable = true;
                  shellAbbrs = {
                    gcm = {
                      expansion = "git commit -m '%'";
                      setCursor = true;
                    };
                    v = "nvim";
                  };

                  shellAliases = {
                    rebuild = "sudo darwin-rebuild switch --flake /Users/spheal/nix-config";
                    ls = "lsd -A";
                  };

                  interactiveShellInit = ''
                    set -gx PATH $HOME/.nix-profile/bin /etc/profiles/per-user/$USER/bin $PATH
                    set fish_greeting
                  '';
                };
                programs.zoxide = {
                  enable = true;
                };
                programs.zsh = {
                  enable = true;
                  initContent = ''
                      if [[ $(ps -o comm= -p $PPID) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
                      # Check if this is a login shell
                      if [[ -o login ]]; then
                        exec ${pkgs.fish}/bin/fish --login
                      else
                        exec ${pkgs.fish}/bin/fish
                      fi
                    fi
                  '';
                };

                programs.starship = {
                  enable = true;
                  settings = {
                    character = {
                      success_symbol = "[λ](bold green)";
                      error_symbol = "[λ](bold red)";
                    };
                  };
                };
              };
          }
        ];
      };
    };
}
