// This code handles different species in the game.

GLOBAL_LIST_EMPTY(roundstart_races)
/datum/species
	var/id	// if the game needs to manually check my race to do something not included in a proc here, it will use this
	var/limbs_id		//this is used if you want to use a different species limb sprites. Mainly used for angels as they look like humans.
	var/name	// this is the fluff name. these will be left generic (such as 'Lizardperson' for the lizard race) so servers can change them to whatever
	var/desc
	var/default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race
	var/limbs_icon_m
	var/limbs_icon_f
	var/icon_override
	var/icon_override_m
	var/icon_override_f
	var/list/possible_ages = ALL_AGES_LIST_WITH_CHILD
	var/sexes = TRUE		// whether or not the race has sexual characteristics. at the moment this is only 0 for skeletons and shadows
	var/patreon_req
	var/max_age = 75
	var/list/offset_features = list(OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0),\
	OFFSET_CLOAK = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), \
	OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), \
	OFFSET_NECK = list(0,0), OFFSET_MOUTH = list(0,0), OFFSET_PANTS = list(0,0), \
	OFFSET_SHIRT = list(0,0), OFFSET_ARMOR = list(0,0), OFFSET_HANDS = list(0,0), \
	OFFSET_ID_F = list(0,0), OFFSET_GLOVES_F = list(0,0), OFFSET_HANDS_F = list(0,0), \
	OFFSET_CLOAK_F = list(0,0), OFFSET_FACEMASK_F = list(0,0), OFFSET_HEAD_F = list(0,0), \
	OFFSET_FACE_F = list(0,0), OFFSET_BELT_F = list(0,0), OFFSET_BACK_F = list(0,0), \
	OFFSET_NECK_F = list(0,0), OFFSET_MOUTH_F = list(0,0), OFFSET_PANTS_F = list(0,0), \
	OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES = list(0,0), OFFSET_UNDIES_F = list(0,0))

	var/dam_icon
	var/dam_icon_f

	var/hairyness = null

	var/custom_clothes = FALSE //append species id to clothing sprite name
	var/custom_id
	var/use_f = FALSE //males use female clothes. for elves
	var/use_m = FALSE //females use male clothes. for aasimar women

	var/datum/voicepack/soundpack_m = /datum/voicepack/male
	var/datum/voicepack/soundpack_f = /datum/voicepack/female

	var/hair_color	// this allows races to have specific hair colors... if null, it uses the H's hair/facial hair colors. if "mutcolor", it uses the H's mutant_color
	var/hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.

	var/use_skintones = 0	// does it use skintones or not? (spoiler alert this is only used by humans)
	var/datum/blood_type/exotic_bloodtype //If my race uses a non standard bloodtype (A+, O-, AB-, etc)
	var/meat = /obj/item/reagent_containers/food/snacks/meat/human //What the species drops on gibbing
	var/liked_food = NONE
	var/disliked_food = GROSS
	var/toxic_food = TOXIC
	var/nutrition_mod = 1	// multiplier for nutrition amount consumed per tic
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	var/say_mod = "says"	// affects the speech message
	var/list/default_features = list() // Default mutant bodyparts for this species. Don't forget to set one for every mutant bodypart you allow this species to have.
	var/list/mutant_bodyparts = list() 	// Visible CURRENT bodyparts that are unique to a species. DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK SHIT UP! Changes to this list for non-species specific bodyparts (ie cat ears and tails) should be assigned at organ level if possible. Layer hiding is handled by handle_mutant_bodyparts() below.
	var/list/mutant_organs = list()		//Internal organs that are unique to this race.
	var/speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/brutemod = 1	// multiplier for brute damage
	var/burnmod = 1		// multiplier for burn damage
	var/coldmod = 1		// multiplier for cold damage
	var/heatmod = 1		// multiplier for heat damage
	var/stunmod = 1		// multiplier for stun duration
	var/bleed_mod = 1	// multiplier for blood loss
	var/pain_mod = 1	// multiplier for pain from wounds
	var/attack_type = BRUTE //Type of damage attack does
	var/punchdamagelow = 10      //lowest possible punch damage. if this is set to 0, punches will always miss
	var/punchdamagehigh = 10      //highest possible punch damage
	var/punchstunthreshold = 0//damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/siemens_coeff = 1 //base electrocution coefficient
	var/damage_overlay_type = "human" //what kind of damage overlays (if any) appear on our species when wounded?
	var/fixed_mut_color = "" //to use MUTCOLOR with a fixed color that's independent of dna.feature["mcolor"]
	var/deathsound //used to set the mobs deathsound on species change
	var/grab_sound //Special sound for grabbing
	var/datum/outfit/outfit_important_for_life /// A path to an outfit that is important for species life e.g. plasmaman outfit

	// species-only traits. Can be found in DNA.dm
	var/list/species_traits = list()
	// generic traits tied to having the species
	var/list/inherent_traits = list()
	/// components to add when spawning
	var/list/components_to_add = list()
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions

	var/attack_verb = "punch"	// punch-specific attack verb
	var/sound/attack_sound = 'sound/combat/hits/punch/punch (1).ogg'
	var/sound/miss_sound = 'sound/blank.ogg'

	var/enflamed_icon = "Standing"

	//Breathing!
	var/obj/item/organ/lungs/mutantlungs = null
	var/breathid = "o2"

	var/obj/item/organ/brain/mutant_brain = /obj/item/organ/brain
	var/obj/item/organ/heart/mutant_heart = /obj/item/organ/heart
	var/obj/item/organ/eyes/mutanteyes = /obj/item/organ/eyes
	var/obj/item/organ/ears/mutantears = /obj/item/organ/ears
	var/obj/item/mutanthands
	var/obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue
	var/obj/item/organ/tail/mutanttail = null

	var/obj/item/organ/liver/mutantliver
	var/obj/item/organ/stomach/mutantstomach
	var/obj/item/organ/guts/mutantguts
	var/override_float = FALSE

	//Bitflag that controls what in game ways can select this species as a spawnable source
	//Think magic mirror and pride mirror, slime extract, ERT etc, see defines
	//in __DEFINES/mobs.dm, defaults to NONE, so people actually have to think about it
	var/changesource_flags = NONE

	//Wording for skin tone on examine and on character setup
	var/skin_tone_wording = "Skin Tone"

	// value for replacing skin tone/origin term
	var/alt_origin

		/// List of bodypart features of this species
	var/list/bodypart_features

	/// List of descriptor choices this species gets in preferences customization
	var/list/descriptor_choices = list(
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/skin,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one,
		/datum/descriptor_choice/prominent_two,
		/datum/descriptor_choice/prominent_three,
		/datum/descriptor_choice/prominent_four,
	)

	/// List of organ customizers for preferences to customize organs.
	var/list/customizers
	/// List of possible body marking sets that the player can choose from in customization
	var/list/body_marking_sets = list(
		/datum/body_marking_set/none,
	)
	/// List all of body markings that the player can choose from in customization. Body markings from sets get added to here
	var/list/body_markings

	///can we be a youngling?
	var/can_be_youngling = TRUE
	var/child_icon = 'icons/roguetown/mob/bodies/c/child.dmi'
	var/child_dam_icon = 'icons/roguetown/mob/bodies/dam/dam_child.dmi'
	var/list/offset_features_child = list(OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0),\
	OFFSET_CLOAK = list(0,-4), OFFSET_FACEMASK = list(0,-4), OFFSET_HEAD = list(0,-4), \
	OFFSET_FACE = list(0,-4), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), \
	OFFSET_NECK = list(0,-4), OFFSET_MOUTH = list(0,-4), OFFSET_PANTS = list(0,0), \
	OFFSET_SHIRT = list(0,0), OFFSET_ARMOR = list(0,0), OFFSET_HANDS = list(0,-3), \
	OFFSET_ID_F = list(0,0), OFFSET_GLOVES_F = list(0,0), OFFSET_HANDS_F = list(0,-3), \
	OFFSET_CLOAK_F = list(0,-4), OFFSET_FACEMASK_F = list(0,-4), OFFSET_HEAD_F = list(0,-4), \
	OFFSET_FACE_F = list(0,-4), OFFSET_BELT_F = list(0,0), OFFSET_BACK_F = list(0,0), \
	OFFSET_NECK_F = list(0,-4), OFFSET_MOUTH_F = list(0,-4), OFFSET_PANTS_F = list(0,0), \
	OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES = list(0,0), OFFSET_UNDIES_F = list(0,0))

	///Statkey = bonus stat, - for malice.
	var/list/specstats = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_END = 0,STATKEY_CON = 0, STATKEY_INT = 0, STATKEY_SPD = 0, STATKEY_LCK = 0)
	///Statkey = bonus stat, - for malice.
	var/list/specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_END = 0,STATKEY_CON = 0, STATKEY_INT = 0, STATKEY_SPD = 0, STATKEY_LCK = 0)
	var/amtfail = 0

///////////
// PROCS //
///////////


/datum/species/proc/get_accent_list()
	return

/datum/species/proc/get_native_language()
	return

/datum/species/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/language = speech_args[SPEECH_LANGUAGE]

	if(message)
		var/list/accent_words = strings("spellcheck.json", "spellcheck")
		var/mob/living/carbon/human/H
		if(ismob(source))
			H = source

		for(var/key in accent_words)
			var/value = accent_words[key]
			if(islist(value))
				value = pick(value)

			if(findtextEx(message,key))
				if(H)
					to_chat(H, "<span class='warning'>[key] -> [value]</span>")
				amtfail++

			message = replacetextEx(message, "[key]", "[value]")

	if(message && message[1] && message[1] != "*")
		message = " [message]"

		var/list/accent_words = strings("accent_universal.json", "universal")
		for(var/key in accent_words)
			var/value = accent_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		var/list/species_accent = get_accent_list()
		var/mob/living/carbon/human/human
		var/special_accent = FALSE
		if(ismob(source))
			human = source
			if(human.accent != ACCENT_DEFAULT)
				species_accent = human.return_accent_list()
				special_accent = TRUE


		if(ismob(source))
			var/nativelang = get_native_language()
			var/language_check

			var/list/language_map = list(
				/datum/language/common = "Imperial",
				/datum/language/elvish = "Elfish",
				/datum/language/dwarvish = "Dwarfish",
				/datum/language/hellspeak = "Infernal",
				/datum/language/orcish = "Orcish",
				/datum/language/celestial = "Celestial",
				/datum/language/zybantine = "Zybean"
			)

			if (language in language_map)
				language_check = language_map[language]
			if(nativelang != language_check || special_accent)
				if(species_accent)
					for(var/key in species_accent)
						var/value = species_accent[key]
						if(islist(value))
							value = pick(value)

						message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
						message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
						message = replacetextEx(message, " [key]", " [value]")

	speech_args[SPEECH_MESSAGE] = trim(message)

/datum/species/proc/is_bodypart_feature_slot_allowed(mob/living/carbon/human/human, feature_slot)
	switch(feature_slot)
		if(BODYPART_FEATURE_FACIAL_HAIR)
			return (human.gender == MALE)
	return TRUE

/datum/species/proc/add_marking_sets_to_markings()
	if(!body_marking_sets)
		return
	if(!body_markings)
		body_markings = list()
	var/datum/body_marking_set/bodyset
	for(var/set_type in body_marking_sets)
		bodyset = GLOB.body_marking_sets_by_type[set_type]
		for(var/body_marking_type in bodyset.body_marking_list)
			body_markings |= body_marking_type

/datum/species/New()

	if(!limbs_id)	//if we havent set a limbs id to use, just use our own id
		limbs_id = name
	..()

/datum/species/proc/after_creation(mob/living/carbon/human/H)
	return TRUE

/proc/generate_selectable_species()
	for(var/I in subtypesof(/datum/species))
		var/datum/species/S = new I
		if(S.check_roundstart_eligible())
			GLOB.roundstart_races += S.name
			qdel(S)
	if(!GLOB.roundstart_races.len)
		GLOB.roundstart_races += "Humen"
	sortList(GLOB.roundstart_races, GLOBAL_PROC_REF(cmp_text_dsc))

/datum/species/proc/check_roundstart_eligible()
	return FALSE
//	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
//		return TRUE
//	return FALSE

/datum/species/proc/get_possible_names(gender = MALE) as /list
	SHOULD_CALL_PARENT(FALSE)
	var/static/list/male_names = world.file2list('strings/names/first_male.txt')
	var/static/list/female_names = world.file2list('strings/names/first_female.txt')

	return (gender == FEMALE) ? female_names : male_names

/datum/species/proc/random_name(gender = MALE, unique = FALSE)
	var/list/possible_names = get_possible_names(gender)
	if(!unique)
		return pick(possible_names)

	for(var/i in 1 to 10)
		. = pick(possible_names)
		if(!findname(.))
			break

/datum/species/proc/get_possible_surnames(gender = MALE) as /list
	var/static/list/last_names = world.file2list('strings/names/last.txt')

	return last_names

/datum/species/proc/random_surname(gender = MALE)
	var/list/possible_surnames = get_possible_surnames(gender)
	return " [pick(possible_surnames)]"

/datum/species/proc/get_spec_undies_list(gender)
	if(!GLOB.underwear_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	var/list/spec_undies = list()
	var/datum/sprite_accessory/X
	switch(gender)
		if(MALE)
			for(var/O in GLOB.underwear_m)
				X = GLOB.underwear_list[O]
				if(X)
					if(id in X.specuse)
						if(X.roundstart)
							spec_undies += X
		if(FEMALE)
			for(var/O in GLOB.underwear_f)
				X = GLOB.underwear_list[O]
				if(X)
					if(id in X.specuse)
						if(X.roundstart)
							spec_undies += X
	return spec_undies

/datum/species/proc/random_underwear(gender)
	var/list/spec_undies = get_spec_undies_list(gender)
	var/datum/sprite_accessory/X
	if(spec_undies.len)
		X = pick(spec_undies)
		return X.name

/datum/species/proc/get_spec_hair_list(gender)
	if(!GLOB.hairstyles_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/hair,GLOB.hairstyles_list, GLOB.hairstyles_male_list, GLOB.hairstyles_female_list)
	var/datum/sprite_accessory/X
	var/list/spec_hair = list()
	switch(gender)
		if(MALE)
			for(var/O in GLOB.hairstyles_male_list)
				X = GLOB.hairstyles_list[O]
				if(X)
					if(id in X.specuse)
						spec_hair += X
		if(FEMALE)
			for(var/O in GLOB.hairstyles_female_list)
				X = GLOB.hairstyles_list[O]
				if(X)
					if(id in X.specuse)
						spec_hair += X
	return spec_hair

/datum/species/proc/random_hairstyle(gender)
	var/list/spec_hair = get_spec_hair_list(gender)
	var/datum/sprite_accessory/X
	if(spec_hair.len)
		X = pick(spec_hair)
		return X.name

/datum/species/proc/regenerate_icons(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/update_damage_overlays(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/get_spec_facial_list(gender)
	if(!GLOB.facial_hairstyles_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hairstyles_list, GLOB.facial_hairstyles_male_list, GLOB.facial_hairstyles_female_list)
	var/datum/sprite_accessory/X
	var/list/spec_hair = list()
	switch(gender)
		if(MALE)
			for(var/O in GLOB.facial_hairstyles_male_list)
				X = GLOB.facial_hairstyles_list[O]
				if(X)
					if(id in X.specuse)
						spec_hair += X
		if(FEMALE)
			for(var/O in GLOB.facial_hairstyles_female_list)
				if(!istype(src, /datum/species/dwarf))
					X = null
				else
					X = GLOB.facial_hairstyles_list[O]
				if(X)
					if(id in X.specuse)
						spec_hair += X
	return spec_hair

/datum/species/proc/random_facial_hairstyle(gender)
	var/list/spec_hair = get_spec_facial_list(gender)
	var/datum/sprite_accessory/X
	if(spec_hair.len)
		X = pick(spec_hair)
		return X.name

/datum/species/proc/get_spec_accessory_list(gender)
	if(!GLOB.accessories_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/accessories, GLOB.accessories_list, GLOB.accessories_m, GLOB.accessories_f)
	var/datum/sprite_accessory/X
	var/list/spec_hair = list()
	switch(gender)
		if(MALE)
			for(var/O in GLOB.accessories_m)
				X = GLOB.accessories_list[O]
				if(X)
					if(id in X.specuse)
						spec_hair += X
			return spec_hair
		if(FEMALE)
			for(var/O in GLOB.accessories_f)
				X = GLOB.accessories_list[O]
				if(X)
					if(id in X.specuse)
						spec_hair += X
			return spec_hair

/datum/species/proc/get_spec_detail_list(gender)
	if(!GLOB.detail_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/detail, GLOB.detail_list, GLOB.detail_m, GLOB.detail_f)
	testing("get spec detail [id]")
	var/datum/sprite_accessory/X
	var/list/spec_hair = list()
	switch(gender)
		if(MALE)
			for(var/O in GLOB.detail_m)
				X = GLOB.detail_list[O]
				if(X)
					if(id in X.specuse)
						testing("added detail[X]")
						spec_hair += X
			return spec_hair
		if(FEMALE)
			for(var/O in GLOB.detail_f)
				X = GLOB.detail_list[O]
				if(X)
					if(id in X.specuse)
						spec_hair += X
			return spec_hair

/datum/species/proc/get_hexcolor(list/L)
	return L

/datum/species/proc/get_skin_list() as /list
	RETURN_TYPE(/list)
	return GLOB.skin_tones

/datum/species/proc/get_hairc_list()
	return GLOB.haircolor

/datum/species/proc/get_oldhc_list()
	return GLOB.oldhc

/datum/species/proc/oldhc2color(oldhc)
	var/list/L = get_oldhc_list()
	return L[oldhc]

/datum/species/proc/ears_list()
	if(!GLOB.ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.ears_list)
	var/list/spec_hair = list()
	var/datum/sprite_accessory/X
	for(var/O in GLOB.ears_list)
		X = GLOB.ears_list[O]
		if(X)
			if(id in X.specuse)
				spec_hair += X.name
	if(spec_hair.len)
		return spec_hair
	else
		spec_hair += "None"
		return spec_hair

/datum/species/proc/tails_list()
	if(!GLOB.tails_list_human.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails, GLOB.tails_list_human)
	var/list/spec_hair = list()
	var/datum/sprite_accessory/X
	for(var/O in GLOB.tails_list_human)
		X = GLOB.tails_list_human[O]
		if(X)
			if(id in X.specuse)
				spec_hair += X.name
	if(spec_hair.len)
		return spec_hair
	else
		spec_hair += "None"
		return spec_hair

//Called when cloning, copies some vars that should be kept
/datum/species/proc/copy_properties_from(datum/species/old_species)
	return

//Please override this locally if you want to define when what species qualifies for what rank if human authority is enforced.
/datum/species/proc/qualifies_for_rank(rank, list/features)
	return 1

//Will regenerate missing organs
/datum/species/proc/regenerate_organs(mob/living/carbon/C,datum/species/old_species,replace_current=TRUE)
	var/obj/item/organ/brain/brain = C.getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
	var/obj/item/organ/lungs/lungs = C.getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/appendix/appendix = C.getorganslot(ORGAN_SLOT_APPENDIX)
	var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
	var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
	var/obj/item/organ/tongue/tongue = C.getorganslot(ORGAN_SLOT_TONGUE)
	var/obj/item/organ/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
	var/obj/item/organ/stomach/stomach = C.getorganslot(ORGAN_SLOT_STOMACH)
	var/obj/item/organ/guts/guts = C.getorganslot(ORGAN_SLOT_GUTS)
	var/obj/item/organ/tail/tail = C.getorganslot(ORGAN_SLOT_TAIL)

	var/should_have_brain = TRUE
	var/should_have_heart = !(NOBLOOD in species_traits)
	var/should_have_lungs = !(TRAIT_NOBREATH in inherent_traits)
	var/should_have_appendix = FALSE
	var/should_have_eyes = TRUE
	var/should_have_ears = TRUE
	var/should_have_tongue = TRUE
	var/should_have_liver = !(TRAIT_NOMETABOLISM in inherent_traits)
	var/should_have_stomach = !(NOSTOMACH in species_traits)
	var/should_have_tail = mutanttail

	if(heart && (!should_have_heart || replace_current))
		heart.Remove(C,1)
		QDEL_NULL(heart)
	if(should_have_heart && !heart)
		heart = new mutant_heart()
		heart.Insert(C)

	if(lungs && (!should_have_lungs || replace_current))
		lungs.Remove(C,1)
		QDEL_NULL(lungs)
	if(should_have_lungs && !lungs)
		if(mutantlungs)
			lungs = new mutantlungs()
		else
			lungs = new()
		lungs.Insert(C)

	if(liver && (!should_have_liver || replace_current))
		liver.Remove(C,1)
		QDEL_NULL(liver)
	if(should_have_liver && !liver)
		if(mutantliver)
			liver = new mutantliver()
		else
			liver = new()
		liver.Insert(C)

	if(stomach && (!should_have_stomach || replace_current))
		stomach.Remove(C,1)
		guts.Remove(C,1)
		QDEL_NULL(stomach)
		QDEL_NULL(guts)
	if(should_have_stomach && !stomach)
		if(mutantstomach)
			stomach = new mutantstomach()
		else
			stomach = new()
		if(mutantguts)
			guts = new mutantguts()
		else
			guts = new()
		stomach.Insert(C)
		guts.Insert(C)

	if(appendix && (!should_have_appendix || replace_current))
		appendix.Remove(C,1)
		QDEL_NULL(appendix)
	if(should_have_appendix && !appendix)
		appendix = new()
		appendix.Insert(C)

	if(tail && (!should_have_tail || replace_current))
		tail.Remove(C,1)
		QDEL_NULL(tail)
	if(should_have_tail && !tail)
		tail = new mutanttail()
		tail.Insert(C)

	if(C.get_bodypart(BODY_ZONE_HEAD))
		if(brain && (replace_current || !should_have_brain))
			if(!brain.decoy_override)//Just keep it if it's fake
				brain.Remove(C,TRUE,TRUE)
				QDEL_NULL(brain)
		if(should_have_brain && !brain)
			brain = new mutant_brain()
			brain.Insert(C, TRUE, TRUE)

		if(eyes && (replace_current || !should_have_eyes))
			eyes.Remove(C,1)
			QDEL_NULL(eyes)
		if(should_have_eyes && !eyes)
			eyes = new mutanteyes
			eyes.Insert(C)

		if(ears && (replace_current || !should_have_ears))
			ears.Remove(C,1)
			QDEL_NULL(ears)
		if(should_have_ears && !ears)
			ears = new mutantears
			ears.Insert(C)

		if(tongue && (replace_current || !should_have_tongue))
			tongue.Remove(C,1)
			QDEL_NULL(tongue)
		if(should_have_tongue && !tongue)
			tongue = new mutanttongue
			tongue.Insert(C)

	if(old_species)
		for(var/mutantorgan in old_species.mutant_organs)
			var/obj/item/organ/I = C.getorgan(mutantorgan)
			if(I)
				I.Remove(C)
				QDEL_NULL(I)

	for(var/path in mutant_organs)
		var/obj/item/organ/I = new path()
		I.Insert(C)

/datum/species/proc/random_character(mob/living/carbon/human/H)
	H.real_name = random_name(H.gender,1)
//	H.age = pick(possible_ages)
	H.underwear = random_underwear(H.gender)
	H.hairstyle = random_hairstyle(H.gender)
	H.facial_hairstyle = random_facial_hairstyle(H.gender)
	var/list/hairs
	if((H.age == AGE_OLD) && (OLDGREY in species_traits))
		hairs = get_oldhc_list()
	else
		hairs = get_hairc_list()
	H.hair_color = hairs[pick(hairs)]
	H.facial_hair_color = H.hair_color
	var/list/skins = get_skin_list()
	H.skin_tone = skins[pick(skins)]
	H.eye_color = random_eye_color()
	H.accessory = "Nothing"
	if(H.dna)
		H.dna.real_name = H.real_name
		var/list/features = random_features()
		if(default_features["ears"])
			features["ears"] = default_features["ears"]
		if(default_features["tail_human"])
			features["tail_human"] = default_features["tail_human"]
		H.dna.features = features.Copy()
	H.update_body()
	H.update_hair()
	H.update_body_parts()


/datum/species/proc/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	// Drop the items the new species can't wear
	if((AGENDER in species_traits))
		C.gender = PLURAL
	for(var/slot_id in no_equip)
		var/obj/item/thing = C.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src,thing.species_exception)))
			C.dropItemToGround(thing)
	if(C.hud_used)
		C.hud_used.update_locked_slots()

	// this needs to be FIRST because qdel calls update_body which checks if we have DIGITIGRADE legs or not and if not then removes DIGITIGRADE from species_traits
	if(("legs" in C.dna.species.mutant_bodyparts) && C.dna.features["legs"] == "Digitigrade Legs")
		species_traits += DIGITIGRADE
	if(DIGITIGRADE in species_traits)
		C.Digitigrade_Leg_Swap(FALSE)

	if(ishuman(C))
		random_character(C)

	C.mob_biotypes = inherent_biotypes

	regenerate_organs(C,old_species)

	if(exotic_bloodtype && C.dna.human_blood_type != exotic_bloodtype)
		C.dna.human_blood_type = exotic_bloodtype

	if(old_species.mutanthands)
		for(var/obj/item/I in C.held_items)
			if(istype(I, old_species.mutanthands))
				qdel(I)

	if(mutanthands)
		// Drop items in hands
		// If you're lucky enough to have a TRAIT_NODROP item, then it stays.
		for(var/V in C.held_items)
			var/obj/item/I = V
			if(istype(I))
				C.dropItemToGround(I)
			else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				C.put_in_hands(new mutanthands())

	for(var/X in inherent_traits)
		ADD_TRAIT(C, X, SPECIES_TRAIT)

	for(var/component in components_to_add)
		C.AddComponent(component)

	if(TRAIT_TOXIMMUNE in inherent_traits)
		C.setToxLoss(0, TRUE, TRUE)

	if(TRAIT_NOMETABOLISM in inherent_traits)
		C.reagents.end_metabolization(C, keep_liverless = TRUE)

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	soundpack_m = new soundpack_m()
	soundpack_f = new soundpack_f()

	C.add_movespeed_modifier(MOVESPEED_ID_SPECIES, TRUE, 100, override=TRUE, multiplicative_slowdown=speedmod, movetypes=(~FLYING))

	C.remove_all_bodypart_features()
	for(var/bodypart_feature_type in bodypart_features)
		var/datum/bodypart_feature/feature = new bodypart_feature_type()
		if(!is_bodypart_feature_slot_allowed(C, feature.feature_slot))
			continue
		C.add_bodypart_feature(feature)
	if(pref_load)
		pref_load.apply_customizers_to_character(C)
		pref_load.apply_descriptors(C)

	SEND_SIGNAL(C, COMSIG_SPECIES_GAIN, src, old_species)


/datum/species/proc/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	if(C.dna.species.exotic_bloodtype)
		C.dna.human_blood_type = random_human_blood_type()
	if(DIGITIGRADE in species_traits)
		C.Digitigrade_Leg_Swap(TRUE)
	for(var/X in inherent_traits)
		REMOVE_TRAIT(C, X, SPECIES_TRAIT)

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction -= i

	C.remove_movespeed_modifier(MOVESPEED_ID_SPECIES)

	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

/datum/species/proc/handle_hair(mob/living/carbon/human/H, forced_colour)
	var/list/offsets = H.dna.species.offset_features
	if(H.age == AGE_CHILD)
		offsets = H.dna.species.offset_features_child
	H.remove_overlay(HAIR_LAYER)
	H.remove_overlay(HAIREXTRA_LAYER)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	if(!HD) // So, no head?
		return

	if(HD.skeletonized)
		return

	if(HAS_TRAIT(H, TRAIT_HUSK))
		return
	var/datum/sprite_accessory/S
	var/list/standing = list()
	var/list/standingover = list()

	var/hair_hidden = FALSE //ignored if the matching dynamic_X_suffix is non-empty
	var/facialhair_hidden = FALSE // ^
	var/dynamic_hair_suffix = "" //if this is non-null, and hair+suffix matches an iconstate, then we render that hair instead
	var/dynamic_fhair_suffix = ""

	//for augmented heads
	if(HD.status == BODYPART_ROBOTIC)
		return

	//we check if our hat or helmet hides our facial hair.
	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix //mask > head in terms of facial hair
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.facial_hairstyle && (FACEHAIR in species_traits) && (!facialhair_hidden || dynamic_fhair_suffix))
		S = GLOB.facial_hairstyles_list[H.facial_hairstyle]
		if(S)
			//Is hair+dynamic_fhair_suffix a valid iconstate?
			var/fhair_state = S.icon_state
			var/fhair_file = S.icon

			var/mutable_appearance/facial_overlay = mutable_appearance(fhair_file, fhair_state, -HAIR_LAYER)

			if((H.gender == MALE) && H.has_stubble && (STUBBLE in species_traits))
				var/mutable_appearance/stubble_underlay = mutable_appearance('icons/roguetown/mob/facial.dmi', "facial_stubble")
				facial_overlay.underlays += stubble_underlay

			if(!S.use_static)
				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							facial_overlay.color = "#" + H.dna.features["mcolor"]
						else
							facial_overlay.color = "#" + hair_color
					else
						facial_overlay.color = "#" + H.facial_hair_color
				else
					facial_overlay.color = forced_colour

			facial_overlay.alpha = hair_alpha
			if(H.gender == "male")
				if(OFFSET_FACE in offsets)
					facial_overlay.pixel_x += offsets[OFFSET_FACE][1]
					facial_overlay.pixel_y += offsets[OFFSET_FACE][2]
			else
				if(OFFSET_FACE_F in offsets)
					facial_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
					facial_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
			standing += facial_overlay

	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.wear_neck)
		var/obj/item/I = H.wear_neck
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	var/obj/item/bodypart/BP = H.get_bodypart(BODY_ZONE_HEAD)
	if(BP)
		if(BP.bandage)
			hair_hidden = TRUE

	if(!hair_hidden)
		var/mutable_appearance/hair_overlay = mutable_appearance(layer = -HAIREXTRA_LAYER)
		if(!hair_hidden && !H.getorgan(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			if(!(NOBLOOD in species_traits))
				hair_overlay.icon = 'icons/mob/human_face.dmi'
				hair_overlay.icon_state = "debrained"

		else if(H.hairstyle && (HAIR in species_traits))
			S = GLOB.hairstyles_list[H.hairstyle]
			if(S)
				if(S.under_layer)
					hair_overlay = mutable_appearance(layer = -HAIR_LAYER)

				//List of all valid dynamic_hair_suffixes
				var/static/list/extensions
				if(!extensions)
					var/icon/hair_extensions = icon('icons/roguetown/mob/hair_extensions.dmi') //hehe
					extensions = list()
					for(var/s in hair_extensions.IconStates(1))
						extensions[s] = TRUE
					qdel(hair_extensions)

				//Is hair+dynamic_hair_suffix a valid iconstate?
				var/hair_state = S.icon_state
				var/hair_file = S.icon
				if(extensions[hair_state+dynamic_hair_suffix])
					hair_state += dynamic_hair_suffix
					hair_file = 'icons/roguetown/mob/hair_extensions.dmi'

				hair_overlay.icon = hair_file
				hair_overlay.icon_state = hair_state

				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							hair_overlay.color = "#" + H.dna.features["mcolor"]
						else
							hair_overlay.color = "#" + hair_color
					else
						hair_overlay.color = "#" + H.hair_color
				else
					hair_overlay.color = forced_colour
				hair_overlay.alpha = hair_alpha
				if(H.gender == "male")
					if(OFFSET_FACE in offsets)
						hair_overlay.pixel_x += offsets[OFFSET_FACE][1]
						hair_overlay.pixel_y += offsets[OFFSET_FACE][2]
				else
					if(OFFSET_FACE_F in offsets)
						hair_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
						hair_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
		if(hair_overlay.icon)
			S = GLOB.hairstyles_list[H.hairstyle]
			if(S)
				if(S.under_layer)
					standing += hair_overlay
				else
					standingover += hair_overlay
			else
				standing += hair_overlay
	if(standing.len)
		H.overlays_standing[HAIR_LAYER] = standing
	if(standingover.len)
		H.overlays_standing[HAIREXTRA_LAYER] = standingover

	H.apply_overlay(HAIR_LAYER)
	H.apply_overlay(HAIREXTRA_LAYER)

/datum/species/proc/handle_body(mob/living/carbon/human/H)
	var/list/offsets = H.dna.species.offset_features
	if(H.age == AGE_CHILD)
		offsets = H.dna.species.offset_features_child
	H.remove_overlay(BODY_LAYER)
	H.remove_overlay(ABOVE_BODY_FRONT_LAYER)

	var/list/standing = list()

	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	if(HD && !(HAS_TRAIT(H, TRAIT_HUSK)) && !HD.skeletonized)
		// lipstick
		if(H.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[H.lip_style]", -BODY_LAYER)
			lip_overlay.color = H.lip_color
			if(H.gender == MALE)
				if(OFFSET_FACE in offsets)
					lip_overlay.pixel_x += offsets[OFFSET_FACE][1]
					lip_overlay.pixel_y += offsets[OFFSET_FACE][2]
			else
				if(OFFSET_FACE_F in offsets)
					lip_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
					lip_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
			standing += lip_overlay

		// eyes
		if(!(NOEYESPRITES in species_traits))
			var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/eye_overlay
			if(!E)
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER)
			else
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "[E.eye_icon_state]", -BODY_LAYER)
			if((EYECOLOR in species_traits) && E)
				eye_overlay.color = "#" + H.eye_color
			if(H.gender == FEMALE)
				if(OFFSET_FACE_F in offsets)
					eye_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
					eye_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
			else
				if(OFFSET_FACE in offsets)
					eye_overlay.pixel_x += offsets[OFFSET_FACE][1]
					eye_overlay.pixel_y += offsets[OFFSET_FACE][2]
			standing += eye_overlay

		//detail
		if(H.detail)
			var/datum/sprite_accessory/detail/detail = GLOB.detail_list[H.detail]
			var/mutable_appearance/accessory_overlay
			if(detail)
				accessory_overlay = mutable_appearance(detail.icon, "[detail.icon_state]_BODY", -BODY_LAYER)
				if(!detail.use_static)
					if(detail.color_src == HAIR)
						accessory_overlay.color = "#[H.hair_color]"
					else
						accessory_overlay.color = "#" + H.detail_color
				if(H.gender == FEMALE)
					if(OFFSET_FACE_F in offsets)
						accessory_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
						accessory_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
				else
					if(OFFSET_FACE in offsets)
						accessory_overlay.pixel_x += offsets[OFFSET_FACE][1]
						accessory_overlay.pixel_y += offsets[OFFSET_FACE][2]
				standing += accessory_overlay

		if(H.accessory)
			var/datum/sprite_accessory/accessories/accessory = GLOB.accessories_list[H.accessory]
			var/mutable_appearance/accessory_overlay
			if(accessory)
				accessory_overlay = mutable_appearance(accessory.icon, "[accessory.icon_state]_BODY", -BODY_LAYER)
				if(H.gender == FEMALE)
					if(OFFSET_FACE_F in offsets)
						accessory_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
						accessory_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
				else
					if(OFFSET_FACE in offsets)
						accessory_overlay.pixel_x += offsets[OFFSET_FACE][1]
						accessory_overlay.pixel_y += offsets[OFFSET_FACE][2]
				standing += accessory_overlay

#ifdef MATURESERVER
		if(H.dna.species.hairyness)
			var/mutable_appearance/bodyhair_overlay
			if(H.gender == MALE)
				bodyhair_overlay = mutable_appearance(H.dna.species.limbs_icon_m, "[H.dna.species.hairyness]", -BODY_LAYER)
			else
				bodyhair_overlay = mutable_appearance(H.dna.species.limbs_icon_f, "[H.dna.species.hairyness]", -BODY_LAYER)
			bodyhair_overlay.color = "#" + H.hair_color
			standing += bodyhair_overlay
#endif

	//Underwear, Undershirts & Socks
	if(!(NO_UNDERWEAR in species_traits))
		var/hide_boob = FALSE
		if(H.wear_armor)
			var/obj/item/I = H.wear_armor
			if(I.flags_inv & HIDEBOOB)
				hide_boob = TRUE

		if(H.wear_shirt)
			var/obj/item/I = H.wear_shirt
			if(I.flags_inv & HIDEBOOB)
				hide_boob = TRUE

		if(H.underwear)
			if(H.age == AGE_CHILD)
				H.underwear = "Youngling"
				if(H.gender == FEMALE)
					H.underwear = "FemYoungling"

			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[H.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, -BODY_LAYER)
				if(H.gender == FEMALE && H.age != AGE_CHILD)
					if(OFFSET_FACE_F in offsets)
						underwear_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
						underwear_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
				else if(H.age != AGE_CHILD)
					if(OFFSET_FACE in offsets)
						underwear_overlay.pixel_x += offsets[OFFSET_FACE][1]
						underwear_overlay.pixel_y += offsets[OFFSET_FACE][2]
				if(!underwear.use_static)
					if(H.underwear_color)
						underwear_overlay.color = H.underwear_color
					else //default undies are brown
						H.underwear_color = "#755f46"
						underwear_overlay.color = "#755f46"
				standing += underwear_overlay
				if(!hide_boob && H.gender == FEMALE)
					underwear_overlay = mutable_appearance(underwear.icon, "[underwear.icon_state]_boob", -BODY_LAYER)
					if(OFFSET_FACE_F in offsets)
						underwear_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
						underwear_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
					if(!underwear.use_static)
						if(H.underwear_color)
							underwear_overlay.color = H.underwear_color
						else
							H.underwear_color = "#755f46"
							underwear_overlay.color = "#755f46"
					standing += underwear_overlay
/*
		if(H.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[H.undershirt]
			if(undershirt)
				if(H.dna.species.sexes && H.gender == FEMALE)
					standing += wear_female_version(undershirt.icon_state, undershirt.icon, BODY_LAYER)
				else
					standing += mutable_appearance(undershirt.icon, undershirt.icon_state, -BODY_LAYER)

		if(H.socks && H.get_num_legs(FALSE) >= 2 && !(DIGITIGRADE in species_traits))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[H.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, -BODY_LAYER)
*/
	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)
	H.apply_overlay(ABOVE_BODY_FRONT_LAYER)
	handle_mutant_bodyparts(H)

/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/offsets = H.dna.species.offset_features
	if(H.age == AGE_CHILD)
		offsets = H.dna.species.offset_features_child
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing	= list()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts)
		return

	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	if("tail_lizard" in mutant_bodyparts)
		if(H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_lizard"

	if("waggingtail_lizard" in mutant_bodyparts)
		if(H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_lizard"
		else if ("tail_lizard" in mutant_bodyparts)
			bodyparts_to_add -= "waggingtail_lizard"

	if("tail_human" in mutant_bodyparts)
		if(H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_human"


	if("waggingtail_human" in mutant_bodyparts)
		if(H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_human"
		else if ("tail_human" in mutant_bodyparts)
			bodyparts_to_add -= "waggingtail_human"

	if("spines" in mutant_bodyparts)
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "spines"

	if("waggingspines" in mutant_bodyparts)
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingspines"
		else if ("tail" in mutant_bodyparts)
			bodyparts_to_add -= "waggingspines"

	if("snout" in mutant_bodyparts) //Take a closer look at that snout!
		if((H.wear_mask && (H.wear_mask.flags_inv & HIDEFACE)) || (H.head && (H.head.flags_inv & HIDEFACE)) || !HD || HD.status == BODYPART_ROBOTIC)
			bodyparts_to_add -= "snout"

	if("frills" in mutant_bodyparts)
		if(!H.dna.features["frills"] || H.dna.features["frills"] == "None" || H.head && (H.head.flags_inv & HIDEEARS) || !HD || HD.status == BODYPART_ROBOTIC)
			bodyparts_to_add -= "frills"

	if("horns" in mutant_bodyparts)
		if(!H.dna.features["horns"] || H.dna.features["horns"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !HD || HD.status == BODYPART_ROBOTIC)
			bodyparts_to_add -= "horns"

	if("ears" in mutant_bodyparts)
		if(!H.dna.features["ears"] || H.dna.features["ears"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || H.head && (H.head.flags_inv & HIDEEARS) || H.wear_neck && (H.wear_neck.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEARS)) || (H.wear_neck && (H.wear_neck.flags_inv & HIDEEARS)) || !HD || HD.status == BODYPART_ROBOTIC || HD.skeletonized)
			bodyparts_to_add -= "ears"

	var/hide_ears = FALSE

	if(H.head && (H.head.flags_inv & HIDEHAIR) || H.head && (H.head.flags_inv & HIDEEARS) || H.wear_neck && (H.wear_neck.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEARS)) || (H.wear_neck && (H.wear_neck.flags_inv & HIDEEARS)) || !HD || HD.skeletonized)
		hide_ears = TRUE

	if(H.accessory && !hide_ears)
		var/datum/sprite_accessory/accessories/accessory = GLOB.accessories_list[H.accessory]
		var/mutable_appearance/accessory_overlay
		if(accessory)
			accessory_overlay = mutable_appearance(accessory.icon, "[accessory.icon_state]_FRONT", -BODY_FRONT_LAYER)
			if(H.gender == FEMALE)
				if(OFFSET_FACE_F in offsets)
					accessory_overlay.pixel_x += offsets[OFFSET_FACE_F][1]
					accessory_overlay.pixel_y += offsets[OFFSET_FACE_F][2]
			else
				if(OFFSET_FACE in offsets)
					accessory_overlay.pixel_x += offsets[OFFSET_FACE][1]
					accessory_overlay.pixel_y += offsets[OFFSET_FACE][2]
			standing += accessory_overlay

	if("wings" in mutant_bodyparts)
		if(!H.dna.features["wings"] || H.dna.features["wings"] == "None" || (H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT) && (!H.wear_armor.species_exception || !is_type_in_list(src, H.wear_armor.species_exception))))
			bodyparts_to_add -= "wings"

	if("wings_open" in mutant_bodyparts)
		if(H.wear_armor && (H.wear_armor.flags_inv & HIDEJUMPSUIT) && (!H.wear_armor.species_exception || !is_type_in_list(src, H.wear_armor.species_exception)))
			bodyparts_to_add -= "wings_open"
		else if ("wings" in mutant_bodyparts)
			bodyparts_to_add -= "wings_open"

	//Digitigrade legs are stuck in the phantom zone between true limbs and mutant bodyparts. Mainly it just needs more agressive updating than most limbs.
	var/update_needed = FALSE
	var/not_digitigrade = TRUE
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/O = X
		if(!O.use_digitigrade)
			continue
		not_digitigrade = FALSE
		if(!(DIGITIGRADE in species_traits)) //Someone cut off a digitigrade leg and tacked it on
			species_traits += DIGITIGRADE
		var/should_be_squished = FALSE
		if(H.wear_armor && ((H.wear_armor.flags_inv & HIDEJUMPSUIT) || (H.wear_armor.body_parts_covered & LEGS)) || (H.wear_pants && (H.wear_pants.body_parts_covered & LEGS)))
			should_be_squished = TRUE
		if(O.use_digitigrade == FULL_DIGITIGRADE && should_be_squished)
			O.use_digitigrade = SQUISHED_DIGITIGRADE
			update_needed = TRUE
		else if(O.use_digitigrade == SQUISHED_DIGITIGRADE && !should_be_squished)
			O.use_digitigrade = FULL_DIGITIGRADE
			update_needed = TRUE
	if(update_needed)
		H.update_body_parts()
	if(not_digitigrade && (DIGITIGRADE in species_traits)) //Curse is lifted
		species_traits -= DIGITIGRADE

	if(!bodyparts_to_add)
		return

	var/g = (H.gender == FEMALE) ? "f" : "m"

	for(var/layer in relevent_layers)
		var/layertext = mutant_bodyparts_layertext(layer)

		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/S
			switch(bodypart)
				if("tail_lizard")
					S = GLOB.tails_list_lizard[H.dna.features["tail_lizard"]]
				if("waggingtail_lizard")
					S = GLOB.animated_tails_list_lizard[H.dna.features["tail_lizard"]]
				if("tail_human")
					S = GLOB.tails_list_human[H.dna.features["tail_human"]]
				if("waggingtail_human")
					S = GLOB.animated_tails_list_human[H.dna.features["tail_human"]]
				if("spines")
					S = GLOB.spines_list[H.dna.features["spines"]]
				if("waggingspines")
					S = GLOB.animated_spines_list[H.dna.features["spines"]]
				if("snout")
					S = GLOB.snouts_list[H.dna.features["snout"]]
				if("frills")
					S = GLOB.frills_list[H.dna.features["frills"]]
				if("horns")
					S = GLOB.horns_list[H.dna.features["horns"]]
				if("ears")
					S = GLOB.ears_list[H.dna.features["ears"]]
				if("body_markings")
					S = GLOB.body_markings_list[H.dna.features["body_markings"]]
				if("wings")
					S = GLOB.wings_list[H.dna.features["wings"]]
				if("wingsopen")
					S = GLOB.wings_open_list[H.dna.features["wings"]]
				if("legs")
					S = GLOB.legs_list[H.dna.features["legs"]]
				if("caps")
					S = GLOB.caps_list[H.dna.features["caps"]]
			if(!S || S.icon_state == "none")
				continue

			var/mutable_appearance/accessory_overlay = mutable_appearance(S.icon, layer = -layer)

			//A little rename so we don't have to use tail_lizard or tail_human when naming the sprites.
			if(bodypart == "tail_lizard" || bodypart == "tail_human")
				bodypart = "tail"
			else if(bodypart == "waggingtail_lizard" || bodypart == "waggingtail_human")
				bodypart = "waggingtail"

			if(S.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[S.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[S.icon_state]_[layertext]"

			if(S.center)
				accessory_overlay = center_image(accessory_overlay, S.dimension_x, S.dimension_y)

			if(!(HAS_TRAIT(H, TRAIT_HUSK)))
				if(!forced_colour)
					switch(S.color_src)
						if(MUTCOLORS)
							if(fixed_mut_color)
								accessory_overlay.color = "#[fixed_mut_color]"
							else
								accessory_overlay.color = "#[H.dna.features["mcolor"]]"
						if(HAIR)
							if(hair_color == "mutcolor")
								accessory_overlay.color = "#[H.dna.features["mcolor"]]"
							else
								accessory_overlay.color = "#[H.hair_color]"
						if(FACEHAIR)
							if(!S.use_static)
								accessory_overlay.color = "#[H.facial_hair_color]"
						if(EYECOLOR)
							accessory_overlay.color = "#[H.eye_color]"
						if(SKINCOLOR)
							accessory_overlay.color = "#[H.skin_tone]"
				else
					accessory_overlay.color = forced_colour
			if(S.offsetti)
				if(H.age == AGE_CHILD)
					if(H.gender == FEMALE)
						if(OFFSET_FACE_F in offset_features_child)
							accessory_overlay.pixel_x += offset_features_child[OFFSET_FACE_F][1]
							accessory_overlay.pixel_y += offset_features_child[OFFSET_FACE_F][2]
					else
						if(OFFSET_FACE in offset_features_child)
							accessory_overlay.pixel_x += offset_features_child[OFFSET_FACE][1]
							accessory_overlay.pixel_y += offset_features_child[OFFSET_FACE][2]
				else
					if(H.gender == FEMALE)
						if(OFFSET_FACE_F in offset_features)
							accessory_overlay.pixel_x += offset_features[OFFSET_FACE_F][1]
							accessory_overlay.pixel_y += offset_features[OFFSET_FACE_F][2]
					else
						if(OFFSET_FACE in offset_features)
							accessory_overlay.pixel_x += offset_features[OFFSET_FACE][1]
							accessory_overlay.pixel_y += offset_features[OFFSET_FACE][2]

			standing += accessory_overlay

			if(S.hasinner)
				var/mutable_appearance/inner_accessory_overlay = mutable_appearance(S.icon, layer = -layer)
				if(S.gender_specific)
					inner_accessory_overlay.icon_state = "[g]_[bodypart]inner_[S.icon_state]_[layertext]"
				else
					inner_accessory_overlay.icon_state = "m_[bodypart]inner_[S.icon_state]_[layertext]"

				if(S.center)
					inner_accessory_overlay = center_image(inner_accessory_overlay, S.dimension_x, S.dimension_y)
				if(S.offsetti)
					if(H.age == AGE_CHILD)
						if(H.gender == FEMALE)
							if(OFFSET_FACE_F in offset_features_child)
								inner_accessory_overlay.pixel_x += offset_features_child[OFFSET_FACE_F][1]
								inner_accessory_overlay.pixel_y += offset_features_child[OFFSET_FACE_F][2]
						else
							if(OFFSET_FACE in offset_features_child)
								inner_accessory_overlay.pixel_x += offset_features_child[OFFSET_FACE][1]
								inner_accessory_overlay.pixel_y += offset_features_child[OFFSET_FACE][2]
					else
						if(H.gender == FEMALE)
							if(OFFSET_FACE_F in offset_features)
								inner_accessory_overlay.pixel_x += offset_features[OFFSET_FACE_F][1]
								inner_accessory_overlay.pixel_y += offset_features[OFFSET_FACE_F][2]
						else
							if(OFFSET_FACE in offset_features)
								inner_accessory_overlay.pixel_x += offset_features[OFFSET_FACE][1]
								inner_accessory_overlay.pixel_y += offset_features[OFFSET_FACE][2]
				standing += inner_accessory_overlay

		H.overlays_standing[layer] = standing.Copy()
		standing = list()

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)

//This exists so sprite accessories can still be per-layer without having to include that layer's
//number in their sprite name, which causes issues when those numbers change.
/datum/species/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_FRONT_LAYER)
			return "FRONT"


/datum/species/proc/spec_life(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		H.setOxyLoss(0)
		H.losebreath = 0

		var/takes_crit_damage = (!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		if((H.health < H.crit_threshold) && takes_crit_damage)
			H.adjustBruteLoss(1)

/datum/species/proc/spec_death(gibbed, mob/living/carbon/human/H)
	return

/datum/species/proc/auto_equip(mob/living/carbon/human/H)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	var/num_arms = H.get_num_arms(FALSE)
	var/num_legs = H.get_num_legs(FALSE)

	switch(slot)
		if(SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(SLOT_WEAR_MASK)
			if(H.wear_mask)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_MASK))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_MOUTH)
			if(H.mouth)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_MOUTH))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_NECK)
			if(H.wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(SLOT_BACK)
			if(H.back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BACK_R)
			if(H.backr)
				return FALSE
			if( (I.slot_flags & ITEM_SLOT_CLOAK) )
				if(H.cloak)
					if((H.cloak.slot_flags & ITEM_SLOT_BACK_R) )
						return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK_R) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BACK_L)
			if(H.backl)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK_L) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_ARMOR)
			if(H.wear_armor)
				return FALSE
			if(I.blocking_behavior & BULKYBLOCKS)
				if(H.cloak)
					return FALSE
				if(istype(H.cloak, I.type))
					return FALSE
			if(H.wear_shirt)
				if(H.wear_shirt.blocking_behavior & BULKYBLOCKS)
					return FALSE
				if(istype(H.wear_shirt, I.type))
					return FALSE
				if(I.blocksound)
					if(I.blocksound == H.wear_shirt.blocksound)
						return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ARMOR) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_GLOVES)
			if(H.gloves)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_GLOVES) )
				return FALSE
			if(num_arms < 1)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_SHOES)
			if(H.shoes)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_SHOES) )
				return FALSE
			if(num_legs < 1)
				return FALSE
			if(DIGITIGRADE in species_traits)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>The footwear around here isn't compatible with my feet!</span>")
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BELT)
			if(H.belt)
				return FALSE

			if(!(I.slot_flags & ITEM_SLOT_BELT))
				return
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BELT_R)
			if(H.beltr)
				return FALSE

			if(!H.belt)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HIP))
				return
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BELT_L)
			if(H.beltl)
				return FALSE

			if(!H.belt)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HIP))
				return
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_HEAD)
			if(H.head)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HEAD))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_PANTS)
			if(H.wear_pants)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_PANTS) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_SHIRT)
			if(H.wear_shirt)
				return FALSE
			if(I.blocking_behavior & BULKYBLOCKS)
				if(H.cloak)
					return FALSE
				if(H.wear_armor)
					return FALSE
			if(H.wear_armor)
				if(istype(H.wear_armor, I.type))
					return FALSE
				if(I.blocksound)
					if(I.blocksound == H.wear_armor.blocksound)
						return FALSE
			if( !(I.slot_flags & ITEM_SLOT_SHIRT) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_CLOAK)
			if(H.cloak)
				return FALSE
			if( (I.slot_flags & ITEM_SLOT_BACK_R) )
				if(H.backr)
					if((H.backr.slot_flags & ITEM_SLOT_CLOAK) )
						return FALSE
			if(H.wear_shirt)
				if(H.wear_shirt.blocking_behavior & BULKYBLOCKS)
					return FALSE
				if(istype(H.wear_shirt, I.type))
					return FALSE
			if(H.wear_armor)
				if(H.wear_armor.blocking_behavior & BULKYBLOCKS)
					return FALSE
				if(istype(H.wear_armor, I.type))
					return FALSE
			if( !(I.slot_flags & ITEM_SLOT_CLOAK) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_RING)
			if(H.wear_ring)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_RING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WRISTS)
			if(H.wear_wrists)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_WRISTS) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_L_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(H.l_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.wear_pants && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>I need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
		if(SLOT_R_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.r_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.wear_pants && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>I need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
			return FALSE
		if(SLOT_S_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.s_store)
				return FALSE
			if(!H.wear_armor)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>I need a suit before you can attach this [I.name]!</span>")
				return FALSE
			if(!H.wear_armor.allowed)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>I somehow have a suit with no defined allowed items for suit storage, stop that.</span>")
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>The [I.name] is too big to attach!</span>") //should be src?
				return FALSE
			return FALSE
		if(SLOT_HANDCUFFED)
			if(H.handcuffed)
				return FALSE
			if(!I.breakouttime)
				return FALSE
//			if(num_arms < 2)
//				return FALSE
			return TRUE
		if(SLOT_LEGCUFFED)
			if(H.legcuffed)
				return FALSE
			if(!I.breakouttime)
				return FALSE
			if(num_legs < 2)
				return FALSE
			return TRUE
		if(SLOT_IN_BACKPACK)
			testing("STARTYES")
			if(H.backr)
				if(SEND_SIGNAL(H.backr, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			if(H.backl)
				if(SEND_SIGNAL(H.backl, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			if(H.beltr)
				if(SEND_SIGNAL(H.beltr, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			if(H.beltl)
				if(SEND_SIGNAL(H.beltl, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			if(H.belt)
				if(SEND_SIGNAL(H.belt, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			testing("NONONO")
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	if(HAS_TRAIT(H, TRAIT_CHUNKYFINGERS))
		return do_after(H, 5 MINUTES)
	var/doafter_flags = I.edelay_type ? (IGNORE_USER_LOC_CHANGE) : (NONE)
	return do_after(H, min((I.equip_delay_self - H.STASPD), 1), timed_action_flags = doafter_flags)

/// Equips the necessary species-relevant gear before putting on the rest of the uniform.
/datum/species/proc/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	return

/datum/species/proc/post_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	return

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == exotic_bloodtype)
		H.blood_volume = min(H.blood_volume + round(chem.volume, 0.1), BLOOD_VOLUME_MAXIMUM)
		H.reagents.del_reagent(chem.type)
		return TRUE
	if(chem.overdose_threshold && chem.volume >= chem.overdose_threshold)
		chem.overdosed = TRUE

/datum/species/proc/check_species_weakness(obj/item, mob/living/attacker, mob/living/parent)
	return 0 //This is not a boolean, it's the multiplier for the damage that the user takes from the item.It is added onto the check_weakness value of the mob, and then the force of the item is multiplied by this value

/**
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return

	outfit_important_for_life= new()
	outfit_important_for_life.equip(human_to_equip)

////////
//LIFE//
////////

/datum/species/proc/handle_digestion(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
//	if(HAS_TRAIT_FROM(H, TRAIT_FAT, OBESITY))//I share my pain, past coder.
//		if(H.overeatduration < 100)
//			to_chat(H, "<span class='notice'>I feel fit again!</span>")
//			REMOVE_TRAIT(H, TRAIT_FAT, OBESITY)
//			H.remove_movespeed_modifier(MOVESPEED_ID_FAT)
//			H.update_inv_w_uniform()
//			H.update_inv_wear_suit()
//	else
//		if(H.overeatduration >= 100)
//			to_chat(H, "<span class='danger'>I suddenly feel blubbery!</span>")
//			ADD_TRAIT(H, TRAIT_FAT, OBESITY)
//			H.add_movespeed_modifier(MOVESPEED_ID_FAT, multiplicative_slowdown = 1.5)
//			H.update_inv_w_uniform()
//			H.update_inv_wear_suit()

	// nutrition decrease and satiety
	if (H.nutrition > 0 && H.stat != DEAD && !HAS_TRAIT(H, TRAIT_NOHUNGER))
		// THEY HUNGER
		var/hunger_rate = (HUNGER_FACTOR * nutrition_mod)
/*		if(H.satiety > MAX_SATIETY)
			H.satiety = MAX_SATIETY
		else if(H.satiety > 0)
			H.satiety--
		else if(H.satiety < -MAX_SATIETY)
			H.satiety = -MAX_SATIETY
		else if(H.satiety < 0)
			H.satiety++
			if(prob(round(-H.satiety/40)))
				H.Jitter(5)
			hunger_rate = 10 * HUNGER_FACTOR*/
//		hunger_rate *= H.physiology.hunger_mod
		H.adjust_nutrition(-hunger_rate)


	if (H.hydration > 0 && H.stat != DEAD && !HAS_TRAIT(H, TRAIT_NOHUNGER))
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
//		hunger_rate *= H.physiology.hunger_mod
		H.adjust_hydration(-hunger_rate)


	if (H.nutrition > NUTRITION_LEVEL_FULL)
		if(H.overeatduration < 600) //capped so people don't take forever to unfat
			H.overeatduration++
	else
		if(H.overeatduration > 1)
			H.overeatduration -= 2 //doubled the unfat rate

	//metabolism change
//	if(H.nutrition > NUTRITION_LEVEL_FAT)
//		H.metabolism_efficiency = 1
//	else if(H.nutrition > NUTRITION_LEVEL_FED && H.satiety > 80)
//		if(H.metabolism_efficiency != 1.25 && !HAS_TRAIT(H, TRAIT_NOHUNGER))
//			to_chat(H, "<span class='notice'>I feel vigorous.</span>")
//			H.metabolism_efficiency = 1.25
//	else if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
//		if(H.metabolism_efficiency != 0.8)
//			to_chat(H, "<span class='notice'>I feel sluggish.</span>")
//		H.metabolism_efficiency = 0.8
//	else
//		if(H.metabolism_efficiency == 1.25)
//			to_chat(H, "<span class='notice'>I no longer feel vigorous.</span>")
//		H.metabolism_efficiency = 1

	//Hunger slowdown for if mood isn't enabled
//	if(CONFIG_GET(flag/disable_human_mood))
//		if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
//			var/hungry = (500 - H.nutrition) / 5 //So overeat would be 100 and default level would be 80
//			if(hungry >= 70)
//				H.add_movespeed_modifier(MOVESPEED_ID_HUNGRY, override = TRUE, multiplicative_slowdown = (hungry / 50))
//			else if(isethereal(H))
//				var/datum/species/ethereal/E = H.dna.species
//				if(E.get_charge(H) <= ETHEREAL_CHARGE_NORMAL)
//					H.add_movespeed_modifier(MOVESPEED_ID_HUNGRY, override = TRUE, multiplicative_slowdown = (1.5 * (1 - E.get_charge(H) / 100)))
//			else
//				H.remove_movespeed_modifier(MOVESPEED_ID_HUNGRY)

	switch(H.nutrition)
//		if(NUTRITION_LEVEL_FAT to INFINITY) //currently disabled/999999 define
//			if(H.energy >= H.max_energy)
//				H.apply_status_effect(/datum/status_effect/debuff/fat)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			H.apply_status_effect(/datum/status_effect/debuff/hungryt1)
			H.remove_status_effect(/datum/status_effect/debuff/hungryt2)
			H.remove_status_effect(/datum/status_effect/debuff/hungryt3)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			H.apply_status_effect(/datum/status_effect/debuff/hungryt2)
			H.remove_status_effect(/datum/status_effect/debuff/hungryt1)
			H.remove_status_effect(/datum/status_effect/debuff/hungryt3)
		if(0 to NUTRITION_LEVEL_STARVING)
			H.apply_status_effect(/datum/status_effect/debuff/hungryt3)
			H.remove_status_effect(/datum/status_effect/debuff/hungryt1)
			H.remove_status_effect(/datum/status_effect/debuff/hungryt2)
			if(prob(3))
				playsound(get_turf(H), pick('sound/vo/hungry1.ogg','sound/vo/hungry2.ogg','sound/vo/hungry3.ogg'), 100, TRUE, -1)

	switch(H.hydration)
//		if(HYDRATION_LEVEL_WATERLOGGED to INFINITY)
//			H.apply_status_effect(/datum/status_effect/debuff/waterlogged)
		if(HYDRATION_LEVEL_THIRSTY to HYDRATION_LEVEL_SMALLTHIRST)
			H.apply_status_effect(/datum/status_effect/debuff/thirstyt1)
			H.remove_status_effect(/datum/status_effect/debuff/thirstyt2)
			H.remove_status_effect(/datum/status_effect/debuff/thirstyt3)
		if(HYDRATION_LEVEL_DEHYDRATED to HYDRATION_LEVEL_THIRSTY)
			H.apply_status_effect(/datum/status_effect/debuff/thirstyt2)
			H.remove_status_effect(/datum/status_effect/debuff/thirstyt1)
			H.remove_status_effect(/datum/status_effect/debuff/thirstyt3)
		if(0 to HYDRATION_LEVEL_DEHYDRATED)
			H.apply_status_effect(/datum/status_effect/debuff/thirstyt3)
			H.remove_status_effect(/datum/status_effect/debuff/thirstyt1)
			H.remove_status_effect(/datum/status_effect/debuff/thirstyt2)


/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return 0

/datum/species/proc/go_bald(mob/living/carbon/human/H)
	if(QDELETED(H))	//may be called from a timer
		return
	if(H.gender == MALE)
		H.facial_hairstyle = "Shaved"
	if(H.gender == FEMALE)
		H.facial_hairstyle = "Nothing"
	H.hairstyle = "Bald"
	H.update_hair()

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_updatehealth(mob/living/carbon/human/H)
	return

/datum/species/proc/spec_fully_heal(mob/living/carbon/human/H)
	return

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
//	if(!((target.health < 0 || HAS_TRAIT(target, TRAIT_FAKEDEATH)) && !(target.mobility_flags & MOBILITY_STAND)))
	if(!(target.mobility_flags & MOBILITY_STAND))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaken")
		return 1
/*	else
		var/we_breathe = !HAS_TRAIT(user, TRAIT_NOBREATH)
		var/we_lung = user.getorganslot(ORGAN_SLOT_LUNGS)

		if(we_breathe && we_lung)
			user.do_cpr(target)
		else if(we_breathe && !we_lung)
			to_chat(user, "<span class='warning'>I have no lungs to breathe with, so you cannot perform CPR!</span>")
		else
			to_chat(user, "<span class='warning'>I do not breathe, so you cannot perform CPR!</span>")*/

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s grab!</span>", \
						"<span class='danger'>I block [user]'s grab!</span>", "<span class='hear'>I hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, user)
		to_chat(user, "<span class='warning'>My grab at [target] was blocked!</span>")
		return FALSE

	if(attacker_style && attacker_style.grab_act(user,target))
		return TRUE
	else
/*		//Steal them shoes
		if(!(target.mobility_flags & MOBILITY_STAND) && (user.zone_selected == BODY_ZONE_L_LEG || user.zone_selected == BODY_ZONE_R_LEG) && user.used_intent.type == INTENT_GRAB && target.shoes)
			var/obj/item/I = target.shoes
			user.visible_message("<span class='warning'>[user] starts stealing [target]'s [I.name]!</span>",
							"<span class='danger'>I start stealing [target]'s [I.name]...</span>", null, null, target)
			to_chat(target, "<span class='danger'>[user] starts stealing my [I.name]!</span>")
			if(do_after(user, I.strip_delay, TRUE, target, TRUE))
				target.dropItemToGround(I, TRUE)
				user.put_in_hands(I)
				user.visible_message("<span class='warning'>[user] stole [target]'s [I.name]!</span>",
								"<span class='notice'>I stole [target]'s [I.name]!</span>", null, null, target)
				to_chat(target, "<span class='danger'>[user] stole my [I.name]!</span>")*/
		var/def_zone = check_zone(user.zone_selected)
		var/obj/item/bodypart/affecting = target.get_bodypart(def_zone)
		if(length(affecting?.embedded_objects))
			for(var/obj/item/embedded in affecting.embedded_objects)
				target.grabbedby(user, 1, item_override = embedded)
				return TRUE
		target.grabbedby(user)
		return TRUE

///This proc handles punching damage. IMPORTANT: Our owner is the TARGET and not the USER in this proc. For whatever reason...
/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>I don't want to harm [target]!</span>")
		return FALSE
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s attack!</span>", \
						"<span class='danger'>I block [user]'s attack!</span>", "<span class='hear'>I hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, user)
		to_chat(user, "<span class='warning'>My attack at [target] was blocked!</span>")
		return FALSE
	if(attacker_style && attacker_style.harm_act(user,target))
		return TRUE
	else

//		var/atk_verb = user.dna.species.attack_verb
//		if(!(target.mobility_flags & MOBILITY_STAND))
//			atk_verb = ATTACK_EFFECT_KICK

//	switch(atk_verb)//this code is really stupid but some genius apparently made "claw" and "slash" two attack types but also the same one so it's needed i guess
//		if(ATTACK_EFFECT_KICK)
//			user.do_attack_animation(target, ATTACK_EFFECT_KICK)
//		if(ATTACK_EFFECT_SLASH || ATTACK_EFFECT_CLAW)//smh
//			user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
//		if(ATTACK_EFFECT_SMASH)
//			user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
///			else
//				user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

		var/cached_intent = user.used_intent
		sleep(user.used_intent.swingdelay)
		if(user.a_intent != cached_intent)
			return FALSE
		if(!target.Adjacent(user))
			return
		if(user.incapacitated())
			return

		var/damage = user.get_punch_dmg()

/*		var/miss_chance = 100//calculate the odds that a punch misses entirely. considers stamina and brute damage of the puncher. punches miss by default to prevent weird cases
		if(user.dna.species.punchdamagelow)
			if(atk_verb == ATTACK_EFFECT_KICK) //kicks never miss (provided my species deals more than 0 damage)
				miss_chance = 0
			else
				miss_chance = min((user.dna.species.punchdamagehigh/user.dna.species.punchdamagelow) + user.getStaminaLoss() + (user.getBruteLoss()*0.5), 100) //old base chance for a miss + various damage. capped at 100 to prevent weirdness in prob()

		if(!damage || !affecting || prob(miss_chance))//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, user.dna.species.miss_sound, 25, TRUE, -1)
			target.visible_message("<span class='danger'>[user]'s [atk_verb] misses [target]!</span>", \
							"<span class='danger'>I avoid [user]'s [atk_verb]!</span>", "<span class='hear'>I hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='warning'>My [atk_verb] misses [target]!</span>")
			log_combat(user, target, "attempted to punch")
			return FALSE
*/
		var/selzone = accuracy_check(user.zone_selected, user, target, /datum/skill/combat/unarmed, user.used_intent)

		var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(selzone))

		if(!affecting)
			to_chat(user, "<span class='warning'>Unfortunately, there's nothing there.</span>")
			return 0

		if(!target.lying_attack_check(user))
			return 0

		var/armor_block = target.run_armor_check(selzone, "blunt", blade_dulling = user.used_intent.blade_class)

		target.lastattacker = user.real_name
		if(target.mind)
			target.mind.attackedme[user.real_name] = world.time
		target.lastattackerckey = user.ckey
		user.dna.species.spec_unarmedattacked(user, target)

		user.do_attack_animation(target, visual_effect_icon = user.used_intent.animname)
		target.next_attack_msg.Cut()

		var/nodmg = FALSE
		var/actual_damage = target.apply_damage(damage, user.dna.species.attack_type, affecting, armor_block)
		if(!actual_damage)
			nodmg = TRUE
			target.next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
		else
			affecting.bodypart_attacked_by(user.used_intent.blade_class, damage, user, selzone, crit_message = TRUE)
		log_combat(user, target, "punched")
		knockback(attacker_style, target, user, nodmg, actual_damage)

		if(!nodmg)
			if(user.limb_destroyer)
				var/easy_dismember = HAS_TRAIT(target, TRAIT_EASYDISMEMBER) || affecting.rotted
				if(prob(damage/2) || (easy_dismember && prob(damage/2))) //try twice
					if(affecting.brute_dam > 0)
						if(affecting.dismember())
							playsound(get_turf(target), "desceration", 80, TRUE)

/*		if(user == target)
			target.visible_message("<span class='danger'>[user] [atk_verb]ed themself![target.next_attack_msg.Join()]</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='userdanger'>I [atk_verb] myself![target.next_attack_msg.Join()]</span>")
		else
			target.visible_message("<span class='danger'>[user] [atk_verb]ed [target]![target.next_attack_msg.Join()]</span>", \
							"<span class='userdanger'>I'm [atk_verb]ed by [user]![target.next_attack_msg.Join()]</span>", "<span class='hear'>I hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>I [atk_verb] [target]![target.next_attack_msg.Join()]</span>")
*/
		var/message_verb = "punched"
		if(user.used_intent)
			message_verb = "[pick(user.used_intent.attack_verb)]"
		var/message_hit_area = ""
		if(selzone)
			message_hit_area = " in the [parse_zone(selzone)]"
		var/attack_message = "[user] [message_verb] [target][message_hit_area]!"
		var/attack_message_local = "[user] [message_verb] me[message_hit_area]!"
		target.visible_message("<span class='danger'>[attack_message][target.next_attack_msg.Join()]</span>",\
			"<span class='danger'>[attack_message_local][target.next_attack_msg.Join()]</span>", null, COMBAT_MESSAGE_RANGE)
		target.next_attack_msg.Cut()

/*		if((target.stat != DEAD) && damage >= user.dna.species.punchstunthreshold)
			target.visible_message("<span class='danger'>[user] knocks [target] down!</span>", \
							"<span class='danger'>You're knocked down by [user]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>I knock [target] down!</span>")
			var/knockdown_duration = 40 + (target.getStaminaLoss() + (target.getBruteLoss()*0.5))*0.8 //50 total damage = 40 base stun + 40 stun modifier = 80 stun duration, which is the old base duration
			target.apply_effect(knockdown_duration, EFFECT_KNOCKDOWN, armor_block)
			target.forcesay(GLOB.hit_appends)
			log_combat(user, target, "got a stun punch with their previous punch")*/
		if(!(target.mobility_flags & MOBILITY_STAND))
			target.forcesay(GLOB.hit_appends)
		if(!nodmg)
			playsound(target.loc, user.used_intent.hitsound, 100, FALSE)


/datum/species/proc/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message("<span class='warning'>[user]'s shove is blocked by [target]!</span>", \
						"<span class='danger'>I block [user]'s shove!</span>", "<span class='hear'>I hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, user)
		to_chat(user, "<span class='warning'>My shove at [target] was blocked!</span>")
		return FALSE
	if(attacker_style && attacker_style.disarm_act(user,target))
		return TRUE
	if(HAS_TRAIT(user, TRAIT_FLOORED))
		return FALSE
	if(user == target)
		return FALSE
	if(user.loc == target.loc)
		return FALSE
	else
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		playsound(target, 'sound/combat/shove.ogg', 100, TRUE, -1)

		if(target.wear_pants)
			target.wear_pants.add_fingerprint(user)
		SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, user, user.zone_selected)

		var/turf/target_oldturf = target.loc
		var/shove_dir = get_dir(user.loc, target_oldturf)
		var/turf/target_shove_turf = get_step(target.loc, shove_dir)
		var/mob/living/target_collateral_mob
		var/obj/structure/table/target_table
//		var/obj/machinery/disposal/bin/target_disposal_bin
		var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied

		if(prob(clamp(30 + (user.stat_fight(target,STATKEY_CON,STATKEY_STR)*10),0,100)))//check if we actually shove them
			//Thank you based whoneedsspace
			target_collateral_mob = locate(/mob/living) in target_shove_turf.contents
			if(target_collateral_mob)
				shove_blocked = TRUE
			else
				target.Move(target_shove_turf, shove_dir)
				if(get_turf(target) == target_oldturf)
					target_table = locate(/obj/structure/table) in target_shove_turf.contents
	//				target_disposal_bin = locate(/obj/machinery/disposal/bin) in target_shove_turf.contents
					if(target_table)
						shove_blocked = TRUE

/*		if(target.IsKnockdown() && !target.IsParalyzed())
			target.Paralyze(SHOVE_CHAIN_PARALYZE)
			target.visible_message("<span class='danger'>[user.name] kicks [target.name] onto their side!</span>",
							"<span class='danger'>You're kicked onto my side by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>I kick [target.name] onto their side!</span>")
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, SetKnockdown), 0), SHOVE_CHAIN_PARALYZE)
			log_combat(user, target, "kicks", "onto their side (paralyzing)")*/

		if(shove_blocked && !target.is_shove_knockdown_blocked() && !target.buckled)
			var/directional_blocked = FALSE
			if(shove_dir in GLOB.cardinals) //Directional checks to make sure that we're not shoving through a windoor or something like that
				var/target_turf = get_turf(target)
				for(var/obj/O in target_turf)
					if(O.flags_1 & ON_BORDER_1 && O.dir == shove_dir && O.density)
						directional_blocked = TRUE
						break
				if(target_turf != target_shove_turf) //Make sure that we don't run the exact same check twice on the same tile
					for(var/obj/O in target_shove_turf)
						if(O.flags_1 & ON_BORDER_1 && O.dir == turn(shove_dir, 180) && O.density)
							directional_blocked = TRUE
							break
			if((!target_table && !target_collateral_mob) || directional_blocked)
				target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
				target.visible_message("<span class='danger'>[user.name] shoves [target.name], knocking them down!</span>",
								"<span class='danger'>You're knocked down from a shove by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
				to_chat(user, "<span class='danger'>I shove [target.name], knocking them down!</span>")
				log_combat(user, target, "shoved", "knocking them down")
			else if(target_table)
				target.Knockdown(SHOVE_KNOCKDOWN_TABLE)
				target.visible_message("<span class='danger'>[user.name] shoves [target.name] onto \the [target_table]!</span>",
								"<span class='danger'>I'm shoved onto \the [target_table] by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
				to_chat(user, "<span class='danger'>I shove [target.name] onto \the [target_table]!</span>")
				target.throw_at(target_table, 1, 1, null, FALSE) //1 speed throws with no spin are basically just forcemoves with a hard collision check
				log_combat(user, target, "shoved", "onto [target_table] (table)")
			else if(target_collateral_mob)
				target.Knockdown(SHOVE_KNOCKDOWN_HUMAN)
				target_collateral_mob.Knockdown(SHOVE_KNOCKDOWN_COLLATERAL)
				target.visible_message("<span class='danger'>[user.name] shoves [target.name] into [target_collateral_mob.name]!</span>",
					"<span class='danger'>I'm shoved into [target_collateral_mob.name] by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
				to_chat(user, "<span class='danger'>I shove [target.name] into [target_collateral_mob.name]!</span>")
				log_combat(user, target, "shoved", "into [target_collateral_mob.name]")
		else
			target.visible_message("<span class='danger'>[user.name] shoves [target.name]!</span>",
							"<span class='danger'>I'm shoved by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>I shove [target.name]!</span>")
			var/target_held_item = target.get_active_held_item()
			var/knocked_item = FALSE
			if(!is_type_in_typecache(target_held_item, GLOB.shove_disarming_types))
				target_held_item = null
			if(!target.has_movespeed_modifier(MOVESPEED_ID_SHOVE))
				target.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
				if(target_held_item)
					target.visible_message("<span class='danger'>[target.name]'s grip on \the [target_held_item] loosens!</span>",
						"<span class='warning'>My grip on \the [target_held_item] loosens!</span>", null, COMBAT_MESSAGE_RANGE)
				addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon/human, clear_shove_slowdown)), SHOVE_SLOWDOWN_LENGTH)
			else if(target_held_item)
				target.dropItemToGround(target_held_item)
				knocked_item = TRUE
				target.visible_message("<span class='danger'>[target.name] drops \the [target_held_item]!</span>",
					"<span class='warning'>I drop \the [target_held_item]!</span>", null, COMBAT_MESSAGE_RANGE)
			var/append_message = ""
			if(target_held_item)
				if(knocked_item)
					append_message = "causing them to drop [target_held_item]"
				else
					append_message = "loosening their grip on [target_held_item]"
			log_combat(user, target, "shoved", append_message)

//shameless copypaste
/datum/species/proc/kicked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>I don't want to harm [target]!</span>")
		return FALSE
	if(HAS_TRAIT(user, TRAIT_FLOORED))
		return FALSE
	if(user == target)
		return FALSE
	if(user.check_leg_grabbed(1) || user.check_leg_grabbed(2))
		if(user.check_leg_grabbed(1) && user.check_leg_grabbed(2))		//If both legs are grabbed
			to_chat(user, span_notice("I can't move my leg!"))
			return
		else															//If only one leg is grabbed
			var/mob/living/G = user.pulledby
			var/userskill = 1
			if(user.mind)
				userskill = ((user.mind.get_skill_level(/datum/skill/combat/wrestling) * 0.1) + 1)
			var/grabberskill = 1
			if(G?.mind)
				grabberskill = ((G.mind.get_skill_level(/datum/skill/combat/wrestling) * 0.1) + 1)
			if(((user.STASTR + rand(1, 6)) * userskill) < ((G.STASTR + rand(1, 6)) * grabberskill))
				to_chat(user, span_notice("I can't move my leg!"))
				user.changeNext_move(CLICK_CD_GRABBING)
				return
			else
				user.resist_grab()

	if(user.stamina >= user.maximum_stamina)
		return FALSE
	if(!(user.mobility_flags & MOBILITY_STAND))
		return FALSE
	var/stander = TRUE
	if(!(target.mobility_flags & MOBILITY_STAND))
		stander = FALSE
	if(user.loc == target.loc)
		if(!stander && (user.mobility_flags & MOBILITY_STAND))
			target.lastattacker = user.real_name
			target.lastattackerckey = user.ckey
			if(target.mind)
				target.mind.attackedme[user.real_name] = world.time
			var/selzone = accuracy_check(user.zone_selected, user, target, /datum/skill/combat/unarmed, user.used_intent)
			var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(selzone))
			var/damage = (user.get_punch_dmg() * 1.4)
			if(user.shoes)
				damage *= (1 + (user.shoes.armor_class * 0.2))
			var/armor_block = target.run_armor_check(selzone, "blunt", blade_dulling = BCLASS_BLUNT)
			var/balance = 10
			target.next_attack_msg.Cut()
			var/nodmg = FALSE
			if(!target.apply_damage(damage, user.dna.species.attack_type, affecting, armor_block))
				nodmg = TRUE
				target.next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
			else
				if(affecting)
					if(selzone == BODY_ZONE_PRECISE_NECK)
						to_chat(user, "<span class='danger'>I put my foot on [target]'s neck!</span>")
						nodmg = TRUE
						target.emote("gasp")
						target.adjustOxyLoss(25)
						target.Immobilize(5)
						balance += 15
						target.visible_message("<span class='danger'>[user] puts their foot on [target]'s neck!</span>", \
										"<span class='danger'>I'm get my throat stepped on by [user]! I can't breathe!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE, user)
					else
						affecting.bodypart_attacked_by(BCLASS_BLUNT, damage, user, user.zone_selected, crit_message = TRUE)
						target.visible_message("<span class='danger'>[user] stomps [target]![target.next_attack_msg.Join()]</span>", \
										"<span class='danger'>I'm stomped by [user]![target.next_attack_msg.Join()]</span>", "<span class='hear'>I hear a sickening kick!</span>", COMBAT_MESSAGE_RANGE, user)
						to_chat(user, "<span class='danger'>I stomp on [target]![target.next_attack_msg.Join()]</span>")
			target.next_attack_msg.Cut()
			log_combat(user, target, "kicked")
			user.OffBalance(balance)
			if(!nodmg)
				playsound(target, 'sound/combat/hits/kick/stomp.ogg', 100, TRUE, -1)
			return TRUE
		else
			to_chat(user, "<span class='warning'>I'm too close to get a good kick in.</span>")
			return FALSE
	else
		if(!target.kick_attack_check(user))
			return 0

		playsound(target, 'sound/combat/hits/kick/kick.ogg', 100, TRUE, -1)

		var/turf/target_oldturf = target.loc
		var/shove_dir = get_dir(user.loc, target_oldturf)
		var/turf/target_shove_turf = get_step(target.loc, shove_dir)
		var/mob/living/target_collateral_mob
		var/obj/structure/table/target_table
		var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied

		target_collateral_mob = locate(/mob/living) in target_shove_turf.contents
		if(target_collateral_mob)
			if(stander)
				shove_blocked = TRUE
		else
			target.Move(target_shove_turf, shove_dir)
			if(get_turf(target) == target_oldturf)
				if(stander)
					target_table = locate(/obj/structure/table) in target_shove_turf.contents
					shove_blocked = TRUE
			else
				if(stander && target.stamina >= target.maximum_stamina) //if you are kicked while fatigued, you are knocked down no matter what
					target.Knockdown(100)

		if(shove_blocked && !target.is_shove_knockdown_blocked() && !target.buckled)
			var/directional_blocked = FALSE
			if(shove_dir in GLOB.cardinals) //Directional checks to make sure that we're not shoving through a windoor or something like that
				var/target_turf = get_turf(target)
				for(var/obj/O in target_turf)
					if(O.flags_1 & ON_BORDER_1 && O.dir == shove_dir && O.density)
						directional_blocked = TRUE
						break
				if(target_turf != target_shove_turf) //Make sure that we don't run the exact same check twice on the same tile
					for(var/obj/O in target_shove_turf)
						if(O.flags_1 & ON_BORDER_1 && O.dir == turn(shove_dir, 180) && O.density)
							directional_blocked = TRUE
							break
			if((!target_table && !target_collateral_mob) || directional_blocked)
				target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
				target.visible_message("<span class='danger'>[user.name] kicks [target.name], knocking them down!</span>",
								"<span class='danger'>I'm knocked down from a kick by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
				to_chat(user, "<span class='danger'>I kick [target.name], knocking them down!</span>")
				log_combat(user, target, "kicked", "knocking them down")
			else if(target_table)
				target.Knockdown(SHOVE_KNOCKDOWN_TABLE)
				target.visible_message("<span class='danger'>[user.name] kicked [target.name] onto \the [target_table]!</span>",
								"<span class='danger'>I'm kicked onto \the [target_table] by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
				to_chat(user, "<span class='danger'>I kick [target.name] onto \the [target_table]!</span>")
				target.throw_at(target_table, 1, 1, null, FALSE) //1 speed throws with no spin are basically just forcemoves with a hard collision check
				log_combat(user, target, "kicked", "onto [target_table] (table)")
			else if(target_collateral_mob)
				target.Knockdown(SHOVE_KNOCKDOWN_HUMAN)
				target_collateral_mob.Knockdown(SHOVE_KNOCKDOWN_COLLATERAL)
				target.visible_message("<span class='danger'>[user.name] kicks [target.name] into [target_collateral_mob.name]!</span>",
					"<span class='danger'>I'm kicked into [target_collateral_mob.name] by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, user)
				to_chat(user, "<span class='danger'>I kick [target.name] into [target_collateral_mob.name]!</span>")
				log_combat(user, target, "kicked", "into [target_collateral_mob.name]")
		else
			target.visible_message("<span class='danger'>[user.name] kicks [target.name]!</span>",
							"<span class='danger'>I'm kicked by [user.name]!</span>", "<span class='hear'>I hear aggressive shuffling!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>I kick [target.name]!</span>")
			log_combat(user, target, "kicked")

		var/selzone = accuracy_check(user.zone_selected, user, target, /datum/skill/combat/unarmed, user.used_intent)
		var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(selzone))
		if(!affecting)
			affecting = target.get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = target.run_armor_check(selzone, "blunt", blade_dulling = BCLASS_BLUNT)
		var/damage = (user.get_punch_dmg() * 2.5)
		if(user.shoes)
			damage *= (1 + (user.shoes.armor_class * 0.2))
		if(!target.apply_damage(damage, user.dna.species.attack_type, affecting, armor_block))
			target.next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
		else
			affecting.bodypart_attacked_by(BCLASS_BLUNT, damage, user, selzone)
		playsound(target, 'sound/combat/hits/kick/kick.ogg', 100, TRUE, -1)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		if(target.mind)
			target.mind.attackedme[user.real_name] = world.time
		user.adjust_stamina(15)
		user.OffBalance(15)
		target.forcesay(GLOB.hit_appends)

/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	return

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if(!istype(M))
		return
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M)) //sanity check for drones.
		return
	if(M.mind)
		attacker_style = M.mind.martial_art
	if((M != H) && M.used_intent.type != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		log_combat(M, H, "attempted to touch")
		H.visible_message("<span class='warning'>[M] attempts to touch [H]!</span>", \
						"<span class='danger'>[M] attempts to touch you!</span>", "<span class='hear'>I hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, M)
		to_chat(M, "<span class='warning'>I attempt to touch [H]!</span>")
		return 0
	SEND_SIGNAL(M, COMSIG_MOB_ATTACK_HAND, M, H, attacker_style)
	switch(M.used_intent.type)
		if(INTENT_HELP)
			help(M, H, attacker_style)
			return

		if(INTENT_GRAB)
			if(!M.has_hand_for_held_index(M.active_hand_index, TRUE)) //we obviously have a hand, but we need to check for fingers/prosthetics
				to_chat(M, "<span class='warning'>I can't move the fingers of my [M.active_hand_index == 1 ? "left" : "right"] hand.</span>")
				return
			grab(M, H, attacker_style)
			return

		if(INTENT_DISARM)
			disarm(M, H, attacker_style)
			return
	if(istype(M.used_intent, /datum/intent/unarmed))
		harm(M, H, attacker_style)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H, selzone)
	// Allows you to put in item-specific reactions based on species
	if(user != H)
		if(H.can_see_cone(user))
			if(H.check_shields(I, I.force, "the [I.name]", MELEE_ATTACK, I.armor_penetration))
				return 0
	if(H.check_block())
		H.visible_message("<span class='warning'>[H] blocks [I]!</span>", \
						"<span class='danger'>I block [I]!</span>")
		return 0

	var/hit_area

	selzone = accuracy_check(user.zone_selected, user, H, I.associated_skill, user.used_intent, I)
	affecting = H.get_bodypart(check_zone(selzone))

	if(!affecting)
		return

	hit_area = affecting.name
	var/def_zone = affecting.body_zone

	var/pen = I.armor_penetration
	if(user.used_intent?.penfactor)
		pen = I.armor_penetration + user.used_intent.penfactor

//	var/armor_block = H.run_armor_check(affecting, "melee", "<span class='notice'>My armor has protected my [hit_area]!</span>", "<span class='warning'>My armor has softened a hit to my [hit_area]!</span>",pen)

	var/Iforce = get_complex_damage(I, user) //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)
	var/armor_block = H.run_armor_check(selzone, I.damage_type, "", "",pen, damage = Iforce, blade_dulling=user.used_intent.blade_class)

	var/nodmg = FALSE

	var/actual_damage = Iforce
	if(Iforce)

		var/weakness = H.check_weakness(I, user)
		actual_damage = apply_damage(Iforce * weakness, I.damtype, def_zone, armor_block, H)
		H.next_attack_msg.Cut()
		if(!actual_damage)
			nodmg = TRUE
			H.next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
			if(!QDELETED(I))
				I.take_damage(1, BRUTE, I.damage_type)
		if(!nodmg)
			var/datum/wound/crit_wound = affecting.bodypart_attacked_by(user.used_intent.blade_class, (Iforce * weakness) * ((100-(armor_block))/100), user, selzone, crit_message = TRUE)
			if(should_embed_weapon(crit_wound, I))
				var/can_impale = TRUE
				if(!affecting)
					can_impale = FALSE
				else if(I.wlength > WLENGTH_SHORT && !(affecting.body_zone in list(BODY_ZONE_CHEST, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))
					can_impale = FALSE
				if(can_impale && user.Adjacent(H))
					affecting.add_embedded_object(I, silent = FALSE, crit_message = TRUE)
					H.emote("embed")
					affecting.receive_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class)//It hurts to rip it out, get surgery you dingus.
					user.put_in_hands(I)
					H.emote("pain", TRUE)
					playsound(H.loc, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
//		if(H.used_intent.blade_class == BCLASS_BLUNT && I.force >= 15 && affecting.body_zone == "chest")
//			var/turf/target_shove_turf = get_step(H.loc, get_dir(user.loc,H.loc))
//			H.throw_at(target_shove_turf, 1, 1, H, spin = FALSE)

	I.funny_attack_effects(H, user, nodmg)
	knockback(I, H, user, nodmg, actual_damage)

	H.send_item_attack_message(I, user, parse_zone(selzone))
	SEND_SIGNAL(I, COMSIG_ITEM_SPEC_ATTACKEDBY, H, user, affecting, actual_damage)
	if(nodmg)
		return FALSE //dont play a sound

	//dismemberment
	var/bloody = 0
	var/probability = I.get_dismemberment_chance(affecting, user)
	if(affecting.brute_dam && prob(probability) && affecting.dismember(I.damtype, user.used_intent?.blade_class, user, selzone))
		bloody = 1
		I.add_mob_blood(H)
		user.update_inv_hands()
		playsound(get_turf(H), I.get_dismember_sound(), 80, TRUE)

	if(((I.damtype == BRUTE) && I.force && prob(25 + (I.force * 2))))
		if(affecting.status == BODYPART_ORGANIC)
			I.add_mob_blood(H)	//Make the weapon bloody, not the person.
			user.update_inv_hands()
			if(prob(I.force * 2) || bloody)	//blood spatter!
				bloody = 1
				var/turf/location = H.loc
				var/splatter_dir = get_dir(H, user)
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(H.loc, splatter_dir)
				if(istype(location))
					H.add_splatter_floor(location)
				if(get_dist(user, H) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(H)

		switch(hit_area)
			if(BODY_ZONE_HEAD)
				if(bloody)	//Apply blood
					if(H.wear_mask)
						H.wear_mask.add_mob_blood(H)
						H.update_inv_wear_mask()
					if(H.head)
						H.head.add_mob_blood(H)
						H.update_inv_head()

			if(BODY_ZONE_CHEST)
				if(bloody)
					if(H.wear_armor)
						H.wear_armor.add_mob_blood(H)
						H.update_inv_armor()
					if(H.wear_shirt)
						H.wear_shirt.add_mob_blood(H)
						H.update_inv_shirt()
					if(H.wear_pants)
						H.wear_pants.add_mob_blood(H)
						H.update_inv_pants()

		if(Iforce > 10 || Iforce >= 5 && prob(Iforce))
			H.forcesay(GLOB.hit_appends)	//forcesay checks stat already.
	return TRUE

/datum/species/proc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE, spread_damage = FALSE)
	SEND_SIGNAL(H, COMSIG_MOB_APPLY_DAMGE, damage, damagetype, def_zone)
	var/hit_percent = 1
	damage = max(damage - (blocked),0)
	hit_percent = (hit_percent * (100-H.physiology.damage_resistance))/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0

	var/obj/item/bodypart/BP = null
	if(!spread_damage)
		if(isbodypart(def_zone))
			BP = def_zone
		else
			if(!def_zone)
				def_zone = ran_zone(def_zone)
			BP = H.get_bodypart(check_zone(def_zone))
			if(!BP)
				BP = H.bodyparts[1]

	var/damage_amount = damage
	switch(damagetype)
		if(BRUTE)
			H.damageoverlaytemp = 20
			damage_amount = forced ? damage : damage * hit_percent * brutemod * H.physiology.brute_mod
			if(!HAS_TRAIT(H, TRAIT_NOPAIN))
				if(damage_amount > 5)
					H.AdjustSleeping(-50)
					if(prob(damage_amount * 3))
						if(damage_amount > ((H.STACON*10) / 3))
							H.emote("painscream")
						else
							H.emote("pain")
				if(damage_amount > ((H.STACON*10) / 3) && !HAS_TRAIT(H, TRAIT_NOPAINSTUN))
					H.Immobilize(8)
					shake_camera(H, 2, 2)
					H.stuttering += 5
				if(damage_amount > 10 && !HAS_TRAIT(H, TRAIT_NOPAINSTUN))
					H.Slowdown(clamp(damage_amount/10, 1, 5))
					shake_camera(H, 1, 1)
				if(damage_amount < 10)
					H.flash_fullscreen("redflash1")
				else if(damage_amount < 20)
					H.flash_fullscreen("redflash2")
				else if(damage_amount >= 20)
					H.flash_fullscreen("redflash3")
			if(BP)
				if(BP.receive_damage(damage_amount, 0))
					H.update_damage_overlays()
			else//no bodypart, we deal damage with a more general method.
				H.adjustBruteLoss(damage_amount)
		if(BURN)
			H.damageoverlaytemp = 20
			damage_amount = forced ? damage : damage * hit_percent * burnmod * H.physiology.burn_mod
			if(damage_amount > 10 && prob(damage_amount))
				H.emote("pain")
			if(damage_amount < 10)
				H.flash_fullscreen("redflash1")
			else if(damage_amount < 20)
				H.flash_fullscreen("redflash2")
			else if(damage_amount >= 20)
				H.flash_fullscreen("redflash3")
			if(BP)
				if(BP.receive_damage(0, damage_amount))
					H.update_damage_overlays()
			else
				H.adjustFireLoss(damage_amount)
		if(TOX)
			damage_amount = forced ? damage : damage * hit_percent * H.physiology.tox_mod
			H.adjustToxLoss(damage_amount)
		if(OXY)
			damage_amount = forced ? damage : damage * hit_percent * H.physiology.oxy_mod
			H.adjustOxyLoss(damage_amount)
		if(CLONE)
			damage_amount = forced ? damage : damage * hit_percent * H.physiology.clone_mod
			H.adjustCloneLoss(damage_amount)
		if(BRAIN)
			damage_amount = forced ? damage : damage * hit_percent * H.physiology.brain_mod
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)
	return damage_amount

/datum/species/proc/on_hit(obj/projectile/P, mob/living/carbon/human/H)

/datum/species/proc/bullet_act(obj/projectile/P, mob/living/carbon/human/H, def_zone = BODY_ZONE_CHEST)
	// called before a projectile hit
	if(def_zone == "head")
		if(H.head)
			var/obj/item/I = H.head
			if(I.blockproj(H))
				return 1
	return 0

/obj/item/proc/blockproj(mob/living/carbon/human/H)
	return

/datum/species/proc/handle_environment(mob/living/carbon/human/H)
	var/loc_temp = BODYTEMP_NORMAL //TODO VANDERLIN: make proximity based temperature
	//Body temperature is adjusted in two parts: first there my body tries to naturally preserve homeostasis (shivering/sweating), then it reacts to the surrounding environment
	//Thermal protection (insulation) has mixed benefits in two situations (hot in hot places, cold in hot places)
	if(!H.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		var/natural = 0
		if(H.stat != DEAD)
			natural = H.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		if(loc_temp < H.bodytemperature) //Place is colder than we are
			thermal_protection -= H.get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(H.bodytemperature < BODYTEMP_NORMAL) //we're cold, insulation helps us retain body heat and will reduce the heat we lose to the environment
				H.adjust_bodytemperature((thermal_protection+1)*natural + max(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_COLD_DIVISOR, BODYTEMP_COOLING_MAX))
			else //we're sweating, insulation hinders our ability to reduce heat - and it will reduce the amount of cooling you get from the environment
				H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + max((thermal_protection * (loc_temp - H.bodytemperature) + BODYTEMP_NORMAL - H.bodytemperature) / BODYTEMP_COLD_DIVISOR , BODYTEMP_COOLING_MAX)) //Extra calculation for hardsuits to bleed off heat
	if (loc_temp > H.bodytemperature) //Place is hotter than we are
		var/natural = 0
		if(H.stat != DEAD)
			natural = H.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		thermal_protection -= H.get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
		if(H.bodytemperature < BODYTEMP_NORMAL) //and we're cold, insulation enhances our ability to retain body heat but reduces the heat we get from the environment
			H.adjust_bodytemperature((thermal_protection+1)*natural + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
		else //we're sweating, insulation hinders out ability to reduce heat - but will reduce the amount of heat we get from the environment
			H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))

	// +/- 50 degrees from 310K is the 'safe' zone, where no damage is dealt.
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTHEAT))
		//Body temperature is too hot.

		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)

		H.remove_movespeed_modifier(MOVESPEED_ID_COLD)

		var/burn_damage
		var/firemodifier = (H.fire_stacks + H.divine_fire_stacks) / 50
		if (H.on_fire)
			burn_damage = 20
			if((H.fire_stacks + H.divine_fire_stacks) >= HUMAN_FIRE_STACK_ICON_NUM)
				burn_damage = 200
		else
			firemodifier = min(firemodifier, 0)
			burn_damage = max(log(2-firemodifier,(H.bodytemperature-BODYTEMP_NORMAL))-5,0) // this can go below 5 at log 2.5
		if (burn_damage)
			switch(burn_damage)
				if(0 to 2)
					H.throw_alert("temp", /atom/movable/screen/alert/status_effect/debuff/hot, 1)
				if(2 to 4)
					H.throw_alert("temp", /atom/movable/screen/alert/status_effect/debuff/hot, 2)
				else
					H.throw_alert("temp", /atom/movable/screen/alert/status_effect/debuff/hot, 3)
		burn_damage = burn_damage * heatmod * H.physiology.heat_mod
		if (H.stat < UNCONSCIOUS && (prob(burn_damage) * 10) / 4) //40% for level 3 damage on humans
			H.emote("pain")
		var/final_damage = CLAMP(burn_damage, 0, CONFIG_GET(number/per_tick/max_fire_damage))
		H.apply_damage(final_damage, BURN, spread_damage = TRUE)
		if(!H.has_smoke_protection())
			H.apply_damage(final_damage/4, OXY) // simulating smoke inhalation

	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTCOLD))
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		//Sorry for the nasty oneline but I don't want to assign a variable on something run pretty frequently
		H.add_movespeed_modifier(MOVESPEED_ID_COLD, override = TRUE, multiplicative_slowdown = ((BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR), blacklisted_movetypes = FLOATING)
		switch(H.bodytemperature)
			if(200 to BODYTEMP_COLD_DAMAGE_LIMIT)
				H.throw_alert("temp", /atom/movable/screen/alert/status_effect/debuff/cold, 1)
				H.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod*H.physiology.cold_mod, BURN)
			if(120 to 200)
				H.throw_alert("temp", /atom/movable/screen/alert/status_effect/debuff/cold, 2)
				H.apply_damage(COLD_DAMAGE_LEVEL_2*coldmod*H.physiology.cold_mod, BURN)
			else
				H.throw_alert("temp", /atom/movable/screen/alert/status_effect/debuff/cold, 3)
				H.apply_damage(COLD_DAMAGE_LEVEL_3*coldmod*H.physiology.cold_mod, BURN)

	else
		H.clear_alert("temp")
		H.remove_movespeed_modifier(MOVESPEED_ID_COLD)
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H, no_protection = FALSE)
	if(!CanIgniteMob(H))
		return TRUE
	if(H.on_fire)
		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		var/list/obscured = H.check_obscured_slots(TRUE)
		//HEAD//

		if(H.wear_mask && !(SLOT_WEAR_MASK in obscured))
			burning_items += H.wear_mask
		if(H.wear_neck && !(SLOT_NECK in obscured))
			burning_items += H.wear_neck
		if(H.head && !(SLOT_HEAD in obscured))
			burning_items += H.head

		//CHEST//
		if(H.wear_pants && !(SLOT_PANTS in obscured))
			burning_items += H.wear_pants
		if(H.wear_shirt && !(SLOT_SHIRT in obscured))
			burning_items += H.wear_shirt
		if(H.wear_armor && !(SLOT_ARMOR in obscured))
			burning_items += H.wear_armor

		//ARMS & HANDS//
		var/obj/item/clothing/arm_clothes = null
		if(H.gloves && !(SLOT_GLOVES in obscured))
			arm_clothes = H.gloves
		else if(H.wear_armor && ((H.wear_armor.body_parts_covered & HANDS) || (H.wear_armor.body_parts_covered & ARMS)))
			arm_clothes = H.wear_armor
		else if(H.wear_pants && ((H.wear_pants.body_parts_covered & HANDS) || (H.wear_pants.body_parts_covered & ARMS)))
			arm_clothes = H.wear_pants
		if(arm_clothes)
			burning_items |= arm_clothes

		//LEGS & FEET//
		var/obj/item/clothing/leg_clothes = null
		if(H.shoes && !(SLOT_SHOES in obscured))
			leg_clothes = H.shoes
		else if(H.wear_armor && ((H.wear_armor.body_parts_covered & FEET) || (H.wear_armor.body_parts_covered & LEGS)))
			leg_clothes = H.wear_armor
		else if(H.wear_pants && ((H.wear_pants.body_parts_covered & FEET) || (H.wear_pants.body_parts_covered & LEGS)))
			leg_clothes = H.wear_pants
		if(leg_clothes)
			burning_items |= leg_clothes

		for(var/X in burning_items)
			var/obj/item/I = X
			I.fire_act(((H.fire_stacks + H.divine_fire_stacks)* 50)) //damage taken is reduced to 2% of this value by fire_act()

		var/thermal_protection = H.get_thermal_protection()

		if(thermal_protection >= 30000 && !no_protection)
			return
		if(thermal_protection >= 30000 && !no_protection)
			H.adjust_bodytemperature(11)
		else
			H.adjust_bodytemperature(BODYTEMP_HEATING_MAX + ((H.fire_stacks + H.divine_fire_stacks)* 12))
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)

/datum/species/proc/CanIgniteMob(mob/living/carbon/human/H)
	if(H.divine_fire_stacks > 0) // tieflings can't say no to astrata
		return TRUE
	if(HAS_TRAIT(H, TRAIT_NOFIRE))
		return FALSE
	return TRUE

/datum/species/proc/ExtinguishMob(mob/living/carbon/human/H)
	return


////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	. = stunmod * H.physiology.stun_mod * amount

//////////////
//Space Move//
//////////////

/datum/species/proc/space_move(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

////////////////
//Tail Wagging//
////////////////

/datum/species/proc/can_wag_tail(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/is_wagging_tail(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/start_wagging_tail(mob/living/carbon/human/H)

/datum/species/proc/stop_wagging_tail(mob/living/carbon/human/H)

/datum/species/proc/knockback(obj/item/I, mob/living/target, mob/living/user, nodmg, actual_damage)
	if(!istype(I))
		if(!target.resting)
			var/chungus_str = target.STASTR
			var/knockback_tiles = 0
			var/damage = actual_damage
			if(chungus_str >= 3)
				knockback_tiles = FLOOR(damage/((chungus_str - 2) * 4), 1)
			else
				knockback_tiles = FLOOR(damage/2, 1)
			if(knockback_tiles >= 1)
				var/turf/edge_target_turf = get_edge_target_turf(target, get_dir(user, target))
				if(istype(edge_target_turf))
					target.safe_throw_at(edge_target_turf, \
										knockback_tiles, \
										knockback_tiles, \
										user, \
										spin = FALSE, \
										force = target.move_force, \
										callback = CALLBACK(target, TYPE_PROC_REF(/mob/living, handle_knockback), get_turf(target)))
	else
		if(!I.force)
			return
		if(!I.sharpness)
			if(!target.resting)
				var/endurance = target.STAEND
				var/knockback_tiles = 0
				var/newforce = actual_damage
				if(endurance >= 3)
					knockback_tiles = FLOOR(newforce/((endurance - 2) * 4), 1)
				else
					knockback_tiles = FLOOR(newforce/2, 1)
				if(knockback_tiles >= 1)
					var/turf/edge_target_turf = get_edge_target_turf(target, get_dir(user, target))
					if(istype(edge_target_turf))
						target.safe_throw_at(edge_target_turf, \
											knockback_tiles, \
											knockback_tiles, \
											user, \
											spin = FALSE, \
											force = target.move_force, \
											callback = CALLBACK(target, TYPE_PROC_REF(/mob/living, handle_knockback), get_turf(target)))

/mob/living/proc/handle_knockback(turf/starting_turf)
	var/distance = 0
	var/skill_modifier = 10
	if(istype(starting_turf) && !QDELETED(starting_turf))
		distance = get_dist(starting_turf, src)
	skill_modifier *= mind?.get_skill_level(/datum/skill/misc/athletics)
	var/modifier = -distance
	if(!prob(STAEND+skill_modifier+modifier))
		Knockdown(8)
