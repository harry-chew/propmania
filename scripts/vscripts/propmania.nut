IncludeScript("VSLib");

function Notifications::OnSpawn::SetupGame(player, params)
{
	if (player == null)
	{
		return;
	}

	if (FileIO.LoadTable("propmania/save_file") != null)
	{
		local table = { "objects" : []};
		FileIO.SaveTable("propmania/save_file", table);
	}
}

//ACTUAL FUNCTIONALITY

//GLOBAL VARS
::rotation <- 1 //storees the current rotational amount, controlled with + - keypad keys
::selected <- "none" //stores the currently selected object, used for copy/paste functionality
::mode <- "rotation"
::sFormat <- "propformat"

//Setup the Menu
::rotationHUD <- HUD.Item("Rotation: {rotation}");
rotationHUD.SetValue("rotation", rotation);
rotationHUD.AttachTo(HUD_FAR_RIGHT);
rotationHUD.Resize(600, 200);
rotationHUD.SetPositionNative(1520, 100, 1920, 1080);
rotationHUD.SetTextPosition(TextAlign.Left);

::selectedHUD <- HUD.Item("Selected: {selected}");
selectedHUD.SetValue("selected", "");
selectedHUD.AttachTo(HUD_TICKER);
selectedHUD.SetWidth(0.5);

//scripted_user_func
function EasyLogic::OnUserCommand::DoCommand(player, args, text)
{
	local command = GetArgument(0);
	switch (command)
	{
		case "increase":
		::IncreaseRotation(player, args);
		break;
		case "decrease":
		::DecreaseRotation(player, args);
		break;
		case "copy":
		::CopyEntity(player, args);
		break;
		case "paste":
		::PasteEntity(player, args);
		break;
		case "rotate":
		::Rotate(player, args);
		break;
		case "saveobject":
		::SaveToFile(player, args, text);
		break;
		case "swapmode":
		::SwapMode(player, args);
		break;
		case "swapformat":
		::SwapFormat(player, args);
		break;
	}
}

::SwapMode <- function(player, args)
{
	local swapmode = GetArgument(1);

	switch (swapmode) {
		case "rotation":
			mode = "rotation";
			rotationHUD.SetFormatString("{format} R: {rotation}");
			rotationHUD.SetValue("rotation", rotation);
			rotationHUD.SetValue("format", sFormat);
			break;
		case "position":
			mode = "position";
			rotationHUD.SetFormatString("{format} P: {rotation}");
			rotationHUD.SetValue("rotation", rotation);
			rotationHUD.SetValue("format", sFormat);
			break;
		default:
			printf("you did a bad");
			break;
	}
	printf("Mode: %s", mode);
}

::SwapFormat <- function(player, args) {
	local swapformat = GetArgument(1);

	switch (swapformat) {
		case "propformat":
			sFormat = "propformat";
			//formatHUD.SetFormatString("Format: Propmania");
			break;
		case "teamformat":
			sFormat = "teamformat";
			//formatHUD.SetFormatString("Format: Teams");
			break;
		default:
			printf("you did a bad");
			break;
	}
	printf("Format: %s", sFormat);
}


::DecreaseRotation <- function(player, args)
{
	local rot = ::rotation;
	rot = rot / 2;
	if (rot <= 1) rot = 1;
	rotation = rot;
	printf("Rotation: %i", rotation);
	rotationHUD.SetValue("rotation", rotation);
}

::IncreaseRotation <- function(player, args)
{
	local rot = ::rotation;
	rot = rot * 2;
	if (rot >= 96) rot = 96;
	rotation = rot;
	printf("Rotation: %i", rotation);
	rotationHUD.SetValue("rotation", rotation);
}

::CopyEntity <- function(player, args)
{
	if (player != null)
	{
		local entity = player.GetLookingEntity();
		if (entity != null)
		{
			selected = entity;
			selectedHUD.SetValue("selected", selected.GetClassname());
			printf("Selected: %s", selected.GetClassname());
		}
	}
}

::PasteEntity <- function(player, args)
{
	if (player != null)
	{
		if (selected != null)
		{
			Utils.SpawnEntity(selected.GetClassname(), "copied entity", player.GetLookingLocation(), player.GetAngles());
			printf("Paste: %s", selected.GetClassname());
		}
	}
}

::Rotate <- function(player, args)
{
	if (player != null)
	{
		local entity = player.GetLookingEntity();
		if (entity != null)
		{
			local direction = GetArgument(1);
			local rotationValue = ::rotation;
			local pos = entity.GetLocation();
			local ang = entity.GetAngles();

			if (mode == "position")
			{
				local posX = pos.x;
				local posY = pos.y;
				local posZ = pos.z;

				switch (direction)
				{
					case "left":
						posX = pos.x + rotationValue.tofloat();
						break;
					case "right":
						posX = pos.x - rotationValue.tofloat();
						break;
					case "rr":
						posZ = pos.z + rotationValue.tofloat();
						break;
					case "rl":
						posZ = pos.z - rotationValue.tofloat();
						break;
					case "up":
						posY = pos.y - rotationValue.tofloat();
						break;
					case "down":
						posY = pos.y + rotationValue.tofloat();
						break;
				}

				entity.SetPosition(posX, posY, posZ);
			}
			else if (mode == "rotation")
			{
				local angX = ang.x;
				local angY = ang.y;
				local angZ = ang.z;

				switch (direction)
				{
					case "left":
						angY = ang.y - rotationValue.tofloat();
						break;
					case "right":
						angY = ang.y + rotationValue.tofloat();
						break;
					case "up":
						angX = ang.x - rotationValue.tofloat();
						break;
					case "down":
						angX = ang.x + rotationValue.tofloat();
						break;
					case "rl":
						angZ = ang.z - rotationValue.tofloat();
						break;
					case "rr":
						angZ = ang.z + rotationValue.tofloat();
						break;
				}

				entity.SetAngles(angX, angY, angZ);
			}
		}
	}
}

::SaveToFile <- function(player, args, text)
{
	if (player != null)
	{
		local entity = player.GetLookingEntity();

		if (entity != null)
		{
			local name = entity.GetClassname();
			local model = entity.GetModel();
			local pos = entity.GetPosition();
			local ang = entity.GetAngles();
			local stringOutput = "";
			if (sFormat == "propformat")
			{
				stringOutput = format("102, true, true, \"%s\", Vector(%f, %f, %f), Vector(%f, %f, %f),", model, pos.x, pos.y, pos.z, ang.x, ang.y, ang.z);
			}
			else if (sFormat == "teamformat")
			{
				local formattedString = GetFormattedItemString(pos, ang, model);
				if (formattedString != "ERROR")
					stringOutput = formattedString;
				else
					stringOutput = format("There was an error processing %s", model);
			}

			printf(stringOutput);
			if (sFormat == "propformat") {
				if (FileIO.LoadTable("propmania/save_file") == null)
				{
					local table = { "objects" : [stringOutput]};
					FileIO.SaveTable("propmania/save_file", table);
				}
				else {
					local table = FileIO.LoadTable("propmania/save_file");
					table.objects.push(stringOutput);
					FileIO.SaveTable("propmania/save_file", table);
				}
			} else if (sFormat == "teamformat") {
				if (FileIO.LoadTable("propmania/team_file") == null)
				{
					local table = { "objects" : [stringOutput]};
					FileIO.SaveTable("propmania/team_file", table);
				}
				else {
					local table = FileIO.LoadTable("propmania/team_file");
					table.objects.push(stringOutput);
					FileIO.SaveTable("propmania/team_file", table);
				}
			}

		}
	}
}

::GetFormattedItemString <- function(pos, ang, model) {
	local formattedString = "";
	local item = "";
	switch (model) {
		case "models/w_models/weapons/w_pistol_B.mdl":
			item = "weapon_pistol";
			formattedString	= format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_desert_eagle.mdl":
			item = "weapon_pistol_magnum"
			formattedString	= format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_smg_uzi.mdl":
			item = "weapon_smg"
			formattedString	= format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_smg_a.mdl":
			item = "weapon_smg_silenced"
			formattedString	= format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_smg_mp5.mdl":
			item = "weapon_smg_mp5"
			formattedString	= format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_shotgun.mdl":
			item = "weapon_pumpshotgun"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_shotgun_spas.mdl":
			item = "weapon_shotgun_spas"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_autoshot_m4super.mdl":
			item = "weapon_autoshotgun"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_sniper_mini14.mdl":
			item = "weapon_hunting_rifle"
			break;
		case "models/w_models/weapons/w_sniper_scout.mdl":
			item = "weapon_sniper_scout"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_sniper_military.mdl":
			item = "weapon_sniper_military"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_sniper_awp.mdl":
			item = "weapon_sniper_awp"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_rifle_m16a2.mdl":
		    item = "weapon_rifle"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_desert_rifle.mdl":
			item = "weapon_rifle_desert"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_rifle_ak47.mdl":
			item = "weapon_rifle_ak47"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_rifle_sg552.mdl":
			item = "weapon_sg552"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_m60.mdl":
			item = "weapon_rifle_m60"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_grenade_launcher.mdl":
			item = "weapon_grenade_launcher"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/w_models/weapons/w_pumpshotgun_A.mdl":
			item = "weapon_pumpshotgun"
			formattedString = format("SpawnFinWep(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/props/terror/ammo_stack.mdl":
			item = "models/props/terror/ammo_stack.mdl"
			formattedString	= format("SpawnFinAmmo(Vector(%f, %f, %f), \"%i %i %i\", \"%s\")", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			break;
		case "models/props_unique/spawn_apartment/lantern.mdl":
			item = "models/props_unique/spawn_apartment/lantern.mdl"
			formattedString = format("SpawnFinProp(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1300, 1500, 1, 0)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item);
			formattedString += format("\\nSpawnFinLight(Vector(%f, %f, %f), \"0 0 0\", \"245 233 194\", 3)", pos.x, pos.y, pos.z);
			break;
		case "models/props/terror/exploding_ammo.mdl":
			formattedString = format("SpawnFinFrag(Vector(%f, %f, %f), \"0 0 0\")", pos.x, pos.y, pos.z);
			break;
		case "models/props/terror/incendiary_ammo.mdl":
			formattedString = format("SpawnFinFire(Vector(%f, %f, %f), \"0 0 0\")", pos.x, pos.y, pos.z);
			break;
		case "models/w_models/weapons/w_eq_Medkit.mdl":
			formattedString = format("SpawnFinKit(Vector(%f, %f, %f), \"%i %i %i\")", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z);
			break;
		case "models/w_models/weapons/w_eq_defibrillator.mdl":
			formattedString = format("SpawnFinDefib(Vector(%f, %f, %f), \"%i %i %i\")", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z);
			break;
		case "models/w_models/weapons/w_eq_pipebomb.mdl":
			formattedString = format("SpawnFinPipe(Vector(%f, %f, %f), \"%i %i %i\")", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z);
			break;
		case "models/w_models/weapons/w_eq_painpills.mdl":
			formattedString = format("SpawnFinPills(Vector(%f, %f, %f), \"%i %i %i\")", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z);
			break;
		case "models/w_models/weapons/w_eq_adrenaline.mdl":
			formattedString = format("SpawnFinAdren(Vector(%f, %f, %f), \"%i %i %i\")", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z);
			break;
		case "models/w_models/weapons/w_eq_molotov.mdl":
			formattedString = format("SpawnFinMolo(Vector(%f, %f, %f), \"%i %i %i\")", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z);
			break;
		case "models/w_models/weapons/w_minigun.mdl":
			item = "models/w_models/weapons/w_minigun.mdl"
			formattedString = format("SpawnFinMinigun(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1, 6, \"%s\"", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item, "prop_minigun_l4d1");
			break;
		case "models/w_models/weapons/50cal.mdl":
			item = "models/w_models/weapons/50cal.mdl"
			formattedString = format("SpawnFinMinigun(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1, 6, \"%s\"", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, item, "prop_mounted_machine_gun");
			break;
		default:
			formattedString = format("SpawnFinProp(Vector(%f, %f, %f), \"%i %i %i\", \"%s\", 1400, 1600, 0, 6)", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z, model);
			break;
	}

	return formattedString;
}

