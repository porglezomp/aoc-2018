/Guard/ { guard = substr($4, 2) }
/falls asleep/ { sleep = substr($2, 4, 2) + 0 }
/wakes up/ {
    wake = substr($2, 4, 2) + 0
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

    max_minute = 0
    for (minute = 0; minute < 60; minute++) {
        if (asleep[max_guard, minute] > asleep[max_guard, max_minute]) {
            max_minute = minute
        }
    }
    print max_guard * max_minute

    for (guard in sleep_time) {
        for (minute = 0; minute < 60; minute++) {
            if (asleep[guard, minute] > asleep[max_guard, max_minute]) {
                max_guard = guard
                max_minute = minute
            }
        }
    }
    print max_guard * max_minute
}
