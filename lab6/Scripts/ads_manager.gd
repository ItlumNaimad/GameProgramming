extends Node

# ------------------------------------------------------------------------------
# Skrypt: AdsManager
# Opis: Singleton (Autoload) zarządzający reklamami Google AdMob w grze.
#       Pełni rolę pośrednika (fasady) między logiką gry a wtyczką AdMob.
# ------------------------------------------------------------------------------

# Sygnał emitowany, gdy gracz obejrzy reklamę z nagrodą do samego końca.
# Gra (np. main.gd) powinna nasłuchiwać tego sygnału, aby wskrzesić gracza.
signal reward_earned

# Referencja do obiektu/węzła wtyczki AdMob.
var admob = null

# Licznik rozegranych gier. Służy do wyświetlania reklamy pełnoekranowej (Interstitial)
# co określoną liczbę podejść (np. co 3 gry).
var game_count = 0

func _ready():
	# Czekamy chwilę na pełną inicjalizację drzewa sceny, aby uniknąć błędów
	# przy szukaniu węzłów startowych.
	await get_tree().create_timer(0.5).timeout
	
	# Próba pobrania instancji AdMob.
	# W zależności od wersji wtyczki może to być Singleton silnika lub węzeł w Autoload (/root/AdMob).
	if Engine.has_singleton("AdMob"):
		admob = Engine.get_singleton("AdMob")
	elif get_node_or_null("/root/AdMob"):
		admob = get_node("/root/AdMob")
	
	if admob:
		print("AdsManager: Znaleziono wtyczkę AdMob.")
		# Podłączamy sygnały (callbacki) emitowane przez wtyczkę:
		
		# Gdy reklama z nagrodą się załaduje (jest gotowa do wyświetlenia)
		admob.rewarded_ad_loaded.connect(_on_rewarded_ad_loaded)
		
		# Gdy nie uda się załadować reklamy (np. brak internetu)
		admob.rewarded_ad_failed_to_load.connect(_on_rewarded_ad_failed_to_load)
		
		# Gdy gracz zamknie reklamę (niezależnie czy obejrzał do końca)
		admob.rewarded_video_ad_closed.connect(_on_rewarded_ad_closed)
		
		# KLUCZOWE: Gdy gracz obejrzy reklamę i zasłużył na nagrodę
		admob.user_earned_rewarded_item.connect(_on_user_earned_rewarded_item)
		
		# Rozpoczynamy ładowanie reklam w tle (pre-loading),
		# aby były gotowe natychmiast, gdy gracz ich potrzebuje.
		load_ads()
	else:
		printerr("AdsManager: Nie znaleziono wtyczki AdMob! Upewnij się, że jest włączona w Project Settings.")

# Funkcja zlecająca załadowanie wszystkich typów reklam.
# Reklamy ładują się asynchronicznie w tle.
func load_ads():
	if admob:
		admob.load_banner()
		admob.load_interstitial()
		admob.load_rewarded_video()

# --- BANNER (Pasek reklamowy) ---

# Wyświetla banner (zazwyczaj mały pasek na dole ekranu).
func show_banner():
	if admob:
		admob.show_banner()

# Ukrywa banner (np. podczas aktywnej rozgrywki, żeby nie zasłaniał widoku).
func hide_banner():
	if admob:
		admob.hide_banner()

# --- INTERSTITIAL (Reklama pełnoekranowa) ---

# Wyświetla reklamę pełnoekranową (przerywnik).
# Powinna być stosowana w momentach naturalnych przerw (np. ekran Game Over).
func show_interstitial():
	if admob:
		admob.show_interstitial()
		# Po wyświetleniu reklama jest "zużyta", więc od razu ładujemy następną
		# na kolejne wyświetlenie za kilka minut.
		admob.load_interstitial()

# --- REWARDED (Wideo z nagrodą) ---

# Wyświetla reklamę, za którą gracz otrzymuje nagrodę (np. dodatkowe życie).
func show_rewarded():
	if admob:
		admob.show_rewarded_video()
		# Uwaga: Kolejną ładujemy dopiero po zamknięciu obecnej (w _on_rewarded_ad_closed)

# --- CALLBACKI (Obsługa zdarzeń z wtyczki) ---

# Wywoływane przez AdMob, gdy gracz spełnił warunki nagrody (obejrzał wideo do końca).
func _on_user_earned_rewarded_item(currency, amount):
	print("AdsManager: Nagroda przyznana przez AdMob!")
	# Przekazujemy informację dalej do gry (main.gd to odbierze)
	reward_earned.emit()

# Wywoływane, gdy gracz zamknie okno reklamy z nagrodą.
func _on_rewarded_ad_closed():
	print("AdsManager: Reklama z nagrodą zamknięta.")
	# Ładujemy następną reklamę na przyszłość, aby była gotowa,
	# gdy gracz znów zechce jej użyć (Pre-loading).
	if admob:
		admob.load_rewarded_video()

# Informacja diagnostyczna - reklama gotowa do wyświetlenia.
func _on_rewarded_ad_loaded():
	print("AdsManager: Reklama z nagrodą załadowana i gotowa.")

# Informacja diagnostyczna - błąd ładowania (np. brak internetu, złe ID).
func _on_rewarded_ad_failed_to_load(error_code):
	print("AdsManager: Błąd ładowania reklamy z nagrodą. Kod: ", error_code)
