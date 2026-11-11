struct KernelLANShareOverride: Equatable {
    var allowLAN: Bool?
    var mixedPort: Int32?
    var httpPort: Int32? = nil
    var socksPort: Int32? = nil
}
