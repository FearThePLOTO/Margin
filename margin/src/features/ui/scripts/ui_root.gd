extends Control
## Local UI flow entry point. Owns the screen switch inside the ui feature and
## never reaches into gameplay. Run this scene directly (F6) to test the flow.
## A single shared background lives at this level; screens above it stay
## transparent, so switching screens never reloads or flashes the background.

@onready var _title_screen = %TitleScreen
@onready var _main_menu = %MainMenu
@onready var _settings_screen = %SettingsScreen
@onready var _conversation_screen = %ConversationTestScreen

func _ready() -> void:
	_title_screen.continue_requested.connect(_on_title_continue)
	_main_menu.settings_requested.connect(_on_settings_requested)
	_settings_screen.back_requested.connect(_on_settings_back)
	_main_menu.start_game_requested.connect(_on_start_game_requested)
	_conversation_screen.back_requested.connect(_on_conversation_back)
	_show_title()

func _show_title() -> void:
	_settings_screen.close()
	_conversation_screen.close()
	_main_menu.hide()
	_title_screen.show()

func _on_title_continue() -> void:
	_title_screen.hide()
	_settings_screen.close()
	_conversation_screen.close()
	_main_menu.show()
	_main_menu.focus_default()

func _on_start_game_requested() -> void:
	_main_menu.hide()
	_conversation_screen.open()

func _on_conversation_back() -> void:
	_conversation_screen.close()
	_main_menu.show()
	_main_menu.focus_default()

func _on_settings_requested() -> void:
	_main_menu.hide()
	_settings_screen.open()

func _on_settings_back() -> void:
	_settings_screen.close()
	_main_menu.show()
	_main_menu.focus_settings()
