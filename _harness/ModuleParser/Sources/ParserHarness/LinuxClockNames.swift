let CLOCK_THREAD_CPUTIME_ID: Int32 = Int32(linuxClockThreadCPU())

let CLOCK_UPTIME_RAW: Int32 = Int32(linuxClockUptime())

func clock_gettime_nsec_np(_ clock: Int32) -> UInt64 {
    linuxClockNanoseconds(clock)
}
