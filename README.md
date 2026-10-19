# Margin

Design the loadout. Fly the mission. Read the failure.

Margin is a lunar mission design game for the NASA Space Apps Challenge 2026, Cairo. The player works from a station hub: pick an objective, build a loadout under mass and budget limits, fly the mission, and read a debrief that explains what worked and what failed. Every failure writes a note into the Book of Books.

## Setup

Once, after cloning:

```bash
pip install --user pre-commit   # or: pipx install pre-commit
pre-commit install
```
This is necessary since you will deal with pre-commits in the future too.

This wires up the git hook from `.pre-commit-config.yaml`, which refuses commits made directly on `main`. Branch first, then open a pull request. To run the checks by hand: `pre-commit run --all-files`.


## What goes here

- Design notes, research, and the game rules before the hackathon.
- The game itself, built during the hackathon on Nov 14 and 15.
- The demo and submission material.

## Status

Research and design. No playable build yet.
