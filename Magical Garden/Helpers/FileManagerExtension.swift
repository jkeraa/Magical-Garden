//
//  FileManagerExtension.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 13/07/24.
//

import Foundation

// MARK: - FileManager Extensions

extension FileManager {
    
    /// Clears all files from the temporary directory.
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(at: fileUrl)
            }
            print("Temporary directory cleared.")
        } catch {
            print("Failed to clear temporary directory: \(error)")
        }
    }
    
    /// Clears all files from the cache directory.
    func clearCacheDirectory() {
        do {
            let cacheURLs = try urls(for: .cachesDirectory, in: .userDomainMask)
            if let cacheURL = cacheURLs.first {
                let cacheDirectory = try contentsOfDirectory(atPath: cacheURL.path)
                try cacheDirectory.forEach { file in
                    let fileUrl = cacheURL.appendingPathComponent(file)
                    try removeItem(at: fileUrl)
                }
                print("Cache directory cleared.")
            }
        } catch {
            print("Failed to clear cache directory: \(error)")
        }
    }
}
