# Arctic Zephyr with personal modifications

## Deploy To Kodi

The deploy helper supports two workflows over SSH:

- `zip`: package the skin as a Kodi install ZIP and copy it to the Kodi box
- `update`: copy the working tree directly into an existing installed skin directory

### Install From ZIP

Package the skin as a Kodi install ZIP and copy it to a Kodi box:

```bash
./scripts/deploy_kodi_zip.sh
```

By default this copies to `root@192.168.1.128:/storage/downloads`.

This creates `dist/skin.arctic.zephyr.custom-<version>.zip` with `skin.arctic.zephyr.custom/` at the top level, then copies it to the remote directory with `scp`.

On many LibreELEC/CoreELEC installs, `root@<kodi-ip>` and `/storage/downloads` are the right defaults. After copying, install it in Kodi with `Add-ons > Install from zip file`.

Override the host or destination directory if needed:

```bash
./scripts/deploy_kodi_zip.sh zip root@192.168.1.128 /storage/downloads
```

The old invocation without an explicit mode still works and defaults to `zip`:

```bash
./scripts/deploy_kodi_zip.sh root@192.168.1.128 /storage/downloads
```

### Update An Existing Installed Skin

To update an already-installed copy of the skin in place on CoreELEC, copy the current working tree directly into the add-on directory:

```bash
./scripts/deploy_kodi_zip.sh update
```

By default this updates:

```text
root@192.168.1.128:/storage/.kodi/addons/skin.arctic.zephyr.custom
```

Override the host or destination directory if needed:

```bash
./scripts/deploy_kodi_zip.sh update root@192.168.1.128 /storage/.kodi/addons/skin.arctic.zephyr.custom
```

This is useful during development when the skin is already installed and you want to push XML, media, and resource changes without reinstalling from a ZIP. The update mode copies files in place but does not remove remote files that no longer exist locally, so if you intentionally delete tracked skin files you may need to clean those up on the Kodi box manually.

---

Creative Commons Non Commercial 3.0 License
Icon images from iconmonstr.com see website for license terms
Some additional icons from metroicon.net courtesy of Piers
