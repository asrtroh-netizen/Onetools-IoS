import Glibc

func linuxClockThreadCPU() -> clockid_t { CLOCK_THREAD_CPUTIME_ID }

func linuxClockUptime() -> clockid_t { CLOCK_MONOTONIC }

func linuxClockNanoseconds(_ clock: Int32) -> UInt64 {
    var time = timespec()
    guard clock_gettime(clockid_t(clock), &time) == 0 else { return 0 }
    return UInt64(time.tv_sec) * 1_000_000_000 + UInt64(time.tv_nsec)
}
