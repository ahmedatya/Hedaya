# Prayer Tree: Design-First Workflow (Figma → SVG → SwiftUI)

Three-step approach so the tree is designed in a proper tool, then rendered and wired in the app.

**Status:** The app currently uses the **drawn tree** (SwiftUI Canvas) for reliability. The SVG workflow (Steps 1–3) is documented and the mapping layer (`PrayerTreeMapping.swift`) and sample `PrayerTree.svg` are in the repo; you can re-enable SVG rendering later (e.g. with the SVGView package) when the design asset is ready.

---

## Step 1: Design the tree (Figma / Illustrator)

**Goal:** One tree graphic where every interactive part is a named layer or group that can be exported with a stable ID.

### Artboard and structure

- **Single artboard** sized for the app (e.g. 390×560 pt for iPhone, or a scalable square like 400×560).
- **Layers / groups** for:
  - **Trunk** – one shape or group named `trunk` (for Quran).
  - **Roots** – five shapes/paths, one per prayer, with IDs:
    - `root-fajr`
    - `root-dhuhr`
    - `root-asr`
    - `root-maghrib`
    - `root-isha`
  - **Branches** – eight branch/leaf elements for optional acts:
    - `branch-sunnah`
    - `branch-sadaqa`
    - `branch-morning-zikr`
    - `branch-sleeping-zikr`
    - `branch-evening-zikr`
    - `branch-extra-duaa`
    - `branch-extra-zikr`
    - `branch-extra-salah`

### Naming convention

- Use **kebab-case** and the exact IDs above so Swift can map them without a config file.
- If your tool exports layers as `<g id="root-fajr">` or similar, the same IDs can be used in the SVG.

### Export

- Export the tree as **one SVG file** (e.g. `PrayerTree.svg`).
- Prefer **outline strokes** so the SVG is clean and scales well.
- Optional: export a version with no labels; labels can be drawn in SwiftUI over the SVG for RTL and localization.

---

## Step 2: Render SVG in SwiftUI

**Options:**

| Approach | Pros | Cons |
|----------|------|------|
| **SVGView (exyte)** | SPM, SwiftUI-native, supports paths and basic interactivity | Need to add package dependency |
| **SwiftSVG (richardpiazza)** | Parses SVG to data structures | You still need to render (e.g. convert to `Path`) |
| **Asset as PDF** | Xcode renders vector PDFs natively in `Image("name")` | No per-element IDs; harder to map taps to nodes |
| **SVG → SwiftUI Path** | No runtime SVG dependency; full control | One-time conversion (script or manual) from SVG to Swift code |

**Recommended for Hedaya:** Use **SVGView** (or similar) so you drop `PrayerTree.svg` into the app and render it. If you prefer **no extra dependency**, export the tree as a **vector PDF** in Assets and overlay **invisible tappable regions** at fixed positions (like we do now with the drawn tree); the “design” is still in Figma, but the app uses a static image + hit areas.

**Implementation sketch (with SVGView):**

1. Add package: e.g. `https://github.com/exyte/SVGView` (or current SVG–SwiftUI package).
2. Add `PrayerTree.svg` to the app target (e.g. in Assets or as a bundle resource).
3. In SwiftUI, load and display the SVG; keep a reference to the view (or use a callback) so we can later map touches to element IDs if the library supports it. If the library does **not** expose per-element hit-testing, fall back to **overlaying invisible buttons** at the same positions as in the design (positions can be defined in code or in a small JSON next to the SVG).

---

## Step 3: Map leaves, roots, trunk to actions

**Data model (unchanged):**

- Roots → `PrayerName` (fajr, dhuhr, asr, maghrib, isha) → `store.markPrayerDone(_:)`
- Trunk → Quran → `store.markQuranDone()`
- Branches/leaves → `BranchType` (sunnah, sadaqa, …) → `store.markBranchDone(_:)`

**Mapping options:**

1. **By element ID (best if SVG lib supports hit-test by ID)**  
   When the user taps, the view reports the tapped element ID (e.g. `root-fajr`). A simple mapping dictionary in code turns that into `PrayerName.fajr` and calls `store.markPrayerDone(.fajr)`.

2. **By overlay frames**  
   If the SVG is “dumb” (no per-element IDs at tap time), place invisible `Button` or `contentShape` views **on top** of the SVG at the same positions as trunk, roots, and branches. Each button calls the right store method. Positions can be:
   - Hard-coded (from design specs), or
   - Loaded from a small JSON (e.g. `PrayerTreeHitAreas.json`) that lists `id` and `frame` (or center + size) for each element so you can tweak without recompiling.

3. **Visual state (glow / checkmark)**  
   Same as now: the **tree graphic** (SVG or PDF) is static; we don’t need to change the SVG at runtime. We overlay:
   - A “completed” state (e.g. checkmark or green tint) for each root/trunk/branch when the corresponding action is done.
   - A “glow” on a root when it’s time for that prayer and not yet done.

So: **design defines the look; code defines the mapping and state.**

---

## Summary

| Step | Owner | Output |
|------|--------|--------|
| **1. Design** | Designer (Figma / Illustrator) | One SVG (or PDF) with named layers: trunk, root-*, branch-*. |
| **2. Render** | Dev | SVG in app (via SVGView or similar), or PDF in Asset catalog. |
| **3. Map** | Dev | IDs or overlay frames → `PrayerName` / Quran / `BranchType` → existing store methods; overlays for state (done, glow). |

No change to `PrayerTrackingStore` or the rest of the flow—only the **tree asset** and the **view that draws it and handles taps** change.

**Applying the mapping in code:** Use `PrayerTreeMapping.action(for: elementID)` to get a `PrayerTreeAction`. Then call the store:

```swift
if let action = PrayerTreeMapping.action(for: tappedElementID) {
    switch action {
    case .prayer(let name): store.markPrayerDone(name)
    case .quran: store.markQuranDone()
    case .branch(let type): store.markBranchDone(type)
    }
}
```
