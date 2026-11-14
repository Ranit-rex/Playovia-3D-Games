# Playovia 3D Games

Three original browser-based 3D game prototypes for Playovia.

## Worlds
- **Street Racer** — steer through a neon city, dodge traffic and survive.
- **Island Adventure** — explore a small island and collect eight crystals.
- **Neon Arena** — first-person target practice with moving targets.

## Tech and assets
Built with Three.js (MIT) and original procedural geometry/materials. No third-party art assets are bundled. This avoids external asset licensing dependencies in this first playable build.

## Controls
- **Racer / Adventure:** WASD or arrow keys. Touch buttons are available on mobile.
- **Arena:** WASD to move; mouse to aim and click to fire. On touch screens, drag to aim and tap FIRE.

## Deploy
The repository includes a GitHub Actions Pages workflow. In GitHub, open **Settings → Pages** and set **Build and deployment → Source** to **GitHub Actions**. The workflow will publish the site on pushes to `main`.

After the first successful deployment, the game launcher is:
`https://ranit-rex.github.io/Playovia-3D-Games/`

Playovia's game library has entries for all three worlds and opens each world directly by URL.

## Note
These are early playable single-player prototypes, not online multiplayer or production-scale games. Three.js is loaded from jsDelivr, so an internet connection is required.
