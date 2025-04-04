import Foundation

/// Represents a vendor or merchant in the application
struct Vendor: Identifiable, Codable {
    let id: UUID
    var vendorName: String
    var vendorLogoImageData: Data?
    
    init(id: UUID = UUID(), 
         vendorName: String, 
         vendorLogoImageData: Data? = nil) {
        self.id = id
        self.vendorName = vendorName
        self.vendorLogoImageData = vendorLogoImageData
    }
} 