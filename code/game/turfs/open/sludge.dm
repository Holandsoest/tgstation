/turf/open/sludge
	name = "Sludge"
	gender = PLURAL
	desc = "Looks sticky, discusting, and unsafe."

	icon = 'icons/turf/floors/sludge.dmi'
	icon_state = "sludge-255"
	// smoothing_groups = SMOOTH_GROUP_SLUDGE //see code/__defines/icon_smoothing.dm
	// canSmoothWith = SMOOTH_GROUP_SLUDGE

	slowdown = 5

	bullet_bounce_sound = 'sound/items/tools/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

	var/depth = 1 // [1..5] how deeper the depth, the more difficult it is to get out
	var/stuck_chance = 20 //[percentage 0..20 ] to fail. This is later multiplied by the depth.
	var/steal_change = 30 //[percentage 0..100] to steal an item from the users inventory everytime src does something.

	var/sludge_damage_L5 = 0.05 // How much damage we deal to living mobs stepping/standing on us.

/turf/open/sludge/Initialize(mapload)
	. = ..()

/turf/open/sludge/Destroy()
	return ..()

/turf/open/sludge/ex_act(severity, target)
	return FALSE

/turf/open/sludge/CanAllowThrough(atom/movable/mover, border_dir)//FIXME: As AnturK said, i should not use this proc, but preferably atom/exit or atom/exited, because this should be pure (maybe not because this fork runs behind).
	. = ..()
	if(isliving(mover))
		var/turf/open/sludge/from_turf = get_turf(mover)

		//If we move from non-sludge, then we are always allowed on.
		if(!istype(from_turf, /turf/open/sludge))
			return .//unless the parent has something to say about it.

		//TODO: There is a chance mobs drop items. Hands and pockets and pulling, then bags pda and ID, then anything but skirt, then skirt.


		//Mobs sometimes sink the sludge they are going towards.
		if (depth != 5 && prob(50))
			depth  = depth + 1
			slowdown = depth * 5

		//Mobs always sink the sludge they are standing on.
		if (from_turf.depth != 5)
			from_turf.depth  = from_turf.depth + 1
			from_turf.slowdown = from_turf.depth * 5
			to_chat(mover, span_warning("You sink further into the sludge!"))

		//TODO: When mobs sink to much they get damaged
		else
			to_chat(mover, span_warning("Oh shit, you are stuck in the sludge!"))
			mover.Shake(pixelshiftx = 1, pixelshifty = 1, duration = 1 DECISECONDS)
			//TEMP till i figure out how to sufficate user when they do not have o2 gear...
			return FALSE

		//There is a chance mobs get stuck and cant move.
		if(prob(depth*stuck_chance))
			mover.Shake(pixelshiftx = 6-depth, pixelshifty = 6-depth, duration = 2 DECISECONDS)
			return FALSE
	return .

/turf/open/sludge/examine(mob/user)
	. = ..()
	if (depth == 1) . += span_notice("It is solidified mix of various fluids, and it looks solid, but that probably only counts for the top crust.")
	if (depth == 2) . += span_notice("It is sticky mix of various fluids, the crust looks disturbed, and it looks solid at some patches, but it is not.")
	if (depth == 3) . += span_notice("It is viscouse mix of various fluids.")
	if (depth == 4) . += span_notice("It is liquid but sticky mix of various fluids.")
	if (depth == 5) . += span_notice("It is runny but sticky mix of various fluids. Impossible to move in.")
	. += span_notice("It can be [EXAMINE_HINT("scooped")] with a beaker.")
