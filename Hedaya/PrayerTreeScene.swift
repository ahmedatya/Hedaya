// MARK: - Prayer Tree — SpriteKit scene (tree drawing + tappable nodes)

import SpriteKit
import SwiftUI

private enum SceneLayout {
    static let width: CGFloat = 400
    static let height: CGFloat = 560
    static let cx: CGFloat = 200
    static let rootY: CGFloat = 32
    static let trunkBottomY: CGFloat = 40
    static let trunkTopY: CGFloat = 336
    static let branchStartY: CGFloat = 358
    static let trunkWidthBottom: CGFloat = 52
    static let trunkWidthTop: CGFloat = 28
    static let rootNodeRadius: CGFloat = 18
    static let branchNodeSize: CGFloat = 36
    static let rootSpread: CGFloat = 220
    static let branchRadius: CGFloat = 110

    static func rootCenter(at index: Int) -> CGPoint {
        let step = rootSpread / 4
        let x = cx - rootSpread / 2 + step * CGFloat(index)
        return CGPoint(x: x, y: rootY)
    }

    static func rootBase(at index: Int) -> CGPoint {
        let progress = (CGFloat(index) + 0.5) / 5
        let x = cx - trunkWidthBottom / 2 + trunkWidthBottom * progress * 0.85
        return CGPoint(x: x, y: trunkBottomY)
    }

    static func branchLeafCenter(at index: Int) -> CGPoint {
        let leftCount = 4
        let isLeft = index < leftCount
        let sideIndex = isLeft ? index : index - leftCount
        let angleStep: CGFloat = .pi / 5.5
        let startAngle: CGFloat = isLeft ? .pi * 0.72 : .pi * 0.28
        let angle = startAngle + angleStep * CGFloat(sideIndex)
        let x = cx + cos(angle) * branchRadius
        let y = branchStartY + sin(angle) * branchRadius
        return CGPoint(x: x, y: y)
    }

    static func branchStart(at index: Int) -> CGPoint {
        let progress = (CGFloat(index) + 0.5) / 8
        let y = trunkTopY - (trunkTopY - branchStartY) * 0.3 - progress * 25
        return CGPoint(x: cx, y: y)
    }
}

protocol PrayerTreeSceneDelegate: AnyObject {
    func prayerTreeScene(_ scene: PrayerTreeScene, didTapNodeNamed name: String)
}

final class PrayerTreeScene: SKScene {
    weak var tapDelegate: PrayerTreeSceneDelegate?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.94, green: 0.97, blue: 0.96, alpha: 0.3)
        scaleMode = .resizeFill
        buildTree()
    }

    private func buildTree() {
        removeAllChildren()
        buildTrunk()
        buildRoots()
        buildBranches()
    }

    private func buildTrunk() {
        let topY = SceneLayout.trunkTopY
        let bottomY = SceneLayout.trunkBottomY
        let path = CGMutablePath()
        path.move(to: CGPoint(x: SceneLayout.cx - SceneLayout.trunkWidthTop / 2, y: topY))
        path.addLine(to: CGPoint(x: SceneLayout.cx + SceneLayout.trunkWidthTop / 2, y: topY))
        path.addLine(to: CGPoint(x: SceneLayout.cx + SceneLayout.trunkWidthBottom / 2, y: bottomY))
        path.addLine(to: CGPoint(x: SceneLayout.cx - SceneLayout.trunkWidthBottom / 2, y: bottomY))
        path.closeSubpath()
        let trunk = SKShapeNode(path: path)
        trunk.fillColor = SKColor(red: 0.33, green: 0.42, blue: 0.18, alpha: 1)
        trunk.strokeColor = SKColor(red: 0.24, green: 0.31, blue: 0.16, alpha: 1)
        trunk.lineWidth = 2
        trunk.name = PrayerTreeElementID.trunk
        trunk.isUserInteractionEnabled = false
        addChild(trunk)
    }

    private func buildRoots() {
        let barkColor = SKColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1)
        for (index, id) in PrayerTreeElementID.rootIDs.enumerated() {
            let start = SceneLayout.rootBase(at: index)
            let end = SceneLayout.rootCenter(at: index)
            let control = CGPoint(
                x: (start.x + end.x) / 2 + CGFloat([-1, 0, 0, 0, 1][index]) * 18,
                y: (start.y + end.y) / 2 - 8
            )
            let path = CGMutablePath()
            path.move(to: start)
            path.addQuadCurve(to: end, control: control)
            let line = SKShapeNode(path: path)
            line.strokeColor = barkColor
            line.lineWidth = 5
            line.lineCap = .round
            line.name = nil
            line.isUserInteractionEnabled = false
            addChild(line)

            let circle = SKShapeNode(circleOfRadius: SceneLayout.rootNodeRadius)
            circle.position = end
            circle.fillColor = SKColor(red: 0.33, green: 0.42, blue: 0.18, alpha: 1)
            circle.strokeColor = SKColor(red: 0.24, green: 0.31, blue: 0.16, alpha: 1)
            circle.lineWidth = 2
            circle.name = id
            circle.isUserInteractionEnabled = false
            addChild(circle)
        }
    }

    private func buildBranches() {
        let branchColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        let leafColor = SKColor(red: 0.33, green: 0.42, blue: 0.18, alpha: 1)
        let leafStroke = SKColor(red: 0.24, green: 0.31, blue: 0.16, alpha: 1)
        for (index, id) in PrayerTreeElementID.branchIDs.enumerated() {
            let start = SceneLayout.branchStart(at: index)
            let end = SceneLayout.branchLeafCenter(at: index)
            let midX = (start.x + end.x) / 2
            let midY = (start.y + end.y) / 2
            let sign: CGFloat = end.x < SceneLayout.cx ? -1 : 1
            let control = CGPoint(x: midX + sign * 25, y: midY + 15)
            let path = CGMutablePath()
            path.move(to: start)
            path.addQuadCurve(to: end, control: control)
            let line = SKShapeNode(path: path)
            line.strokeColor = branchColor
            line.lineWidth = 3
            line.lineCap = .round
            line.name = nil
            line.isUserInteractionEnabled = false
            addChild(line)

            let node: SKShapeNode
            switch index % 4 {
            case 0:
                node = SKShapeNode(rectOf: CGSize(width: SceneLayout.branchNodeSize * 0.85, height: SceneLayout.branchNodeSize * 0.85), cornerRadius: 8)
            case 1:
                node = SKShapeNode(circleOfRadius: SceneLayout.branchNodeSize / 2)
            case 2:
                let w = SceneLayout.branchNodeSize * 0.9
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: -w/2))
                path.addLine(to: CGPoint(x: w/2, y: 0))
                path.addLine(to: CGPoint(x: 0, y: w/2))
                path.addLine(to: CGPoint(x: -w/2, y: 0))
                path.closeSubpath()
                node = SKShapeNode(path: path)
            default:
                node = SKShapeNode(ellipseOf: CGSize(width: SceneLayout.branchNodeSize * 0.9, height: SceneLayout.branchNodeSize * 0.7))
            }
            node.position = end
            node.fillColor = leafColor
            node.strokeColor = leafStroke
            node.lineWidth = 1.2
            node.name = id
            node.isUserInteractionEnabled = false
            addChild(node)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location).filter { node in
            guard let name = node.name else { return false }
            return PrayerTreeElementID.allIDs.contains(name)
        }
        if let hit = nodes.first, let name = hit.name {
            tapDelegate?.prayerTreeScene(self, didTapNodeNamed: name)
        }
    }
}

// MARK: - Tap handler (bridge to store)
final class PrayerTreeTapHandler: PrayerTreeSceneDelegate {
    private weak var store: PrayerTrackingStore?
    private var onBranchTap: ((BranchType) -> Void)?

    init(store: PrayerTrackingStore, onBranchTap: ((BranchType) -> Void)? = nil) {
        self.store = store
        self.onBranchTap = onBranchTap
    }

    func prayerTreeScene(_ scene: PrayerTreeScene, didTapNodeNamed name: String) {
        guard let store = store, let action = PrayerTreeMapping.action(for: name) else { return }
        switch action {
        case .prayer(let prayer):
            store.markPrayerDone(prayer)
        case .quran:
            if !store.todayLog.quranDone { store.markQuranDone() }
        case .branch(let branch):
            if store.todayLog.branchesCompleted.contains(branch) { return }
            if let cb = onBranchTap {
                DispatchQueue.main.async { cb(branch) }
            } else {
                store.markBranchDone(branch)
            }
        }
    }
}
