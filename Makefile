switch:
	nixos-rebuild switch --flake .# --use-remote-sudo

debug:
	nixos-rebuild switch --flake .# --use-remote-sudo --show-trace --verbose

update:
	nix flake update

history:
	nix profile history --profile /nix/var/nix/profiles/system

switch-home:
	home-manager switch --flake .#tygo@aerial
