/turf/open/sludge
	name = "Sludge"
	gender = PLURAL
	desc = "Looks sticky, discusting, and unsafe."

	icon = 'icons/turf/floors/sludge.dmi'
	icon_state = "lava-255"
	// smoothing_groups = SMOOTH_GROUP_SLUDGE //see code/__defines/icon_smoothing.dm
	// canSmoothWith = SMOOTH_GROUP_SLUDGE

	// slowdown = 10

	bullet_bounce_sound = 'sound/items/tools/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

	var/depth = 1 // [1..5] how deeper the depth, the more difficult it is to get out
	var/stuck_chance = 20 //[percentage 0..20] to fail. This is later multiplied by the depth.

	var/sludge_damage_L5 = 0.05			/// How much damage we deal to living mobs stepping/standing on us.

	var/disturbed_layer = 0				/// The longer you disturb the sludge, the quicker it pulls you in. [0..3]
	var/disturbed_pull_multiplier = 0.05/// How much we pull mobs down into the sludge if they don't move.



/turf/open/sludge/Initialize(mapload)
	. = ..()

/turf/open/sludge/Destroy()
	return ..()

/turf/open/sludge/ex_act(severity, target)
	return FALSE


/turf/open/sludge/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isliving(mover))
		// if(HAS_TRAIT(mover, TRAIT_SLUDGE_WALKER))//see code/__defines/traits.dm
		// 	return TRUE
		// if(mover.pulledby && HAS_TRAIT(mover.pulledby, TRAIT_SLUDGE_WALKER))
		// 	return TRUE

		if(prob(depth*stuck_chance))
			mover.Shake(duration = 1 SECONDS)
			if(depth == 5)
				loc.balloon_alert(mover, "stuggles hopelessly in the goop!")
				return FALSE
			loc.balloon_alert(mover, "sinks into the goop!")
			depth = depth + 1
			return FALSE
	return .
