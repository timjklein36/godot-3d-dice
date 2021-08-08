extends Camera

export (int) var movement_speed = 4
export (int) var rotation_speed = 4

onready var TEST = $".."

var old_mouse_pos = Vector2()


func _ready():
    # Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    pass


func _input(event):
    # Mouse in viewport coordinates.
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        var viewport_size = get_viewport().size

        global_rotate(
            Vector3.UP,
            - rotation_speed * event.relative.x / viewport_size.x
        )

        rotate_object_local(
            Vector3.RIGHT,
            - rotation_speed * event.relative.y / viewport_size.y
        )


func _process(delta):
    if Input.is_action_just_pressed('ui_select'):
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    if Input.is_action_just_pressed('ui_cancel'):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        return
    elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
        return

    var movement = Vector3()

    if Input.is_action_pressed('ui_right'):
        movement.x += 1

    if Input.is_action_pressed('ui_left'):
        movement.x -= 1

    if Input.is_action_pressed('ui_up'):
        movement.z -= 1

    if Input.is_action_pressed('ui_down'):
        movement.z += 1

    movement = movement.normalized() * movement_speed * delta

    translate_object_local(movement)
