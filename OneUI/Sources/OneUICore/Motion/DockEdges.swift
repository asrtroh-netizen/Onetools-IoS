/// Dock tab-edge interpolation samples from `_golden/fixtures/dock_edges.json`.
public struct DockEdgeSample: Equatable {
    public let t: Double
    public let left: Double
    public let right: Double

    public init(t: Double, left: Double, right: Double) {
        self.t = t
        self.left = left
        self.right = right
    }

    public var fixtureTree: OneTokenValue {
        .group([
            "t": .number(t),
            "left": .number(left),
            "right": .number(right),
        ])
    }
}

public struct DockEdgeTransition: Equatable {
    public let from: Int
    public let to: Int
    public let samples: [DockEdgeSample]

    public init(from: Int, to: Int, samples: [DockEdgeSample]) {
        self.from = from
        self.to = to
        self.samples = samples
    }

    public var fixtureTree: OneTokenValue {
        .group([
            "from": .number(Double(from)),
            "to": .number(Double(to)),
            "samples": .list(samples.map { $0.fixtureTree }),
        ])
    }
}

public enum DockEdges {
    public static let count = 4

    public static let transitions: [DockEdgeTransition] = [
        DockEdgeTransition(
            from: 0,
            to: 1,
            samples: [
                DockEdgeSample(t: 0.0, left: 0.0, right: 1.0),
                DockEdgeSample(t: 0.1, left: 0.011592838424257935, right: 1.2754585593938828),
                DockEdgeSample(t: 0.2, left: 0.028051465563476083, right: 1.5075639337301254),
                DockEdgeSample(t: 0.3, left: 0.05174532067030668, right: 1.6778898239135742),
                DockEdgeSample(t: 0.4, left: 0.08845500964671374, right: 1.795684544220567),
                DockEdgeSample(t: 0.5, left: 0.14525883290916683, right: 1.875116347586736),
                DockEdgeSample(t: 0.6, left: 0.23393742412328722, right: 1.9284469521790744),
                DockEdgeSample(t: 0.7, left: 0.3629912292584777, right: 1.963994747623801),
                DockEdgeSample(t: 0.8, left: 0.5402368053793907, right: 1.9852329379320144),
                DockEdgeSample(t: 0.9, left: 0.75766508102417, right: 1.996651049470529),
                DockEdgeSample(t: 1.0, left: 1.0, right: 2.0)
            ]
        ),
        DockEdgeTransition(
            from: 0,
            to: 3,
            samples: [
                DockEdgeSample(t: 0.0, left: 0.0, right: 1.0),
                DockEdgeSample(t: 0.1, left: 0.034778515272773806, right: 1.8263756781816483),
                DockEdgeSample(t: 0.2, left: 0.08415439669042825, right: 2.5226918011903763),
                DockEdgeSample(t: 0.3, left: 0.15523596201092005, right: 3.0336694717407227),
                DockEdgeSample(t: 0.4, left: 0.26536502894014125, right: 3.3870536326617002),
                DockEdgeSample(t: 0.5, left: 0.43577649872750046, right: 3.625349042760208),
                DockEdgeSample(t: 0.6, left: 0.7018122723698617, right: 3.7853408565372226),
                DockEdgeSample(t: 0.7, left: 1.0889736877754332, right: 3.8919842428714038),
                DockEdgeSample(t: 0.8, left: 1.620710416138172, right: 3.955698813796043),
                DockEdgeSample(t: 0.9, left: 2.27299524307251, right: 3.989953148411587),
                DockEdgeSample(t: 1.0, left: 3.0, right: 4.0)
            ]
        ),
        DockEdgeTransition(
            from: 3,
            to: 0,
            samples: [
                DockEdgeSample(t: 0.0, left: 3.0, right: 4.0),
                DockEdgeSample(t: 0.1, left: 2.1736243218183517, right: 3.965221484727226),
                DockEdgeSample(t: 0.2, left: 1.4773081988096237, right: 3.9158456033095717),
                DockEdgeSample(t: 0.3, left: 0.9663305282592773, right: 3.84476403798908),
                DockEdgeSample(t: 0.4, left: 0.6129463673382998, right: 3.734634971059859),
                DockEdgeSample(t: 0.5, left: 0.3746509572397918, right: 3.5642235012724997),
                DockEdgeSample(t: 0.6, left: 0.21465914346277737, right: 3.2981877276301383),
                DockEdgeSample(t: 0.7, left: 0.10801575712859623, right: 2.9110263122245668),
                DockEdgeSample(t: 0.8, left: 0.044301186203957066, right: 2.379289583861828),
                DockEdgeSample(t: 0.9, left: 0.01004685158841312, right: 1.72700475692749),
                DockEdgeSample(t: 1.0, left: 0.0, right: 1.0)
            ]
        )
    ]

    public static var fixtureTree: OneTokenValue {
        .group([
            "count": .number(Double(count)),
            "transitions": .list(transitions.map { $0.fixtureTree }),
        ])
    }
}
