import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import ".."
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    function paint() { FiatGlossaTheme.applyPalette(page) }
    Component.onCompleted: {
        paint()
        restoreLanguages()
    }
    Connections {
        target: FiatGlossaTheme
        onAmbientChanged: page.paint()
    }

    // A language is identified by its DeepL TARGET code, because that is the
    // code that tells the variants apart -- DeepL's source_lang knows no
    // variants, so the backend derives it: EN-GB and EN-US both go out as EN.
    readonly property var languages: [
        { name: "Detect language",       code: "" },
        { name: "English (Traditional)", code: "EN-GB" },
        { name: "English (Simplified)",  code: "EN-US" },
        { name: "Chinese (Traditional)", code: "ZH-HANT" },
        { name: "Chinese (Simplified)",  code: "ZH-HANS" },
        { name: "Swedish",               code: "SV" },
        { name: "Finnish",               code: "FI" },
        { name: "Norwegian",             code: "NB" },
        { name: "Danish",                code: "DA" },
        { name: "German",                code: "DE" },
        { name: "Dutch",                 code: "NL" },
        { name: "French",                code: "FR" },
        { name: "Italian",               code: "IT" },
        { name: "Spanish",               code: "ES" },
        { name: "Portuguese (Portugal)", code: "PT-PT" },
        { name: "Portuguese (Brazil)",   code: "PT-BR" },
        { name: "Russian",               code: "RU" },
        { name: "Ukrainian",             code: "UK" },
        { name: "Polish",                code: "PL" },
        { name: "Czech",                 code: "CS" },
        { name: "Slovak",                code: "SK" },
        { name: "Slovenian",             code: "SL" },
        { name: "Estonian",              code: "ET" },
        { name: "Latvian",               code: "LV" },
        { name: "Lithuanian",            code: "LT" },
        { name: "Greek",                 code: "EL" },
        { name: "Hungarian",             code: "HU" },
        { name: "Romanian",              code: "RO" },
        { name: "Bulgarian",             code: "BG" },
        { name: "Turkish",               code: "TR" },
        { name: "Arabic",                code: "AR" },
        { name: "Hebrew",                code: "HE" },
        { name: "Japanese",              code: "JA" },
        { name: "Korean",                code: "KO" },
        { name: "Indonesian",            code: "ID" },
        { name: "Vietnamese",            code: "VI" },
        { name: "Thai",                  code: "TH" }
    ]
    readonly property var targetLanguages: languages.slice(1)

    property bool ready: false
    property int sourceIndex: 0
    property int targetIndex: 0

    readonly property string sourceCode: languages[sourceIndex].code
    readonly property string targetCode: targetLanguages[targetIndex].code

    // The button shows the code, the picker shows the name: a code is short
    // enough to sit on one line beside its twin, and this is an instrument.
    readonly property string sourceLabel: sourceIndex === 0 ? "detect" : sourceCode
    readonly property string targetLabel: targetCode

    // Full names for the caption line under the buttons -- where "EN-US"
    // just reads as a code, "English (Simplified)" reads as the feature.
    // Under Detect language the button still just says "detect", but once
    // DeepL has actually detected something, the caption names it -- and
    // falls back to "Detect language" itself before that first translation.
    readonly property string sourceName: sourceIndex !== 0
        ? languages[sourceIndex].name
        : (glossa.detectedSource !== "" ? nameForCode(glossa.detectedSource) : languages[0].name)
    readonly property string targetName: targetLanguages[targetIndex].name

    // Both ends of the same language: EN-GB to EN-US, ZH-HANT to ZH-HANS,
    // PT-PT to PT-BR. DeepL takes no variant as a SOURCE, so it sees one
    // language on both ends, finds nothing to translate, and hands the text
    // back nearly as written. Worth saying out loud rather than letting it
    // look like the app did nothing.
    readonly property string sourceFamily: sourceIndex !== 0
        ? sourceCode.split("-")[0]
        : glossa.detectedSource.split("-")[0]
    readonly property string targetFamily: targetCode.split("-")[0]
    readonly property bool sameFamily: sourceFamily !== "" && sourceFamily === targetFamily
    readonly property string familyName: nameForCode(targetFamily)

    property bool noticeOpen: false

    // DeepL's source_lang carries no variant, so a detected family that has
    // one (English, Chinese, Portuguese) shows its bare name rather than
    // guessing which half of the pair was actually seen.
    function nameForCode(code) {
        for (var i = 0; i < languages.length; ++i)
            if (languages[i].code === code) return languages[i].name
        if (code === "EN") return "English"
        if (code === "ZH") return "Chinese"
        if (code === "PT") return "Portuguese"
        if (code === "NO" || code === "NN") return "Norwegian"
        return code
    }

    // Swapping needs somewhere to swap to. Under "Detect language" that means
    // DeepL must have told us what it detected.
    readonly property bool canSwap: sourceIndex > 0
        || (glossa.detectedSource !== "" && indexOf(targetLanguages, glossa.detectedSource) >= 0)

    function indexOf(list, code) {
        for (var i = 0; i < list.length; ++i)
            if (list[i].code === code) return i
        return -1
    }

    function systemTarget() {
        var name = Qt.locale().name             // "sv_SE", "en_GB", "zh_TW" ...
        var lang = name.split("_")[0].toUpperCase()
        if (lang === "EN")
            return (name === "en_GB" || name === "en_IE" || name === "en_AU" || name === "en_NZ")
                   ? "EN-GB" : "EN-US"
        if (lang === "ZH")
            return (name === "zh_TW" || name === "zh_HK") ? "ZH-HANT" : "ZH-HANS"
        if (lang === "PT")
            return name === "pt_BR" ? "PT-BR" : "PT-PT"
        if (lang === "NO" || lang === "NN") return "NB"
        return indexOf(targetLanguages, lang) >= 0 ? lang : "EN-US"
    }

    function restoreLanguages() {
        var s = indexOf(languages, sourceConfig.value)
        sourceIndex = s >= 0 ? s : 0
        var t = indexOf(targetLanguages, targetConfig.value)
        if (t < 0) t = indexOf(targetLanguages, systemTarget())
        targetIndex = Math.max(0, t)
        ready = true
    }

    function selectionChanged() {
        if (!ready) return
        sourceConfig.value = sourceCode
        targetConfig.value = targetCode
        glossa.cancel()
    }

    // The list is its own page rather than a menu. 36 entries with variants
    // will not open inline here: the two cards are anchored between the head
    // and the status line, so anything that grows the head squashes them to
    // nothing and takes its own tail off the bottom of the screen with it.
    function pickSource() {
        var picker = pageStack.animatorPush(Qt.resolvedUrl("LanguagePage.qml"), {
            languages: page.languages,
            currentIndex: page.sourceIndex,
            heading: qsTr("translate from")
        })
        picker.pageCompleted.connect(function (p) {
            p.selected.connect(function (i) {
                page.sourceIndex = i
                page.selectionChanged()
            })
        })
    }

    function pickTarget() {
        var picker = pageStack.animatorPush(Qt.resolvedUrl("LanguagePage.qml"), {
            languages: page.targetLanguages,
            currentIndex: page.targetIndex,
            heading: qsTr("translate into")
        })
        picker.pageCompleted.connect(function (p) {
            p.selected.connect(function (i) {
                page.targetIndex = i
                page.selectionChanged()
            })
        })
    }

    function translateNow() {
        input.focus = false
        glossa.translate(input.text, sourceCode, targetCode)
    }

    function swapLanguages() {
        var from = sourceIndex > 0 ? sourceCode : glossa.detectedSource
        var to = targetCode
        var carried = glossa.translation

        ready = false
        sourceIndex = Math.max(0, indexOf(languages, to))
        targetIndex = Math.max(0, indexOf(targetLanguages, from))
        ready = true
        selectionChanged()

        if (carried !== "")
            input.text = carried
    }

    ConfigurationValue {
        id: sourceConfig
        key: "/apps/harbour-fiatglossa/source"
        defaultValue: ""
    }
    ConfigurationValue {
        id: targetConfig
        key: "/apps/harbour-fiatglossa/target"
        defaultValue: ""
    }

    Background { }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: height              // the split fills the page; nothing scrolls

        PullDownMenu {
            // Without this the menu's selection highlight follows Silica's
            // chrome default rather than this app's colour. chromeAccent
            // rather than the raw accent: teal at full saturation reads as a
            // large glowing fill rather than as an accent.
            highlightColor: FiatGlossaTheme.chromeAccent

            MenuItem {
                text: "About"
                color: FiatGlossaTheme.primaryText
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: FiatGlossaTheme.ambient ? "Fiat colours" : "Follow ambience"
                color: FiatGlossaTheme.primaryText
                onClicked: FiatGlossaTheme.setAmbient(!FiatGlossaTheme.ambient)
            }
            MenuItem {
                text: "Settings"
                color: FiatGlossaTheme.primaryText
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: "Clear"
                color: FiatGlossaTheme.primaryText
                enabled: input.text !== ""
                onClicked: {
                    input.text = ""
                    glossa.cancel()
                    glossa.translate("", page.sourceCode, page.targetCode)
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: "Copy translation"
                color: FiatGlossaTheme.primaryText
                enabled: glossa.translation !== ""
                onClicked: Clipboard.text = glossa.translation
            }
        }

        Column {
            id: head
            width: parent.width
            anchors.top: parent.top

            Wordmark { }

            Item {
                width: parent.width
                height: pickers.height + Theme.paddingLarge

                Row {
                    id: pickers
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingMedium

                    Button {
                        id: fromButton
                        text: page.sourceLabel
                        preferredWidth: Theme.buttonWidthSmall
                        onClicked: page.pickSource()
                    }

                    // Drawn rather than image://theme/icon-m-swap. That icon
                    // does not exist in the theme -- it failed to resolve and
                    // left an invisible button in the middle of the row.
                    MouseArea {
                        id: swapButton
                        anchors.verticalCenter: fromButton.verticalCenter
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                        enabled: page.canSwap
                        onClicked: page.swapLanguages()

                        onEnabledChanged: swapGlyph.requestPaint()
                        onPressedChanged: swapGlyph.requestPaint()

                        Canvas {
                            id: swapGlyph
                            anchors.fill: parent
                            renderStrategy: Canvas.Immediate
                            opacity: swapButton.enabled ? 1.0 : 0.35

                            Connections {
                                target: FiatGlossaTheme
                                onAmbientChanged: swapGlyph.requestPaint()
                            }

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.clearRect(0, 0, width, height)

                                ctx.strokeStyle = swapButton.pressed
                                                  ? FiatGlossaTheme.accent
                                                  : FiatGlossaTheme.primaryText
                                ctx.fillStyle = ctx.strokeStyle
                                ctx.lineWidth = Math.max(1, width * 0.07)
                                ctx.lineCap = "round"

                                var x0 = width * 0.22
                                var x1 = width * 0.78
                                var head = width * 0.18
                                var yTop = height * 0.36
                                var yBot = height * 0.64

                                // Upper arrow points left, lower points right.
                                ctx.beginPath()
                                ctx.moveTo(x0, yTop)
                                ctx.lineTo(x1, yTop)
                                ctx.stroke()

                                ctx.beginPath()
                                ctx.moveTo(x0, yTop)
                                ctx.lineTo(x0 + head, yTop - head * 0.55)
                                ctx.lineTo(x0 + head, yTop + head * 0.55)
                                ctx.closePath()
                                ctx.fill()

                                ctx.beginPath()
                                ctx.moveTo(x0, yBot)
                                ctx.lineTo(x1, yBot)
                                ctx.stroke()

                                ctx.beginPath()
                                ctx.moveTo(x1, yBot)
                                ctx.lineTo(x1 - head, yBot - head * 0.55)
                                ctx.lineTo(x1 - head, yBot + head * 0.55)
                                ctx.closePath()
                                ctx.fill()
                            }
                        }
                    }

                    Button {
                        id: toButton
                        text: page.targetLabel
                        preferredWidth: Theme.buttonWidthSmall
                        onClicked: page.pickTarget()
                    }
                }
            }

            // Same widths and spacing as the button row above, so each name
            // sits under its own button and the arrow sits under the swap
            // glyph, rather than the three drifting as one centered line.
            Row {
                id: captionRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium

                Label {
                    width: fromButton.width
                    horizontalAlignment: Text.AlignHCenter
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: FiatGlossaTheme.secondaryText
                    text: page.sourceName
                }
                Label {
                    width: swapButton.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: FiatGlossaTheme.secondaryText
                    text: "→"
                }
                Label {
                    width: toButton.width
                    horizontalAlignment: Text.AlignHCenter
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: FiatGlossaTheme.secondaryText
                    text: page.targetName
                }
            }

            // Shown only for a same-language pair, and silent until tapped:
            // the cards below are anchored to the bottom of this column, so
            // anything that stands open up here takes height from them.
            Item {
                width: parent.width
                height: page.sameFamily ? Theme.iconSizeMedium : 0
                visible: page.sameFamily

                // The glyph is small, the tap target is not: the drawing
                // takes a fraction of a full-sized touch area rather than
                // asking for a finger the size of the mark.
                MouseArea {
                    anchors.centerIn: parent
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    onClicked: page.noticeOpen = !page.noticeOpen

                    Canvas {
                        id: infoGlyph
                        anchors.fill: parent
                        renderStrategy: Canvas.Immediate

                        Connections {
                            target: FiatGlossaTheme
                            onAmbientChanged: infoGlyph.requestPaint()
                        }
                        Connections {
                            target: page
                            onNoticeOpenChanged: infoGlyph.requestPaint()
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)

                            ctx.strokeStyle = page.noticeOpen
                                              ? FiatGlossaTheme.accent
                                              : FiatGlossaTheme.secondaryText
                            ctx.fillStyle = ctx.strokeStyle

                            var c = width / 2
                            var r = width * 0.22

                            ctx.lineWidth = Math.max(1, r * 0.16)
                            ctx.lineCap = "round"

                            ctx.beginPath()
                            ctx.arc(c, c, r, 0, Math.PI * 2)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.arc(c, c - r * 0.45, r * 0.13, 0, Math.PI * 2)
                            ctx.fill()

                            ctx.beginPath()
                            ctx.moveTo(c, c - r * 0.12)
                            ctx.lineTo(c, c + r * 0.52)
                            ctx.stroke()
                        }
                    }
                }
            }

            Label {
                visible: page.sameFamily && page.noticeOpen
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                text: "DeepL finds little to translate with " + page.familyName
                      + " on both sides: most words come back as written, spelling included. "
                      + "A single word is respelt here on the phone instead."
            }
        }

        // The split: what you type above, what comes back below.
        Item {
            id: split
            anchors.top: head.bottom
            anchors.bottom: status.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: Theme.paddingSmall

            readonly property real halfHeight: (height - Theme.paddingMedium) / 2

            Rectangle {
                id: inputCard
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: split.halfHeight
                radius: FiatGlossaTheme.cardRadius
                color: FiatGlossaTheme.card
                border.color: FiatGlossaTheme.cardBorder
                border.width: FiatGlossaTheme.cardBorderWidth

                Flickable {
                    anchors.fill: parent
                    anchors.margins: Theme.paddingMedium
                    contentHeight: input.height
                    clip: true

                    TextArea {
                        id: input
                        width: parent.width
                        backgroundStyle: TextEditor.NoBackground
                        placeholderText: "Write or paste text"
                        color: FiatGlossaTheme.primaryText
                    }
                }
            }

            Rectangle {
                anchors.top: inputCard.bottom
                anchors.topMargin: Theme.paddingMedium
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: split.halfHeight
                radius: FiatGlossaTheme.cardRadius
                color: FiatGlossaTheme.card
                border.color: FiatGlossaTheme.cardBorder
                border.width: FiatGlossaTheme.cardBorderWidth

                Flickable {
                    anchors.fill: parent
                    anchors.margins: Theme.paddingMedium
                    contentHeight: output.height
                    clip: true

                    TextArea {
                        id: output
                        width: parent.width
                        readOnly: true              // still selectable and copyable
                        backgroundStyle: TextEditor.NoBackground
                        text: glossa.translation
                        placeholderText: glossa.busy ? "" : "The translation appears here"
                        color: FiatGlossaTheme.primaryText
                        font.family: FiatGlossaTheme.serif
                    }
                }

                BusyIndicator {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.paddingLarge
                    size: BusyIndicatorSize.Small
                    running: glossa.busy
                }
            }
        }

        Label {
            id: status
            anchors.bottom: go.top
            anchors.bottomMargin: Theme.paddingSmall
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * Theme.horizontalPageMargin
            horizontalAlignment: Text.AlignHCenter
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            color: glossa.error !== "" ? FiatGlossaTheme.wrong : FiatGlossaTheme.secondaryText
            text: glossa.error !== "" ? glossa.error
                : glossa.local ? "Respelt on the phone. Nothing sent, nothing spent."
                : glossa.translation !== "" ? "via DeepL, " + glossa.billedCharacters + " characters"
                : !glossa.hasKey ? "No DeepL key yet. Settings, then How to get a key."
                : ""
        }

        // Deliberately a button and not translate-as-you-type: DeepL bills per
        // character, and retyping one sentence would spend it several times.
        Button {
            id: go
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Translate"
            enabled: input.text !== "" && !glossa.busy
            onClicked: page.translateNow()
        }
    }
}
