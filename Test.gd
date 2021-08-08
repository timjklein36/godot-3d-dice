extends Spatial

var main_script = preload('res://MainLoop.gd')

export (bool) var auto_roll = false
export (String) var auto_roll_die = '6'

onready var dice_input: LineEdit = $Menu/DiceEdit
onready var camera_position: Position3D = $Camera/Position

var auto_roll_transform: Transform
# var time: float = 0
# var auto_roll_num: int = 0

var record: Dictionary = {
    '6': {
        'total': 0
        # Plus count for '1' -> '6'
    },
    '8': {
        'total': 0
        # Plus count for '1' -> '8'
    },
    '12': {
        'total': 0
        # Plus count for '1' -> '12'
    },
    '20': {
        'total': 0
        # Plus count for '1' -> '20'
    }
}

var D_6 = preload('res://d6.tscn')
var D_8 = preload('res://d8.tscn')
var D_12 = preload('res://d12.tscn')
var D_20 = preload('res://d20.tscn')


var keys_to_dice: Dictionary = {
    KEY_1: '6',
    KEY_2: '8',
    KEY_3: '12',
    KEY_4: '20'
}


func _ready():
    get_tree().set_script(main_script)
    for die_name in record:
        for i in range(1, int(die_name) + 1):
            record[die_name][str(i)] = 0

    if auto_roll:
        auto_roll_transform = camera_position.global_transform


func _process(_delta):
    # time += delta

    if auto_roll and not len(get_tree().get_nodes_in_group('dice')):
        roll(auto_roll_die)


func _input(event: InputEvent):
    if event is InputEventKey and not auto_roll:
        if event.scancode in [KEY_1, KEY_2, KEY_3, KEY_4] and not event.pressed:
            roll(keys_to_dice[event.scancode])

        if event.scancode == KEY_BACKSPACE:
            for die in get_tree().get_nodes_in_group('dice'):
                die.queue_free()


func update_dice(delta):
    var new_value = int(dice_input.text) + delta

    if new_value < 1:
        new_value = 1

    dice_input.text = str(new_value)


func set_dice(number_text):
    if not number_text:
        return

    var new_value = int(number_text)

    if new_value < 1:
        new_value = 1

    dice_input.text = str(new_value)

    if dice_input.has_focus():
        dice_input.caret_position = len(dice_input.text)


func get_dice():
    var num_dice = int(dice_input.text)

    if not num_dice:
        return 1

    return num_dice


func capture_roll_face(die_faces, roll_face):
    record[die_faces]['total'] += 1
    record[die_faces][roll_face] += 1


func roll(die):
    var transform: Transform = camera_position.global_transform

    if auto_roll:
        transform = auto_roll_transform

    for _i in range(get_dice()):
        var die_inst: RigidBody = get('D_' + die).instance()

        die_inst.visible = false

        add_child(die_inst)

        die_inst.global_translate(transform.origin)
        die_inst.rotate_object_local(
            [Vector3.UP, Vector3.RIGHT, Vector3.FORWARD][randi() % 3],
            deg2rad(rand_range(0, 180))
        )

        var err = die_inst.connect('final_face', self, 'capture_roll_face')

        if err:
            print('Issue connecting signal for capturing die roll to die instance (d%s)' % die)

        die_inst.visible = true

        die_inst.stability_free = true

        die_inst.add_to_group('dice')

        die_inst.apply_impulse(
            Vector3(0, 0, 0),
            -transform.basis.z * 300
        )

        die_inst.apply_torque_impulse(
            Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized() * 4
        )
