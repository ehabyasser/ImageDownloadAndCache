//
//  ImageCacheManager.swift
//  Talent
//
//  Created by Ihab yasser on 05/08/2023.
//

import Foundation
import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    private init() {
        let cacheDirectoryName = "ImageCache"
        if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let cachePath = cacheDirectory.appendingPathComponent(cacheDirectoryName)
            if !fileManager.fileExists(atPath: cachePath.path) {
                do {
                    try fileManager.createDirectory(at: cachePath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating cache directory: \(error.localizedDescription)")
                }
            }
        }
    }

    func setImage(_ image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        saveImageToDisk(image, forKey: key)
    }

    func image(forKey key: String) -> UIImage? {
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }

        return loadImageFromDisk(forKey: key)
    }

    private func saveImageToDisk(_ image: UIImage, forKey key: String) {
        if let data = image.pngData() {
            let cachePath = getCacheFilePath(forKey: key)
            fileManager.createFile(atPath: cachePath.path, contents: data, attributes: nil)
        }
    }

    private func loadImageFromDisk(forKey key: String) -> UIImage? {
        let cachePath = getCacheFilePath(forKey: key)
        if let imageData = fileManager.contents(atPath: cachePath.path) {
            return UIImage(data: imageData)
        }
        return nil
    }

    private func getCacheFilePath(forKey key: String) -> URL {
        let cacheDirectoryName = "ImageCache"
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cachePath = cacheDirectory.appendingPathComponent(cacheDirectoryName)
        let fileName = key.replacingOccurrences(of: "/", with: "_")
        return cachePath.appendingPathComponent(fileName)
    }
}

