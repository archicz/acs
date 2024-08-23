// Created by Crowbar 0.74

$modelname "props_phx\amraam.mdl"

$bodygroup "Body"
{
	studio "ref.smd"
}


$surfaceprop "phx_ww2bomb"

$contents "solid"

$illumposition 0.042 -1.206 3.976

$cdmaterials "phoenix_storms\"

$cbox 0 0 0 0 0 0

$bbox -74.85 -9.147 -9.55 77.315 9.232 17.892

$definebone "static_prop" "" 0 -20.333332 -9.549994 0 0 89.999982 0 0 0 0 0 0


$sequence "idle" {
	"amraam_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "amraam_physics.smd"
{
	$mass 200
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 10

}

$keyvalues
{
	prop_data 
	{
		"base" "Metal.Large"
		"dmg.bullets" "1.0"
		"dmg.club" "500.0"
		"dmg.explosive" "0.5"
		"health" "1"
		"explosive_damage" "200"
		"explosive_radius" "500"
	}
	physgun_interactions 
	{
		"onbreak" "explode_fire"
		"onfirstimpact" "break"
	}
	fire_interactions 
	{
		"flammable" "yes"
		"ignite" "halfhealth"
	}
}
