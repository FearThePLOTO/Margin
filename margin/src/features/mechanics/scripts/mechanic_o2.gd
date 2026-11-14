class_name PlayerO2Mechanic
extends PlayerMechanic
## O2 supply, equipped as a loadout tool (tool.o2). The cave is its domain:
## inside a Cave zone the supply drains over time and NOTHING else changes —
## when the tank runs dry the mission fails directly (book.life_support.o2).
## The supply NEVER refills on its own — scattered O2 tank pickups
## (add_supply) are the only way it goes back up. Without the tool there is
## no supply at all, so entering a cave fails on the spot — you can't breathe.

var o2 := 1.0  # 0..1 remaining supply


func process(delta: float) -> void:
	if player.hazards.is_in_zone(&"Cave"):
		if not player.has_tool(&"tool.o2"):
			o2 = 0.0
			player.fail(&"book.life_support.o2",
					"Entered the Cave with no O2 supply — nothing down there is breathable.")
			return
		o2 = maxf(o2 - delta / GameConstants.O2_SUPPLY_S, 0.0)
		if o2 <= 0.0:
			player.fail(&"book.life_support.o2",
					"Breathable O2 ran dry inside the Cave. The tank buys time, not air — grab the scattered tanks and plan the crossing.")
	else:
		if not player.has_tool(&"tool.o2"):
			o2 = 0.0
		# Outside caves: nothing — pickups are the only refill.


## Fixed refill from a scattered O2 tank pickup (o2_tank.gd), clamped at full.
func add_supply(amount: float) -> void:
	o2 = minf(o2 + amount, 1.0)
