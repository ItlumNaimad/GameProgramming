extends TextureRect

# Parametry animacji
var speed = 4.0
var amplitude = 10.0
var base_y = 0.0

func _ready():
	base_y = position.y

func _process(delta):
	# Używamy funkcji sinus do płynnego ruchu góra-dół
	var offset = sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
	position.y = base_y + offset
