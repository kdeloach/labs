bar = 45

plates = [55, 45, 35, 25, 10, 10, 5, 5, 2.5]

min_weight = int(bar + min(plates) * 2)
max_weight = int(bar + sum(plates) * 2)


def greedy(goal):
    goal -= bar
    goal /= 2
    out = []
    for plate in plates:
        if goal <= 0:
            break
        if plate > goal:
            continue
        goal -= plate
        out.append(str(plate))
    out = ', '.join(out)
    return out


for weight in range(min_weight, max_weight + 1, 5):
    plates_str = greedy(weight)
    print(f'{weight}\t{plates_str}')
