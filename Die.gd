extends RigidBody

var stable_threshhold = 0.02
var min_stable_frames = 40

var faces = []
var stable_frames = 0
var last_transform = Transform()

var stability_free = false

onready var ROOF = $'../ROOF?'

signal final_face


func _ready():
    stable_threshhold = stable_threshhold / Engine.time_scale

    add_collision_exception_with(ROOF)
    for face in get_tree().get_nodes_in_group('faces'):
        if self.is_a_parent_of(face):
            faces.append(face)


func _process(_delta):
    if global_transform.origin.y < 0:
        queue_free()

    if not stability_free:
        return

    if stable_frames < min_stable_frames:
        var current_transform = global_transform

        var x = (current_transform.basis.x - last_transform.basis.x).length() < stable_threshhold
        var y = (current_transform.basis.y - last_transform.basis.y).length() < stable_threshhold
        var z = (current_transform.basis.z - last_transform.basis.z).length() < stable_threshhold
        var origin = (current_transform.origin - last_transform.origin).length() < stable_threshhold

        if x and y and z and origin:
            stable_frames += 1
        else:
            stable_frames = 0

        last_transform = current_transform
    else:
        var face_names: Array = []

        for face in faces:
            face_names.append(face.name)

        var face_up = find_up_face()

        print('Final face (d', len(faces), '): ', face_up)
        emit_signal('final_face', str(len(faces)), face_up)

        queue_free()


func _physics_process(_delta):
    if global_transform.origin.y < 3:
        remove_collision_exception_with(ROOF)


func find_up_face():
    var best_so_far = -1
    var best_face = null

    for face in faces:
        var dot = (face.global_transform.origin - global_transform.origin).dot(Vector3.UP)
        # print(
        #     'Face: ', face.name,
        #     ', Dot: ', dot,
        #     ', Best: ', best_so_far)

        if dot > best_so_far:
            best_so_far = dot
            best_face = face

    return best_face.name
