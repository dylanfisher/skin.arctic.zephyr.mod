# Agent Notes

## Generated files
- Do not edit ignored or generated files unless explicitly requested for local-only debugging.
- In particular, do not modify `1080i/script-skinshortcuts-includes.xml`.
- Treat ignored files as build/runtime artifacts and trace back to the tracked source templates instead.

## Kodi Skin Development

- This repo is a Kodi skin derived from Arctic: Zephyr - Reloaded.
- Primary skin manifest is `addon.xml`.
- Refer to `/docs` for documentation and tips on Kodi skin development.

## Views And XML Cleanup

- When removing a view from a window, update all of the following together:
  - the window's `<views>` list
  - the window's `<defaultcontrol>` if it points at a removed view
  - the `<include>` entries that instantiate that view inside the window
  - any conditional side panels or overlays that only apply to the removed view ids
- Do not leave dead view files or include registrations behind if they are no longer used.
- If a view XML file is no longer referenced anywhere, remove the file and remove its registration from `xml/Includes.xml`.
- After structural cleanup, search for stale references with `rg` before finishing.

## Practical Guardrails

- Prefer deleting obsolete files over keeping unused cruft.
- When simplifying the skin, remove unused assets, views, strings, and include registrations in the same change when practical.
- Before concluding a cleanup change, verify there are no remaining references to removed files, ids, or old branding with `rg`.
