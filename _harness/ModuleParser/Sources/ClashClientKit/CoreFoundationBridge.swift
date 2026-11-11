import CoreFoundation
import Foundation

func linuxCFBooleanGetTypeID() -> CFTypeID { CoreFoundation.CFBooleanGetTypeID() }

func linuxCFGetTypeID(_ value: NSNumber) -> CFTypeID { CoreFoundation.CFGetTypeID(value) }
