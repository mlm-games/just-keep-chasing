@tool
extends EditorPlugin

# This will be loaded only on the first plugin activation. If you want to
# change the KEYS, then use Project -> Project Settings -> Input Map
const DEFAULT_DEBUG_SHORTCUTS = {
    "input/debug_restart_game": KEY_R,
    "input/debug_pause_game": KEY_P,
    "input/debug_quit_game": KEY_Q
}

var debug_shortcuts_autoload: Node = null

func _enter_tree() -> void:
    register_input_mappings(save_project_settings)

func _enable_plugin() -> void:
    debug_shortcuts_autoload = load("res://addons/ggt-debug-shortcuts/autoload/debug_shortcuts.tscn").instantiate()
    add_child(debug_shortcuts_autoload)
    register_input_mappings(save_project_settings)

func _exit_tree() -> void:
    if debug_shortcuts_autoload:
        debug_shortcuts_autoload.queue_free()
        debug_shortcuts_autoload = null

func _disable_plugin() -> void:
    if debug_shortcuts_autoload:
        remove_child(debug_shortcuts_autoload)
        debug_shortcuts_autoload.queue_free()
        debug_shortcuts_autoload = null
    unregister_input_mappings()
    save_project_settings()

func save_project_settings() -> void:
    var error = ProjectSettings.save()
    if error != OK:
        push_error("Failed to save project settings: %s" % error)

func create_input_action(keycode: Key) -> Dictionary:
    var trigger := InputEventKey.new()
    trigger.keycode = keycode
    return {
        "deadzone": 0.5,
        "events": [trigger]
    }

func register_input_mappings(on_project_settings_changed: Callable) -> void:
    var dirty := false
    for key in DEFAULT_DEBUG_SHORTCUTS:
        var value = DEFAULT_DEBUG_SHORTCUTS[key]
        if not ProjectSettings.has_setting(key):
            dirty = true
            ProjectSettings.set_setting(key, create_input_action(value))  # Set default value
    if dirty and on_project_settings_changed is Callable:
        on_project_settings_changed.call()

func unregister_input_mappings() -> void:
    for key in DEFAULT_DEBUG_SHORTCUTS:
        ProjectSettings.set_setting(key, null)