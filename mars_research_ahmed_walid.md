## 1. Environment table

Cells hold value, unit and a short condition only. Derivations, caveats and correction history are in "Notes on Section 1" below and in Appendix A/B. The `accessed` column reads `unverified` unless the content was actually read on the stated date (see Section 7, "Access status"). Value types: **measured** (instrument/mission), **derived** (computed here), **estimated** (mission-team estimate).

| id | quantity | value | unit | conditions | source | accessed | confidence |
|---|---|---|---|---|---|---|---|
| mars.gravity | Mean surface gravity | 3.73 | m/s² | NASA fact-sheet mean; ESA quotes 3.711 (different reference radius) | [1], [19] | unverified | High |
| mars.day_length | Solar day (sol) | 24.66 (24 h 39 min 35.244 s) | hours | Fact sheet 24.6597 h; sidereal 24.6229 h | [1], [2] | unverified | High |
| mars.year_length | Orbital year | 668.6 | sols | Derived; equals 686.98 Earth days (sidereal) | [1], derived | unverified | High |
| mars.axial_tilt | Axial tilt (obliquity) | 25.19 | degrees | Orbital eccentricity 0.0935 makes seasons unequal | [1] | unverified | High |
| mars.atmosphere.co2 | Carbon dioxide | 95.1% by volume | % by volume | Fact-sheet composition; MSL/SAM 95.32 % (ESA) | [1], [19] | unverified | High |
| mars.atmosphere.n2 | Nitrogen | 2.59 | % by volume | Fact-sheet composition | [1] | unverified | High |
| mars.atmosphere.ar | Argon | 1.94 | % by volume | Fact-sheet composition | [1] | unverified | High |
| mars.atmosphere.o2 | Oxygen | 0.16 | % by volume | Trace; not breathable | [1] | unverified | High |
| mars.atmosphere.co | Carbon monoxide | 0.06 | % by volume | Fact-sheet composition | [1] | unverified | High |
| mars.surface_pressure | Surface pressure | 6.36 | mbar | Mean-radius reference; seasonal 4.0–8.7 mbar | [1] | unverified | High |
| mars.atmosphere_density | Surface density | ~0.016 ± 0.006 | kg/m³ | Approximate global reference; scale height 11.0 km | [1] | unverified | Medium-high |
| mars.temperature.mean | Average temperature | ~214 (−59 °C) | K | Global-average fact-sheet value | [1] | unverified | High |
| mars.temperature.diurnal | Temperature range | 184–242 (−89 to −31 °C) | K | Viking 1 landing site, not a global limit | [1] | unverified | High |
| mars.solar_irradiance | Solar irradiance (mean) | 586.2 | W/m² | Top of atmosphere, mean orbital distance | [1] | unverified | High |
| mars.solar_irradiance_range | Solar irradiance, perihelion to aphelion | ≈ 490–713 | W/m² | Derived; top of atmosphere | [1], derived | unverified | Medium-high |
| mars.dust_tau.background | Dust/aerosol optical depth (τ), non-storm | typically 0.2–1 | dimensionless | Visible band; MER record, site- and season-specific | [4], [20] | unverified | Medium-high |
| mars.dust_tau.gale | Dust optical depth (τ), Gale crater | ≈0.4 to >1.25 | dimensionless | Year without global storm; min near Ls ≈ 135°, max at Ls > 200°; MSL Navcam retrievals | [21] | unverified | Medium-high |
| mars.dust_tau.storm | Dust optical depth (τ), global storms | 10.8 (2018-06-10); 2007: ≈5–5.5 or >5.5 | dimensionless | Opportunity, single site, mission-team estimate (estimated, not a published measurement); Pancam 440/750 nm filters | [41], [22], [43] | 2026-10-25 ([41] only) | Medium |
| mars.radiation_dose | Surface absorbed dose rate (tissue) | 0.21 ± 0.04 | mGy/day | Curiosity RAD, ~300 sols from 7 Aug 2012, solar maximum | [6], [23] | unverified | High |
| mars.radiation_dose_equiv | Surface dose-equivalent rate | 0.64 ± 0.12 | mSv/day | Same RAD period; cruise 1.84 ± 0.3; ISS ≈ 1.3 | [6], [23], [24] | unverified | High |
| mars.earth_distance_min | Earth–Mars minimum distance | 54.6 | million km | Fact-sheet theoretical bound; observed approach ≈ 55.7 | [1], [25] | unverified | High |
| mars.earth_distance_max | Earth–Mars maximum distance | 401.4 | million km | Near solar conjunction | [1], [25] | unverified | High |
| mars.earth_distance_opposition | Mean distance at opposition | 78.34 | million km | Fact sheet | [1] | unverified | High |
| mars.synodic_period | Earth–Mars synodic period | 779.94 | days | About 26 months | [1] | unverified | High |
| mars.light_time_min | One-way light time, minimum | 3.04 (182 s) | minutes | Derived, t = d / c; 3.10 min at 55.7 million km | [1], derived | unverified | High |
| mars.light_time_max | One-way light time, maximum | 22.3 (1339 s) | minutes | Derived, t = d / c; mean at opposition 4.36 min | [1], [26], derived | unverified | High |
| mars.conjunction_blackout | Solar-conjunction commanding moratorium | ≈ 10–14 | days | NASA moratorium in 2019, 2021, 2023; secondary reporting | [8], [27], [28] | 2026-10-25 ([27], 2023 only) | Medium-high |
| mars.wind_speed_summer | Wind speed | 2–7 | m/s | Viking landing-site range, summer | [1] | unverified | High |
| mars.wind_speed_fall | Wind speed | 5–10 | m/s | Viking landing-site range, fall | [1] | unverified | High |
| mars.wind_speed_storm | Wind speed during dust storm | 17–30 | m/s | Viking landing-site fact-sheet range | [1] | unverified | Medium-high |
| mars.solar_array_dust_loss | Solar-array output loss from dust | typical 0.2 (range 0.05–2) | %/sol | Landed-mission records; cleaning events site-dependent | [29], [30] | unverified | High |

**Notes on Section 1** (moved out of table cells)

- *Year length.* 686.98 d × 86 400 s ÷ 88 775.244 s = 668.60 sols (derived). The tropical year is 686.97 d / 668.59 sols; commonly rounded to 669 sols. The separate `mars.year_length_days` row was a duplicate and was removed; 686.98 Earth days now sits in the `mars.year_length` conditions.
- *Gravity.* GM/R² at mean radius gives 3.73; equatorial 3.69, polar 3.73. ESA's 3.711 uses a differently defined reference radius.
- *Temperature.* Black-body equilibrium temperature is 209.8 K; the ~214 K value is the fact-sheet global average.
- *Irradiance range (derived).* S = 1361 W/m² × (1 AU / r)², using fact-sheet perihelion 206.650 and aphelion 249.261 million km. Surface values are lower because of dust.
- *Dust τ.* The background 0.2–1 range is from the MER five-Mars-year record [20]. The Gale range [21] comes from MSL Navcam retrievals in a year without a global storm and is site- and season-specific. A τ figure must always name site, season, instrument and wavelength. Direct-beam transmission is about e^−τ (τ = 3 → ~5 % per NASA/JPL [42]; τ = 10.8 → ~0.002 %).
- *The 10.8 value.* NASA/JPL states it was estimated from Opportunity Pancam images of the Sun on 10 June 2018 (sol 5111) and calls it the largest the rover had recorded [41]. No peer-reviewed paper or PDS data product for this number was found in this review, so it stays labelled a **mission-team estimate**. The caption names the 440 nm and 750 nm Pancam filters but does not say which wavelength 10.8 refers to. For 2007, JPL text says "above 5.5" [22], while a Planetary Society report quotes M. Lemmon as 5 to 5.5 [43]; the sources disagree, so both are shown.
- *Radiation.* One rover's record at one site during solar maximum; a baseline, not a forecast. Mostly galactic cosmic rays.
- *Distance.* 54.6 million km = Mars perihelion 206.65 − Earth aphelion 152.10 (54.55), a theoretical bound. 401.4 = 249.26 + 152.10 (401.36).
- *Light time cross-check.* Perseverance landing-day delay ≈ 700 s (≈ 11.7 min), secondary [26].
- *Conjunction.* NASA's "command moratorium" is about two weeks: 28 Aug–7 Sep 2019 (~10 d), 2–14 Oct 2021 (some missions to 16 Oct), 11–25 Nov 2023 (14 d). NASA also describes a "few weeks" of quieter communication around it; that is the quiet period, not the moratorium. The 2023 dates were confirmed in this review on a page quoting NASA [27]; the 2019 and 2021 dates remain secondary and unverified here.
- *Array dust loss.* Pathfinder ≈ 0.25 %/sol; 0.2 %/sol held for InSight's first 800 sols, Phoenix and much of MER. MER had cleaning events (dust devils, gusts); the InSight site did not.

**Section 1 research gaps**

- PDS product, wavelength, site, season and retrieval method for design-grade `mars.dust_tau.*` values (Lemmon's Perseverance Mastcam-Z record, https://data.mendeley.com/datasets/gktjp9jptb, is a candidate).
- Peer-reviewed or PDS source for the 2018 τ = 10.8 and a reconciled 2007 value.
- Radiation values away from Gale crater and for solar particle events.
- Current relay-orbiter throughput and availability.

---

## 2. Materials table

**Important:** `found` and `abundance` are location-dependent. Do not present a global abundance unless the cited source supports it; `UNSOURCED` means no supported figure. Crafting costs are provisional game-economy units (`GU`), not physical quantities. Optical-depth (τ) values for airborne dust live in Section 1 (`mars.dust_tau.*`), not in `abundance`. There is no separate `material.silica` entry: silica feedstock is taken from `material.regolith` (see notes).

| id | material | real | grounded_in | found | abundance | what it makes | crafting cost | unlocks | source |
|---|---|---|---|---|---|---|---|---|---|
| material.regolith | Regolith / soil | yes | Loose basaltic surface material | Surface; varies by site | UNSOURCED | Sintered bricks, berms, shielding; silica feedstock (fraction UNSOURCED) | 3 GU (provisional) | Basic shelter and shielding | [9] |
| material.iron_oxide | Iron-bearing oxides | yes | Iron (hydr)oxides in soils; give the red colour | Soil and rocks; site-dependent | UNSOURCED | Pigment; iron only with processing | 4 GU (provisional) | Pigment / metal-processing research | [2], [9] |
| material.dust | Fine airborne dust | yes | Dust transported by winds and storms | Atmosphere and surface | UNSOURCED (τ in Section 1) | Feedstock only after filtration | 1 GU collect; 3 GU filter (provisional) | Filter media / dust study | [4], [20], [22] |
| material.sulfates | Sulfate minerals | yes | Identified by landed missions | Selected soils and rocks | UNSOURCED | Chemical feedstock after processing | 4 GU (provisional) | Mineral processing | [9], [11] |
| material.clays | Clay minerals | yes | Identified in rocks by orbiter and rover science | Ancient aqueous terrains | UNSOURCED | Ceramic-like composites after processing | 5 GU (provisional) | Advanced composites | [11], [12] |
| material.water_ice | Water ice | yes | Odyssey neutron/gamma data; Phoenix (68° N) reached ice under a few cm of dry soil | Polar and high-latitude subsurface; depth cm to m | >~20 % ice poleward of ~60° latitude; no global figure | Water; oxygen and hydrogen via electrolysis | 5 GU mine; 4 GU purify (provisional) | Water reserve / electrolysis | [2], [31], [32] |
| material.co2_ice | Carbon-dioxide ice | yes | CO₂ freezes in polar and seasonal conditions | Seasonal polar caps | UNSOURCED | Sublimation gas; not a general resource | 4 GU (provisional) | Seasonal gas handling | [2] |
| material.co2_atmosphere | Atmospheric CO₂ | yes | Atmospheric composition; MOXIE (Perseverance) | Everywhere, but thin | 95.1% by volume | Oxygen via MOXIE-like electrolysis: 122 g over 16 runs, peak 12 g/h, ≥ 98 % purity; methane needs an H source | 6 GU processor (provisional) | Oxygen plant; fuel chemistry | [1], [3], [33] |
| material.perchlorate | Perchlorate salts | yes | Phoenix wet chemistry; Curiosity SAM oxychlorine phases | Detected at multiple sites | Phoenix 0.4–0.6 wt %; Gale ~0.35–1.4 wt % by sample; not global | Controlled-process oxidizer only | Remediation cost UNSOURCED | Hazard analysis / decontamination | [9], [14], [34], [35] |
| material.ferric_sinter | Ferric sinter | no | Inspired by iron-oxide-rich soil and regolith sintering | Heated regolith kiln | Not applicable | Durable bricks / abrasion-resistant panels | 6 GU + material.regolith (provisional) | Dust-resistant structure | [9], [2] |
| material.aerogel_salt | "Aerogel salt" | no | Inspired by real silica aerogel (JPL: ~99.8 % empty space) and sulfate/perchlorate chemistry | Sealed chemistry bench | Not applicable | Lightweight dust trap or thermal insert | 8 GU + material.regolith (silica fraction) (provisional) | Lightweight filter module | [11], [15] |

**Notes on Section 2**

- *`material.silica` (review comment 1).* The aerogel recipe previously named an undefined "silica feedstock". It is now linked to `material.regolith`. Silica content of regolith and extraction yield are UNSOURCED here; no silica abundance is claimed.
- *Water ice.* Poleward of ~60° latitude, Odyssey data show ice above ~20 % almost everywhere in the upper soil [31]. Phoenix scraped a few inches of dry soil before hitting ice; the pre-landing estimate was 2–6 cm [32]. Depth varies from centimetres to metres.
- *Atmospheric CO₂.* Methane needs a hydrogen source and a suitable process; none is claimed as demonstrated here. The MOXIE figures are a measured Perseverance result [33].
- *Perchlorate.* Phoenix reported 0.4–0.6 wt % in leachate [34]; Gale values come from partial abstract data [35] and need full-paper confirmation. Hazardous oxidizing salts: never treat raw dust as safe.
- *Aerogel.* JPL: ~39× more insulating than the best fiberglass; used to insulate Sojourner's electronics [15]. The combined material is fictional. Failure mode: brittle and loses performance when contaminated.

**Section 2 research gaps**

- Numeric Mars-wide abundance of regolith, iron oxides, sulfates, clays and CO₂ ice (use site-specific data).
- Silica content of regolith and extraction yield.
- Full-paper confirmation of the Gale oxychlorine range [35].
- Aerogel density and conductivity for the chosen design; all `GU` costs are game placeholders.

---

## 3. Hazards table

Ranges must be evidence-based. Where a defensible number was not verified it is `UNSOURCED`, not invented. Hazard ranges are not automatically a global environmental range. Longer rationale is in "Notes on Section 3".

| id | hazard | real | grounded_in | trigger | range | duration | tests | counters | source |
|---|---|---|---|---|---|---|---|---|---|
| hazard.local_dust_storm | Local dust storm | yes | Wind lifts dust; storms cut visibility and solar input | Dust optical depth / wind alert exceeds site threshold | Viking-era τ ≈ 3–4 (secondary); wind 17–30 m/s | Roughly a day (secondary, Medium-low) | visibility, solar_output, filter_load, navigation | Dust-sealed panel cover (higher cost); intake filter (lower cost) | [1], [20], [36] |
| hazard.global_dust_storm | Global dust storm | yes | Planet-encircling dust events cut sunlight | Global dust opacity reaches mission-defined threshold | Opportunity τ 10.8 (2018, mission-team estimate); 2007 ≈5–5.5 or >5.5 | Months: 2018 storm grew over ~1 month, stayed near peak ~3 weeks, then decayed over months | solar_output, visibility, battery_reserve, thermal_margin | Oversized battery (high cost); dispatchable backup source (high cost) | [41], [42], [22], [37] |
| hazard.panel_dust | Dust-covered solar panels | yes | Deposition lowers output; cleaning is site-dependent | Panel dust-load threshold reached | −0.2 %/sol typical (0.05–2); −2 % at 10 sols, −18 % at 100, −33 % at 200, −55 % at 400 | Until cleaned; natural cleaning not guaranteed | solar_output, battery_reserve | Manual brush (low cost); electrostatic/mechanical cleaner (higher cost) | [29], [30] |
| hazard.perchlorate_exposure | Perchlorate-contaminated dust / soil | yes | Detected by Phoenix and Curiosity; oxidizer and health concern | Sample or dust contacts suit, food/water path, or unsealed equipment | Phoenix 0.4–0.6 wt %; Gale ~0.35–1.4 wt %; global range UNSOURCED | UNSOURCED | contamination, suit_integrity, water_purity | Sealed sample canister (medium cost); decontamination station (high cost) | [9], [14], [34], [35] |
| hazard.cold_thin_atmosphere | Cold + thin atmosphere | yes | Low pressure and cold complicate exposed equipment | Component temperature or pressure crosses rated limit | ~214 K mean; 184–242 K at Viking 1; 6.36 mbar (4.0–8.7) | UNSOURCED | temperature, pressure_rating, heater_power | Insulated enclosure (medium cost); active heater (high cost) | [1] |
| hazard.landing_edl | Entry, descent, landing failure | yes | Atmosphere gives heating and drag but is too thin for a parachute alone | Vehicle enters without a compatible EDL sequence | Perseverance profile only; safe envelope UNSOURCED | About 7 min entry to touchdown (Perseverance) | heat_shield, parachute_load, landing_velocity, nav_error | Heat shield (high cost); parachute + terminal retropropulsion (high cost) | [16], [17], [38], [39], [40] |
| hazard.comms_delay | Earth–Mars signal delay | yes | Finite light speed delays control and acknowledgement | Remote command assumes real-time response | One-way 3.04–22.3 min; 4.36 min mean at opposition | Continuous; varies over 779.94-day synodic cycle | command_age, autonomy_level, link_state | Local autonomous controller (medium cost); queued command plan (low cost) | [1], [18] |
| hazard.solar_conjunction | Solar conjunction blackout/restriction | yes | Solar plasma can corrupt radio signals | Mission calendar enters conjunction window (~26 months) | Command moratorium ≈ 10–14 days (2019, 2021, 2023) | ≈ 10–14 days; exact dates per event | link_state, command_queue, autonomy_level | Preloaded safe-mode plan (low cost); onboard fault recovery (medium/high cost) | [8], [27], [28] |
| hazard.radiation | Ionizing radiation | yes | Curiosity RAD measured the surface environment | Dose meter exceeds mission threshold | 0.21 ± 0.04 mGy/day; 0.64 ± 0.12 mSv/day (Gale, ~300 sols); event extremes UNSOURCED | Accumulates with exposure | cumulative_dose, shield_integrity | Regolith berm (medium cost); shielded storm shelter (high cost) | [6], [23], [24] |
| hazard.redglass_haze | Redglass haze (fictional) | no | Real airborne dust and iron-oxide-rich particles; fictional hazard | Storm front + local terrain + damaged filter system | UNSOURCED; set by playtesting, not Mars data | UNSOURCED | visibility, filter_load, sensor_confidence | Spare filter pack (low cost); sheltered sensor mast (medium cost) | Grounding: [4], [2]; effect UNSOURCED |

**Notes on Section 3**

- *EDL (Perseverance, one mission, not a safe envelope).* Entry at ~20 000 km/h; parachute deployed ~240 s after entry at ~11 km altitude and ~1 512 km/h; the parachute slows the vehicle to about 320 km/h (200 mph) per NASA/JPL [40], so rockets and the sky crane finish the landing. An earlier draft said ~300 km/h from a news article; it was replaced with the NASA figure. Peak heat-shield temperature ~1 300 °C appears only in secondary reporting [39]; no primary source was located.
- *Local storms.* The τ ≈ 3–4 and one-day figures come from a secondary summary [36]; a primary Viking source was not located.
- *Global storm.* Timeline from NASA/JPL's MRO Mars Climate Sounder caption [42]; this replaces reliance on the Scientific American article [37].
- *Panel dust.* Compounded at 0.998 per sol. InSight's site showed no cleaning for ~800 sols.
- *Perchlorate.* Global minimum/maximum unknown.
- *Redglass haze.* No new physics or radiation; not a reported Martian phenomenon.

**Section 3 research gaps**

- Primary Viking (or PDS) source for τ ≈ 3–4 and local storm duration.
- Exact start/end dates of global storms from a primary source.
- Primary source for the peak heat-shield temperature [39] and a safe landing envelope.
- Solar-particle-event dose extremes.
- Primary NASA/JPL releases for the 2019 and 2021 moratorium dates.

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

**Format status:** the Moon team's book-entry file was not attached, so consistency with the Moon entry format has **not** been checked. The entries below keep this file's existing field layout (Principle / Rule of thumb / Crafting effect / Source / Dialogue); field names, order and length limits must be compared against the Moon entry before merging.

### book.mars.atmosphere

**Principle.** Mars has an atmosphere, but it is not a weaker version of Earth's that can be treated as breathable air. NASA's fact sheet lists it as about 95.1 % carbon dioxide, with a mean surface pressure of 6.36 mbar (seasonal range 4.0–8.7 mbar) and a surface density of about 0.016 ± 0.006 kg/m³; these values vary with season, elevation and location. The atmosphere matters in two opposite ways: it provides drag and causes entry heating, yet it is too thin for a parachute to finish the landing of a large vehicle by itself. During Perseverance's landing the parachute slowed the vehicle only to about 320 km/h (200 mph) according to NASA/JPL, and rockets finished the job. The atmosphere is also a chemical feedstock: the MOXIE experiment on Perseverance made 122 g of oxygen over 16 runs from atmospheric CO₂, peaking at 12 g/h at 98 % purity or better, using solid-oxide electrolysis. That is not free: it needs machinery, power and control.

**Rule of thumb.** Use sourced local pressure and density for atmospheric mechanics. Treat CO₂-to-oxygen as a powered processing recipe (MOXIE's demonstrated peak is 12 g/h), not a direct resource pickup. Landing is a sequence (heat shield, parachute, propulsion), never a single braking step.

**Crafting effect.** Unlock an atmosphere processor and a Mars-specific EDL module; keep oxygen as a manufactured resource.

**Source.** [1], [3], [16], [17], [33], [38], [40].

**Dialogue.** "The air is a resource, not a lungful."

### book.mars.dust

**Principle.** Martian dust is both a resource and a system-wide contaminant. Wind can lift fine material into the atmosphere, storms reduce visibility, and airborne dust changes the sunlight reaching a solar panel. Outside storms, dust/aerosol optical depth is typically around 0.2–1 [20]; at Gale crater, in a year without a global storm, it ranged from about 0.4 to above 1.25 [21]. The 2018 global storm reached an estimated 10.8 at Opportunity (a mission-team estimate, not a peer-reviewed measurement [41]), which leaves almost no direct sunlight. Deposited dust also lowers panel output steadily: landed missions typically lost about 0.2 % of array output per sol (range 0.05–2 %/sol), and only some sites got natural cleaning events from dust devils and gusts [29], [30]. Dust should therefore not be modelled as a visual effect or a single damage event: it changes energy planning, sensor confidence, maintenance demand and equipment exposure. Mars soil is not chemically uniform, and perchlorates detected by Phoenix (0.4–0.6 wt % in its soil leachate) and oxychlorine phases at Gale mean a sample cannot be assumed safe because it looks like ordinary dirt. A dust-opacity number must always name its site, season and instrument.

**Rule of thumb.** Panel output = clean-panel output × `dust_factor`, where `dust_factor` falls by about 0.2 % per sol of accumulation (0.998^100 ≈ 0.82; 0.998^200 ≈ 0.67) and resets only on cleaning. Treat 0.2 %/sol as typical, not guaranteed, and make the rate tunable between 0.05 and 2 %/sol. Track airborne dust, deposited dust and chemical contamination as separate states.

**Crafting effect.** Filters, panel cleaners, sealed sample containers and contamination checks become meaningful choices with different costs.

**Source.** [4], [9], [14], [20], [21], [22], [29], [30], [34], [35], [41], [42].

**Dialogue.** "The storm doesn't need to break the panel; it only needs to starve it."

### book.mars.comms_delay

**Principle.** Mars control is not a real-time conversation with Earth. Radio signals travel at the speed of light, so the one-way delay changes as Earth and Mars move around the Sun. NASA's fact sheet gives an Earth–Mars distance between 54.6 and 401.4 million km, which means a one-way delay of about 3.0 to 22.3 minutes (4.4 minutes at average opposition distance). Solar conjunction is a separate problem: when Mars is on the far side of the Sun, solar plasma can corrupt radio commands, and NASA holds a command moratorium of about two weeks (10–14 days in 2019, 2021 and 2023) with reduced communications for a few weeks around it. Conjunctions come roughly every 26 months (synodic period 779.94 days). Even a well-designed remote-control system needs safe local behaviour when commands are delayed, stale or unavailable. Real missions handle this by sending about two weeks of instructions before conjunction and then waiting.

**Rule of thumb.** For signal delay use t = d / c, with d in km and c = 299 792.458 km/s (for example 54.6 million km → 182 s; 401.4 million km → 1339 s). A command carries a timestamp and an expiry/validity rule. If its age exceeds the allowed window, the vehicle holds a safe state or runs a preloaded plan rather than blindly executing stale instructions. During conjunction, queue non-urgent commands and rely on onboard fault handling. For game balance, a 3-to-22-minute one-way latency range is sourced; anything beyond that is design choice.

**Crafting effect.** A communications relay improves link availability and data volume but cannot eliminate light-time delay; autonomy software and preloaded plans are distinct upgrades.

**Source.** [1], [8], [18], [26], [27], [28].

**Dialogue.** "Earth has answered. The answer just hasn't arrived yet."

---

## 6. Fantasy ideas (mechanic concepts only; not implementation)

These are fictional gameplay concepts anchored to real principles. They are not claims about actual Mars phenomena.

1. **Ferric sinter (`material.ferric_sinter`):** a heat-processed building composite inspired by iron-oxide-rich regolith and real sintering. Trade-off: durable dust-facing parts, but high processing energy and brittle failure under impact. Counter: reinforce with a second real-material input. No physical performance number assigned.
2. **Aerogel salt (`material.aerogel_salt`):** a fictional porous filter/thermal insert inspired by real silica aerogel (real property anchor: ~99.8 % empty space, strong insulation, used on the Sojourner rover) and mineral salts. Silica comes from `material.regolith`. Trade-off: light and useful for filtration/insulation, but contamination clogs pores and the material is fragile. Counter: replaceable filter cassette or a more robust, higher-cost metal mesh.
3. **Redglass haze (`hazard.redglass_haze`):** a fictional visibility/sensor-confidence event grounded in real airborne dust and iron-bearing particles. It must not introduce magic radiation or new physics. Gameplay test: visibility and sensor-confidence stats. Range and duration stay `UNSOURCED` until playtesting; never display them as real Mars measurements.
4. **Autonomy buffer:** a software "resource" rather than a physical substance. A larger buffer stores more pre-approved actions for comms outages, but takes engineering time and can execute an obsolete plan if its validity rules are weak. Grounded in real conjunction operations (about two weeks of pre-sent instructions); no invented physical values.

---

## 7. Sources and gaps

**Access status.** The earlier blanket access date (2026-10-22, originally 2026-10-19) has been withdrawn: it was not individually verified for the 39 sources. Every entry is `Accessed: unverified` unless it says otherwise. Only entries marked "read 2026-10-25" had their content read during the PR #2 review. A "read" mark means the specific claim named was checked, not that the whole source was audited.

**Numbering.** Original numbers are kept so earlier review comments still resolve. [7] is merged into [1], [10] into [2], and [13] is removed as a separate source; all citations were updated. Those three numbers are intentionally unused. [40]–[43] are new.

**Source types.** Primary = NASA/JPL/mission or peer-reviewed. Secondary = news, blog or aggregator.

1. **NASA/NSSDC — Mars Fact Sheet** (last updated 19 May 2025). https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
   Supports gravity, solar irradiance, orbital parameters, day length, obliquity, Earth–Mars distance extrema (54.6 and 401.4 million km; light times are derived with t = d / c, c = 299 792.458 km/s), atmospheric composition, pressure, density, temperature and Viking-site wind ranges. Accessed: unverified.
2. **NASA Science — Mars: Facts.** https://science.nasa.gov/mars/facts/
   General background (sol length, year length, tilt, seasons; red appearance linked to oxidized iron minerals; water-ice background). Numeric values use the Fact Sheet [1] where they differ. Accessed: unverified.
3. **NASA — Mars Oxygen In-Situ Resource Utilization Experiment (MOXIE).** https://www.nasa.gov/space-technology-mission-directorate/tdm/mars-oxygen-in-situ-resource-utilization-experiment-moxie/
   Electrochemical oxygen production from atmospheric CO₂. See also [33]. Accessed: unverified.
4. **NASA Planetary Data System (PDS).** https://pds.nasa.gov/
   Archive starting point. Select the exact instrument product before assigning dust optical-depth numbers for design use. Accessed: unverified.
5. **NASA Mars mission pages: Curiosity and Perseverance.** https://science.nasa.gov/mission/msl-curiosity/ and https://science.nasa.gov/mission/mars-2020-perseverance/
   Mission starting points for surface meteorology. Accessed: unverified.
6. **NASA Science — Radiation Measurements on Mars.** https://science.nasa.gov/resource/radiation-measurements-on-mars/
   ~210 µGy/day Curiosity RAD context. Primary reference: [23]. Accessed: unverified.
7. *Merged into [1].* (Same URL and the same distance/observational claims.)
8. **NASA — What's Mars Solar Conjunction, and Why Does It Matter?** https://www.nasa.gov/solar-system/whats-mars-solar-conjunction-and-why-does-it-matter/
   Radio interference, "command moratorium", quiet communications for a few weeks. Primary. Accessed: unverified.
9. **NASA NTRS — The Chemistry and Mineralogy of Mars Soils: A Tour of Landed Mission Results from the Last 45 years.** https://ntrs.nasa.gov/citations/20210022622
   Soil mineralogy, iron (hydr)oxides, sulfates, perchlorate findings. Accessed: unverified.
10. *Merged into [2].* (Same URL; red appearance from oxidized iron minerals.)
11. **NASA — What is the Chemistry and Mineralogy Instrument?** https://www.nasa.gov/missions/mars-science-laboratory/curiosity-rover/what-is-the-chemistry-and-mineralogy-instrument/
    Clays, sulfates, carbonates identified by Curiosity CheMin. Accessed: unverified.
12. **NASA — Curiosity Rover Finds Clues to Chilly Ancient Mars Buried in Rocks.** https://www.nasa.gov/missions/nasas-curiosity-rover-finds-clues-to-chilly-ancient-mars-buried-in-rocks/
    Clay/mineral evidence in ancient aqueous terrains; not a global abundance estimate. Accessed: unverified.
13. *Removed as a separate source.* Water-ice citations now point to [2], [31] and [32] directly.
14. **NASA — Signs of Perchlorates and Sulfur Containing Compounds.** https://science.nasa.gov/resource/signs-of-perchlorates-and-sulfur-containing-compounds/
    Curiosity and Phoenix detections. Accessed: unverified.
15. **NASA/JPL — Aerogel (Stardust "Aerogel" pages and "Ideas that gel").** https://www.jpl.nasa.gov/news/ideas-that-gel/ and https://solarsystem.nasa.gov/stardust/tech/aerogel
    Silica aerogel is 99.8 % empty space, ~39× more insulating than the best fiberglass, used to insulate the Sojourner rover's electronics. Conceptual grounding only for the fictional "aerogel salt". Accessed: unverified.
16. **NASA Science — Landing On Mars: A Tricky Feat!** https://science.nasa.gov/solar-system/skywatching/night-sky-network/landing-on-mars-a-tricky-feat/
    Thin-atmosphere EDL challenge. Accessed: unverified.
17. **NASA Science — How We Land on Mars.** https://science.nasa.gov/planetary-science/programs/mars-exploration/mission-timeline/how-we-land-on-mars/
    Heritage heat shield, parachute, radar, rocket-descent sequence. Accessed: unverified.
18. **NASA — The Mars Relay Network Connects Us to NASA's Martian Explorers.** https://www.nasa.gov/missions/the-mars-relay-network-connects-us-to-nasas-martian-explorers/
    Most surface data is relayed through Mars orbiters to the Deep Space Network. Historical relay throughput (Odyssey ≈ 56 Mbit/sol, MRO ≈ 49 Mbit/sol) is in the arXiv survey "Communications for the Planet Mars: Past, Present, and Future" (https://arxiv.org/pdf/2211.14245); indicative, not current. Accessed: unverified.
19. **ESA — Facts about Mars (Mars Express).** https://m.esa.int/Our_Activities/Space_Science/Mars_Express/Facts_about_Mars
    Alternative figures: 3.711 m/s², CO₂ 95.32 %. Accessed: unverified.
20. **Lemmon et al., MER optical-depth record** (via NASA NTRS presentation, 20160013317). https://ntrs.nasa.gov/api/citations/20160013317/downloads/20160013317.pdf
    Typical non-storm optical depth 0.2–1. Accessed: unverified.
21. **Dust particle size and optical depth on Mars retrieved by the MSL Navigation Cameras** (arXiv 1905.01073). https://arxiv.org/pdf/1905.01073
    Source for the Gale τ ≈ 0.4 to > 1.25 range over a non-global-storm year (`mars.dust_tau.gale`). See also Lemmon, "The Mars Science Laboratory record of optical depth measurements via solar imaging" (arXiv 2309.07378). Content not re-read in this review; accessed: unverified.
22. **NASA/JPL — Opportunity Hunkers Down During Dust Storm** (2018). https://www.jpl.nasa.gov/news/opportunity-hunkers-down-during-dust-storm/
    τ ≈ 10.8 estimated 10 Jun 2018 vs. "somewhere above 5.5" in 2007. Mission news release (primary but not peer-reviewed). The listed URL was not opened; the same text was read 2026-10-25 on a syndicated copy (marsdaily.com). For the number's provenance see [41].
23. **Hassler et al. (2014), Science 343 (6169) — Mars' Surface Radiation Environment Measured with the MSL Curiosity Rover.** https://ntrs.nasa.gov/citations/20180007641
    0.21 ± 0.04 mGy/day; 0.64 ± 0.12 mSv/day (also in the DLR record https://elib.dlr.de/106090 which gives 1.84 ± 0.3 mSv/day for cruise). Accessed: unverified.
24. **NASA NTRS — The Martian Radiation Environment** (Simonsen). https://ntrs.nasa.gov/api/citations/20240009831/downloads/NAS%20BPS%20Simonsen%20v4%20strives.pdf
    Context: ISS ≈ 1.3 mSv/day; Mars surface ≈ 0.6 mSv/day. Accessed: unverified.
25. **Canadian Space Agency — Planet Mars in numbers.** https://asc-csa.gc.ca/eng/multimedia/search/image/4982
    Earth–Mars distance 55.7 to 401 million km. Accessed: unverified.
26. **Summary of Perseverance EDL** (landing-day delay ≈ 700 s). https://guildofscientifictroubadours.com/2020/12/27/nasas-mars-rover-trains-for-seven-minutes-of-terror/
    Secondary (blog); use only as a cross-check of the derived light time. The earlier "BBC-sourced" label was not verified. Accessed: unverified.
27. **Secondary reporting of NASA conjunction moratorium dates:** 2021 (2–14 Oct, some to 16 Oct) at https://www.inverse.com/science/mars-solar-conjunction-means-lights-off-at-nasa and 2023 (11–25 Nov) at https://www.sciencealert.com/?p=112172
    Secondary. The ScienceAlert page (Business Insider repost quoting NASA) was read 2026-10-25 and confirms the 2023 moratorium of 11–25 Nov and the practice of sending two weeks of instructions beforehand. The Inverse page was not re-read (accessed: unverified). A primary NASA/JPL release was not located in this review.
28. **EarthSky / Earth.com — 2019 moratorium 28 Aug–7 Sep.** https://earthsky.org/?p=319629
    Secondary reporting of a NASA/JPL statement. Not re-read; accessed: unverified; primary release not located.
29. **Lorenz et al., "Lander and rover histories of dust accumulation on and removal from solar arrays on Mars"** (Planetary and Space Science). https://hal.sorbonne-universite.fr/hal-03369920
    Typical −0.2 %/sol, range 0.05–2 %/sol; cleaning events contingent on local meteorology. Accessed: unverified.
30. **Lorenz, "Planning Multi-Year Solar Powered Missions on Mars: The Challenge of Dust"** (SpaceOps 2023). https://publications.spaceops.org/2023/download_by_id.php?id=0293
    Pathfinder ≈ 0.25 %/sol; typical 0.2 %/sol. Accessed: unverified.
31. **ASU Mars Education — Water ice.** https://marsed.mars.asu.edu/mep/ice
    Poleward of 60° latitude, ice concentrations exceed ~20 % almost everywhere; Phoenix at 68° N found ice after scraping a few inches of dry soil. Educational summary of Odyssey data. Accessed: unverified.
32. **Mellon et al. (2009), prelanding ice-table assessment, Phoenix site** (USGS). https://pubs.usgs.gov/publication/70035046
    Ground ice expected 2–6 cm below surface at Phoenix. Accessed: unverified.
33. **NASA/MIT — MOXIE completes Mars mission.** https://aeroastro.mit.edu/news-impact/oxygen-generating-experiment-moxie-completes-mars-mission
    122 g O₂, 16 runs, 12 g/h peak, ≥ 98 % purity. Accessed: unverified.
34. **Hecht et al. (2009), Science 325, 64–67 — Detection of perchlorate… at the Phoenix lander site.** https://experts.arizona.edu/en/publications/detection-of-perchlorate-and-the-soluble-chemistry-of-martian-soi/
    0.4–0.6 wt % perchlorate by mass in leached soil samples. Accessed: unverified.
35. **NASA NTRS — Oxychlorine Species on Mars: The Gale Crater Story.** https://ntrs.nasa.gov/api/citations/20150001957/downloads/20150001957.pdf
    Oxychlorine content varies by Gale sample (~0.35 to ~1.4 wt %); extraction from the abstract is partial, verify against the full paper before quoting. Accessed: unverified.
36. **arXiv 2504.16955 — On the feasibility of laser satellite communications from the Martian surface.** https://arxiv.org/pdf/2504.16955
    Secondary summary of Viking-era dust: τ ≈ 0.5–1 for much of the year, storms τ ≈ 3–4, local storms about a day. Low confidence; a primary Viking or PDS source was not located in this review. Accessed: unverified.
37. **Scientific American — NASA's Opportunity Rover Still Silent on Mars** (2018). https://www.scientificamerican.com/article/nasa-rsquo-s-opportunity-rover-still-silent-on-mars
    Secondary: storm still only beginning to die down about two months in; last measured τ 10.8 on 10 June. Not re-read; the storm timeline is now backed by primary NASA/JPL caption [42]. Accessed: unverified.
38. **NASA/JPL — Perseverance Heat Shield Separates (PIA24317).** https://photojournal.jpl.nasa.gov/catalog/PIA24317
    Entry at ~20 000 km/h; EDL ~7 min; parachute at ~240 s, ~11 km, ~1 512 km/h. Not opened in this review; the same figures were confirmed in [40]. Accessed: unverified.
39. **AFP via Kuwait Times — "7 minutes of terror".** https://kuwaittimes.com/7-minutes-of-terror-perseverance-rovers-nail-biting-landing-phase/
    Secondary. Read 2026-10-25: it gives ~20 000 km/h entry and peak heat-shield ~1 300 °C (about 80 s in), but its parachute figure ("300 km/h") differs from NASA's ~320 km/h [40]. The 1 300 °C figure has no primary source yet; use [40] for parachute speed.
40. **NASA/JPL — Perseverance Deploys its Parachute (PIA24316, Illustration).** https://science.nasa.gov/resource/perseverance-deploys-its-parachute-illustration/
    Primary. Read 2026-10-25: EDL starts at nearly 20 000 km/h and ends about seven minutes after entry; the 21.5 m parachute deploys ~240 s after entry at ~11 km altitude and ~1 512 km/h and slows the vehicle to about 200 mph (320 km/h). Supports the parachute-speed claim in `book.mars.atmosphere` and `hazard.landing_edl`.
41. **NASA/JPL — Last Images Opportunity Took (PIA22930).** https://science.nasa.gov/photojournal/last-images-opportunity-took/
    Primary mission record. Read 2026-10-25: Pancam images (440 nm and 750 nm filters) were used to estimate τ ≈ 10.8 on 10 June 2018 (sol 5111). Mission-team estimate; no peer-reviewed paper found; wavelength of the 10.8 not stated.
42. **NASA/JPL — Mars Climate Sounder Studies 2018 Dust Storm (PIA22737).** https://pds-rings.seti.org/press_releases/pages/PIA22xxx/PIA22737.html
    Primary. Read 2026-10-25: complex growth over the first month, near peak for three weeks, then a multi-month decay; τ = 3 means about 5 % of sunlight directly reaches the surface. Mirror of the NASA photojournal caption.
43. **The Planetary Society — MER Update: Opportunity Pummeled by Massive Dust Storm** (14 Jun 2018). https://www.planetary.org/explore/space-topics/space-missions/mer-updates/2018/06-mer-update-opportunity-dust-storm-sleep.html
    Secondary. Read 2026-10-25: reports τ 10.8 as a record and quotes M. Lemmon on the 2007 high as 5 to 5.5; conflicts with JPL's "above 5.5" in [22].

### Cross-section source gaps — do not silently fill

The per-section gap lists above are subsets of this list.

- `mars.dust_tau`: ranges are literature values. For design-grade numbers, pick a specific PDS product (Mastcam-Z, MEDA, REMS or MSL solar-imaging record) and log wavelength, site, season and retrieval method. Lemmon's Perseverance Mastcam-Z record (https://data.mendeley.com/datasets/gktjp9jptb) is a candidate.
- Peer-reviewed or PDS source and wavelength for the 10.8 (2018) value; reconciliation of the 2007 value (5–5.5 vs > 5.5).
- Primary sources for: Viking-era τ and local storm duration [36]; the 2019 and 2021 moratorium dates [27], [28]; peak heat-shield temperature [39].
- Exact global dust-storm start/end dates from a primary source.
- Radiation event extremes (solar particle events) and any radiation number from a site other than Gale Crater.
- Full-paper confirmation of the Gale oxychlorine wt % range [35].
- Numeric abundance of iron oxides, sulfates, clays, regolith and CO₂ ice for a Mars-wide crafting system; silica content and yield from regolith.
- Numeric mining yield, processing energy, recipe quantities, crafting costs and fantasy-material performance: game-design placeholders (`GU`), not planetary facts.
- Specific aerogel specification (density, conductivity) beyond the JPL headline figures in [15].
- Current (not historical) relay-orbiter throughput and availability numbers.
- Content re-check of [21] (Gale τ range) against the paper itself; it was not re-read in this review.
- Moon book-entry format comparison (Moon file not attached).
- Contents of PR #3 (not accessible during this review).
- Any other player-visible physical number not directly supported by the sources above.

**Submission check**

- [x] Seven required sections present.
- [x] Stable IDs used for major facts, materials and hazards (one new ID added: `mars.dust_tau.gale`; one removed duplicate: `mars.year_length_days`).
- [x] Every numeric physical fact has a source or an explicit `UNSOURCED` marker (structural check done in this revision).
- [x] Fantasy items are marked `real = no` and grounded in real principles.
- [x] Porting checklist gives the smallest rule change rather than a redesign.
- [x] Duplicate references merged ([7]→[1], [10]→[2], [13] removed) and citations updated.
- [x] Blanket access date withdrawn; no access dates assigned without reading the source.
- [ ] Values fully re-verified against primary sources (only the items marked "read 2026-10-25" were checked; the rest are unverified).
- [ ] Book entries consistent with the Moon entry format (Moon file not available; comparison not done).
- [ ] Replace remaining source gaps after locating the exact primary dataset/paper.
- [ ] Save this `.md` file in the shared folder and post it to the WhatsApp group (not done).
- [ ] PR #3 reviewed (not accessible).

---

## Appendix A — Revision log, round 1 (removable)

| item | was | now | why |
|---|---|---|---|
| mars.year_length | 669.6 sols | 668.6 sols | 686.98 d ÷ 1.02749 d/sol = 668.6 |
| mars.day_length | 24.6 h ("rounded") | 24.66 h (24 h 39 min 35 s) | Fact sheet 24.6597 h |
| mars.axial_tilt | 25° | 25.19° | Fact sheet precision |
| Perchlorate (Phoenix) | ~0.6 wt % | 0.4–0.6 wt % | Hecht et al. 2009 |
| Radiation | ~210 µGy/day only | 0.21 ± 0.04 mGy/day plus 0.64 ± 0.12 mSv/day; period ~300 sols | Hassler et al. 2014 |
| Conjunction | "a few weeks" blackout | ≈ 10–14 day command moratorium; quiet comms for a few weeks | NASA statements 2019/2021/2023 |
| Conjunction frequency | (implied "every two years") | ~26 months (779.94 d) | Synodic period |
| Earth–Mars distance min/max | UNSOURCED | 54.6 / 401.4 million km | Fact sheet |
| Light time min/max | UNSOURCED | 3.04 / 22.3 min | t = d / c |
| Dust τ | UNSOURCED | 0.2–1 background; > 5.5 (2007); 10.8 (2018) | Literature, with caveats |
| Panel dust loss | UNSOURCED | 0.2 %/sol typical (0.05–2) | Lorenz et al. |
| Global storm duration | UNSOURCED | months (2018 event) | NASA/JPL, SciAm |
| EDL | "minutes-scale" | ~7 min, Perseverance profile | NASA/JPL |
| Water ice | "site dependent" | Added latitude rule (>60°: > ~20 %; Phoenix ~5 cm) | Odyssey, Phoenix |
| MOXIE | qualitative | 122 g, 16 runs, 12 g/h, ≥ 98 % | NASA/MIT |
| Irradiance | 586.2 only | adds ≈ 490–713 W/m² orbit range (derived) | Fact sheet geometry |
| Source list | Sources 1/7 and 2/10/13 were duplicates; access date 2026-10-19 | Distinct sources added [19]–[39]; access date 2026-10-22 | Traceability (access date later withdrawn, see Appendix B) |
| Formatting | Pandoc grid tables, `(t=d/c)` | GitHub pipe tables, plain `t = d / c` | Readability |
| Previously inline-tagged items | `[FILLED]` / `[CORRECTED]` notes in cells | Moved here | Filled: atmosphere.co, temperature.mean, irradiance range, dust_tau (background, storm), radiation_dose_equiv, earth distances, synodic period, light times, array dust loss, water-ice rule, MOXIE, EDL figures, global storm duration. Corrected: day length, year length, axial tilt, radiation baseline, conjunction moratorium, Phoenix perchlorate range |

## Appendix B — Revision log, PR #2 review round (removable)

| item | was | now | why |
|---|---|---|---|
| `material.silica` | Undefined "silica feedstock" in aerogel recipe | Linked to `material.regolith`; yield UNSOURCED | Review comment 1 |
| `material.dust` abundance | τ values in abundance cell | `UNSOURCED`; τ stays in Section 1 | Review comment 2 |
| `mars.year_length_days` | Duplicate row | Removed; 686.98 d in `mars.year_length` conditions | Review comment 3 |
| `mars.atmosphere.co2` | 95.1 in value cell | "95.1% by volume"; also in CO₂ `abundance` | Review comment 4 |
| MOXIE data | In `grounded_in` | In `what it makes` for `material.co2_atmosphere` (no separate production field exists) | Review comment 4 |
| `book.mars.atmosphere` | Contained t = d / c example | Removed; example kept in `book.mars.comms_delay` | Review comment 5 |
| Access dates | 2026-10-22 on all sources and rows | Withdrawn; `unverified` except items read 2026-10-25 | Review comment 6 |
| Gaps | One list at the end | Gap lists under Sections 1–3; end list labelled cross-section | Review comment 7 |
| Table cells | Long notes, derivations, tags | Short cells; prose notes below each table | Review comment 8 |
| Sources [7], [10], [13] | Duplicates / separate source | Merged into [1] / [2]; [13] removed; numbers kept unused | Review comment 9 |
| Parachute speed | ~300 km/h (AFP) | ~320 km/h (200 mph), NASA/JPL [40] | Review comment 13 |
| 10.8 τ | Cited to [22] only | Mission-team estimate; [41] primary record; wavelength unresolved | Review comments 10–11 |
| 2007 storm τ | > 5.5 | ≈5–5.5 or > 5.5 (sources disagree: [22], [43]) | Discrepancy found during review |
| Global storm timeline | "began ~30 May; two months in" (SciAm) | Growth ~1 month, peak ~3 weeks, multi-month decay [42] | Primary NASA/JPL caption |
| Gale τ range | Cited with [4], [20], [21] | Own row `mars.dust_tau.gale` citing [21]; [21] added to dust book entry | Review comment 12 |
| `book.mars.dust` | Said 10.8 "ended that rover's mission"; `0.9982 after 100 sols` | Mission-end claim removed (unsourced here); formula corrected to 0.998^100 ≈ 0.82 | Accuracy |
| Submission check | "Values re-verified" ticked | Unticked; partial verification stated | Review comment 14 |
| Book format | Not compared | Flagged incomplete; Moon file not attached | Review comment 15 |
| Sources [26], [39] | "BBC-sourced" label; "300 km/h" | Labelled secondary; discrepancy noted | Review comments 10, 13 |
