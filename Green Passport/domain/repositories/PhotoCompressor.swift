import Foundation

protocol PhotoCompressor {
    func compress(_ imageData: Data) throws -> Data
}
