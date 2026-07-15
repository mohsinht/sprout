import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Generates launcher icons from the supplied artwork. The source is cleaned by
// flood-filling the near-white canvas, preserving enclosed white eye details,
// then retaining the largest connected mascot component.

guard CommandLine.arguments.count == 3 else {
    fputs("usage: generate_app_icons.swift <source.png> <output-directory>\n", stderr)
    exit(2)
}

let sourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    fatalError("Unable to read source image")
}

let width = image.width
let height = image.height
let bytesPerPixel = 4
let bytesPerRow = width * bytesPerPixel
var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(data: &pixels,
                              width: width,
                              height: height,
                              bitsPerComponent: 8,
                              bytesPerRow: bytesPerRow,
                              space: colorSpace,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    fatalError("Unable to create image context")
}
context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

func index(_ x: Int, _ y: Int) -> Int { (y * width + x) * bytesPerPixel }
func isNearWhite(_ x: Int, _ y: Int) -> Bool {
    let i = index(x, y)
    let r = Int(pixels[i]), g = Int(pixels[i + 1]), b = Int(pixels[i + 2]), a = pixels[i + 3]
    return a > 0 && r > 232 && g > 232 && b > 232 && max(r, max(g, b)) - min(r, min(g, b)) < 28
}

// Remove only the canvas-connected white area so the mascot's white eyes remain.
var background = [Bool](repeating: false, count: width * height)
var queue: [(Int, Int)] = []
for x in 0..<width {
    queue.append((x, 0)); queue.append((x, height - 1))
}
for y in 0..<height {
    queue.append((0, y)); queue.append((width - 1, y))
}
var q = 0
while q < queue.count {
    let (x, y) = queue[q]; q += 1
    guard x >= 0, y >= 0, x < width, y < height else { continue }
    let flat = y * width + x
    guard !background[flat], isNearWhite(x, y) else { continue }
    background[flat] = true
    queue.append((x + 1, y)); queue.append((x - 1, y))
    queue.append((x, y + 1)); queue.append((x, y - 1))
}
for y in 0..<height {
    for x in 0..<width where background[y * width + x] {
        pixels[index(x, y) + 3] = 0
    }
}

// Retain the largest remaining connected component, removing confetti.
var visited = [Bool](repeating: false, count: width * height)
var largest: [Int] = []
for y in 0..<height {
    for x in 0..<width {
        let flat = y * width + x
        let alpha = pixels[index(x, y) + 3]
        guard alpha > 16, !visited[flat] else { continue }
        var component: [Int] = [flat]
        visited[flat] = true
        var cursor = 0
        while cursor < component.count {
            let current = component[cursor]; cursor += 1
            let cx = current % width, cy = current / width
            for (nx, ny) in [(cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)] {
                guard nx >= 0, ny >= 0, nx < width, ny < height else { continue }
                let next = ny * width + nx
                guard !visited[next], pixels[index(nx, ny) + 3] > 16 else { continue }
                visited[next] = true
                component.append(next)
            }
        }
        if component.count > largest.count { largest = component }
    }
}
var keep = Set(largest)
for y in 0..<height {
    for x in 0..<width where pixels[index(x, y) + 3] > 0 && !keep.contains(y * width + x) {
        pixels[index(x, y) + 3] = 0
    }
}
for y in 0..<height {
    for x in 0..<width where pixels[index(x, y) + 3] == 0 {
        pixels[index(x, y)] = 0
        pixels[index(x, y) + 1] = 0
        pixels[index(x, y) + 2] = 0
    }
}

var minX = width, minY = height, maxX = 0, maxY = 0
for y in 0..<height {
    for x in 0..<width where pixels[index(x, y) + 3] > 16 {
        minX = min(minX, x); minY = min(minY, y); maxX = max(maxX, x); maxY = max(maxY, y)
    }
}
let bbox = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
let cleanedData = Data(pixels) as CFData
guard let provider = CGDataProvider(data: cleanedData),
      let cleaned = CGImage(width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bitsPerPixel: 32,
                            bytesPerRow: bytesPerRow,
                            space: colorSpace,
                            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                            provider: provider,
                            decode: nil,
                            shouldInterpolate: true,
                            intent: .defaultIntent) else { fatalError("Unable to create cleaned image") }
guard let mascot = cleaned.cropping(to: bbox) else { fatalError("Unable to crop mascot") }

func writePNG(_ image: CGImage, _ url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { fatalError("Unable to create PNG destination") }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Unable to write \(url.path)") }
}

func makeCanvas(size: Int, background: (UInt8, UInt8, UInt8, UInt8), mascotScale: CGFloat) -> CGImage {
    var data = [UInt8](repeating: 0, count: size * size * 4)
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: &data, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setFillColor(red: CGFloat(background.0) / 255, green: CGFloat(background.1) / 255, blue: CGFloat(background.2) / 255, alpha: CGFloat(background.3) / 255)
    ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
    // Fit within the square without changing the mascot's original aspect ratio.
    let sourceAspect = bbox.width / bbox.height
    let maxDimension = CGFloat(size) * mascotScale
    let targetWidth: CGFloat
    let targetHeight: CGFloat
    if sourceAspect >= 1 {
        targetWidth = maxDimension
        targetHeight = maxDimension / sourceAspect
    } else {
        targetHeight = maxDimension
        targetWidth = maxDimension * sourceAspect
    }
    let drawRect = CGRect(x: (CGFloat(size) - targetWidth) / 2,
                          y: (CGFloat(size) - targetHeight) / 2,
                          width: targetWidth,
                          height: targetHeight)
    ctx.interpolationQuality = .high
    ctx.draw(mascot, in: drawRect)
    return ctx.makeImage()!
}

func makeForeground(size: Int, mascotScale: CGFloat) -> CGImage {
    makeCanvas(size: size, background: (0, 0, 0, 0), mascotScale: mascotScale)
}

let mint: (UInt8, UInt8, UInt8, UInt8) = (233, 248, 239, 255) // Sprout mint
try writePNG(makeCanvas(size: 1024, background: mint, mascotScale: 0.80), outputURL.appendingPathComponent("sprout_icon_1024.png"))
// Adaptive icons reserve an inner safe zone because Android applies its own mask.
try writePNG(makeForeground(size: 432, mascotScale: 0.60), outputURL.appendingPathComponent("sprout_icon_foreground_432.png"))

let legacySizes = [48, 72, 96, 144, 192]
for size in legacySizes {
    try writePNG(makeCanvas(size: size, background: mint, mascotScale: 0.80), outputURL.appendingPathComponent("android_\(size).png"))
}

let iosSizes: [(String, Int)] = [
    ("Icon-App-20x20@1x.png", 20), ("Icon-App-20x20@2x.png", 40), ("Icon-App-20x20@3x.png", 60),
    ("Icon-App-29x29@1x.png", 29), ("Icon-App-29x29@2x.png", 58), ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40), ("Icon-App-40x40@2x.png", 80), ("Icon-App-40x40@3x.png", 120),
    ("Icon-App-60x60@2x.png", 120), ("Icon-App-60x60@3x.png", 180),
    ("Icon-App-76x76@1x.png", 76), ("Icon-App-76x76@2x.png", 152),
    ("Icon-App-83.5x83.5@2x.png", 167), ("Icon-App-1024x1024@1x.png", 1024)
]
for (name, size) in iosSizes {
    try writePNG(makeCanvas(size: size, background: mint, mascotScale: 0.80), outputURL.appendingPathComponent(name))
}
