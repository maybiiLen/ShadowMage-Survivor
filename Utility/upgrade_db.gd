extends Node

const ICON_PATH = "res://Textures/Items/Upgrades/"
const WEAPON_PATH = "res://Textures/Items/Weapons/"
const UPGRADES = {
	"shadowspear1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Shadow Spear",
		"details" : "A Shadow Spear is thrown at a random target",
		"Level" : "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"shadowspear2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Shadow Spear",
		"details" : "An additional Shadow Spear is thrown",
		"Level" : "Level: 2",
		"prerequisite": ["shadowspear1"],
		"type": "weapon"
	},
	"food": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Food",
		"details" : "Heals you for 20 health",
		"Level" : "N/A",
		"prerequisite": [],
		"type": "item"
	}
}
