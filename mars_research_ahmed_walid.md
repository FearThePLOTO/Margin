



## 1. Environment table

| id | quantity | value | unit | conditions | source | accessed | confidence |
|---|---|---|---|---|---|---|---|
| mars.gravity | Mean surface gravity | 3.73 | m/s² | NASA fact-sheet mean (GM/R² at mean radius gives 3.73; equatorial value 3.69, polar 3.73). ESA quotes 3.711, which is a differently defined reference radius. | [1] | 2026-10-22 | High |
| mars.day_length | Solar day (sol) | 24.66 (= 24 h 39 min 35.244 s) | hours | **[CORRECTED]** Fact sheet "length of day" 24.6597 h. The old "24.6" was truncated, not rounded. Sidereal rotation is 24.6229 h. | [1], [2] | 2026-10-22 | High |
| mars.year_length | Orbital year | 668.6 | sols | **[CORRECTED]** Old value 669.6 was wrong. 686.98 d × 86400 s ÷ 88775.244 s = 668.60 sols (tropical year 668.59). Commonly rounded to 669 sols. | [1], derived | 2026-10-22 | High |
| mars.year_length_days | Orbital year | 686.98 (sidereal); 686.97 (tropical) | Earth days | Fact sheet; commonly "687 days". | [1] | 2026-10-22 | High |
| mars.axial_tilt | Axial tilt (obliquity) | 25.19 | degrees | **[CORRECTED]** more precise. Seasons differ in length because orbital eccentricity is 0.0935. | [1] | 2026-10-22 | High |
| mars.atmosphere.co2 | Carbon dioxide | 95.1 | % by volume | Fact-sheet composition. MSL/SAM gives 95.32 % (ESA). Use ~95 %. | [1], [19] | 2026-10-22 | High |
| mars.atmosphere.n2 | Nitrogen | 2.59 | % by volume | Fact-sheet composition | [1] | 2026-10-22 | High |
| mars.atmosphere.ar | Argon | 1.94 | % by volume | Fact-sheet composition | [1] | 2026-10-22 | High |
| mars.atmosphere.o2 | Oxygen | 0.16 | % by volume | Trace; not breathable | [1] | 2026-10-22 | High |
| mars.atmosphere.co | Carbon monoxide | 0.06 | % by volume | **[FILLED]** was missing | [1] | 2026-10-22 | High |
| mars.surface_pressure | Surface pressure | 6.36 | mbar | Mean-radius reference; seasonal range 4.0–8.7 mbar (6.9–9 mbar at Viking 1 site) | [1] | 2026-10-22 | High |
| mars.atmosphere_density | Surface density | ~0.016 ± 0.006 | kg/m³ | Approximate global reference; local and seasonal variation. Scale height 11.0 km. | [1] | 2026-10-22 | Medium-high |
| mars.temperature.mean | Average temperature | ~214 (−59 °C) | K | **[FILLED]** global-average fact-sheet value. Black-body equilibrium temperature 209.8 K. | [1] | 2026-10-22 | High |
| mars.temperature.diurnal | Temperature range | 184–242 (−89 to −31 °C) | K | Viking 1 landing site, not a global limit | [1] | 2026-10-22 | High |
| mars.solar_irradiance | Solar irradiance (mean) | 586.2 | W/m² | Top of atmosphere, mean orbital distance | [1] | 2026-10-22 | High |
| mars.solar_irradiance_range | Solar irradiance, perihelion to aphelion | ≈ 490–713 | W/m² | **[FILLED, derived]** S = 1361 W/m² × (1 AU / r)² using fact-sheet perihelion 206.650 and aphelion 249.261 million km. Top of atmosphere; surface value is lower (see dust_tau). | [1], derived | 2026-10-22 | Medium-high |
| mars.dust_tau.background | Dust/aerosol optical depth, non-storm | typically 0.2–1 (visible) | dimensionless | **[FILLED]** MER 5-Mars-year record: 0.2–1 outside storms. At Gale (MSL Navcam retrievals, a year without a global storm): ≈0.4 minimum (Ls ≈ 135°) to >1.25 maximum (Ls > 200°). Site- and season-specific. | [4], [20], [21] | 2026-10-22 | Medium-high |
| mars.dust_tau.storm | Dust optical depth, storms | >5.5 (2007 global storm, Opportunity); 10.8 (2018 global storm, Opportunity, 10 Jun 2018) | dimensionless | **[FILLED]** 10.8 is a mission-team estimate and the largest ever reported from a Mars surface. Single site, single moment. Wavelength not stated in the news sources; treat as visible-band opacity until the PDS product is identified. Sunlight transmission ≈ e^−τ (τ = 10.8 → ~0.002 % direct beam). | [22] | 2026-10-22 | Medium |
| mars.radiation_dose | Surface absorbed dose rate (in tissue) | 0.21 ± 0.04 (≈210) | mGy/day | **[CORRECTED]** baseline: Curiosity RAD, ~300 sols (7 Aug 2012 – 1 Jun 2013), during solar maximum. Mostly galactic cosmic rays. Not a universal constant. | [6], [23] | 2026-10-22 | High |
| mars.radiation_dose_equiv | Surface dose-equivalent rate | 0.64 ± 0.12 | mSv/day | **[FILLED]** same RAD period. For scale: cruise 1.84 ± 0.3 mSv/day; ISS ≈ 1.3 mSv/day (NASA). | [6], [23], [24] | 2026-10-22 | High |
| mars.earth_distance_min | Earth–Mars minimum distance | 54.6 | million km | **[FILLED]** NASA fact-sheet minimum. This is a theoretical bound (Mars perihelion 206.65 − Earth aphelion 152.10 = 54.55). Closest real approach in recent decades is ≈ 55.7 million km (CSA). | [1], [25] | 2026-10-22 | High |
| mars.earth_distance_max | Earth–Mars maximum distance | 401.4 | million km | **[FILLED]** fact-sheet maximum (Mars aphelion 249.26 + Earth aphelion 152.10 = 401.36, consistent). Occurs near solar conjunction. | [1], [25] | 2026-10-22 | High |
| mars.earth_distance_opposition | Mean distance at opposition | 78.34 | million km | **[FILLED]** | [1] | 2026-10-22 | High |
| mars.synodic_period | Earth–Mars synodic period | 779.94 | days | **[FILLED]** about 26 months between oppositions and between conjunctions | [1] | 2026-10-22 | High |
| mars.light_time_min | One-way light time, minimum | 3.04 (182 s) | minutes | **[FILLED, derived]** t = d / c = 54.6×10⁶ km ÷ 299 792.458 km/s. Using the observed 55.7 million km gives 3.10 min. | [1], derived | 2026-10-22 | High |
| mars.light_time_max | One-way light time, maximum | 22.3 (1339 s) | minutes | **[FILLED, derived]** t = 401.4×10⁶ km ÷ 299 792.458 km/s. Mean at opposition: 4.36 min (261 s). Cross-check: Perseverance landing-day delay ≈ 700 s (≈11.7 min). | [1], [26], derived | 2026-10-22 | High |
| mars.conjunction_blackout | Solar-conjunction commanding moratorium | ≈ 10–14 | days | **[CORRECTED]** NASA's "command moratorium" has been about two weeks: 28 Aug–7 Sep 2019 (~10 d), 2 Oct–14 Oct 2021 (some missions to 16 Oct), 11–25 Nov 2023 (14 d). NASA also describes communications being "much quieter for a few weeks" around it, so "a few weeks" is the quiet period, not the moratorium. | [8], [27], [28] | 2026-10-22 | Medium-high |
| mars.wind_speed_summer | Wind speed | 2–7 | m/s | Viking landing-site seasonal range, summer | [1] | 2026-10-22 | High |
| mars.wind_speed_fall | Wind speed | 5–10 | m/s | Viking landing-site seasonal range, fall | [1] | 2026-10-22 | High |
| mars.wind_speed_storm | Wind speed during dust storm | 17–30 | m/s | Viking landing-site fact-sheet range; local gusts and measurement methods matter | [1] | 2026-10-22 | Medium-high |
| mars.solar_array_dust_loss | Solar-array output loss from dust deposition | typical 0.2 (range 0.05–2) | %/sol | **[FILLED]** Pathfinder ≈ 0.25 %/sol. 0.2 %/sol held for InSight's first 800 sols, Phoenix and much of MER. Cleaning events (dust devils, gusts) occurred for MER but not at the InSight site. | [29], [30] | 2026-10-22 | High |

**Why the numbers matter in play**

- `mars.gravity`: changes jump arcs, carried-load movement and fall damage; do not copy lunar tuning unchanged.
- `mars.day_length` and `mars.year_length`: define the day/night cycle and long seasonal planning. Use 24 h 39 min 35 s per sol and 668.6 sols per year.
- `mars.axial_tilt`: supports seasonal variation; seasons are unequal in length because of the elliptical orbit.
- Atmospheric composition, pressure and density: CO₂ is a feedstock, but low pressure means the atmosphere is not breathable and gives limited aerodynamic braking.
- Temperature and irradiance: drive heater demand, battery sizing and solar generation (irradiance swings ≈ 490–713 W/m² over the orbit before dust).
- Dust optical depth: drives solar derating and visibility. Use 0.2–1 as background and treat storms (τ > 5) as events.
- Radiation dose: supports a radiation meter and shielding mechanic. One rover's record at one site is a baseline, not a forecast.
- Distance, light time and conjunction: set communication latency (3–22 min one way) and blackout modes.
- Wind: affects dust exposure and operations; thin air means high wind does not equal Earth-like force.

---

## 2. Materials table

**Important:** `found` and `abundance` are location-dependent. Do not present a global abundance unless the cited source supports it. Crafting costs are provisional game-economy units (`GU`), not physical quantities.

| id | material | real | grounded_in | found | abundance | what it makes | crafting cost | unlocks | source |
|---|---|---|---|---|---|---|---|---|---|
| material.regolith | Regolith / soil | yes | Loose surface material and basaltic soil | Surface; varies by site | Global numeric abundance UNSOURCED | Sintered bricks, berms, radiation shielding; soil sampling | 3 GU (provisional) | Basic shelter and shielding | [9] |
| material.iron_oxide | Iron-bearing oxides | yes | Iron (hydr)oxides detected in Martian soils; iron minerals give the red appearance | Soil and rocks; site dependent | Numeric abundance UNSOURCED | Pigment; possible iron extraction only with processing | 4 GU (provisional) | Pigment / metal-processing research | [10], [9] |
| material.dust | Fine airborne dust | yes | Martian dust is transported by winds and storms | Atmosphere and surface | Background optical depth 0.2–1; storms τ > 5 (see Section 1) | Collectable as feedstock only after filtration; otherwise contaminates machinery and panels | 1 GU to collect; 3 GU to filter (provisional) | Filter media / dust study | [4], [20], [22] |
| material.sulfates | Sulfate minerals | yes | Sulfates identified by landed missions and mineralogy instruments | Selected soils and rocks | Site-dependent; numeric abundance UNSOURCED for game-wide use | Chemical feedstock / construction additives after processing | 4 GU (provisional) | Mineral processing | [9], [11] |
| material.clays | Clay minerals | yes | Clay minerals identified in Martian rocks by orbital and rover science | Selected ancient aqueous terrains | Site-dependent; numeric abundance UNSOURCED | Ceramic-like composites / sealed storage after processing | 5 GU (provisional) | Advanced composites | [11], [12] |
| material.water_ice | Water ice | yes | Poleward of ~60° latitude, Odyssey neutron/gamma data show ice concentrations above ~20 % almost everywhere in the upper soil. Phoenix (68° N) hit solid ice after scraping a few inches of dry soil (pre-landing estimate 2–6 cm). Depth varies from centimetres to metres. | Polar and high-latitude subsurface; not guaranteed at every site | **[FILLED]** latitude-dependent (see grounded_in); no single global number | Water, then oxygen and hydrogen via energy-intensive electrolysis | 5 GU to mine; 4 GU to purify (provisional) | Water reserve / electrolysis | [2], [13], [31], [32] |
| material.co2_ice | Carbon-dioxide ice | yes | CO₂ freezes in polar and seasonal conditions | Seasonal polar caps | Seasonal and regional; numeric abundance UNSOURCED | Thermal experiments / sublimation gas; not a general surface resource | 4 GU (provisional) | Seasonal gas handling | [2] |
| material.co2_atmosphere | Atmospheric CO₂ | yes | Atmosphere is ~95.1 % CO₂ by volume. MOXIE (Perseverance) made 122 g of oxygen over 16 runs, peak 12 g/h at ≥ 98 % purity. | Everywhere in the atmosphere, but thin | **[FILLED]** composition sourced; MOXIE demonstrated rate above | Oxygen via MOXIE-like solid-oxide electrolysis; methane only with a hydrogen source and a suitable process | 6 GU for processor (provisional) | Oxygen plant; fuel chemistry research | [1], [3], [33] |
| material.perchlorate | Perchlorate salts | yes | Phoenix wet chemistry found 0.4–0.6 wt % perchlorate in leachate at its site **[CORRECTED from "~0.6"]**. Curiosity SAM found oxychlorine phases in Gale samples, roughly 0.35–1.4 wt % depending on sample. Hazardous oxidizing salts. | Detected at multiple sites; not safe to assume every sample matches | Phoenix ~0.5 wt % in one site/sample context; not a global abundance | Potential industrial oxidizer only under controlled processing; never treat raw dust as safe | Not a normal crafting input; remediation cost UNSOURCED | Hazard analysis / decontamination | [9], [14], [34], [35] |
| material.ferric_sinter | Ferric sinter | no | Inspired by real iron-oxide-rich soil and sintering of regolith; fictional processed composite, not a discovered Mars mineral | Crafted at a heated regolith kiln | Not applicable | Durable bricks / abrasion-resistant panels | 6 GU + regolith (provisional) | Dust-resistant structure | [9], [10] |
| material.aerogel_salt | "Aerogel salt" | no | Inspired by real silica aerogel (JPL aerogel is ~99.8 % empty space, ~39× more insulating than the best fiberglass, used to insulate Sojourner's electronics) and sulfate/perchlorate chemistry. The combined material is fictional, not a Martian deposit. | Crafted in a sealed chemistry bench | Not applicable | Lightweight dust trap or thermal insert; counter: brittle and loses performance when contaminated | 8 GU + silica feedstock (provisional) | Lightweight filter module | [11], [15] |

---

## 3. Hazards table

Ranges must be evidence-based. Where a defensible number was not verified, it is explicitly `UNSOURCED` rather than invented. Hazard ranges are not automatically the same as a global environmental range.

| id | hazard | real | grounded_in | trigger | range | duration | tests | counters | source |
|---|---|---|---|---|---|---|---|---|---|
| hazard.local_dust_storm | Local dust storm | yes | Wind lifts and transports dust; storms alter visibility and solar input | Dust optical depth / wind alert exceeds site threshold | **[FILLED]** Viking-era storms reached τ ≈ 3–4 (secondary source); wind 17–30 m/s in the Viking-site storm range | Roughly a day for local storms, hence "event-dependent" (secondary source, Medium-low confidence) | visibility, solar_output, filter_load, navigation | Dust-sealed panel cover (higher cost); replaceable intake filter (lower cost) | [1], [20], [36] |
| hazard.global_dust_storm | Global dust storm | yes | Planet-encircling dust events obscure the surface and cut sunlight | Global dust opacity reaches a mission-defined threshold | **[FILLED]** Opportunity: τ > 5.5 (2007), 10.8 (2018, record). Single-site values. | **[FILLED]** months: the 2018 storm began ~30 May 2018 (a local storm that grew) and was still only beginning to die down about two months later. Exact bounds UNSOURCED. | solar_output, visibility, battery_reserve, thermal_margin | Oversized battery (high cost); nuclear/dispatchable backup source (high cost) | [22], [37] |
| hazard.panel_dust | Dust-covered solar panels | yes | Dust accumulation lowers panel output; severity depends on deposition and cleaning | Panel dust-load threshold reached | **[FILLED]** typical −0.2 %/sol of array output (observed 0.05–2 %/sol). At 0.2 %/sol: −2 % after 10 sols, −18 % after 100 sols, −33 % after 200 sols, −55 % after 400 sols. | Until cleaning or natural removal. MER had cleaning events from dust devils and gusts; InSight's site showed none for ~800 sols, so natural cleaning cannot be assumed. | solar_output, battery_reserve | Manual brush (low cost); electrostatic/mechanical cleaner (higher cost) | [29], [30] |
| hazard.perchlorate_exposure | Perchlorate-contaminated dust / soil | yes | Perchlorates detected by Phoenix and Curiosity; oxidizer and health concern | Sample or dust contacts suit, food/water path, or unsealed equipment | **[CORRECTED]** Phoenix 0.4–0.6 wt % in its soil leachate; Gale oxychlorine ~0.35–1.4 wt % by sample. Global min/max UNSOURCED. | Exposure-dependent; UNSOURCED | contamination, suit_integrity, water_purity | Sealed sample canister (medium cost); wash/decontamination station (high cost) | [9], [14], [34], [35] |
| hazard.cold_thin_atmosphere | Cold + thin atmosphere | yes | Low pressure and cold surface complicate exposed equipment and heat transfer | Component temperature or pressure crosses its rated limit | Average ~214 K; Viking 1 diurnal 184–242 K; mean surface pressure 6.36 mbar (4.0–8.7 mbar seasonal) | Depends on exposure; UNSOURCED | temperature, pressure_rating, heater_power | Insulated enclosure (medium cost); active heater (high power/cost) | [1] |
| hazard.landing_edl | Entry, descent, landing failure | yes | Atmosphere is thick enough for heating and drag but too thin for parachutes alone. Perseverance: entry at ~20 000 km/h, peak heat-shield ~1 300 °C, parachute deployed ~240 s after entry at ~11 km altitude and ~1 500 km/h, but the parachute only slows the vehicle to ~300 km/h, so rockets and sky crane finish the landing. | Vehicle enters atmosphere without a compatible EDL sequence | **[FILLED]** reference profile above is one mission, not a safe envelope; safe landing envelope UNSOURCED | **[FILLED]** about 7 minutes from entry to touchdown (Perseverance) | heat_shield, parachute_load, landing_velocity, nav_error | Heat shield (high cost); parachute + terminal retropropulsion (high cost) | [16], [17], [38], [39] |
| hazard.comms_delay | Earth–Mars signal delay | yes | Finite light speed creates delayed control and acknowledgement | Remote command assumes real-time response | **[FILLED]** one-way 3.04–22.3 min (54.6–401.4 million km ÷ c); mean at opposition 4.36 min | Continuous; varies with orbital geometry over the 779.94-day synodic cycle | command_age, autonomy_level, link_state | Local autonomous controller (medium cost); queued command plan (low cost) | [1], [7], [18] |
| hazard.solar_conjunction | Solar conjunction blackout/restriction | yes | Solar plasma can corrupt radio signals when Mars is opposite Earth across the Sun | Mission calendar enters conjunction window (about every 26 months) | **[CORRECTED]** NASA command moratorium ≈ 10–14 days (2019: 28 Aug–7 Sep; 2021: 2–14 Oct; 2023: 11–25 Nov); reduced communication for "a few weeks" around it | ≈ 10–14 days moratorium; exact start/end per event | link_state, command_queue, autonomy_level | Preloaded safe-mode plan (low cost); onboard fault recovery (medium/high cost) | [8], [27], [28] |
| hazard.radiation | Ionizing radiation | yes | Curiosity RAD measured the surface radiation environment; solar particle events remain variable | Dose meter exceeds mission threshold | **[CORRECTED/FILLED]** baseline 0.21 ± 0.04 mGy/day absorbed, 0.64 ± 0.12 mSv/day dose equivalent (~300 sols at Gale, solar maximum). Event extremes UNSOURCED. | Accumulates over exposure; event duration varies | cumulative_dose, shield_integrity | Regolith berm (medium cost); storm shelter with dedicated shielding (high cost) | [6], [23], [24] |
| hazard.redglass_haze | Redglass haze (fictional) | no | Grounded in real airborne dust, iron-oxide-rich particles and reduced visibility; fictional hazard, not a reported Martian phenomenon | A storm front combines with local terrain and a damaged filter system | UNSOURCED, fantasy gameplay range set only after playtesting, not represented as physical Mars data | UNSOURCED | visibility, filter_load, sensor_confidence | Spare filter pack (low cost); sheltered sensor mast (medium cost) | Grounding: [4], [10]; fictional effect UNSOURCED |

---

## 4. Porting checklist: Moon → Mars

| system | what breaks on Mars | smallest rule change that fixes it |
|---|---|---|
| Power | Solar input is lower than near Earth (~586 W/m² mean, ~490–713 W/m² over the orbit) and dust deposition can further cut output (typical −0.2 %/sol). Storms and long dark periods make a clean-panel assumption unsafe. | Add a multiplicative `dust_derating` factor to panel output (default: × 0.998 per sol of accumulation, reset on cleaning) and a storm-forecast state; keep existing battery rules. |
| Thermal | The Moon is effectively vacuum; Mars has a thin atmosphere (6.36 mbar) that changes convective heat transfer, while still being too thin for Earth-like assumptions. | Add an atmosphere-dependent heat-transfer term; do not replace the current radiation/conduction model wholesale. |
| Comms | Remote actions cannot assume immediate acknowledgements (3–22 min one way); solar conjunction interrupts commanding for about 10–14 days. | Add a command queue + command-age display, and a conjunction mode that blocks/restricts Earth commands while local autonomy continues. |
| Movement | Gravity is higher than lunar (3.73 vs 1.62 m/s²) and the atmosphere adds drag; jumps, falling, gliding and landing trajectories differ. | Swap gravity/drag constants by environment profile; preserve the same loadout validation rules. |
| Resources | CO₂ is abundant by composition but low-pressure processing costs power; water ice is latitude-dependent; perchlorates add contamination risk. | Add resource provenance + processing requirement flags; samples tagged `perchlorate_risk` require sealed handling before water/food/tool use. |
| Launch and landing | Mars has atmospheric entry heating and partial aerodynamic braking, but parachutes alone are insufficient for final landing (~7 min EDL). The Moon has no atmospheric entry. | Add a Mars EDL sequence: heat shield → parachute where appropriate → terminal propulsion; do not reuse the Moon landing sequence. |
| Suit / life support | Atmospheric CO₂ is not breathable; dust and perchlorates create separate filtration/contamination problems. | Keep breathable oxygen as a processed resource; separate particulate filtration from chemical decontamination. |
| Crafting / inventory | "Found" resources are not necessarily usable; raw samples may be contaminated or need energy-intensive processing. | Add `raw`, `processed` and `contaminated` states rather than creating a new crafting architecture. |

---

## 5. Book entries

### book.mars.atmosphere

**Principle.** Mars has an atmosphere, but it is not a weaker version of Earth's that can be treated as breathable air. NASA's fact sheet lists it as about 95.1 % carbon dioxide, with a mean surface pressure of 6.36 mbar (seasonal range 4.0–8.7 mbar) and a surface density of about 0.016 ± 0.006 kg/m³; these values vary with season, elevation and location. The atmosphere matters in two opposite ways: it provides drag and causes entry heating, yet it is too thin for a parachute to finish the landing of a large vehicle by itself. During Perseverance's landing the parachute only brought the vehicle down to roughly 300 km/h, and rockets finished the job. The atmosphere is also a chemical feedstock: the MOXIE experiment on Perseverance made 122 g of oxygen over 16 runs from atmospheric CO₂, peaking at 12 g/h at 98 % purity or better, using solid-oxide electrolysis. That is not free: it needs machinery, power and control.

**Rule of thumb.** Use sourced local pressure and density for atmospheric mechanics. For signal delay use t = d / c, with d in km and c = 299 792.458 km/s (for example 54.6 million km → 182 s; 401.4 million km → 1339 s). Treat CO₂-to-oxygen as a powered processing recipe, not a direct resource pickup.

**Crafting effect.** Unlock an atmosphere processor and a Mars-specific EDL module; keep oxygen as a manufactured resource.

**Source.** [1], [3], [16], [17], [33], [38].

**Dialogue.** "The air is a resource, not a lungful."

### book.mars.dust

**Principle.** Martian dust is both a resource and a system-wide contaminant. Wind can lift fine material into the atmosphere, storms reduce visibility, and airborne dust changes the sunlight reaching a solar panel. Outside storms, dust/aerosol optical depth is typically around 0.2–1 (about 0.4 to above 1.25 at Gale over a non-storm year), but the 2018 global storm reached an estimated 10.8 at Opportunity, which is enough to cut direct sunlight to almost nothing and ended that rover's mission. Deposited dust also lowers panel output steadily: landed missions typically lost about 0.2 % of array output per sol (range 0.05–2 %/sol), and only some sites got natural cleaning events from dust devils and gusts. Dust should therefore not be modelled as a visual effect or a single damage event: it changes energy planning, sensor confidence, maintenance demand and equipment exposure. Mars soil is not chemically uniform, and perchlorates detected by Phoenix (0.4–0.6 wt % in its soil leachate) and oxychlorine phases at Gale mean a sample cannot be assumed safe because it looks like ordinary dirt. A dust-opacity number must always name its site, season and instrument.

**Rule of thumb.** Panel output = clean-panel output × `dust_factor`, where `dust_factor` falls by about 0.2 % per sol of accumulation (0.9982 after 100 sols → 0.82; 0.998^200 → 0.67) and resets only on cleaning. Treat the 0.2 %/sol default as a typical, not guaranteed, value, and make the rate tunable between 0.05 and 2 %/sol. Track airborne dust, deposited dust and chemical contamination as separate states.

**Crafting effect.** Filters, panel cleaners, sealed sample containers and contamination checks become meaningful choices with different costs.

**Source.** [4], [9], [14], [20], [22], [29], [30], [34], [35].

**Dialogue.** "The storm doesn't need to break the panel; it only needs to starve it."

### book.mars.comms_delay

**Principle.** Mars control is not a real-time conversation with Earth. Radio signals travel at the speed of light, so the one-way delay changes as Earth and Mars move around the Sun. NASA's fact sheet gives an Earth–Mars distance between 54.6 and 401.4 million km, which with t = d / c means a one-way delay of about 3.0 to 22.3 minutes (4.4 minutes at average opposition distance). Solar conjunction is a separate problem: when Mars is on the far side of the Sun, solar plasma can corrupt radio commands, and NASA holds a command moratorium of about two weeks (10–14 days in 2019, 2021 and 2023) with reduced communications for a few weeks around it. Conjunctions come roughly every 26 months (synodic period 779.94 days). Even a well-designed remote-control system needs safe local behaviour when commands are delayed, stale or unavailable. Real missions handle this by sending about two weeks of instructions before conjunction and then waiting.

**Rule of thumb.** A command carries a timestamp and an expiry/validity rule. If its age exceeds the allowed window, the vehicle holds a safe state or runs a preloaded plan rather than blindly executing stale instructions. During conjunction, queue non-urgent commands and rely on onboard fault handling. For game balance, a 3-to-22-minute one-way latency range is sourced; anything beyond that is design choice.

**Crafting effect.** A communications relay improves link availability and data volume but cannot eliminate light-time delay; autonomy software and preloaded plans are distinct upgrades.

**Source.** [1], [7], [8], [18], [26], [27], [28].

**Dialogue.** "Earth has answered. The answer just hasn't arrived yet."

---

## 6. Fantasy ideas (mechanic concepts only; not implementation)

These are fictional gameplay concepts anchored to real principles. They are not claims about actual Mars phenomena.

1. **Ferric sinter (`material.ferric_sinter`):** a heat-processed building composite inspired by iron-oxide-rich regolith and real sintering. Trade-off: durable dust-facing parts, but high processing energy and brittle failure under impact. Counter: reinforce with a second real-material input. No physical performance number assigned.
2. **Aerogel salt (`material.aerogel_salt`):** a fictional porous filter/thermal insert inspired by real silica aerogel (real property anchor: ~99.8 % empty space, strong insulation, used on the Sojourner rover) and mineral salts. Trade-off: light and useful for filtration/insulation, but contamination clogs pores and the material is fragile. Counter: replaceable filter cassette or a more robust, higher-cost metal mesh.
3. **Redglass haze (`hazard.redglass_haze`):** a fictional visibility/sensor-confidence event grounded in real airborne dust and iron-bearing particles. It must not introduce magic radiation or new physics. Gameplay test: visibility and sensor-confidence stats. Range and duration stay `UNSOURCED` until playtesting; never display them as real Mars measurements.
4. **Autonomy buffer:** a software "resource" rather than a physical substance. A larger buffer stores more pre-approved actions for comms outages, but takes engineering time and can execute an obsolete plan if its validity rules are weak. Grounded in real conjunction operations (about two weeks of pre-sent instructions); no invented physical values.

---

## 7. Sources and gaps

**Access date for all sources below: 2026-10-22** (original draft listed 2026-10-19). Prefer mission/instrument data and primary technical sources.

1. **NASA/NSSDC — Mars Fact Sheet** (last updated 19 May 2025). https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
   Supports gravity, solar irradiance, orbital parameters, day length, obliquity, Earth–Mars distance extrema, atmospheric composition, pressure, density, temperature, and Viking-site wind ranges.
2. **NASA Science — Mars: Facts.** https://science.nasa.gov/mars/facts/
   General background (sol length, year length, tilt, seasons). Numeric values in this note use the Fact Sheet [1] where they differ.
3. **NASA — Mars Oxygen In-Situ Resource Utilization Experiment (MOXIE).** https://www.nasa.gov/space-technology-mission-directorate/tdm/mars-oxygen-in-situ-resource-utilization-experiment-moxie/
   Electrochemical oxygen production from atmospheric CO₂. See also [33].
4. **NASA Planetary Data System (PDS).** https://pds.nasa.gov/
   Archive starting point. Select the exact instrument product before assigning dust optical-depth numbers for design use.
5. **NASA Mars mission pages: Curiosity and Perseverance.** https://science.nasa.gov/mission/msl-curiosity/ and https://science.nasa.gov/mission/mars-2020-perseverance/
   Mission starting points for surface meteorology.
6. **NASA Science — Radiation Measurements on Mars.** https://science.nasa.gov/resource/radiation-measurements-on-mars/
   ~210 µGy/day Curiosity RAD context. Primary reference: [23].
7. **NASA/NSSDC — Mars Fact Sheet (observational parameters).** https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
   Source of the 54.6 and 401.4 million km extrema; light times are derived with t = d / c, c = 299 792.458 km/s.
8. **NASA — What's Mars Solar Conjunction, and Why Does It Matter?** https://www.nasa.gov/solar-system/whats-mars-solar-conjunction-and-why-does-it-matter/
   Radio interference, "command moratorium", quiet communications for a few weeks.
9. **NASA NTRS — The Chemistry and Mineralogy of Mars Soils: A Tour of Landed Mission Results from the Last 45 years.** https://ntrs.nasa.gov/citations/20210022622
   Soil mineralogy, iron (hydr)oxides, sulfates, perchlorate findings.
10. **NASA Science — Mars: Facts.** https://science.nasa.gov/mars/facts/
    Red appearance linked to oxidized iron minerals.
11. **NASA — What is the Chemistry and Mineralogy Instrument?** https://www.nasa.gov/missions/mars-science-laboratory/curiosity-rover/what-is-the-chemistry-and-mineralogy-instrument/
    Clays, sulfates, carbonates identified by Curiosity CheMin.
12. **NASA — Curiosity Rover Finds Clues to Chilly Ancient Mars Buried in Rocks.** https://www.nasa.gov/missions/nasas-curiosity-rover-finds-clues-to-chilly-ancient-mars-buried-in-rocks/
    Clay/mineral evidence in ancient aqueous terrains; not a global abundance estimate.
13. **Water ice background:** see [31] and [32]; [2] is background only.
14. **NASA — Signs of Perchlorates and Sulfur Containing Compounds.** https://science.nasa.gov/resource/signs-of-perchlorates-and-sulfur-containing-compounds/
    Curiosity and Phoenix detections.
15. **NASA/JPL — Aerogel (Stardust "Aerogel" pages and "Ideas that gel").** https://www.jpl.nasa.gov/news/ideas-that-gel/ and https://solarsystem.nasa.gov/stardust/tech/aerogel
    Silica aerogel is 99.8 % empty space, ~39× more insulating than the best fiberglass, used to insulate the Sojourner rover's electronics. Conceptual grounding only for the fictional "aerogel salt".
16. **NASA Science — Landing On Mars: A Tricky Feat!** https://science.nasa.gov/solar-system/skywatching/night-sky-network/landing-on-mars-a-tricky-feat/
    Thin-atmosphere EDL challenge.
17. **NASA Science — How We Land on Mars.** https://science.nasa.gov/planetary-science/programs/mars-exploration/mission-timeline/how-we-land-on-mars/
    Heritage heat shield, parachute, radar, rocket-descent sequence.
18. **NASA — The Mars Relay Network Connects Us to NASA's Martian Explorers.** https://www.nasa.gov/missions/the-mars-relay-network-connects-us-to-nasas-martian-explorers/
    Most surface data is relayed through Mars orbiters to the Deep Space Network. Historical relay throughput per rover (survey, older figures: Odyssey ≈ 56 Mbit/sol, MRO ≈ 49 Mbit/sol) is in the arXiv survey "Communications for the Planet Mars: Past, Present, and Future" (https://arxiv.org/pdf/2211.14245); treat as indicative, not current.
19. **ESA — Facts about Mars (Mars Express).** https://m.esa.int/Our_Activities/Space_Science/Mars_Express/Facts_about_Mars
    Alternative figures: 3.711 m/s², CO₂ 95.32 %.
20. **Lemmon et al., MER optical-depth record** (via NASA NTRS presentation, 20160013317). https://ntrs.nasa.gov/api/citations/20160013317/downloads/20160013317.pdf
    Typical non-storm optical depth 0.2–1.
21. **Dust particle size and optical depth on Mars retrieved by the MSL Navigation Cameras** (arXiv 1905.01073). https://arxiv.org/pdf/1905.01073
    Gale τ ≈ 0.4 minimum to > 1.25 maximum over a non-global-storm year. See also Lemmon, "The Mars Science Laboratory record of optical depth measurements via solar imaging" (arXiv 2309.07378).
22. **NASA/JPL — Opportunity Hunkers Down During Dust Storm** (2018). https://www.jpl.nasa.gov/news/opportunity-hunkers-down-during-dust-storm/
    τ ≈ 10.8 estimated 10 Jun 2018 vs. > 5.5 in 2007.
23. **Hassler et al. (2014), Science 343 (6169) — Mars' Surface Radiation Environment Measured with the MSL Curiosity Rover.** https://ntrs.nasa.gov/citations/20180007641
    0.21 ± 0.04 mGy/day; 0.64 ± 0.12 mSv/day (also in the DLR record https://elib.dlr.de/106090 which gives 1.84 ± 0.3 mSv/day for cruise).
24. **NASA NTRS — The Martian Radiation Environment** (Simonsen). https://ntrs.nasa.gov/api/citations/20240009831/downloads/NAS%20BPS%20Simonsen%20v4%20strives.pdf
    Context: ISS ≈ 1.3 mSv/day; Mars surface ≈ 0.6 mSv/day.
25. **Canadian Space Agency — Planet Mars in numbers.** https://asc-csa.gc.ca/eng/multimedia/search/image/4982
    Earth–Mars distance 55.7 to 401 million km.
26. **BBC-sourced summary of Perseverance EDL** (landing-day delay ≈ 700 s). https://guildofscientifictroubadours.com/2020/12/27/nasas-mars-rover-trains-for-seven-minutes-of-terror/
    Secondary; use only as a cross-check of the derived light time.
27. **NASA conjunction moratorium dates** as reported for 2021 (2–14 Oct, some to 16 Oct) and 2023 (11–25 Nov). https://www.inverse.com/science/mars-solar-conjunction-means-lights-off-at-nasa and https://www.sciencealert.com/?p=112172
    Secondary reporting of NASA statements.
28. **EarthSky / Earth.com — 2019 moratorium 28 Aug–7 Sep.** https://earthsky.org/?p=319629
    Secondary reporting of NASA/JPL statement.
29. **Lorenz et al., "Lander and rover histories of dust accumulation on and removal from solar arrays on Mars"** (Planetary and Space Science). https://hal.sorbonne-universite.fr/hal-03369920
    Typical −0.2 %/sol, range 0.05–2 %/sol; cleaning events contingent on local meteorology.
30. **Lorenz, "Planning Multi-Year Solar Powered Missions on Mars: The Challenge of Dust"** (SpaceOps 2023). https://publications.spaceops.org/2023/download_by_id.php?id=0293
    Pathfinder ≈ 0.25 %/sol; typical 0.2 %/sol.
31. **ASU Mars Education — Water ice.** https://marsed.mars.asu.edu/mep/ice
    Poleward of 60° latitude, ice concentrations exceed ~20 % almost everywhere; Phoenix at 68° N found ice after scraping a few inches of dry soil.
32. **Mellon et al. (2009), prelanding ice-table assessment, Phoenix site** (USGS). https://pubs.usgs.gov/publication/70035046
    Ground ice expected 2–6 cm below surface at Phoenix.
33. **NASA/MIT — MOXIE completes Mars mission.** https://aeroastro.mit.edu/news-impact/oxygen-generating-experiment-moxie-completes-mars-mission
    122 g O₂, 16 runs, 12 g/h peak, ≥ 98 % purity.
34. **Hecht et al. (2009), Science 325, 64–67 — Detection of perchlorate… at the Phoenix lander site.** https://experts.arizona.edu/en/publications/detection-of-perchlorate-and-the-soluble-chemistry-of-martian-soi/
    0.4–0.6 wt % perchlorate by mass in leached soil samples.
35. **NASA NTRS — Oxychlorine Species on Mars: The Gale Crater Story.** https://ntrs.nasa.gov/api/citations/20150001957/downloads/20150001957.pdf
    Oxychlorine content varies by Gale sample (~0.35 to ~1.4 wt %; extraction from the abstract is partial, verify against the full paper before quoting).
36. **arXiv 2504.16955 — On the feasibility of laser satellite communications from the Martian surface.** https://arxiv.org/pdf/2504.16955
    Secondary summary of Viking-era dust: τ ≈ 0.5–1 for much of the year, storms τ ≈ 3–4, local storms about a day. Low-confidence, replace with a primary Viking or PDS source.
37. **Scientific American — NASA's Opportunity Rover Still Silent on Mars** (2018). https://www.scientificamerican.com/article/nasa-rsquo-s-opportunity-rover-still-silent-on-mars
    Storm still only beginning to die down about two months in; last measured τ 10.8 on 10 June.
38. **NASA/JPL — Perseverance Heat Shield Separates (PIA24317).** https://photojournal.jpl.nasa.gov/catalog/PIA24317
    Entry at ~20 000 km/h; EDL ~7 min; parachute at ~240 s, ~11 km, ~1 512 km/h.
39. **AFP via Kuwait Times — "7 minutes of terror".** https://kuwaittimes.com/7-minutes-of-terror-perseverance-rovers-nail-biting-landing-phase/
    Peak heat-shield ~1 300 °C; parachute only slows to ~300 km/h. Secondary reporting.

### Remaining source gaps — do not silently fill

- `mars.dust_tau`: ranges above are literature values. For design-grade numbers, still pick a specific PDS product (Mastcam-Z, MEDA, REMS or MSL solar-imaging record) and log wavelength, site, season and retrieval method. Lemmon's Perseverance Mastcam-Z record (https://data.mendeley.com/datasets/gktjp9jptb) is a candidate.
- Primary source and wavelength for the 10.8 (2018) and > 5.5 (2007) values.
- Global dust-storm start/end dates and duration, local storm duration (primary source), and Viking-era τ values (currently secondary [36]).
- Radiation event extremes (solar particle events) and any radiation number from a site other than Gale Crater.
- Full-paper confirmation of the Gale oxychlorine wt % range [35].
- Numeric abundance of iron oxides, sulfates, clays, regolith and water ice for a general Mars-wide crafting system. Use site-specific data.
- Numeric mining yield, processing energy, recipe quantities, crafting costs and fantasy-material performance: game-design placeholders (`GU`), not planetary facts.
- Specific aerogel specification (density, conductivity) for the selected design, beyond the JPL headline figures in [15].
- Current (not historical) relay-orbiter throughput and availability numbers.
- Any other player-visible physical number not directly supported by the sources above.

**Submission check**

- [x] Seven required sections present.
- [x] Stable IDs used for major facts, materials and hazards.
- [x] Every numeric physical fact has a source or an explicit `UNSOURCED` marker.
- [x] Fantasy items are marked `real = no` and grounded in real principles.
- [x] Porting checklist gives the smallest rule change rather than a redesign.
- [x] Values re-verified and gaps filled where sources were found (2026-10-22).
- [ ] Save this `.md` file in the shared folder and post it to the WhatsApp group.
- [ ] Verify the Moon team's existing entry format before finalizing the three book entries.
- [ ] Replace remaining source gaps only after locating the exact primary dataset/paper.

---

## Appendix A — Revision log (removable)

| item | was | now | why |
|---|---|---|---|
| mars.year_length | 669.6 sols | **668.6 sols** | 686.98 d ÷ 1.02749 d/sol = 668.6 |
| mars.day_length | 24.6 h ("rounded") | **24.66 h (24 h 39 min 35 s)** | Fact sheet 24.6597 h |
| mars.axial_tilt | 25° | 25.19° | Fact sheet precision |
| Perchlorate (Phoenix) | ~0.6 wt % | **0.4–0.6 wt %** | Hecht et al. 2009 |
| Radiation | ~210 µGy/day only | 0.21 ± 0.04 mGy/day **plus** 0.64 ± 0.12 mSv/day; period is ~300 sols | Hassler et al. 2014 |
| Conjunction | "a few weeks" blackout | **≈ 10–14 day command moratorium**; quiet comms for a few weeks | NASA statements 2019/2021/2023 |
| Conjunction frequency | (implied "every two years") | **~26 months (779.94 d)** | Synodic period |
| Earth–Mars distance min/max | UNSOURCED | **54.6 / 401.4 million km** | Fact sheet |
| Light time min/max | UNSOURCED | **3.04 / 22.3 min** | t = d / c |
| Dust τ | UNSOURCED | **0.2–1 background; > 5.5 (2007); 10.8 (2018)** | Literature, with caveats |
| Panel dust loss | UNSOURCED | **0.2 %/sol typical (0.05–2)** | Lorenz et al. |
| Global storm duration | UNSOURCED | **months (2018 event)** | NASA/JPL, SciAm |
| EDL | "minutes-scale" | **~7 min, Perseverance profile** | NASA/JPL |
| Water ice | "site dependent" | Added latitude rule (>60°: > ~20 %; Phoenix ~5 cm) | Odyssey, Phoenix |
| MOXIE | qualitative | 122 g, 16 runs, 12 g/h, ≥ 98 % | NASA/MIT |
| Irradiance | 586.2 only | adds ≈ 490–713 W/m² orbit range (derived) | Fact sheet geometry |
| Source list | Sources 1/7 and 2/10/13 were duplicates; access date 2026-10-19 | Distinct sources added [19]–[39]; access date 2026-10-22 | Traceability |
| Formatting | Pandoc grid tables, `(t=d/c)` | GitHub pipe tables, plain `t = d / c` | Readability |