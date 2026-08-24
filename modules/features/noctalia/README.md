## Updating noctalia

To update the configuration of Noctalia, first make the desired changes in through the Noctalia settings.
After all changes have been made, export the config using the command below:

```nix
nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia/noctalia.json
```

After rebuilding the configuration, the changes are persisted.
