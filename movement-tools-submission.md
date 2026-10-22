# Movement Tools

Four movement tools that open routes the core set (jetpack, tether, climbing spikes) cannot.

**Rules**

- Every real number has a source and an access date (Section 4).

- Game values are design proposals, kept in separate columns, and marked `FLAGGED` until the team approves them.

- Anything not found in a source is marked `UNSOURCED`.

- Source conflicts are written out, not resolved by guessing.

- **Power rule (all tools):** game power = game force × game speed (P = F × v).

---

## 1. Movement Tools Table

Game values in this table. Real values are in the two-number tables below each row group.

| id | tool | mass_kg | power_w | force_n | range_m | speed_ms | setup_min | cost_usd | unlocks | weakness |
|---|---|---|---|---|---|---|---|---|---|---|
| `tool.drone` | Line-Laying Drone | 2.3 (FLAGGED) | 175 (FLAGGED) | 35 (FLAGGED) | 150 (FLAGGED) | 5.0 (FLAGGED) | 0.2 (FLAGGED) | 5000 (FLAGGED) | Long Traverse | Limited payload; needs suitable anchor points |
| `tool.bridge` | Deployable Bridge | 18 (FLAGGED) | N/A | 1766 (FLAGGED) | 6 (FLAGGED) | N/A | 3 (FLAGGED) | 8000 (FLAGGED) | Wide Gap | Needs a trained team and about 6 min to deploy a 30 m span; length fixed by modules |
| `tool.ascender` | Powered Ascender | 6.5 (FLAGGED) | 1440 (FLAGGED) | 1200 (FLAGGED) | 50 (FLAGGED) | 1.2 (FLAGGED) | 0.5 (FLAGGED) | 3500 (FLAGGED) | Vertical Shaft | Battery range caps shaft height per charge; needs a pre-anchored 11 mm rope |
| `tool.winch` | Powered Winch | 10 (FLAGGED) | 300 (FLAGGED) | 10000 (FLAGGED) | 15 (FLAGGED) | 0.03 (FLAGGED) | 1.5 (FLAGGED) | 600 (FLAGGED) | Heavy Lift Cargo | Slow under heavy load; needs a flat, hard mount; rope must keep at least 5 wraps |

---

### 1.1 Line-Laying Drone (`tool.drone`)

**Gameplay role:** Flies a lightweight pilot line between two anchor points. The pilot line can then pull a heavier rope or cable across a gap. It does not carry the astronaut or cargo.

**Real-world reference:** MAV Drones, *SkyStringer Wire Stringing Drone*. **Concept reference (not a product spec):** US Patent US10985539B1, *Unmanned aerial vehicle line and cable stringing system* (the drone sheds weight as line is dispensed, and the patent says dragging a lead line needs a large drone).

| id | metric | real_value | game_value | unit | why | source |
|---|---|---|---|---|---|---|
| `tool.drone.mass` | Product weight | 50 | 2.3 | kg | Game value is an inventory mass; real product is much heavier | [2] |
| `tool.drone.allup` | Maximum all-up weight | 95 | N/A | kg | Real only | [2] |
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
| `tool.bridge.force.real` | Weight force of 171 kg (171 × 9.81) | 1677 | N/A | N | Real reference only; not a structural rating | [4] + calculation |
| `tool.bridge.force.game` | Weight force of 180 kg game load (180 × 9.81) | N/A | 1766 | N | Game load reference; FLAGGED | Game design proposal |
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
| `tool.ascender.force` | WLL as weight force (220 × 9.81) | 2158 | 1200 | N | Game value limits astronaut plus equipment | [6] + calculation |
| `tool.ascender.speed` | Maximum ascent rate | 0.4 (24 m/min) | 1.2 | m/s | About 3× real rate, so platforming feels responsive; FLAGGED | [6] + design proposal |
| `tool.ascender.descent` | Maximum descent rate | 0.42 (25 m/min) | N/A | m/s | Real only | [6] |
| `tool.ascender.power` | Power at full load (F × v) | 863 (2158 × 0.4) | 1440 (1200 × 1.2) | W | Real value calculated, not manufacturer spec; game value FLAGGED | [6] + calculation |
| `tool.ascender.range` | Battery range at 20 °C, 100 kg | 550 | 50 | m | Game value is designed shaft height, not battery range | [6] |
| `tool.ascender.remote` | Remote control range | 150 | N/A | m | Real only | [6] |
| `tool.ascender.charge` | Charging time | 90 | N/A | min | Real only | [6] |
| `tool.ascender.batteries` | Rechargeable batteries | 2 | N/A | count | Real only | [6] |
| `tool.ascender.ip` | Water and dust protection | IP55 | N/A | rating | Real only | [6] |
| `tool.ascender.temp` | Operating temperature | -10 to 40 | N/A | °C | Real only | [6] |
| `tool.ascender.rope` | Compatible rope diameter | 11 | N/A | mm | Real only | [6] |
| `tool.ascender.setup` | Setup time | UNSOURCED | 0.5 | min | Game assumption, FLAGGED | UNSOURCED |
| `tool.ascender.cost` | Acquisition cost | UNSOURCED | 3500 | game currency | Fictional balance value | UNSOURCED |

**Real safety features (datasheet):** emergency stop and emergency descent are listed. The game does not use either yet.

---

### 1.4 Powered Winch (`tool.winch`)

**Gameplay role:** Hauls cargo along a cable. It moves cargo, not the player.

**Real-world reference:** COMEUP, *Cub 4s Powersports Winch* [7][8].

| id | metric | real_value | game_value | unit | why | source |
|---|---|---|---|---|---|---|
| `tool.winch.mass` | Winch weight including rope | 8.0 | 10.0 | kg | Game version heavier for inventory balance; FLAGGED | [7] |
| `tool.winch.force` | Rated line pull, first layer (1814 kg × 9.81) | 17795 | 10000 | N | Game value limits cargo | [8] + calculation |
| `tool.winch.force.layers` | Line pull, 2nd / 3rd / 4th layer | 15058 / 13057 / 11517 (from 1535 / 1331 / 1174 kg × 9.81) | N/A | N | Rating drops on later layers; kg values are from the product page [7], not the manual | [7] + calculation |
| `tool.winch.range` | Rope length | 15.2 | 15.0 | m | Rounded for level design | [8] |
| `tool.winch.rope` | Rope diameter | 5.5 | N/A | mm | Real only | [8] |
| `tool.winch.speed` | Line speed, full load, 12 V (2.0 m/min) | 0.033 | 0.03 | m/s | Slow hauling is the trade-off; FLAGGED | [7] + calculation |
| `tool.winch.power.motor` | Motor rating | 800 | N/A | W | Manufacturer rating; not used in game; see conflict 1 | [7] |
| `tool.winch.power.mech` | Mechanical output at full load (F × v) | 587 (17795 × 0.033) | N/A | W | Calculated from real values | [7][8] + calculation |
| `tool.winch.power` | Power (F × v) | 587 (see above) | 300 (10000 × 0.03) | W | Game value lower than real mechanical output, by design; FLAGGED | Game design proposal |
| `tool.winch.current` | Current draw, full load, 12 V | 230 | N/A | A | Manufacturer value. Independent support not verified (see Section 4) | [7] |
| `tool.winch.setup` | Setup time | UNSOURCED | 1.5 | min | Game value FLAGGED | UNSOURCED |
| `tool.winch.cost` | Acquisition cost | UNSOURCED | 600 | game currency | Fictional balance value | UNSOURCED |

**Open conflict 1 (motor rating vs current):** At 12 V, 230 A at full load gives about 2,760 W of electrical input, roughly 3.5× the 800 W motor rating. The source does not explain this. One possibility is that 800 W is a nominal or mechanical rating. Full-load mechanical output (587 W) is about 73% of 800 W, a plausible efficiency. The gap between 587 W mechanical and 2,760 W electrical (about 21%) is unexplained. The game uses the power rule, not 800 W.

**Open conflict 2 (rope wraps):** The manual [8] says at least 5 wraps must remain on the drum. The product page [7] says 10. This file uses the manual as primary. The team may choose 10 as the game value (more conservative).

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
| `tool.bridge` | Load from the same mass | 292 N on the Moon for a 180 kg game load (1766 N on Earth; 180 × 1.62 = 291.6) | [1]; calculation; FLAGGED |
| `tool.drone` | Gravity is not the main issue; the Moon has almost no atmosphere (night surface pressure 3 × 10⁻¹⁵ bar) | Not a gravity effect | [1] (atmosphere section) |

**Team note:** The drone is not covered by gravity. Its problem is the lack of atmosphere.

---

### 2.2 book.work_power: Work and Power

**Principle:** Work is force multiplied by distance. Power is the rate of doing work, meaning work per second. Lifting the same load faster needs more power, even though the total work is the same.

**Formula:** P = F × v

**What the player changes:** Speed and pulling load. Raising the speed under the same load raises the power needed.

**Game effect:** At full load, the real winch delivers about 587 W of mechanical output (17,795 N × 0.033 m/s). The real ascender delivers about 863 W at full load (2,158 N × 0.4 m/s). Both are calculations from manufacturer values, not rated powers. The human body also has a limit. On a 30% grade traverse, test subjects reached peak metabolic rates of about 485–512 W, converted from 1,656 and 1,747 BTU/hr [9][3]. That is energy burned by the body, not mechanical power, so the two figures must not be compared directly.

**Trade-off:** Speed saves time but costs energy and drains the battery faster. The winch slows as the load grows, from 4.6 m/min with no load to 2.0 m/min at full load.

**Counter:** Split the task and take rest breaks. Average work on the Moon was 31–36% of peak aerobic capacity, inside the sustainable range of 30–40% [10]. But the heaviest single xEMU tasks averaged 45–47%, and individual peaks reached 60–69%. Long routes and heavy tasks should be split into shorter stages.

**Linked tools:** winch, ascender, drone, bridge.

**Sources:** [2][3][6][7][8][9][10]

**Tool power table (team data):**

| tool | what is affected by power | real value | game value | source |
|---|---|---|---|---|
| `tool.winch` | Mechanical output at full load (F × v) | 587 W (17,795 N × 0.033 m/s) | 300 W (10,000 N × 0.03 m/s) | [7][8]; calculation |
| `tool.winch` | Rated motor power | 800 W | Not used in game | [7] |
| `tool.ascender` | Power at full load (F × v) | 863 W (2,158 N × 0.4 m/s) | 1,440 W (1,200 N × 1.2 m/s) | [6]; calculation |
| `tool.drone` | Rated motor power | 22 W | 175 W (35 N × 5 m/s) | [2]; calculation |
| `tool.bridge` | No motor; deployment is by people | 485–512 W metabolic at peak effort | Not applicable | [9]; [3] |

**Team note:** The 587 W and 863 W figures are calculated from manufacturer values. The 485–512 W figure is converted from BTU/hr using NIST SP 811 [3]. The BTU/hr figures are the paper's maximum values, not averages. Game power values follow P = F × v.

---

### 2.3 book.load_paths: Load Paths

**Principle:** Load travels from the load point to the anchor along a path. Every element on that path (rope, beam, anchor) must carry the force passing through it, and the weakest one sets the limit.

**Formulas:**

- Rope tension under a steady load: T = m × g. On the Moon, g = 1.62 m/s², so a 220 kg load pulls the rope with about 356 N.

- Bending moment in a simply supported beam with a load at midspan: M = F × L / 4 [12][13].

- Bending stress: σ = M × y / I (at the outer fibre, y = c, so σ_max = M × c / I) [11][11b].

**What the player changes:** Anchor points, their number, and where the load sits.

**Game effect:** The ascender carries up to 220 kg (WLL), about 356 N on the Moon. The winch pulls 17,795 N on its first rope layer. Newton force does not change with gravity, but the mass it moves does. Pull drops on later layers, for example 1,535 kg on the second (≈ 15,058 N, product page [7]). A load at midspan gives the bridge its largest bending moment.

**Trade-off:** One anchor is faster to set up but carries the whole load. Several anchors share it but take longer.

**Counter:** Spread the load across several anchors, and use rotational stabilization on the winch [14].

**Linked tools:** ascender, winch, bridge, drone.

**Sources:** [4][6][7][8][11][12][13][14][15]

**Load path table (team data):**

| Path element | Quantity | Real value | Game value | Source |
|---|---|---|---|---|
| `tool.ascender` (load on rope) | Working Load Limit | 220 kg = 356 N on the Moon (220 × 1.62) | 1,200 N (≈ 741 kg on the Moon, 1200 ÷ 1.62); FLAGGED | [6]; calculation; rope under load: [15] |
| `tool.winch` (cable) | Line pull, first layer | 17,795 N (force does not change with gravity) | 10,000 N | [8] |
| `tool.winch` (cable) | Line pull, second layer | 15,058 N (1,535 kg × 9.81) | Not used | [7]; calculation |
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

**Scope note:** Each body's row in 3.1 gives gravity only. Materials for each body come from that body's own material table. Until a body's table is received, its inputs stay `FLAGGED`.

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

### 3.4 Material factors

| material | source | purity_factor | status |
|---|---|---|---|
| (from each body's table) | Moon: Mo3tez; Mars: Ahmed Walid; other bodies: their owners | TBD | FLAGGED: table not received |

Materials for any body are not listed here until that body's table is received.

### 3.5 Input availability (where each input is found)

Crafting happens at the station. Inputs are gathered from a body (Moon, Mars, or another body) and brought back. Each input is listed below with the body where it is found. Nothing is filled in until the matching table is received.

| tool | input | found at (body) | source table | status |
|---|---|---|---|---|
| `tool.drone` | TBD | TBD | Body's material table | FLAGGED: table not received |
| `tool.bridge` | TBD | TBD | Body's material table | FLAGGED: table not received |
| `tool.ascender` | TBD | TBD | Body's material table | FLAGGED: table not received |
| `tool.winch` | TBD | TBD | Body's material table | FLAGGED: table not received |

**Rule:** An input can be listed as found on a body only if that body's material table has it. Anything else stays TBD.

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

