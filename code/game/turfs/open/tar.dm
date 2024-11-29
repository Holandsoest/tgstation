/turf/open/tar
	name = "tar"
	gender = PLURAL
	desc = "Looks sticky, discusting, and unsafe."

	icon = 'icons/turf/floors/tar.dmi'
	icon_state = "lava-255"

	baseturfs = /turf/open/tar //lava all the way down
	slowdown = 5

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	light_on = FALSE
	bullet_bounce_sound = 'sound/items/tools/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	/// How much fire damage we deal to living mobs stepping on us
	var/lava_damage = 20
	/// How many firestacks we add to living mobs stepping on us
	var/lava_firestacks = 20
	/// How much temperature we expose objects with
	var/temperature_damage = 10000
	/// mobs with this trait won't burn.
	var/immunity_trait = TRAIT_LAVA_IMMUNE
	/// objects with these flags won't burn.
	var/immunity_resistance_flags = LAVA_PROOF
	/// the temperature that this turf will attempt to heat/cool gasses too in a heat exchanger, in kelvin
	var/lava_temperature = 5000
	/// The icon that covers the lava bits of our turf
	var/mask_icon = 'icons/turf/floors.dmi'
	/// The icon state that covers the lava bits of our turf
	var/mask_state = "lava-lightmask"
	/// The type for the preset fishing spot of this type of turf.
	var/fish_source_type = /datum/fish_source/lavaland
	/// The color we use for our immersion overlay
	var/immerse_overlay_color = "#a15e1b"
	rust_resistance = RUST_RESISTANCE_ABSOLUTE

/turf/open/tar/Initialize(mapload)
	. = ..()
	if(fish_source_type)
		AddElement(/datum/element/lazy_fishing_spot, fish_source_type)
	// You can release chrabs and lavaloops and likes in lava, or be an absolute scumbag and drop other fish there too.
	ADD_TRAIT(src, TRAIT_CATCH_AND_RELEASE, INNATE_TRAIT)
	refresh_light()
	if(!smoothing_flags)
		update_appearance()
	AddElement(/datum/element/immerse, icon, icon_state, "immerse", immerse_overlay_color)

/turf/open/tar/Destroy()
	for(var/mob/living/leaving_mob in contents)
		leaving_mob.RemoveElement(/datum/element/perma_fire_overlay)
		REMOVE_TRAIT(leaving_mob, TRAIT_NO_EXTINGUISH, TURF_TRAIT)
	return ..()

/turf/open/tar/update_overlays()
	. = ..()
	. += emissive_appearance(mask_icon, mask_state, src)
	// We need a light overlay here because not every lava turf casts light, only the edge ones
	var/mutable_appearance/light = mutable_appearance(mask_icon, mask_state, LIGHTING_PRIMARY_LAYER, src, LIGHTING_PLANE)
	light.color = light_color
	light.blend_mode = BLEND_ADD
	. += light
	// Mask away our light underlay, so things don't double stack
	// This does mean if our light underlay DOESN'T look like the light we emit things will be wrong
	// But that's rare, and I'm ok with that, quartering our light source count is useful
	var/mutable_appearance/light_mask = mutable_appearance(mask_icon, mask_state, LIGHTING_MASK_LAYER, src, LIGHTING_PLANE)
	light_mask.blend_mode = BLEND_MULTIPLY
	light_mask.color = COLOR_MATRIX_INVERT
	. += light_mask

/// Refreshes this lava turf's lighting
/turf/open/tar/proc/refresh_light()
	var/border_turf = FALSE
	var/list/turfs_to_check = RANGE_TURFS(1, src)
	if(GET_LOWEST_STACK_OFFSET(z))
		var/turf/above = GET_TURF_ABOVE(src)
		if(above)
			turfs_to_check += RANGE_TURFS(1, above)
		var/turf/below = GET_TURF_BELOW(src)
		if(below)
			turfs_to_check += RANGE_TURFS(1, below)

	for(var/turf/around as anything in turfs_to_check)
		if(islava(around))
			continue
		border_turf = TRUE

	if(!border_turf)
		set_light(l_on = FALSE)
		return

	set_light(l_on = TRUE)

/turf/open/tar/ChangeTurf(path, list/new_baseturfs, flags)
	var/turf/result = ..()

	if(result && !islava(result))
		// We have gone from a lava turf to a non lava turf, time to let them know
		var/list/turfs_to_check = RANGE_TURFS(1, result)
		if(GET_LOWEST_STACK_OFFSET(z))
			var/turf/above = GET_TURF_ABOVE(result)
			if(above)
				turfs_to_check += RANGE_TURFS(1, above)
			var/turf/below = GET_TURF_BELOW(result)
			if(below)
				turfs_to_check += RANGE_TURFS(1, below)
		for(var/turf/open/tar/inform in turfs_to_check)
			inform.set_light(l_on = TRUE)

	return result

/turf/open/tar/smooth_icon()
	. = ..()
	mask_state = icon_state
	update_appearance(~UPDATE_SMOOTHING)

/turf/open/tar/ex_act(severity, target)
	return FALSE
