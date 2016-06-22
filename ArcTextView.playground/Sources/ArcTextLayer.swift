import QuartzCore
import CoreText

public class ArcTextLayer: CALayer {

    public enum Alignment {
        case start
        case center
        case end
    }

    public var attributedText: AttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    public var alignment: Alignment = .start {
        didSet {
            setNeedsDisplay()
        }
    }
    public var radius: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    public var angle: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func draw(in ctx: CGContext) {
        // Check pre-conditions
        guard radius > 0, let attributedText = attributedText else {
            return
        }
        let line = CTLineCreateWithAttributedString(attributedText)
        guard CTLineGetGlyphCount(line) > 0 else {
            return
        }

        let dimensions = calcurateGlyphDimensions(from: line, radius: radius)

        ctx.saveGState()

        // Initialize canvas position
        ctx.translate(x: bounds.width / 2, y: bounds.height / 2)
        ctx.scale(x: -1, y: 1)
        ctx.rotate(byAngle: CGFloat(M_PI))

        // Adjust alignment
        let totalWidth = dimensions.map({ $0.width }).reduce(0, combine: +)
        let startAngle: CGFloat
        switch alignment {
        case .start:
            startAngle = 0
        case .center:
            startAngle = -(totalWidth / radius) / 2
        case .end:
            startAngle = -(totalWidth / radius)
        }
        ctx.rotate(byAngle: -(startAngle + angle))

        // Draw glyphs
        var textPosition = CGPoint(x: 0, y: radius)
        ctx.setTextPosition(x: textPosition.x, y: textPosition.y)
        var glyphOffset = 0
        let runs = CTLineGetGlyphRuns(line) as NSArray as! [CTRun]
        for run in runs {
            let runGlyphCount = CTRunGetGlyphCount(run)

            for runGlyphIndex in (0..<runGlyphCount) {
                let dimension = dimensions[glyphOffset + runGlyphIndex]
                let glyphRange = CFRange(location: runGlyphIndex, length: 1)

                ctx.rotate(byAngle: -dimension.angle)

                let thisGlyphPosition = CGPoint(x: textPosition.x - dimension.width / 2, y: textPosition.y)

                textPosition.x -= dimension.width

                var textMatrix = CTRunGetTextMatrix(run)
                textMatrix.tx = thisGlyphPosition.x
                textMatrix.ty = thisGlyphPosition.y
                ctx.textMatrix = textMatrix

                CTRunDraw(run, ctx, glyphRange)
            }

            glyphOffset += runGlyphCount
        }

        ctx.restoreGState()
    }

    private struct GlyphDimension {
        let width: CGFloat
        let angle: CGFloat
    }

    private func calcurateGlyphDimensions(from line: CTLine, radius: CGFloat) -> [GlyphDimension] {
        let glyphCount = CTLineGetGlyphCount(line)
        guard glyphCount > 0 else {
            return []
        }

        let runs = CTLineGetGlyphRuns(line) as NSArray as! [CTRun]
        let glyphWidth = runs.flatMap { run in
            (0..<CTRunGetGlyphCount(run)).map { index in
                CGFloat(CTRunGetTypographicBounds(run, CFRange(location: index, length: 1), nil, nil, nil))
            }
        }

        let glyphAngle = glyphWidth.enumerated().map { (index, width) -> CGFloat in
            let lastGlyphWidth: CGFloat = index > 0 ? glyphWidth[index - 1] : 0
            return (lastGlyphWidth + width) / 2 / radius
        }
        
        return zip(glyphWidth, glyphAngle).map(GlyphDimension.init)
    }
}
