# Movement and Protection Deliverable

Author: Mahmoud FathAllah [(@Ma7moudEGY)](https://github.com/Ma7moudEGY)

## 1. Movement Tools Table

| id           | tool                     | mass_kg                      | power_w | force_n | range_m | acceleration_m/s^2 | setup_min | cost_usd | unlocks                   | weakness                                                           | source |
| :----------- | :----------------------- | :--------------------------- | :------ | :------ | :------ | :----------------- | :-------- | :------- | :------------------------ | :----------------------------------------------------------------- | :----- |
| tool.jetpack | Jetpack / Thruster Pack  | 153.314                      | 74.48   | 3.56    | 121.92  | 0.0232             | 1.5       | 5000     | High Altitude<br>Void Gap | Propellant depletes rapidly<br>Extremely bulky in tight spaces.    | [1]*   |
| tool.tether  | Tether / Grapple         | large: 0.227 <br>small: 0.01 | -       | 2602.23 | 25.9    | -                  | 0.2       | 600      | Gap Swing                 | Cannot be operated by a single.<br>Fatiguing when used frequently. | [1]    |
| tool.spikes  | Climbing Spikes / Pitons | 0.07                         | -       | 8.9     | -       | -                  | 0.5       | 400      | Vertical Wall Climb       | Very low pull-out resistance in loose regolith.                    | [1]    |

> **Source trace ([1]):** Thrust 3.56 N is an exact 0.8 lbf conversion and matches SAFER-class hardware (~38 kg / 84 lb with tanks); the original 0.079–0.101 m/s² acceleration range also fits a ~35–45 kg moving unit. So thrust and acceleration are [1]-consistent. But mass `153.314 kg` matches no SAFER figure, `74.48 W` has no matched row, and `121.92 m` is an exact 400 ft conversion needing confirmation — these three cells carry the `*` and are flagged in the Gaps list.

> **Jetpack real vs game:** This row holds real, sourced values — game-tuned values are in the Jetpack Performance Metrics table below. Acceleration is recomputed from the row's own numbers, `F/m = 3.56 / 153.314 ≈ 0.0232 m/s²`; the previous `0.079–0.101 m/s²` range implied a moving mass of only ~35–45 kg (`m = F/a`) and came from a different system than the 153.314 kg unit listed here. Real cold-gas thrust (3.56 N) supports only ~2.2 kg against lunar gravity — a microgravity translation aid, not a lifter.

### Jetpack Performance Metrics

| id                  | metric           | real_value | game_value | unit | why                                                                                             | source |
| :------------------ | :--------------- | :--------- | :--------- | :--- | :---------------------------------------------------------------------------------------------- | :----- |
| tool.jetpack.thrust | Max Thrust       | 3.56       | 600        | N    | Game boost sized to actually deliver the "High Altitude" sell: with game masses — 80 kg player (assumed; pin as project constant) + 133.8 kg suit + 15 kg jetpack (crafting mass) = 228.8 kg — lunar hover costs ~371 N, so the previous 250 N value could not even hover the system. 600 N gives a net upward acceleration of ~1.0 m/s² at full throttle (T/W ≈ 1.6) and ~140 kg of payload margin. Real cold-gas thrusters (3.56 N) cannot lift a player in planetary gravity. | [1]    |
| tool.jetpack.isp    | Specific Impulse | 65         | 300        | s    | Game value boosted, real nitrogen gas drains too rapidly for playable flight durations.         | [2]    |

---

## 2. Protection Tools Table

| id           | tool                     | mass_kg   | power_w   | insulation_w_m2k | heat_rejection_w | temp_limit_c | anchor_force_n | setup_min | cost_usd | protects                                          | weakness                                                                       | source |
| :----------- | :----------------------- | :-------- | :-------- | :--------------- | :--------------- | :----------- | :------------- | :-------- | :------- | :------------------------------------------------ | :----------------------------------------------------------------------------- | :----- |
| tool.suit    | Pressure & Thermal Suit  | 133.8     | 150       | 0.02             | 400              | 112.8        | -              | 3.0       | 12000    | Vacuum<br>Extreme temperatures<br>Micrometeoroids | Restrictive joint mobility.<br>Gloves cause severe hand fatigue.               | [2]    |
| tool.shelter | Storm Anchor / Shelter   | UNSOURCED | -         | -                | -                | UNSOURCED    | UNSOURCED      | 1.5       | 3500     | Solar radiation,<br>Dust storms                   | Immobile.<br>Requires flat bedrock or <br>deep regolith to anchor properly.    | [1]    |
| tool.heater  | Heater / Thermal Control | 0.18      | UNSOURCED | -                | -                | 176.7        | -              | 0.1       | 800      | Freezing in permanent shadows                     | Significantly reduces finger dexterity.                                        | [1]    |
| tool.shield  | Dust / Radiation Shield  | UNSOURCED | UNSOURCED | -                | -                | -            | -              | 2.0       | 8500     | Galactic cosmic rays,<br>Abrasive charged dust    | Immense mass penalty if physical<br>High constant power draw if electrostatic. | [1]    |

> **Unit notes:** `tool.suit.temp_limit_c` (112.8 °C) and `tool.heater.temp_limit_c` (176.7 °C) are exact conversions of Fahrenheit source values — 235 °F and 350 °F respectively; the columns are correct in °C. `tool.heater` runs on a Battery Cell (see crafting inputs), so `power_w = 0` was an error — a heater that draws nothing heats nothing. Its nominal draw is flagged `UNSOURCED` pending a source.

---

## 3. Book Entries

### book.thermal.control
- **Linked tools:** `tool.suit`, `tool.heater`
- **Real Principle:** In the vacuum of space, heat transfer is restricted because there is no air to provide convective cooling. An astronaut's body and suit electronics generate continuous heat that must be dissipated, or the suit will quickly overheat. Real-world Extravehicular Mobility Units (EMUs) absorb this heat via a liquid cooling garment and pump it to a sublimator, where water freezes and turns instantly to gas, carrying the energy away into the vacuum. Externally, Multi-Layer Insulation (MLI) acts as a highly reflective barrier to block incoming solar radiation.
- **Formula:** $Q = \epsilon \sigma A (T^4 - T_{surr}^4)$ and $Q = U A \Delta T$
- **What the Player Changes:** Upgrading MLI layers (insulation) or expanding the sublimator's water reservoir.
- **Game Effect:** Increases the `temp_limit_c` threshold, allowing the player to traverse through high-heat solar exposure zones or survive longer in deep, freezing craters.
- **Trade-off:** Expanding the cooling system heavily increases the suit's base mass, slowing down base walking speed and reducing jump height.
- **Counter:** Plan routes that dart between shadows to passively cool down, or retreat to `tool.shelter` to reset the suit's thermal state.
- **Source:**[2]

### book.mass.rocket_equation
- **Linked tools:** `tool.jetpack`
- **Real Principle:** The Tsiolkovsky rocket equation dictates that changing velocity ($\Delta v$) in a vacuum requires expelling mass. The engineering challenge is that propellant itself has mass. To carry more fuel, you need a larger tank, which makes the unit heavier, requiring even more fuel just to move that added weight. Rescue packs like SAFER rely on cold gaseous nitrogen, which has a very low specific impulse ($I_{sp}$). Consequently, the system burns through its reserves extremely fast to yield only minor thrust.
- **Formula:** $\Delta v = I_{sp} \cdot g_0 \cdot \ln\left(\frac{m_0}{m_f}\right)$
- **What the Player Changes:** Equipping larger high-pressure nitrogen tanks ($m_0$) or tweaking the nozzle for higher $I_{sp}$.
- **Game Effect:** Extends the continuous thrust duration and maximum vertical `range_m` of the jetpack.
- **Trade-off:** The massive weight of upgraded tanks alters the player's physics state, making them sluggish and highly susceptible to fall damage when the thrusters are inactive.
- **Counter:** Use `tool.tether` to swing across horizontal gaps, conserving limited jetpack propellant purely for vertical ascension.
- **Source:**[1]

### book.tether_tension
- **Linked tools:** `tool.tether`, `tool.spikes`
- **Real Principle:** While an astronaut weighs significantly less on the Moon ($1.62\text{ m/s}^2$), their inertial mass remains identical to Earth. If a player falls and reaches the end of a slack tether, the sudden deceleration creates a violent spike in dynamic tension force. The line must absorb not just the static weight, but the kinetic shock of that sudden arrest, multiplied by a safety factor ($SF$). This requires advanced, heavy-duty materials like Kevlar or Vectran to avoid catastrophic snapping.
- **Formula:** $T = m(g + a) \cdot SF$
- **What the Player Changes:** Upgrading the tether reel's cable material to higher tensile strength ratings.
- **Game Effect:** Increases the `force_n` limit, preventing the line from snapping during high-velocity falls or when hauling heavy environmental objects.
- **Trade-off:** High-tensile cables are significantly thicker and heavier, limiting the spool size and greatly reducing the tether's maximum throw `range_m`.
- **Counter:** Drive `tool.spikes` into walls during a descent to create intermediate anchor points, resetting fall velocity and avoiding massive tension spikes.
- **Source:**[1]

### book.radiation.shielding
- **Linked tools:** `tool.shield`, `tool.shelter`
- **Real Principle:** Galactic cosmic rays and solar particle events are managed by areal density — the mass per unit area a charged particle must traverse. Hydrogen-rich materials (polyethylene, water) give the best attenuation per kilogram: high hydrogen content maximizes inelastic scattering without generating heavy secondary particle showers the way high-Z materials like aluminum or lead do. A reflective surface shelter cuts the entire solar load during a storm, while an electrostatic shield deflects charged lunar dust, which clings to suits and equipment and abrades seals by constant static adhesion.
- **Formula:** $D(x) = D_0 \cdot e^{-\mu x}$ — dose falls exponentially with areal density $x$.
- **What the Player Changes:** Adding polyethylene or water layering to the shield pack (passive path) or raising the electrostatic field generator's power (active path).
- **Game Effect:** Reduces the radiation dose rate in `Radioactive Wastes` and extends the maximum safe exposure window before suit or health penalties apply; `tool.shelter` enables safe holdover during `Solar Storm Zone` events.
- **Trade-off:** Passive layering adds immense carried mass and slows movement; the electrostatic variant draws a high constant power drain on the suit battery instead.
- **Counter:** Treat radiation zones as short sprint-through crossings, never slow hauls, and retreat to `tool.shelter` during storm events rather than shielding through them.
- **Source:**[1]

---

## 4. Crafting Table

| tool         | inputs                                                                                                | mass_kg   | energy_kwh | cost_usd | station_tier | unlocks                   |
| :----------- | :---------------------------------------------------------------------------------------------------- | :-------- | :--------- | :------- | :----------- | :------------------------ |
| tool.jetpack | Gaseous Nitrogen [FLAG: UNMATCHED MATERIAL],<br>Aluminum Assembly [FLAG: UNMATCHED MATERIAL]          | 15.0      | 0.447      | 5000     | Tier 2       | High Altitude<br>Void Gap |
| tool.tether  | Kevlar/Vectran Weave [FLAG: UNMATCHED MATERIAL],<br>Aluminum Hook [FLAG: UNMATCHED MATERIAL]          | 0.23      | -          | 600      | Tier 1       | Gap Swing                 |
| tool.spikes  | Titanium Alloy [FLAG: UNMATCHED MATERIAL]                                                             | 0.07      | -          | 400      | Tier 1       | Vertical Wall Climb       |
| tool.suit    | Multi-Layer Insulation [FLAG: UNMATCHED MATERIAL],<br>Liquid Cooling Water [FLAG: UNMATCHED MATERIAL] | 12.0      | 0.9        | 12000    | Tier 3       | Surface Vacuum Exposure   |
| tool.shelter | Lunar Regolith [FLAG: UNMATCHED MATERIAL],<br>Reflective Mylar [FLAG: UNMATCHED MATERIAL]             | UNSOURCED | -          | 3500     | Tier 2       | Solar Storm Zone          |
| tool.heater  | Copper Wiring [FLAG: UNMATCHED MATERIAL],<br>Battery Cell [FLAG: UNMATCHED MATERIAL]                  | 0.18      | 0.09       | 800      | Tier 1       | Permanent Shadow Zone     |
| tool.shield  | Polyethylene Layering [FLAG: UNMATCHED MATERIAL],<br>Water shielding [FLAG: UNMATCHED MATERIAL]       | UNSOURCED | UNSOURCED  | 8500     | Tier 3       | Radioactive Wastes        |

> **Note:** Inputs reference Mo3tez's Moon materials table. Any missing material is flagged as `[FLAG: UNMATCHED MATERIAL]`.

---

## 5. Sources and Gaps

### Sources
1. [EVA Tools and Equipment Reference Book](https://ntrs.nasa.gov/citations/19940017339), Accessed: 2026-10-19
2. [Development of the Extravehicular Mobility Unit](https://ntrs.nasa.gov/citations/19760003073), Accessed: 2026-10-21

### Unsourced Real Numbers (Gaps)
- `tool.shelter`: `UNSOURCED` (No standard surface storm shelter mass, temperature limit, or anchoring force found).
- `tool.shield`: `UNSOURCED` (No standard EVA radiation shield mass or power draw found).
- `tool.heater.power_w`: `UNSOURCED` (Battery-powered thermal control must draw electrical power; the previous 0 W was an error, nominal draw not yet sourced).
- `tool.jetpack.*` `RE-VERIFY vs [1]`: mass `153.314 kg` matches no SAFER-class row (~38 kg / 84 lb) in [1]; `74.48 W` has no matched row; `121.92 m` is an exact 400 ft conversion. Confirm all three against the [1] unit row or re-derive — thrust (3.56 N, exact 0.8 lbf) and acceleration are source-consistent.
