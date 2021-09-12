import csv
import itertools
import sys


# https://symmetricstrength.com/standards#/166/lb/male/32
lifts = {
    "Squat": {"repmax": 290},  # Goal: 320
    "Bench": {"repmax": 200},  # Goal: 240
    "Deadlift": {"repmax": 300},  # Goal: 370
    "Press": {"repmax": 140},  # Goal: 155
}

# 5/3/1 BBB
# https://www.jimwendler.com/blogs/jimwendler-com/101077382-boring-but-big
PROGRAM_LIFTS = [
    ("Press", "Bench"),
    ("Deadlift", "Squat"),
    ("Bench", "Press"),
    ("Squat", "Deadlift"),
]
PROGRAM_TMS = [
    [0.65, 0.75, 0.85, 0.65],
    [0.7, 0.8, 0.9, 0.7],
    [0.75, 0.85, 0.95, 0.75],
]
PROGRAM_REPS = [
    [5, 5, 5, 5],
    [3, 3, 3, 5],
    [5, 3, 1, 5],
]
# TODO: increase by 10% each cycle
BBB_TM = [0.5]
BBB_SETS = [5]
BBB_REPS = [10]

program = []
for week in range(3):
    for day in range(4):
        lift_1, lift_2 = PROGRAM_LIFTS[day]
        tms = PROGRAM_TMS[week]
        sets = [1, 1, 1, 5]
        reps = PROGRAM_REPS[week]
        program += [
            (lift_1, week, day, tms, sets, reps),
            (lift_2, week, day, BBB_TM, BBB_SETS, BBB_REPS),
        ]


def round_to_nearest(n, increment):
    return increment * round(n / increment)


for lift in lifts.values():
    lift["training_max"] = round_to_nearest(lift["repmax"] * 0.9, 5)


bar = 45
plates = [45, 35, 25, 10, 10, 5, 5, 2.5]

min_weight = bar
max_weight = bar + int(sum(plates) * 2)


def calculate_perms(plates):
    """
    Return every possible ordering.
    [45]
    [45, 2.5]
    [45, 2.5, 5]
    [45, 5, 2.5]
    etc.
    """
    return sorted(
        set(
            itertools.chain(
                *[itertools.permutations(plates, i + 1) for i in range(len(plates))]
            )
        )
    )


perms = calculate_perms(plates)

# Group plate orderings by weight (how many different ways can you arrange
# the plates to equal some weight) in 5 lbs increments
perms_by_weight = {}

for weight in range(min_weight, max_weight + 1, 5):
    perms_by_weight[weight] = [tup for tup in perms if sum(tup) * 2 + bar == weight]

# Hack to support lifting empty bar
perms_by_weight[bar] = [(0,)]


def plates_score(plates):
    return sum(plate_change_score(a, b) for a, b in zip(plates, plates[1:]))


def plate_change_score(a, b):
    """
    Return score of changing from plates a to b based on number of
    additions and removals. Lower is better.
    """
    prefix = largest_common_prefix(a, b)
    plates_added = b[prefix:]
    plates_removed = a[prefix:]

    # return len(plates_added) + len(plates_removed)
    # return sum(plates_added) + sum(plates_removed)

    score = plate_base_score(a)
    score += plate_base_score(b)

    score += sum(plates_added) * len(plates_added)
    score += sum(plates_removed) * len(plates_removed)
    # score += sum(plates_added)
    # score += sum(plates_removed)

    # Penalize adding and removing the same plate
    for n in plates_removed:
        if n in plates_added:
            score += 1

    return score


def plate_base_score(a):
    # Prefer plates in order from high to low
    score = len(a)
    for j, k in zip(a, a[1:]):
        if j < k:
            score += 10
    return score


def largest_common_prefix(a, b):
    """
    Find index of largest common prefix between 2 lists.
    """
    prefix = 0
    size = min(len(a), len(b))
    for i in range(size):
        if a[i] != b[i]:
            break
        prefix += 1
    return prefix


def generate_plans(weights):
    """
    Return all possible plate combinations for a progression of weights
    along with a score.

    Returns a list of tuples. First element is list of plates tuples.
    Second element is list of scores.
    """
    if not weights:
        return []

    plates_list_tuples = perms_by_weight[weights[0]]
    sub_plans = generate_plans(weights[1:])

    if not sub_plans:
        return [
            ([plates_tuple], plate_base_score(plates_tuple))
            for plates_tuple in plates_list_tuples
        ]

    candidates = []
    for plates_tuple in plates_list_tuples:
        for sub_plates, sub_score in sub_plans:
            plates = [plates_tuple] + sub_plates
            score = plates_score(plates)
            candidates.append((plates, score))

    # return 100 best candidates
    return sorted(candidates, key=lambda tup: tup[1])[:100]


def find_best_plans(weights, n=1):
    plans = generate_plans(weights)
    return plans[:n]


def main():
    w = csv.writer(sys.stdout, delimiter=";", quoting=csv.QUOTE_NONE)
    w.writerow(["Lift", "Week", "Day", "TM %", "Weight", "Plates", "Sets", "Reps"])

    for lift_name, week, day, tm_percs, sets, reps in program:
        lift = lifts[lift_name]
        tm = lift["training_max"]
        weights = [max(bar, round_to_nearest(tm * w, 5)) for w in tm_percs]
        plans = find_best_plans(weights, n=1)

        for plan in plans:
            plates, score = plan

            for perc, weight, lift_sets, lift_reps, plates in zip(
                tm_percs, weights, sets, reps, plates
            ):
                plates_display = ", ".join(str(n) for n in plates)
                if plates_display == "0":
                    plates_display = "-"
                w.writerow(
                    [
                        lift_name,
                        week + 1,
                        day + 1,
                        f"{perc:0.0%}",
                        weight,
                        plates_display,
                        lift_sets,
                        lift_reps,
                    ]
                )


if __name__ == "__main__":
    main()
