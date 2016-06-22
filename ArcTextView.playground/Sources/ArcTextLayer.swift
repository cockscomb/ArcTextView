import QuartzCore
import CoreText

public class ArcTextLayer: CALayer {

    public enum Alignment {
        case Start
        case Center
        case End
    }

    public var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    public var alignment: Alignment = .Start {
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

    override public func drawInContext(ctx: CGContext) {
        // Check pre-conditions
        guard radius > 0, let attributedText = attributedText else {
            return
        }
        let line = CTLineCreateWithAttributedString(attributedText)
        guard CTLineGetGlyphCount(line) > 0 else {
            return
        }

        let dimensions = calcurateGlyphDimensions(from: line, radius: radius)

        CGContextSaveGState(ctx)

        // Initialize canvas position
        CGContextTranslateCTM(ctx, bounds.width / 2, bounds.height / 2)
        CGContextScaleCTM(ctx, -1, 1)
        CGContextRotateCTM(ctx, CGFloat(M_PI))

        // Adjust alignment
        let totalWidth = dimensions.map({ $0.width }).reduce(0, combine: +)
        let startAngle: CGFloat
        switch alignment {
        case .Start:
            startAngle = 0
        case .Center:
            startAngle = -(totalWidth / radius) / 2
        case .End:
            startAngle = -(totalWidth / radius)
        }
        CGContextRotateCTM(ctx, -(startAngle + angle))

        // Draw glyphs
        var textPosition = CGPoint(x: 0, y: radius)
        CGContextSetTextPosition(ctx, textPosition.x, textPosition.y)
        var glyphOffset = 0
        let runs = CTLineGetGlyphRuns(line) as NSArray as! [CTRun]
        for run in runs {
            let runGlyphCount = CTRunGetGlyphCount(run)

            for runGlyphIndex in (0..<runGlyphCount) {
                let dimension = dimensions[glyphOffset + runGlyphIndex]
                let glyphRange = CFRange(location: runGlyphIndex, length: 1)

                CGContextRotateCTM(ctx, -dimension.angle)

                let thisGlyphPosition = CGPoint(x: textPosition.x - dimension.width / 2, y: textPosition.y)

                textPosition.x -= dimension.width

                var textMatrix = CTRunGetTextMatrix(run)
                textMatrix.tx = thisGlyphPosition.x
                textMatrix.ty = thisGlyphPosition.y
                CGContextSetTextMatrix(ctx, textMatrix)

                CTRunDraw(run, ctx, glyphRange)
            }

            glyphOffset += runGlyphCount
        }

        CGContextRestoreGState(ctx)
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

        let glyphAngle = glyphWidth.enumerate().map { (index, width) -> CGFloat in
            let lastGlyphWidth: CGFloat = index > 0 ? glyphWidth[index - 1] : 0
            return (lastGlyphWidth + width) / 2 / radius
        }
        
        return zip(glyphWidth, glyphAngle).map(GlyphDimension.init)
    }
}
