import Foundation

struct AvatarRNG {
    private var state: UInt64

    init(seed: String) {
        var hash: UInt64 = 1469598103934665603
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        if hash == 0 {
            hash = 0x9E3779B97F4A7C15
        }
        state = hash
    }

    mutating func nextUInt() -> UInt64 {
        var x = state
        x ^= x << 13
        x ^= x >> 7
        x ^= x << 17
        state = x
        return x
    }

    mutating func nextInt(_ upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        return Int(nextUInt() % UInt64(upperBound))
    }

    mutating func nextDouble() -> Double {
        let value = nextUInt() & 0xFFFF_FFFF
        return Double(value) / Double(UInt32.max)
    }

    mutating func nextDouble(in range: ClosedRange<Double>) -> Double {
        let t = nextDouble()
        return range.lowerBound + (range.upperBound - range.lowerBound) * t
    }

    mutating func nextBool(probability: Double) -> Bool {
        nextDouble() < probability
    }

    mutating func nextColorIndex(excluding used: inout Set<Int>, count: Int) -> Int {
        guard count > 0 else { return 0 }

        if used.count >= count {
            return nextInt(count)
        }

        var index = nextInt(count)
        var attempts = 0
        while used.contains(index) && attempts < count {
            index = nextInt(count)
            attempts += 1
        }
        used.insert(index)
        return index
    }
}
