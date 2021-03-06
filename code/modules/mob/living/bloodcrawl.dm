//Travel through pools of blood. Slaughter Demon powers for everyone!

#define BLOODCRAWL 1
#define BLOODCRAWL_EAT 2

/mob/living/proc/phaseout(obj/effect/decal/cleanable/B)
	var/mob/living/kidnapped = null
	var/turf/mobloc = get_turf(src.loc)
	var/turf/bloodloc = get_turf(B.loc)
	if(Adjacent(bloodloc))
		src.notransform = TRUE
		spawn(0)
			src.visible_message("[src] sinks into the pool of blood.")
			playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
			var/obj/effect/dummy/slaughter/holder = PoolOrNew(/obj/effect/dummy/slaughter,mobloc)
			src.ExtinguishMob()
			if(src.buckled)
				src.buckled.unbuckle_mob()
			if(src.pulling && src.bloodcrawl == BLOODCRAWL_EAT)
				if(istype(src.pulling, /mob/living))
					var/mob/living/victim = src.pulling
					if(victim.stat == CONSCIOUS)
						src.visible_message("[victim] kicks free of the [src] at the last second!")
					else
						victim.loc = holder
						src.visible_message("<span class='warning'><B>[src] drags [victim] into the pool of blood!</B>")
						kidnapped = victim
			src.loc = holder
			src.holder = holder
			if(kidnapped)
				src << "<B>You begin to feast on [kidnapped]. You can not move while you are doing this.</B>"
				playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
				sleep(30)
				playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
				sleep(30)
				playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
				sleep(30)
				if(kidnapped) //Make sure it still exists after the sleeps
					src << "<B>You devour [kidnapped]. Your health is fully restored.</B>"
					src.adjustBruteLoss(-1000)
					src.adjustFireLoss(-1000)
					src.adjustOxyLoss(-1000)
					src.adjustToxLoss(-1000)
					kidnapped.ghostize()
					qdel(kidnapped)
				else
					src << "<B>You happily devour...nothing? Your meal vanished at some point!</B>"
			src.notransform = 0

/mob/living/proc/phasein(obj/effect/decal/cleanable/B)
	if(src.notransform)
		src << "<B>Finish eating first!</B>"
	else
		src.loc = B.loc
		src.client.eye = src
		src.visible_message("<span class='warning'><B>[src] rises out of the pool of blood!</B>")
		playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
		qdel(src.holder)
		src.holder = null

/obj/effect/decal/cleanable/blood/CtrlClick(mob/living/user)
	..()
	if(istype(user) && user.bloodcrawl)
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)


/obj/effect/decal/cleanable/trail_holder/CtrlClick(mob/living/user)
	..()
	if(istype(user) && user.bloodcrawl)
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)



/turf/CtrlClick(var/mob/living/user)
	..()
	if(istype(user) && user.bloodcrawl)
		for(var/obj/effect/decal/cleanable/B in src.contents)
			if(istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/trail_holder))
				if(user.holder)
					user.phasein(B)
					break
				else
					user.phaseout(B)
					break

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1
	invisibility = 60

obj/effect/dummy/slaughter/relaymove(mob/user, direction)
	if (!src.canmove || !direction) return
	var/turf/newLoc = get_step(src,direction)
	loc = newLoc
	src.canmove = 0
	spawn(1)
		src.canmove = 1

/obj/effect/dummy/slaughter/ex_act(blah)
	return
/obj/effect/dummy/slaughter/bullet_act(blah)
	return

/obj/effect/dummy/slaughter/singularity_act(blah)
	return

/obj/effect/dummy/slaughter/Destroy()
	return QDEL_HINT_PUTINPOOL
