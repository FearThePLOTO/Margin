# Tests

Headless smoke tests. Run from `margin/`:

```bash
godot --headless res://tests/test_o2.tscn
```

- Runs in game mode (not `-s`) so the autoloads (`EventBus`, `GameState`,
  `BookOfBooks`) are registered like in a real run.
- Exits 0 when everything passes, 1 on any failure — safe to wire into CI.
- `test_o2.gd` covers: the O2 supply (drain as a function of time in the cave,
  NO passive refill outside — pickups only, fail the moment it runs dry inside
  the cave, instant fail on entry without the tool), the scattered tank
  pickups (fixed 30% refill, clamped at full, consumed on contact), the
  mission HUD bars, and the `player_test.tscn` composition (Cave zone + HUD +
  tanks present).
