extends Node

# ------------------------------------------------------------------------------
# Skrypt: AdsManager
# Opis: Singleton (Autoload) zarządzający reklamami Google AdMob w grze.
#       Pełni rolę pośrednika (fasady) między logiką gry a wtyczką AdMob.
# ------------------------------------------------------------------------------

# Counters
var death_count_for_interstitial : int = 0

# Ad Objects
var ad_view : AdView
var interstitial_ad : InterstitialAd
var rewarded_ad : RewardedAd

# Load Callbacks (Strongly typed for Poing Studios API)
var interstitial_load_callback := InterstitialAdLoadCallback.new()
var rewarded_load_callback := RewardedAdLoadCallback.new()

# Callback to execute when reward is earned (passed from UI)
var _on_reward_earned_callback : Callable

func _ready():
	# Initialize the MobileAds SDK
	MobileAds.initialize()
	
	# Setup Interstitial Load Callbacks
	interstitial_load_callback.on_ad_failed_to_load = _on_interstitial_failed_to_load
	interstitial_load_callback.on_ad_loaded = _on_interstitial_loaded
	
	# Setup Rewarded Load Callbacks
	rewarded_load_callback.on_ad_failed_to_load = _on_rewarded_failed_to_load
	rewarded_load_callback.on_ad_loaded = _on_rewarded_loaded
	
	# Initial Load of Ads
	load_banner()
	load_interstitial()
	load_rewarded()

# ------------------------------------------------------------------------------
# BANNER ADS
# ------------------------------------------------------------------------------
func load_banner():
	# Destroy existing banner if any
	if ad_view:
		ad_view.destroy()
		ad_view = null
		
	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/6300978111" # Android Test ID
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/2934735716" # iOS Test ID
	else:
		unit_id = "ca-app-pub-3940256099942544/6300978111" # Fallback
		
	# Create and load the banner view at the bottom of the screen
	ad_view = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM)
	ad_view.load_ad(AdRequest.new())

func show_banner():
	# AdView shows automatically when loaded, but we can ensure it's visible if we hid it
	if ad_view:
		ad_view.show()

func hide_banner():
	if ad_view:
		ad_view.hide()

# ------------------------------------------------------------------------------
# INTERSTITIAL ADS
# ------------------------------------------------------------------------------
func load_interstitial():
	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/1033173712"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/4411468910"
	else:
		unit_id = "ca-app-pub-3940256099942544/1033173712"
		
	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), interstitial_load_callback)

func _on_interstitial_loaded(ad : InterstitialAd):
	print("AdsManager: Interstitial loaded.")
	interstitial_ad = ad

func _on_interstitial_failed_to_load(adError : LoadAdError):
	print("AdsManager: Interstitial failed to load: ", adError.message)

func on_player_died():
	death_count_for_interstitial += 1
	print("AdsManager: Death count: ", death_count_for_interstitial)
	
	# Show interstitial every 3rd death
	if death_count_for_interstitial % 3 == 0:
		show_interstitial()

func show_interstitial():
	if interstitial_ad:
		interstitial_ad.show()
		interstitial_ad = null # Clear reference as it's single use
		load_interstitial() # Preload the next one
	else:
		print("AdsManager: Interstitial not ready yet.")
		load_interstitial() # Try loading again

# ------------------------------------------------------------------------------
# REWARDED ADS
# ------------------------------------------------------------------------------
func load_rewarded():
	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/5224354917"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/1712485313"
	else:
		unit_id = "ca-app-pub-3940256099942544/5224354917"
		
	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_load_callback)

func _on_rewarded_loaded(ad : RewardedAd):
	print("AdsManager: Rewarded Ad loaded.")
	rewarded_ad = ad

func _on_rewarded_failed_to_load(adError : LoadAdError):
	print("AdsManager: Rewarded Ad failed to load: ", adError.message)

func show_rewarded_ad(on_reward_callback : Callable):
	if rewarded_ad:
		_on_reward_earned_callback = on_reward_callback
		
		var listener := OnUserEarnedRewardListener.new()
		listener.on_user_earned_reward = _on_user_earned_reward
		
		rewarded_ad.show(listener)
		rewarded_ad = null # Single use
		load_rewarded() # Preload next
	else:
		print("AdsManager: Rewarded Ad not ready.")
		load_rewarded() # Try loading again

func _on_user_earned_reward(rewarded_item : RewardedItem):
	print("AdsManager: User earned reward: ", rewarded_item.amount, " ", rewarded_item.type)
	# Execute the callback provided by the UI
	if _on_reward_earned_callback.is_valid():
		_on_reward_earned_callback.call()
