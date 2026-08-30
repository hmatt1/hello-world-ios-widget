# Launcher Board

Shortcuts on your Home Screen. Every tile runs a shortcut in place through the system `RunSystemShortcutIntent`, so nothing opens.

iOS 27. XcodeGen. Unsigned `.ipa` from GitHub Actions. No accounts, no purchases, no analytics, no network.

## Configure

Touch and hold the widget, choose **Edit Widget**. Fourteen rows:

```
1 … 12    the shortcut for each tile
Theme     Ink · Paper · Midnight · Aurora · Sunset
Density   Edge · Compact · Roomy
```

The number of shortcuts you assign is the slot count. Assign three and you get three tiles filling the widget, with no separate count to keep in sync. The sheet always lists twelve rows because an intent cannot know which family the widget was placed in, so a family shows the first however many it holds: four on small, six on medium, twelve on large.

Tiles are typographic. A tile shows the shortcut's own name, so it can never show the wrong icon, and there is nothing to type.

One text size is chosen for the whole board, from the longest name it has to hold. Short names get a large size; a long one steps the whole board down together rather than shrinking its own tile, because on a board with no icons the name is the only thing telling tiles apart, and mixed sizes take that away.

`Theme = Ink` with `Density = Edge` is the minimum: one near-black field, names in faint chips, edge to edge.

## Layout

Structure comes from the family and the number of shortcuts. There is no layout control, because there is nothing left for one to decide.

| Shortcuts | Small | Medium | Large |
|---|---|---|---|
| 1 | one tile | one tile | one tile |
| 2 to 3 | 1 column, left aligned | 1 row | 1 column, left aligned |
| 4 | 2 × 2 | 2 × 2 | 2 × 2 |
| 5 to 6 | — | 3 × 2 | 3 × 2 |
| 7 to 12 | — | — | balanced grid |

Capacity is 4 on small, 6 on medium, 12 on large. Balanced grid column counts:

| Slots | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|
| Columns | 2 | 3 | 3 | 4 | 4 | 3 | 4 | 4 | 4 |

`Density` sets outer padding and the gap between tiles: `Edge` 0pt, `Compact` 4pt padding with an 8pt gap, `Roomy` 12pt. When a board is tall enough that both would push a tile under the 44pt minimum touch target, separation between tiles is paid first and outer padding takes the remainder, so both stay non-decreasing as density rises. Every tile runs a shortcut, so none of them is allowed to be smaller than a finger.

The clamp runs against the smallest canvas iOS gives a family, the 320 × 568pt layout a 4.7 inch iPhone reaches with Display Zoom on (141 × 141, 291 × 141, 291 × 299), so tiles only ever grow on bigger phones.

`BoardGrid.resolve` is pure arithmetic, so its invariants are checkable without a simulator:

```bash
python3 Tools/verify-layout.py
```

That walks every family, shortcut count, density, published iPhone widget canvas and a range of name lengths, and asserts that no tile falls under the 44pt touch target, that the chosen text style still fits on every device rather than only on the smallest, that padding and gap are both non-decreasing as Density rises, and that every accent clears 4.5:1 against its label. 2790 checks. Run it after touching `Shared/BoardGrid.swift` or `Shared/Theme.swift`.

## Rendering

Accented mode was designed first. When someone picks a tinted or clear Home Screen the system switches the widget out of `WidgetRenderingMode.fullColor`, tints content white and replaces the container background. The widget then draws no background and no color, and each tile keeps a translucent white chip, because the system preserves the opacity of translucent content and tints it. That chip is what keeps the board readable as a grid once the color is gone. All widget content is one group, so there is nothing for `.widgetAccentable()` to separate.

Tiles keep their rounded corners even at `Edge`, where there is no gap at all: at zero separation the corner notch is the only thing marking where one tap target ends and the next begins, and in accented mode every tile carries the same fill.

Full color adds exactly one thing on top: a flat surface per tile and a background. No gradients on tiles, no strokes, no shadows, and no `Material` or `.glassEffect` anywhere. Liquid Glass belongs to the system.

Every accent in the three color themes clears 4.5:1 against its label color. Contrast is fixed in the palette and checked by `Tools/verify-layout.py`, never computed at runtime.

## Build

On a Mac:

```bash
brew install xcodegen
xcodegen generate
open LauncherBoard.xcodeproj
```

Set your Personal Team under **Signing & Capabilities** for both targets, enable **Developer Mode** under **Settings > Privacy & Security** on the iPhone, then run. The generated project carries no signing overrides, so this works; the unsigned build for release passes them on the `xcodebuild` command line instead.

From Windows, download `LauncherBoard.ipa` from **Releases** and sideload it with [Sideloadly](https://sideloadly.io/) using a free Apple ID. Enable **Developer Mode** on the iPhone first, then trust the developer under **Settings > General > VPN & Device Management**. Free-signed apps expire after seven days; Sideloadly's Wi-Fi auto refresh renews them.

Tag a release to publish a new build:

```bash
gh release create v2.0.0 --generate-notes
```

## Files

```
Shared/Theme.swift       five themes and three densities, as plain enums
Shared/BoardGrid.swift   columns, rows, tile mode, touch-target clamp, type scale, sample names
Shared/BoardView.swift   tiles, background, empty state
App/App.swift            the whole app
App/Assets.xcassets      app icon and accent color
Widget/LauncherIntent.swift   fourteen parameters, AppEnum conformances
Widget/Widget.swift      provider, entry view, widget
Tools/verify-layout.py   re-derives the layout arithmetic and checks it
```

`Shared/` never imports AppIntents. `BoardView` takes a tile builder, so the widget wraps each tile in `Button(intent:)` and the app renders the same `SlotFace` inert.

## Development Lessons Learned

While building this widget, we encountered and resolved several strict Apple requirements for iOS 27 widgets:

1. **App Extensions Must be Embedded:** Widgets must be explicitly embedded into the main app for them to be signed and installed properly via tools like Sideloadly. This requires the `embed: true` flag in the `project.yml` dependencies.
2. **Synchronized Version Strings:** Apple strictly mandates that App Extensions share the exact same `CFBundleVersion` and `CFBundleShortVersionString` as their parent App. Our `project.yml` sets these dynamically using Xcode variables `$(CURRENT_PROJECT_VERSION)` and `$(MARKETING_VERSION)`, which are injected by the GitHub Action at compile time.
3. **Globally Unique Bundle Identifiers:** Bundle IDs must be globally unique to bypass Apple's free-tier signing restrictions (e.g., `com.hmatt1.launcherboard` and `com.hmatt1.launcherboard.Widget`).
4. **Xcode 27 Cloud Compilation:** iOS 27 features like `RunSystemShortcutIntent` require the Xcode 27 SDK. Our GitHub Action uses `runs-on: xcode-27` to ensure the cloud compiler recognizes these new APIs.
5. **Widget Intent Constraints:** The iOS 27 `RunSystemShortcutIntent` is only valid when explicitly passed into a `Button(intent:)` initializer within the widget's view.

## License

MIT. Take it, change it, ship it.
