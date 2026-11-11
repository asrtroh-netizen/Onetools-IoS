import Foundation

func CFBooleanGetTypeID() -> UInt { UInt(linuxCFBooleanGetTypeID()) }

func CFGetTypeID(_ value: NSNumber) -> UInt { UInt(linuxCFGetTypeID(value)) }
