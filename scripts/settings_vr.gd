# Copyright © 2017 Hugo Locurcio and contributors - MIT license
# See LICENSE.md included in the source distribution for more information.
extends Spatial

# The preset to use when starting the project
# 0: Low
# 1: Medium
# 2: High
# 3: Ultra
const default_preset = 1

# The description texts for each preset
const preset_descriptions = [
	"For low-end PCs with integrated graphics, as well as mobile devices.",
	"For mid-range PCs with slower dedicated graphics.",
	"For recent PCs with mid-range dedicated graphics, or older PCs with high-end graphics.",
	"For recent PCs with high-end dedicated graphics.",
]

# The presets' settings
#
# Each key contains an array. Index 0 is the actual setting, index 1 is the
# value to display in the preset summary GUI (which may be empty, in case it is
# not displayed).
#
# The following categories are not actually part of the Project Settings, but
# are applied to the relevant nodes instead:
#   - "environment"
const presets = [
	# Low
	{
		"environment/glow_enabled": [false, "Disabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [false, "Disabled"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/anisotropic_filter_level": [4, "4×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_DISABLED, "Disabled"],
		# "rendering/giprobe/enabled": [false, "Disabled"],
		"rendering/giprobe/enabled": [true, "Enabled"],
		"rendering/quality/voxel_cone_tracing/high_quality": [false, "Low-quality"],
	},

	# Medium
	{
		"environment/glow_enabled": [false, "Disabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [false, "Disabled"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/anisotropic_filter_level": [8, "8×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_2X, "2×"],
		# "rendering/giprobe/enabled": [false, "Disabled"],
		"rendering/giprobe/enabled": [true, "Enabled"],
		"rendering/quality/voxel_cone_tracing/high_quality": [false, "Low-quality"],
	},

	# High
	{
		"environment/glow_enabled": [true, "Enabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [true, "Medium-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/anisotropic_filter_level": [16, "16×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_4X, "4×"],
		"rendering/giprobe/enabled": [true, "Enabled"],
		"rendering/quality/voxel_cone_tracing/high_quality": [false, "Low-quality"],
	},

	# Ultra
	{
		"environment/glow_enabled": [true, "Enabled"],
		"environment/ss_reflections_enabled": [true, "Enabled"],
		"environment/ssao_enabled": [true, "High-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_2x2, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_MEDIUM, ""],
		"rendering/quality/anisotropic_filter_level": [16, "16×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_8X, "8×"],
		"rendering/giprobe/enabled": [true, "Enabled"],
		"rendering/quality/voxel_cone_tracing/high_quality": [true, "High-quality"],
	},
]

# The root of the Sponza scene
onready var root = $"/root/Scene Root"

# The environment resource used for settings adjustments
onready var environment = root.get_environment()

# Nodes used in the menu
onready var GraphicsBlurb = $"Viewport/SettingsGUI/Panel/GraphicsBlurb"
onready var GraphicsInfo = $"Viewport/SettingsGUI/Panel/GraphicsInfo"
onready var WorldScaleSlider = $"Viewport/SettingsGUI/Panel/WorldScaleSlider"
onready var WorldScaleValue = $"Viewport/SettingsGUI/Panel/WorldScaleValue"

func _ready():
	$"Area/Projection".get_surface_material(0).set_shader_param("viewport_texture", $Viewport.get_texture())

	# Initialize the project on the default preset
	$"Viewport/SettingsGUI/Panel/GraphicsQuality/OptionButton".select(default_preset)
	_on_graphics_preset_change(default_preset)
	
	WorldScaleSlider.value = int((ARVRServer.world_scale - 0.5) * 100.0)

func _on_Right_Hand_button_pressed( button ):
	if (button == 1):
		# B on the Rift, menu on the right hand controller on the vive
		visible = not(visible)
		$Area/CollisionShape.disabled = not(visible)
		get_node("../../Right_Hand/Function_pointer").set_enabled(visible)

# Returns a string containing BBCode text of the preset description
func construct_bbcode(preset):
	return """[table=2]
[cell][b]Anti-aliasing[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/filters/msaa"][1]) + """[/cell]
[cell][b]Anisotropic filtering[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/anisotropic_filter_level"][1]) + """[/cell]
[cell][b]GI enabled[/b][/cell] [cell]""" + str(presets[preset]["rendering/giprobe/enabled"][1]) + """[/cell]
[cell][b]Global illumination[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/voxel_cone_tracing/high_quality"][1]) + """[/cell]
[cell][b]Ambient occlusion[/b][/cell] [cell]""" + str(presets[preset]["environment/ssao_enabled"][1]) + """[/cell]
[cell][b]Bloom[/b][/cell] [cell]""" + str(presets[preset]["environment/glow_enabled"][1]) + """[/cell]
[cell][b]Screen-space reflections[/b][/cell] [cell]""" + str(presets[preset]["environment/ss_reflections_enabled"][1]) + """[/cell]
[/table]"""

func _on_graphics_preset_change(preset):
	# Update preset blurb
	GraphicsBlurb.bbcode_text = preset_descriptions[preset]

	# Update the preset summary table
	GraphicsInfo.bbcode_text = construct_bbcode(preset)

	# Apply settings from the preset
	for setting in presets[preset]:
		var value = presets[preset][setting][0]
		ProjectSettings.set_setting(setting, value)
		match setting:
			# Environment settings
			"environment/glow_enabled":
				environment.glow_enabled = value
			"environment/ss_reflections_enabled":
				environment.ss_reflections_enabled = value
			"environment/ssao_enabled":
				environment.ssao_enabled = value
			"environment/ssao_blur":
				environment.ssao_blur = value
			"environment/ssao_quality":
				environment.ssao_quality = value

			# Project settings
			"rendering/quality/filters/msaa":
				get_viewport().msaa = value
			"rendering/giprobe/enabled":
				get_node("/root/Scene Root/GIProbe").visible = value

func _on_ConfirmButton_pressed():
	visible = false
	$Area/CollisionShape.disabled = true
	get_node("../../Right_Hand/Function_pointer").set_enabled(false)

func _on_Quit_pressed():
	get_tree().quit()

func _on_WorldScaleSlider_value_changed( value ):
	var ws = value / 100.0
	ws += 0.5
	WorldScaleValue.text = str(ws)
	ARVRServer.world_scale = ws
