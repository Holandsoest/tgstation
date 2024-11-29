/turf/open/sludge
	name = "Sludge"
	gender = PLURAL
	desc = "Looks sticky, discusting, and unsafe."

	icon = 'icons/turf/floors/sludge.dmi'
	icon_state = "lava-255"

	slowdown = 10

	bullet_bounce_sound = 'sound/items/tools/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

	var/sludge_damage_L5 = 0.05			/// How much damage we deal to living mobs stepping/standing on us.

	var/disturbed_layer = 0				/// The longer you disturb the sludge, the quicker it pulls you in. [0..3]
	var/disturbed_pull_multiplier = 0.05/// How much we pull mobs down into the sludge if they don't move.



/turf/open/sludge/Initialize(mapload)
	. = ..()

/turf/open/sludge/Destroy()
	return ..()

/turf/open/sludge/ex_act(severity, target)
	return FALSE
