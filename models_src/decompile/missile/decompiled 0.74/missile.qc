$modelname "acs/missiles/default.mdl"
$cdmaterials "models/weapons/w_missile/"

$body "body" "ref.smd"

$surfaceprop "metal"
$contents "solid"
$illumposition 0 0 -0.003

$attachment "propeller" "cylinder" 0 0 -15 rotate 90 0 0
$attachment "propeller_flash" "cylinder" 0 0 -21 rotate 90 0 0

$sequence "idle" "ref.smd"

$collisionmodel "phys.smd"
{
	$mass 2
	$inertia 1
	$damping 0
	$concave
	$maxconvexpieces 1
}
