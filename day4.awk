/Guard/ { guard = $4; sleep = none }
/falls asleep/ { sleep = substr($2, 4, 2) }
/wakes up/ {
    wake = substr($2, 4, 2)
    sleep_time[guard] += wake - sleep
    for (time = sleep; time < wake; time++) {
        asleep[guard, time]++
    }
}

END {
    max_sleep = 0
    max_guard = none
    for (guard in sleep_time) {
        time = sleep_time[guard]
        if (time > max_sleep) {
            max_sleep = time
            max_guard = guard
        }
    }

    best_time = 0
    for (minute = 0; minute < 60; minute++) {
        if (asleep[max_guard, minute] >= asleep[max_guard, best_time]) {
            best_time = minute
        }
    }
    print substr(max_guard, 2) * best_time
}
