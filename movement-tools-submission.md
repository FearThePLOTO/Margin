# Movement Tools (Raghda)

Four movement tools that open routes the core set (jetpack, tether, climbing spikes) cannot.

**Rules**

- Every real number has a source and an access date (Section 4).

- Game values are design proposals, kept in separate columns, and marked `FLAGGED` until the team approves them.

- Anything not found in a source is marked `UNSOURCED`.

- Source conflicts are written out, not resolved by guessing.

- **Power rule (all tools):** game power = game force × game speed (P = F × v).
- **Decision needed (team):** fantasy tool. Not added (optional). Team decides whether to add one.

---

## 1. Movement Tools Table

Game values in this table. Real values are in the two-number tables below each row group.

| id | tool | mass_kg | power_w | force_n | range_m | speed_ms | setup_min | cost_usd | unlocks | weakness |
|---|---|---|---|---|---|---|---|---|---|---|
| `tool.drone` | Line-Laying Drone | 2.3 (FLAGGED) | 175 (FLAGGED) | 35 (FLAGGED) | 150 (FLAGGED) | 5.0 (FLAGGED) | 0.2 (FLAGGED) | 5000 (FLAGGED) | Long Traverse | Limited payload; needs suitable anchor points |
| `tool.bridge` | Deployable Bridge | 18 (FLAGGED) | N/A | 1765 (FLAGGED) | 6 (FLAGGED) | N/A | 3 (FLAGGED) | 8000 (FLAGGED) | Wide Gap | Needs a trained team and about 6 min to deploy a 30 m span; length fixed by modules |
| `tool.ascender` | Powered Ascender | 6.5 (FLAGGED) | 1440 (FLAGGED) | 1200 (FLAGGED) | 50 (FLAGGED) | 1.2 (FLAGGED) | 0.5 (FLAGGED) | 3500 (FLAGGED) | Vertical Shaft | Battery range caps shaft height per charge; needs a pre-anchored 11 mm rope |
| `tool.winch` | Powered Winch | 10 (FLAGGED) | 300 (FLAGGED) | 10000 (FLAGGED) | 15 (FLAGGED) | 0.03 (FLAGGED) | 1.5 (FLAGGED) | 600 (FLAGGED) | Heavy Lift Cargo | Slow under heavy load; needs a flat, hard mount; rope must keep at least 5 wraps |

---

### 1.1 Line-Laying Drone (`tool.drone`)

**Gameplay role:** Flies a lightweight pilot line between two anchor points. The pilot line can then pull a heavier rope or cable across a gap. It does not carry the astronaut or cargo.

**Real-world reference:** MAV Drones, *SkyStringer Wire Stringing Drone*. **Propulsion note:** The rotor drone in [2] needs air. On the Moon, the night surface pressure is about 3 × 10⁻¹⁵ bar, so it cannot fly there. The power rule (P = F × v) gives 175 W for the game drone, but that number only means something for a motor-driven design. Before the team accepts the 175 W value, it must choose a propulsion method: (a) compressed-gas thrusters, which need tank and thrust values (both UNSOURCED); or (b) a non-flying design, such as a cannon or spool, which changes the tool's name and role. Until the team chooses, the drone's power and mass values stay FLAGGED.

**Decision needed (team):** choose the game propulsion method for the drone: (a) compressed-gas thrusters, or (b) a non-flying design. The drone's power and mass stay FLAGGED until this is chosen.

**Concept reference (not a product spec):** US Patent US10985539B1, *Unmanned aerial vehicle line and cable stringing system* (the drone sheds weight as line is dispensed, and the patent says dragging a lead line needs a large drone). [16]

| id | metric | real_value | game_value | unit | why | source |
|---|---|---|---|---|---|---|
| `tool.drone.mass` | Product weight | 50 | 2.3 | kg | Game value is an inventory mass; real product is much heavier | [2] |
| `tool.drone.allup` | Maximum all-up weight | 95 | N/A | kg | Real only | [2] |
| `tool.drone.propulsion` | Propulsion method | rotors (need air to fly) | compressed gas thrusters (TBD, see note) | type | The real drone cannot fly in near-vacuum. The game version must use a principle that works without air | [2]; UNSOURCED for game choice |
| `tool.drone.tank` | Propellant tank mass and capacity | UNSOURCED | UNSOURCED | kg | No source found for a gas-thruster version of this drone | UNSOURCED |
| `tool.drone.thrust` | Thrust per thruster | UNSOURCED | UNSOURCED | N | No source found | UNSOURCED |
| `tool.drone.motor` | Motor power (manufacturer rating) | 22 | N/A | W | Real only; not used in game | [2] |
| `tool.drone.power` | Power (F × v) | UNSOURCED | 175 (35 × 5.0) | W | Game power follows the rule; FLAGGED | Game design proposal |
| `tool.drone.span` | Stringing span | 250–300 | 150 | m | Game value is the in-level distance; real is "250–300 m and beyond" | [2] |
| `tool.drone.cable` | Supported cable diameter | 2.5–6 | N/A | mm | Real only | [2] |
| `tool.drone.rpm` | Motor speed | 2200 | N/A | RPM | Real only | [2] |
| `tool.drone.force` | Rated line-towing force | UNSOURCED | 35 | N | Game value FLAGGED | UNSOURCED |
| `tool.drone.speed` | Maximum flight speed | UNSOURCED | 5.0 | m/s | Game controllability value; FLAGGED | UNSOURCED |
| `tool.drone.endurance` | Maximum endurance | UNSOURCED | UNSOURCED | min | Not on cited page | UNSOURCED |
| `tool.drone.range` | Maximum operational range | UNSOURCED | UNSOURCED | m | Not on cited page | UNSOURCED |
| `tool.drone.setup` | Setup time | UNSOURCED | 0.2 | min | Game value FLAGGED | UNSOURCED |
| `tool.drone.cost` | Acquisition cost | UNSOURCED | 5000 | game currency | Fictional balance value | UNSOURCED |

---

### 1.2 Deployable Bridge (`tool.bridge`)

**Gameplay role:** Deploys a rigid modular bridge across a gap the player cannot jump. It creates a walking surface, not a rope route.

**Real-world reference:** GDELS, *MAMBA Modular Foot Bridge* [4].

| id | metric | real_value | game_value | unit | why | source |
|---|---|---|---|---|---|---|
| `tool.bridge.load` | Maximum weight per soldier with equipment | 171 | 180 | kg | Certification per soldier, not structural load | [4] |
| `tool.bridge.span` | Maximum span | 30 (dry gap) | 6 | m | Game span is a level-design constraint; real span is up to 30 m, and more with floats | [4] |
| `tool.bridge.setup` | Deployment time, 30 m bridge | 6 | 3 | min | Faster deploy keeps gameplay moving; FLAGGED | [4] |
| `tool.bridge.modules` | Modules per set | 7 | N/A | count | Set also includes 1 float | [4] |
| `tool.bridge.mass` | Module mass | UNSOURCED | 18 | kg | Page says modules "can be carried by hand"; design value, FLAGGED | UNSOURCED |
| `tool.bridge.force.real` | Weight force of 171 kg (171 × 9.80665) | 1677 | N/A | N | Real reference only; not a structural rating | [4] + calculation |
| `tool.bridge.force.game` | Weight force of 180 kg game load (180 × 9.80665) | N/A | 1765 | N | Game load reference; FLAGGED | Game design proposal |
| `tool.bridge.cost` | Acquisition cost | UNSOURCED | 8000 | game currency | Fictional balance value | UNSOURCED |

**Power:** Not applicable. The bridge is deployed by people, not a motor.

---

### 1.3 Powered Ascender (`tool.ascender`)

**Gameplay role:** Raises or lowers the astronaut along a pre-anchored rope. The real product is rated for people and loads; in the game it moves only the player.

**Real-world reference:** SKYLOTEC, *ActSafe ACX Power Ascender* [5][6].

| id | metric | real_value | game_value | unit | why | source |
|---|---|---|---|---|---|---|
| `tool.ascender.mass` | Net weight | 12.5 | 6.5 | kg | Game version lighter for inventory balance | [6] |
| `tool.ascender.wll` | Working Load Limit | 220 | 220 | kg | Real limit used as load cap | [6] |
| `tool.ascender.force` | WLL as weight force (220 × 9.80665) | 2157 | 1200 | N | Game force cap. It binds on Earth only (see cap note below) | [6] + calculation |
| `tool.ascender.speed` | Maximum ascent rate | 0.4 (24 m/min) | 1.2 | m/s | About 3× real rate, so platforming feels responsive; FLAGGED | [6] + design proposal |
| `tool.ascender.descent` | Maximum descent rate | 0.42 (25 m/min) | N/A | m/s | Real only | [6] |
| `tool.ascender.power` | Power at full load (F × v) | 863 (2157 × 0.4) | 1440 (1200 × 1.2) | W | Real value calculated, not manufacturer spec; game value FLAGGED | [6] + calculation |
| `tool.ascender.range` | Battery range at 20 °C, 100 kg | 550 | 50 | m | Game value is designed shaft height, not battery range | [6] |
| `tool.ascender.remote` | Remote control range | 150 | N/A | m | Real only | [6] |
| `tool.ascender.charge` | Charging time | 90 | N/A | min | Real only | [6] |
| `tool.ascender.batteries` | Rechargeable batteries | 2 | N/A | count | Real only | [6] |
| `tool.ascender.ip` | Water and dust protection | IP55 | N/A | rating | Real only | [6] |
| `tool.ascender.temp` | Operating temperature | -10 to 40 | N/A | °C | Real only | [6] |
| `tool.ascender.rope` | Compatible rope diameter | 11 | N/A | mm | Real only | [6] |
| `tool.ascender.setup` | Setup time | UNSOURCED | 0.5 | min | Game assumption, FLAGGED | UNSOURCED |
| `tool.ascender.cost` | Acquisition cost | UNSOURCED | 3500 | game currency | Fictional balance value | UNSOURCED |

**Effective load cap per body (the two caps cannot both bind everywhere):**
- Real cap: WLL = 220 kg (mass, same on every body).
- Game cap: 1200 N (force). On Earth it equals 1200 ÷ 9.80665 ≈ 122 kg, and on the Moon it equals 1200 ÷ 1.62 ≈ 741 kg.

| body | game cap (kg) | WLL (kg) | binding cap | effective load cap |
|---|---|---|---|---|
| Earth | 122 | 220 | game force cap | 122 kg |
| Moon | 741 | 220 | WLL | 220 kg |

So the game force cap only matters on Earth. On the Moon the WLL binds first.

**Decision needed (team):** confirm this is the intended load-cap rule for each body.

**Real safety features (datasheet):** emergency stop and emergency descent are listed. The game does not use either yet.

---

### 1.4 Powered Winch (`tool.winch`)

**Gameplay role:** Hauls cargo along a cable. It moves cargo, not the player.

**Real-world reference:** COMEUP, *Cub 4s Powersports Winch* [7][8].

| id | metric | real_value | game_value | unit | why | source |
|---|---|---|---|---|---|---|
| `tool.winch.mass` | Winch weight including rope | 8.0 | 10.0 | kg | Game version heavier for inventory balance; FLAGGED | [7] |
| `tool.winch.force` | Rated line pull, first layer (1814 kg × 9.80665) | 17789 | 10000 | N | Game value limits cargo | [8] + calculation |
| `tool.winch.force.layers` | Line pull, 2nd / 3rd / 4th layer | 15053 / 13053 / 11513 (from 1535 / 1331 / 1174 kg × 9.80665) | N/A | N | Rating drops on later layers; kg values are from the product page [7], not the manual | [7] + calculation |
| `tool.winch.range` | Rope length | 15.2 | 15.0 | m | Rounded for level design | [8] |
| `tool.winch.rope` | Rope diameter | 5.5 | N/A | mm | Real only | [8] |
| `tool.winch.speed` | Line speed, full load, 12 V (2.0 m/min) | 0.033 | 0.03 | m/s | Slow hauling is the trade-off; FLAGGED | [7] + calculation |
| `tool.winch.power.motor` | Motor rating | 800 | N/A | W | Manufacturer rating; not used in game; see conflict 1 | [7] |
| `tool.winch.power.mech` | Mechanical output at full load (F × v) | 587 (17789 × 0.033) | N/A | W | Calculated from real values | [7][8] + calculation |
| `tool.winch.power` | Power (F × v) | 587 (see above) | 300 (10000 × 0.03) | W | Game value lower than real mechanical output, by design; FLAGGED | Game design proposal |
| `tool.winch.current` | Current draw, full load, 12 V | 230 | N/A | A | Manufacturer value. Independent support not verified (see Section 4) | [7] |
| `tool.winch.setup` | Setup time | UNSOURCED | 1.5 | min | Game value FLAGGED | UNSOURCED |
| `tool.winch.cost` | Acquisition cost | UNSOURCED | 600 | game currency | Fictional balance value | UNSOURCED |

**Open conflict 1 (motor rating vs current):** At 12 V, 230 A at full load gives about 2,760 W of electrical input, roughly 3.5× the 800 W motor rating. The source does not explain this. One possibility is that 800 W is a nominal or mechanical rating. Full-load mechanical output (587 W) is about 73% of 800 W, a plausible efficiency. 587 W is about 21% of the 2,760 W electrical input, so about 79% of the electrical input is unexplained by the mechanical output. The game uses the power rule, not 800 W.

**Open conflict 2 (rope wraps):** The manual [8] says at least 5 wraps must remain on the drum. The product page [7] says 10. This file uses the manual as primary. The team may choose 10 as the game value (more conservative).

**Decision needed (team):** conflict 1 (800 W vs 230 A) and conflict 2 (5 vs 10 wraps). Choose a game value for wraps. Conflict 1 can stay open, since the game does not use 800 W.

**Safety limit:** The manual states the winch is not intended for lifting or moving people.

---

## 2. Book Entries

### 2.1 book.low_gravity: Low Gravity

**Principle:** Mass stays the same, but weight depends on gravity. The Moon's surface gravity is about 1.62 m/s², roughly one-sixth of Earth's. An object with the same mass weighs about one-sixth as much on the Moon.

**Formula:** h = v² / (2g). The same launch speed takes you much higher on the Moon.

**What the player changes:** Push strength, launch angle, and the load they carry.

**Game effect:** At a launch speed of 3 m/s, a jump on Earth reaches about 0.46 m, and on the Moon about 2.78 m, roughly six times higher. This opens routes that were impossible on Earth. The ascender lifts a heavier load with the same force, the winch lifts about six times more mass vertically, and the bridge carries a much smaller load.

**Trade-off:** Light weight does not always mean easier movement. Motion is faster and longer in the air, and the player needs more control, because a small extra push can send them a long way.

**Counter:** A heavy load on the Moon still has its full mass and inertia. Spread it across several anchor points so it does not drag equipment out of place.

**Linked tools:** ascender, winch, bridge, drone (gravity affects the first three; the drone is covered by atmosphere, see the table).

**Sources:** [1]

**Tool effect table (team data):**

| tool | effect on the Moon | value | source |
|---|---|---|---|
| `tool.ascender` | Energy to climb a given height (E = mgh) | About 1/6 of Earth's value | [1]; calculation |
| `tool.winch` | Mass lifted vertically at the same pulling force | About 6× Earth's value | [1]; calculation |
| `tool.bridge` | Load from the same mass | 292 N on the Moon for a 180 kg game load (1765 N on Earth; 180 × 1.62 = 291.6) | [1]; calculation; FLAGGED |
| `tool.drone` | Propulsion. The real SkyStringer uses rotors, which need air to produce lift. The Moon has almost no atmosphere (night surface pressure 3 × 10⁻¹⁵ bar), so the real design cannot fly there. The game version needs a different propulsion (see 1.1). | Not a gravity effect. Blocker for the rotor design | [1] (atmosphere section); [2] (rotor design) |

**Team note:** The drone is not covered by gravity. Its problem is the lack of atmosphere.

---

### 2.2 book.work_power: Work and Power

**Principle:** Work is force multiplied by distance. Power is the rate of doing work, meaning work per second. Lifting the same load faster needs more power, even though the total work is the same.

**Formula:** P = F × v

**What the player changes:** Speed and pulling load. Raising the speed under the same load raises the power needed.

**Game effect:** At full load, the real winch delivers about 587 W of mechanical output (17,789 N × 0.033 m/s). The real ascender delivers about 863 W at full load (2,157 N × 0.4 m/s). Both are calculations from manufacturer values, not rated powers. The human body also has a limit. On a 30% grade traverse, test subjects reached peak metabolic rates of about 485–512 W, converted from 1,656 and 1,747 BTU/hr [9][3]. That is energy burned by the body, not mechanical power, so the two figures must not be compared directly.

**Trade-off:** Speed saves time but costs energy and drains the battery faster. The winch slows as the load grows, from 4.6 m/min with no load to 2.0 m/min at full load.

**Counter:** Split the task and take rest breaks. Average work on the Moon was 31–36% of peak aerobic capacity, inside the sustainable range of 30–40% [10]. But the heaviest single xEMU tasks averaged 45–47%, and individual peaks reached 60–69%. Long routes and heavy tasks should be split into shorter stages.

**Linked tools:** winch, ascender, drone, bridge.

**Sources:** [2][3][6][7][8][9][10]

**Tool power table (team data):**

| tool | what is affected by power | real value | game value | source |
|---|---|---|---|---|
| `tool.winch` | Mechanical output at full load (F × v) | 587 W (17,789 N × 0.033 m/s) | 300 W (10,000 N × 0.03 m/s) | [7][8]; calculation |
| `tool.winch` | Rated motor power | 800 W | Not used in game | [7] |
| `tool.ascender` | Power at full load (F × v) | 863 W (2,157 N × 0.4 m/s) | 1,440 W (1,200 N × 1.2 m/s) | [6]; calculation |
| `tool.drone` | Rated motor power | 22 W | 175 W (35 N × 5 m/s) | [2]; calculation |
| `tool.bridge` | No motor; deployment is by people | 485–512 W metabolic at peak effort | Not applicable | [9]; [3] |

**Team note:** The 587 W and 863 W figures are calculated from manufacturer values. The 485–512 W figure is converted from BTU/hr using NIST SP 811 [3]. The BTU/hr figures are the paper's maximum values, not averages. Game power values follow P = F × v.

---

### 2.3 book.load_paths: Load Paths

**Principle:** Load travels from the load point to the anchor along a path. Every element on that path (rope, beam, anchor) must carry the force passing through it, and the weakest one sets the limit.

**Formulas:**

- Rope tension under a steady load: T = m × g. On the Moon, g = 1.62 m/s², so a 220 kg load pulls the rope with about 356 N.

- Bending moment in a simply supported beam with a load at midspan: M = F × L / 4 [12][13].

- Bending stress (Hibbeler, 9th/11th ed., section 6.4; page to be checked in the team's copy): σ = M × y / I (at the outer fibre, y = c, so σ_max = M × c / I) [11][11b].

**What the player changes:** Anchor points, their number, and where the load sits.

**Game effect:** The ascender carries up to 220 kg (WLL), about 356 N on the Moon. The winch pulls 17,789 N on its first rope layer. Newton force does not change with gravity, but the mass it moves does. Pull drops on later layers, for example 1,535 kg on the second (≈ 15,053 N, product page [7]). A load at midspan gives the bridge its largest bending moment.

**Trade-off:** One anchor is faster to set up but carries the whole load. Several anchors share it but take longer.

**Counter:** Spread the load across several anchors, and use rotational stabilization on the winch [14].

**Linked tools:** ascender, winch, bridge, drone.

**Sources:** [4][6][7][8][11][12][13][14][15]

**Load path table (team data):**

| Path element | Quantity | Real value | Game value | Source |
|---|---|---|---|---|
| `tool.ascender` (load on rope) | Working Load Limit | 220 kg = 356 N on the Moon (220 × 1.62) | 1,200 N (≈ 741 kg on the Moon, 1200 ÷ 1.62); FLAGGED | [6]; calculation; rope under load: [15] |
| `tool.winch` (cable) | Line pull, first layer | 17,789 N (force does not change with gravity) | 10,000 N | [8] |
| `tool.winch` (cable) | Line pull, second layer | 15,053 N (1,535 kg × 9.80665) | Not used | [7]; calculation |
| `tool.winch` (cable) | Rope length | 15.2 m | 15 m | [8] |
| `tool.winch` (rope) | Rope diameter | 5.5 mm | Not used | [8] |
| `tool.bridge` (load on bridge) | Soldier with equipment, on the Moon | 171 kg = 277 N | 180 kg = 292 N | [4]; calculation |
| `tool.bridge` (bending moment, 30 m vs 6 m) | M = F × L / 4 | 2,078 N·m (30 m span) | 437 N·m (6 m span) | calculation [12][13] |
| `tool.drone` (pilot line) | Line diameter | 2.5 mm | Not specified | [2] |
| `tool.drone` (line load) | Allowed load | UNSOURCED | UNSOURCED | No source |
| Anchor (picket), fixing point, not a tool | Allowed pull | UNSOURCED | UNSOURCED | [14] mentions anchors with no numbers |

**Team note:** The beam calculation is an example of the method, not a structural check of the bridge. Moon values (g = 1.62): real bridge (171 kg, 30 m) M ≈ 2,078 N·m (Earth: 12,581); game bridge (180 kg, 6 m) M ≈ 437 N·m (Earth: 2,649). Any game calculation must be labeled as a design choice.

---

## 3. Crafting Table

**Rules**
- Inputs come only from the material table of the body where they are found (for example, Moon: Mo3tez's table; Mars: Ahmed Walid's table). Any material not in that body's table is `FLAGGED`, not invented.
- Each tool unlocks one specific thing: a shaft, a gap, a cargo route, or a long traverse. "Better stats" is not an unlock.
- Values are not hard-coded to the Moon. Mass is constant across environments; weight and other environment-dependent values use factors.

### 3.1 Environment factors (any celestial body)

| body | g (m/s²) | g_factor = g ÷ 9.80665 | source |
|---|---|---|---|
| Earth | 9.80665 | 1.000 (reference) | [3] (NIST standard gravity; the NSSDC Moon sheet [1] rounds it to 9.80) |
| Moon | 1.62 | 0.165 | [1] |
| Mars | 3.73 (mean surface) | 0.380 | [17] |

**Note:** The Moon is a natural satellite, not a planet, so this table is named by celestial body. All g values come from NASA fact sheets and use the mean surface value. For any new body, use the same type of source.

Any celestial body (planet, moon, or other) is a row in this table. A new body needs only its surface gravity from a NASA fact sheet; no other values change.

### 3.2 Crafting formulas

- **mass_kg:** constant. Not multiplied by any environment factor.
- **weight_N:** mass_kg × 9.80665 × g_factor. This is the only value that changes with the environment.
- **energy_kwh:** base_energy × material_factor. `FLAGGED`, pending the body's material table.
- **cost_usd:** base_cost × purity_factor. `FLAGGED`, pending the body's material table.

**Open decision for the team:** whether base_energy and base_cost are defined on Earth or on the Moon. This sets the value the factors multiply.

### 3.3 Crafting table

| tool | inputs | mass_kg | energy_kwh | cost_usd | station_tier | unlocks |
|---|---|---|---|---|---|---|
| `tool.drone` | FLAGGED: no body table received yet | 2.3 (game value, FLAGGED) | FLAGGED | FLAGGED | FLAGGED | Long Traverse |
| `tool.bridge` | FLAGGED: no body table received yet | 18 (game value, FLAGGED) | FLAGGED | FLAGGED | FLAGGED | Wide Gap |
| `tool.ascender` | FLAGGED: no body table received yet | 6.5 (game value, FLAGGED) | FLAGGED | FLAGGED | FLAGGED | Vertical Shaft |
| `tool.winch` | FLAGGED: no body table received yet | 10 (game value, FLAGGED) | FLAGGED | FLAGGED | FLAGGED | Heavy Lift Cargo |

**Note:** mass_kg values come from Section 1 (game values). They are constant across environments, so they do not change in this table.

**Decision needed (team):** the Mars material list is received (Ahmed Walid's Mars research), but purity, energy, cost, tool inputs, and station tier are still missing from it. Moon materials are still pending Mo3tez's table. Any other body waits for its owner's table.

### 3.4 Material factors

**Moon materials (Mo3tez's table).** Not received yet. This table stays empty until it arrives. Inputs, purity, energy, and cost for any Moon-based item stay `FLAGGED`.

**Scope rule (applies to every body):** Each body's row in 3.1 gives gravity only. Materials for each body come only from that body's own material table. Until a body's table is received, its inputs stay `FLAGGED`.

**Other bodies:** add a new subsection here when a body's table is received, using the same format as Mars.

**Mars materials (Ahmed Walid's Mars research).** Source numbers in the table refer to Ahmed Walid's Mars research source list, not this file's list. Purity factors are TBD. Found-at locations are from Ahmed Walid's Mars research and are not yet tied to any tool.

| id | material | real | found at (Mars) | Mars research source | purity_factor | status |
|---|---|---|---|---|---|---|
| `material.regolith` | Regolith / soil | yes | Surface, varies by site | Mars research [1] | TBD | FLAGGED |
| `material.iron_oxide` | Iron-bearing oxides | yes | Soil and rocks, site-dependent | Mars research [9], Mars research [10] | TBD | FLAGGED |
| `material.dust` | Fine airborne dust | yes | Atmosphere and surface | Mars research [4], Mars research [20], Mars research [22] | TBD | FLAGGED |
| `material.sulfates` | Sulfate minerals | yes | Selected soils and rocks | Mars research [9], Mars research [11] | TBD | FLAGGED |
| `material.clays` | Clay minerals | yes | Ancient aqueous terrains | Mars research [11], Mars research [12] | TBD | FLAGGED |
| `material.water_ice` | Water ice | yes | Polar and high-latitude subsurface (latitude-dependent) | Mars research [2], Mars research [13], Mars research [31], Mars research [32] | TBD | FLAGGED |
| `material.co2_ice` | CO₂ ice | yes | Seasonal polar caps | Mars research [2] | TBD | FLAGGED |
| `material.co2_atmosphere` | Atmospheric CO₂ | yes | Atmosphere (about 95.1% by volume) | Mars research [1], Mars research [3], Mars research [33] | TBD | FLAGGED |
| `material.perchlorate` | Perchlorate salts | yes (hazard) | Multiple sites; not safe to assume | Mars research [9], Mars research [14], Mars research [34], Mars research [35] | TBD | FLAGGED |

**Decision needed (team, with Ahmed Walid):** perchlorate is listed as a material in Ahmed Walid's Mars research and also as a hazard. Confirm whether it is a crafting input or a hazard only.

**Not included as real materials:** `material.ferric_sinter` and `material.aerogel_salt` are fictional (`real = no`) and stay out of the crafting inputs unless the team decides otherwise.

**Purity factor:** `purity_factor` is not in Ahmed Walid's Mars materials table. No purity values exist for any Mars material yet, so every `purity_factor` in this section stays TBD. Values come from each body's own material table (Moon: Mo3tez; Mars: Ahmed Walid, if he adds it). Until then, `cost_usd` and `energy_kwh` cannot be scaled by purity.

**GU values:** Ahmed Walid's Mars research gives crafting costs in game units (GU). They are not USD and must not go into `cost_usd` without a team decision.

**Decision needed (team):** whether GU values go into `cost_usd` or stay a separate game currency.

## 4. Sources and Gaps

All sources accessed 2026-10-21.

1. NASA Goddard, *Moon Fact Sheet*. https://nssdc.gsfc.nasa.gov/planetary/factsheet/moonfact.html
2. MAV Drones, *SkyStringer Wire Stringing Drone*. https://www.mavdrones.com/product/skystringer-wire-stringing-drone/
3. NIST, *Guide for the Use of the International System of Units (SI)*, SP 811, Appendix B.8, p. 45 (BtuIT = 1.055 056 × 10³ J, so 1 BTU/hr = 0.293071 W). http://physics.nist.gov/Pubs/SP811/appenB8.html
4. GDELS, *MAMBA Modular Foot Bridge*. https://www.gdels.com/en/products/bridge-systems/mamba
5. SKYLOTEC, *ActSafe ACX Power Ascender*, product page. https://www.skylotec.com/int_en/ACTSAFE-ACX-POWER-ASCENDER/P-POA-001
6. SKYLOTEC, *ActSafe ACX Power Ascender*, datasheet. https://mediaservice.skylotec.com/v2/clients/2/sources/13/files/4384711?public=true&download=true&website=true
7. COMEUP Industries, *Cub 4s Powersports Winch*, product page. https://www.comeupwinch.com/products-view.php?ID=120
8. COMEUP Industries, *Powersports Winch Model Cub 4s*, user manual (PN 129410, Ver. 11). Uploaded file.
9. Schlotman et al., *A Preliminary Assessment of Physical Demand during Simulated Lunar Surface Extravehicular Activities*, IEEE Aerospace Conference 2023, NASA NTRS 20220009964. https://ntrs.nasa.gov/citations/20220009964
10. Strock et al., *Evaluation of Aerobic Capacity in Relation to Simulated Lunar Surface Extravehicular Activities*, AsMA 2024 poster, NASA NTRS 20230014953. https://ntrs.nasa.gov/citations/20230014953
11. MATHalino, *Flexure Formula* (derivation of σ = My/I and σ_max = Mc/I). https://mathalino.com/reviewer/mechanics-and-strength-of-materials/flexure-formula . Accessed 2026-10-21.
11b. Hibbeler, R. C., *Mechanics of Materials*, SI Edition, 11th ed. (Pearson, 2024), Section 6.4 "The Flexure Formula". Printed book; no free online link. Section and page to be verified in the team's copy or a library copy.
12. CEC lecture notes, Mechanics of Structures II, Lecture 3 (M = Wl/4). https://cec.nic.in/webpath/curriculum/Module/Arch/Paper08/3/downloads/script.pdf
13. WJEC, *Structural analysis and building comfort* (WL/4 for central point load, kNm). https://resource.download.wjec.co.uk/vtc/2020-21/qw20-21_2-9/ENG/2.3.4_structural_analysis_and_building_comfort.pdf
14. NASA NTRS 20060050772, *Haughton-Mars Project/NASA 2006 Lunar Medical Contingency Simulation* (winch, picket anchors, rotational stabilization; no anchor pull values). https://ntrs.nasa.gov/citations/20060050772
15. NASA NTRS 20210012162, *Design and Test of an Electromechanical Rover Tether for the Exploration of Vertical Lunar Pit* (JPL preprint; 100 W, 1 Mbps, 300 m traverse; tether under load in contact with terrain). https://ntrs.nasa.gov/citations/20210012162
16. US Patent US10985539B1, *Unmanned aerial vehicle line and cable stringing system* (concept reference only). https://patents.google.com/patent/US10985539B1/en
17. NASA NSSDC, *Mars Fact Sheet* (mean surface gravity 3.73 m/s²; equatorial 3.69; pole 3.73). https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html?embed=true . Accessed 2026-10-21. Some other copies of the same sheet quote 3.71 m/s².


**Not yet sourced:**

- Hibbeler or Roark for the beam formulas, with edition and page.

**Gaps**

- Drone: endurance, operational range, flight speed, rated line-towing force, setup time, cost.

- Bridge: module mass, cost.

- Ascender: setup time, cost.

- Winch: setup time, cost; open conflicts 1 and 2.

- Crafting table: Section 3 (not started; needs the material table of each body, starting with Mo3tez's Moon table).

- Fantasy option: none added (optional).