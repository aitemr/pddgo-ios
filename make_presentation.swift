import AppKit
import CoreGraphics

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assetRoot = root.appendingPathComponent("presentation_assets")
let outputURL = root.appendingPathComponent("PDD_App_Presentation.pdf")

let page = CGSize(width: 1280, height: 720)
let blue = NSColor(calibratedRed: 0.106, green: 0.561, blue: 0.937, alpha: 1)
let dark = NSColor(calibratedRed: 0.08, green: 0.10, blue: 0.14, alpha: 1)
let muted = NSColor(calibratedRed: 0.38, green: 0.42, blue: 0.48, alpha: 1)
let light = NSColor(calibratedRed: 0.96, green: 0.97, blue: 0.99, alpha: 1)

extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            calibratedRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255,
            alpha: 1
        )
    }
}

func font(_ size: CGFloat, _ weight: NSFont.Weight = .regular) -> NSFont {
    NSFont.systemFont(ofSize: size, weight: weight)
}

func drawText(_ text: String, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, size: CGFloat, weight: NSFont.Weight = .regular, color: NSColor = dark, align: NSTextAlignment = .left) {
    let style = NSMutableParagraphStyle()
    style.alignment = align
    style.lineSpacing = size * 0.18
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font(size, weight),
        .foregroundColor: color,
        .paragraphStyle: style
    ]
    NSAttributedString(string: text, attributes: attrs).draw(in: CGRect(x: x, y: y, width: w, height: h))
}

func rounded(_ rect: CGRect, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil, width: CGFloat = 1) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = width
        path.stroke()
    }
}

func image(_ name: String) -> NSImage? {
    NSImage(contentsOf: assetRoot.appendingPathComponent(name))
}

func drawImage(_ img: NSImage, in rect: CGRect, radius: CGFloat = 0) {
    NSGraphicsContext.saveGraphicsState()
    if radius > 0 {
        NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).addClip()
    }
    img.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()
}

func drawPhone(_ imageName: String, x: CGFloat, y: CGFloat, h: CGFloat) {
    guard let img = image(imageName) else { return }
    let ratio = img.size.width / img.size.height
    let w = h * ratio
    rounded(CGRect(x: x - 10, y: y - 10, width: w + 20, height: h + 20), radius: 42, fill: NSColor.white, stroke: NSColor(hex: 0xDCE5F5), width: 2)
    drawImage(img, in: CGRect(x: x, y: y, width: w, height: h), radius: 34)
}

func drawPill(_ text: String, x: CGFloat, y: CGFloat, w: CGFloat, color: NSColor = blue) {
    rounded(CGRect(x: x, y: y, width: w, height: 44), radius: 22, fill: color)
    drawText(text, x: x, y: y + 10, w: w, h: 24, size: 16, weight: .semibold, color: .white, align: .center)
}

func drawBullet(_ text: String, x: CGFloat, y: CGFloat, w: CGFloat) {
    rounded(CGRect(x: x, y: y + 9, width: 10, height: 10), radius: 5, fill: blue)
    drawText(text, x: x + 26, y: y, w: w - 26, h: 52, size: 22, weight: .medium)
}

func drawStat(_ value: String, _ label: String, x: CGFloat, y: CGFloat, w: CGFloat) {
    rounded(CGRect(x: x, y: y, width: w, height: 120), radius: 20, fill: light, stroke: NSColor(hex: 0xDCE5F5))
    drawText(value, x: x + 18, y: y + 18, w: w - 36, h: 44, size: 34, weight: .bold, color: blue, align: .center)
    drawText(label, x: x + 18, y: y + 66, w: w - 36, h: 34, size: 16, weight: .medium, color: muted, align: .center)
}

func slide(_ context: CGContext, title: String? = nil, subtitle: String? = nil, body: () -> Void) {
    var box = CGRect(origin: .zero, size: page)
    context.beginPDFPage([kCGPDFContextMediaBox as String: NSData(bytes: &box, length: MemoryLayout<CGRect>.size)] as CFDictionary)
    context.saveGState()
    context.translateBy(x: 0, y: page.height)
    context.scaleBy(x: 1, y: -1)
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: true)
    NSColor.white.setFill()
    NSBezierPath(rect: CGRect(origin: .zero, size: page)).fill()
    if let title {
        drawText(title, x: 64, y: 52, w: 780, h: 68, size: 42, weight: .bold)
    }
    if let subtitle {
        drawText(subtitle, x: 66, y: 116, w: 760, h: 44, size: 19, weight: .medium, color: muted)
    }
    body()
    context.restoreGState()
    context.endPDFPage()
}

var mediaBox = CGRect(origin: .zero, size: page)
let data = NSMutableData()
guard let consumer = CGDataConsumer(data: data),
      let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
    fatalError("Cannot create PDF context")
}

slide(context, title: "PDD KZ Mobile Application", subtitle: "Driving theory preparation for Kazakhstan with tests, AI help, progress tracking, widgets, and watch companion.") {
    rounded(CGRect(x: 0, y: 0, width: page.width, height: page.height), radius: 0, fill: NSColor(hex: 0xF8FBFF))
    drawText("PDD KZ", x: 72, y: 78, w: 520, h: 76, size: 58, weight: .heavy, color: blue)
    drawText("Application & Functional Presentation", x: 76, y: 160, w: 570, h: 42, size: 27, weight: .semibold)
    drawText("A SwiftUI iOS app for exam practice, mistake review, AI guidance, subscriptions, and daily learning retention.", x: 76, y: 226, w: 540, h: 100, size: 24, color: muted)
    drawPill("iOS + WidgetKit + watchOS", x: 76, y: 356, w: 260)
    drawPill("AI: Akzhol assistant", x: 356, y: 356, w: 230, color: NSColor(hex: 0x7A4DFF))
    drawPhone("splash.png", x: 820, y: 46, h: 610)
}

slide(context, title: "What The App Does", subtitle: "The app is built around a learner journey: start, practice, test, understand mistakes, and keep progress visible.") {
    drawStat("848", "question bank", x: 70, y: 194, w: 210)
    drawStat("40", "trial exam questions", x: 310, y: 194, w: 230)
    drawStat("32/40", "pass threshold", x: 570, y: 194, w: 220)
    drawStat("72", "course tasks", x: 820, y: 194, w: 190)
    drawBullet("Official-style trial tests and individual tests based on saved mistakes.", x: 86, y: 376, w: 700)
    drawBullet("Akzhol AI assistant explains traffic rules, images, and wrong answers.", x: 86, y: 438, w: 700)
    drawBullet("Progress, streaks, favorites, history replay, profile settings, and subscription gating.", x: 86, y: 500, w: 790)
    drawPhone("tests.png", x: 1030, y: 168, h: 470)
}

slide(context, title: "Onboarding & Account Setup", subtitle: "First launch introduces the product, asks key learner preferences, then routes to auth and social proof.") {
    drawPhone("onboarding.png", x: 80, y: 112, h: 540)
    drawBullet("Carousel explains the value of the PDD preparation flow.", x: 560, y: 196, w: 560)
    drawBullet("Survey captures vehicle category, region, and current knowledge level.", x: 560, y: 270, w: 560)
    drawBullet("Sign in supports Apple, Google/Firebase, and guest mode.", x: 560, y: 344, w: 560)
    drawBullet("Loading and social-proof screens complete the funnel before the main app.", x: 560, y: 418, w: 560)
}

slide(context, title: "Testing Experience", subtitle: "The main tab prioritizes exam readiness with trial testing, road-sign detection, work on mistakes, and result history.") {
    drawPhone("tests.png", x: 94, y: 92, h: 570)
    drawBullet("Standard Kazakhstan trial exam uses 40 questions and an 80% pass rule.", x: 548, y: 190, w: 590)
    drawBullet("Individual testing is generated from the MistakesBank, so weak topics return until fixed.", x: 548, y: 274, w: 590)
    drawBullet("History rows store score, date, pass/fail status, question ids, and user choices for replay.", x: 548, y: 358, w: 590)
    drawBullet("Sound effects, haptics, favorites, and answer explanations support active learning.", x: 548, y: 442, w: 590)
}

slide(context, title: "Course & Quiz Logic", subtitle: "Behind the UI is a deterministic learning catalog and quiz state machine.") {
    rounded(CGRect(x: 72, y: 186, width: 340, height: 330), radius: 24, fill: light, stroke: NSColor(hex: 0xDCE5F5))
    drawText("Catalog", x: 104, y: 220, w: 280, h: 40, size: 30, weight: .bold, color: blue)
    drawText("8 cards: easy x3, medium x2, advanced x3. Each card has 2 modules and 9 tasks, giving 72 total tasks.", x: 104, y: 278, w: 270, h: 150, size: 22, color: muted)
    rounded(CGRect(x: 470, y: 186, width: 340, height: 330), radius: 24, fill: light, stroke: NSColor(hex: 0xDCE5F5))
    drawText("Quiz Engine", x: 502, y: 220, w: 280, h: 40, size: 30, weight: .bold, color: blue)
    drawText("Tracks current question, selected answer, submitted state, timer, score, replay choices, favorites, and final result.", x: 502, y: 278, w: 270, h: 170, size: 22, color: muted)
    rounded(CGRect(x: 868, y: 186, width: 340, height: 330), radius: 24, fill: light, stroke: NSColor(hex: 0xDCE5F5))
    drawText("Persistence", x: 900, y: 220, w: 280, h: 40, size: 30, weight: .bold, color: blue)
    drawText("Updates ProgressStore, TestHistory, MistakesBank, StreakStore, usage limits, and WidgetSnapshot after quiz completion.", x: 900, y: 278, w: 270, h: 170, size: 22, color: muted)
}

slide(context, title: "Akzhol AI Assistant", subtitle: "Akzhol is the in-app traffic-rules assistant, available from its own tab and from quiz mistake flows.") {
    drawPhone("akzhol.png", x: 92, y: 96, h: 560)
    drawBullet("Chat persona: experienced Kazakhstan traffic inspector, concise and practical.", x: 540, y: 180, w: 600)
    drawBullet("Supports text conversation and image attachments through the photo picker.", x: 540, y: 256, w: 600)
    drawBullet("Uses on-device FoundationModels on eligible iOS 26 devices for text-only chats.", x: 540, y: 332, w: 600)
    drawBullet("Falls back to Gemini REST models for cloud replies and image understanding.", x: 540, y: 408, w: 600)
    drawBullet("Wrong-answer context can be sent to Akzhol for focused mistake explanations.", x: 540, y: 484, w: 600)
}

slide(context, title: "Profile, Progress & Settings", subtitle: "The profile area keeps long-term learning state visible and gives users control over preferences.") {
    drawPhone("profile.png", x: 92, y: 96, h: 560)
    drawBullet("Shows learner name, license category, provider badge, streak card, and level progress.", x: 540, y: 186, w: 600)
    drawBullet("Settings include notifications, haptics, sound, animations, language, and profile editing.", x: 540, y: 270, w: 600)
    drawBullet("Favorites and test history let users revisit important or difficult questions.", x: 540, y: 354, w: 600)
    drawBullet("Supports premium entry point, app rating, sharing, privacy, terms, support, and logout.", x: 540, y: 438, w: 600)
}

slide(context, title: "Premium & Monetization", subtitle: "Usage limits route high-value actions into a subscription paywall while keeping the core app usable.") {
    drawPhone("paywall.png", x: 92, y: 96, h: 560)
    drawBullet("Weekly and monthly plans are selectable in the current paywall UI.", x: 540, y: 190, w: 600)
    drawBullet("Premium messaging highlights videos, tests, Akzhol access, and mistake practice.", x: 540, y: 274, w: 600)
    drawBullet("Akzhol has a free-turn limit before premium gating.", x: 540, y: 358, w: 600)
    drawBullet("Purchase and restore calls are handled by SubscriptionGate.", x: 540, y: 442, w: 600)
}

slide(context, title: "Apple Ecosystem Support", subtitle: "The project includes extensions beyond the phone app.") {
    drawStat("WidgetKit", "progress + streak widgets", x: 104, y: 202, w: 300)
    drawStat("watchOS", "companion streak view", x: 490, y: 202, w: 300)
    drawStat("Sync", "shared snapshot data", x: 876, y: 202, w: 300)
    drawBullet("Home-screen and lock-screen widgets show percent progress, correct answers, current streak, and longest streak.", x: 120, y: 404, w: 980)
    drawBullet("The watch app displays current streak, progress gauge, record, and correct-answer count.", x: 120, y: 480, w: 980)
    drawBullet("WidgetSnapshot and WatchConnectivity keep external surfaces aligned with quiz activity.", x: 120, y: 556, w: 980)
}

slide(context, title: "Functional Map", subtitle: "The current codebase already covers the major product layers needed for a complete PDD learning app.") {
    let items = [
        ("Acquisition", "Splash, onboarding, survey, auth, social proof"),
        ("Learning", "Course catalog, videos, useful materials, multilingual question bank"),
        ("Testing", "Timed trial exam, individual mistake exam, replay history"),
        ("Assistance", "Akzhol text/image chat and mistake explanations"),
        ("Retention", "Progress, streaks, widgets, watch companion, notifications"),
        ("Business", "Paywall, subscription gate, free usage limits")
    ]
    for (index, item) in items.enumerated() {
        let row = index / 2
        let col = index % 2
        let x = CGFloat(88 + col * 565)
        let y = CGFloat(178 + row * 142)
        rounded(CGRect(x: x, y: y, width: 505, height: 104), radius: 20, fill: light, stroke: NSColor(hex: 0xDCE5F5))
        drawText(item.0, x: x + 24, y: y + 18, w: 460, h: 30, size: 24, weight: .bold, color: blue)
        drawText(item.1, x: x + 24, y: y + 54, w: 440, h: 36, size: 17, weight: .medium, color: muted)
    }
}

context.closePDF()
data.write(to: outputURL, atomically: true)
print(outputURL.path)
