extends Node
#Export global constants
@export var MAX_INGREDIENTS: int = 6
@export var LANE_TOTAL: int = 5
@export var CLIENT_SPAWN_AREA_Y: int = 620
@export var MAX_CLIENTS_PER_LANE: int = 3
@export var SPAWN_INTERVAL: int = 6
@export var SPAWN_VARIATION: int = 2
@export var TIME_LIMIT: int = 180
@export var MAX_SPEED: float = 1400.0
@export var ACCEL: float = 6000.0
@export var FRICTION: float = 600.0
@export var BOUNCE_DAMP: float = 0.8 # 0 = full reversal, 1 = no bounce
@export var CLIENT_VERTICAL_SPACING: int = 180
@export var CLIENT_DARKNESS_FACTOR: float = 0.2
@export var INGREDIENT_SCALE: Vector2 = Vector2(0.08, 0.08)
@export var INGREDIENTS: Dictionary = GameData.ingredients
@export var BUBBLE_TEXTURE: Texture2D = preload("res://assets/game-ui/bubble.svg")
@export var IMPATIENT_THRESHOLD: float = 0.5
@export var IMPATIENT_INTENSITY: float = 2.0
@export var PANIC_THRESHOLD: float = 0.75
@export var PANIC_INTENSITY: float = 8.0
@export var CALM_INTENSITY: float = 0.0
@export var TIMER_SHAKE_HURRY: float = 5.0