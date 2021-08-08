extends SceneTree


func _finalize():
    var TEST = current_scene
    # print(JSON.print(TEST.record, '  '))

    for die in TEST.record:
        if TEST.record[die]['total']:
            print('d%s:' % die)

            for face in TEST.record[die]:
                print(
                    '  %s: %6.2f%% (%d)' % [
                        face,
                        int(TEST.record[die][face]) / float(TEST.record[die]['total']) * 100,
                        int(TEST.record[die][face])
                    ]
                )
