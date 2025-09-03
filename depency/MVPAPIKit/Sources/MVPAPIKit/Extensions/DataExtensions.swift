import Foundation

extension Data {
    func components(separatedBy separator: Data) -> [Data] {
        var components: [Data] = []
        var currentIndex = startIndex
        
        while currentIndex < endIndex {
            if let range = self[currentIndex...].range(of: separator) {
                let component = self[currentIndex..<range.lowerBound]
                components.append(component)
                currentIndex = range.upperBound
            } else {
                let component = self[currentIndex...]
                components.append(component)
                break
            }
        }
        
        return components
    }
}