import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    function paint() { FiatGlossaTheme.applyPalette(page) }
    Component.onCompleted: paint()
    Connections {
        target: FiatGlossaTheme
        onAmbientChanged: page.paint()
    }

    Background { }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            PageHead {
                title: qsTr("about")
                subtitle: "fiat glossa"
            }

            // -- What it is -----------------------------------------------

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeMedium
                font.family: FiatGlossaTheme.serif
                color: FiatGlossaTheme.primaryText
                text: qsTr("Glossa is the tongue, and a gloss is what someone wrote in the margin when the word was hard.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                text: qsTr("Translations come from DeepL, with a key that belongs to you. fiat glossa has no server and no account: your text goes from the phone to DeepL and nowhere else.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                text: qsTr("English (Traditional) against English (Simplified) is settled on the phone, from a word table, with no request and no characters spent. It is a joke that happens to be the fastest path in the app.")
            }

            // -- The name --------------------------------------------------

            SectionLabel {
                x: Theme.horizontalPageMargin
                text: qsTr("The name")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                textFormat: Text.StyledText
                linkColor: FiatGlossaTheme.accent
                text: qsTr("<b>fiat</b> — Latin, <i>let there be</i>. From <i>fiat lux</i> in the Vulgate: let there be light, and there was light. The first app took the phrase. The rest of the family kept the verb.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                textFormat: Text.StyledText
                text: qsTr("<b>glossa</b> — Latin, from the Greek <i>glōssa</i>, <i>tongue</i>. A gloss is the word written in the margin to explain the hard one in the text. This app is a small, modern gloss.")
            }

            // -- The motto -------------------------------------------------

            Item { width: 1; height: Theme.paddingMedium }

            Rectangle {
                x: Theme.horizontalPageMargin
                width: content.width - Theme.horizontalPageMargin * 2
                height: mottoColumn.height + Theme.paddingLarge * 2
                radius: FiatGlossaTheme.cardRadius
                color: FiatGlossaTheme.card
                border.color: FiatGlossaTheme.cardBorder
                border.width: FiatGlossaTheme.cardBorderWidth

                Column {
                    id: mottoColumn
                    anchors.centerIn: parent
                    width: parent.width - Theme.paddingLarge * 2
                    spacing: Theme.paddingSmall

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: FiatGlossaTheme.serif
                        font.italic: true
                        color: FiatGlossaTheme.primaryText
                        text: "Non verbum e verbo,\nsed sensum exprimere de sensu"
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: FiatGlossaTheme.secondaryText
                        text: qsTr("Not word for word, but sense for sense.")
                    }

                    Label {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.fontSizeTiny
                        color: FiatGlossaTheme.secondaryText
                        text: "Jerome, Epistula 57.5"
                    }
                }
            }

            // -- Privacy ---------------------------------------------------

            SectionLabel {
                x: Theme.horizontalPageMargin
                text: qsTr("Your data")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                text: qsTr("There is no account and no server of ours. Text you translate travels from this phone straight to DeepL, using a key that belongs to you, and nowhere else.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                text: qsTr("Nothing is measured or reported. The only things kept between sessions are your DeepL key and your last-used languages.")
            }

            // -- Who ---------------------------------------------------------

            SectionLabel {
                x: Theme.horizontalPageMargin
                text: qsTr("Made by")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                font.pixelSize: Theme.fontSizeMedium
                font.family: FiatGlossaTheme.serif
                color: FiatGlossaTheme.primaryText
                text: "Munkstolen"
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                text: "Caesar Prometheus Ivarsson"
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                highlightedColor: FiatGlossaTheme.highlightWash
                onClicked: Qt.openUrlExternally("https://munkstolen.se")

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.horizontalPageMargin
                    width: parent.width - Theme.horizontalPageMargin * 2

                    Label {
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        color: FiatGlossaTheme.accent
                        font.pixelSize: Theme.fontSizeSmall
                        text: "munkstolen.se"
                    }

                    Label {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: FiatGlossaTheme.secondaryText
                        text: qsTr("Everything else I make")
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                highlightedColor: FiatGlossaTheme.highlightWash
                onClicked: Qt.openUrlExternally("https://github.com/munksh/FiatGlossa")

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.horizontalPageMargin
                    width: parent.width - Theme.horizontalPageMargin * 2

                    Label {
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        color: FiatGlossaTheme.accent
                        font.pixelSize: Theme.fontSizeSmall
                        text: "github.com/munksh/FiatGlossa"
                    }

                    Label {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: FiatGlossaTheme.secondaryText
                        text: qsTr("Source and issues · MIT licence")
                    }
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeTiny
                color: FiatGlossaTheme.secondaryText
                text: qsTr("DeepL is a trademark of DeepL SE, which has nothing to do with this app.")
            }

            // -- The family ---------------------------------------------------

            SectionLabel {
                x: Theme.horizontalPageMargin
                text: qsTr("The fiat family")
            }

            Repeater {
                model: [
                    { name: "fiat agenda", what: qsTr("let there be doing — a task list"), icon: "images/family/harbour-fiatagenda.png", url: "https://openrepos.net/content/munkstolen/fiat-agenda-task-list" },
                    { name: "fiat margo", what: qsTr("let there be edge — keeps edges"), icon: "images/family/harbour-fiatmargo.png", url: "https://openrepos.net/content/munkstolen/fiat-margo-keeps-edges" },
                    { name: "fiat glossa", what: qsTr("let there be tongue — this one"), icon: "images/family/harbour-fiatglossa.png", url: "" },
                    { name: "fiat vox", what: qsTr("let there be voice — a chromatic tuner"), icon: "images/family/harbour-fiatvox.png", url: "https://openrepos.net/content/munkstolen/fiat-vox-chromatic-tuner" },
                    { name: "fiat pons", what: qsTr("let there be bridge — a native Qobuz client"), icon: "images/family/harbour-fiatpons.png", url: "https://openrepos.net/content/munkstolen/fiat-pons-native-qobuz-client" },
                    { name: "fiat lux", what: qsTr("let there be light — a light meter for film - Coming soon"), icon: "images/family/harbour-fiatlux.png", url: "" },
                    { name: "fiat cor", what: qsTr("let there be heart — a metronome"), icon: "images/family/harbour-fiatcor.png", url: "https://openrepos.net/content/munkstolen/fiat-cor-a-metronome" },
                    { name: "fiat passus", what: qsTr("let there be step — a step counter - Coming soon"), icon: "images/family/harbour-fiatpassus.png", url: "" },
                    { name: "fiat mos", what: qsTr("let there be habit — a habit tracker"), icon: "images/family/harbour-fiatmos.png", url: "https://openrepos.net/content/munkstolen/fiat-mos-habit-tracker" }
                ]

                delegate: BackgroundItem {
                    id: familyRow
                    x: Theme.horizontalPageMargin
                    width: content.width - Theme.horizontalPageMargin * 2
                    height: familyText.height
                    enabled: modelData.url !== ""
                    highlightedColor: FiatGlossaTheme.highlightWash
                    onClicked: Qt.openUrlExternally(modelData.url)

                    // A cap, not a measurement of familyText: sizing the icon
                    // from the text's height while the text's width comes
                    // from the icon's width would make each depend on the
                    // other, and QML gives no guarantee a loop like that
                    // settles. Every "what" line here is one short sentence,
                    // so in practice this cap and the real name+what height
                    // match; if one ever wraps past it the icon just stops
                    // growing with it instead of the layout misbehaving.
                    readonly property real iconSlot: Theme.itemSizeSmall

                    Image {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(familyText.height, familyRow.iconSlot)
                        height: width
                        source: Qt.resolvedUrl(modelData.icon)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        opacity: modelData.url !== "" ? 1.0 : 0.55
                    }

                    Column {
                        id: familyText
                        anchors.left: parent.left
                        anchors.leftMargin: familyRow.iconSlot + Theme.paddingMedium
                        anchors.right: parent.right

                        Label {
                            width: parent.width
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: FiatGlossaTheme.serif
                            color: modelData.url !== "" ? FiatGlossaTheme.accent : FiatGlossaTheme.primaryText
                            text: modelData.name
                        }

                        Label {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: FiatGlossaTheme.secondaryText
                            text: modelData.what
                        }
                    }
                }
            }

            Item { width: 1; height: Theme.paddingMedium }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeTiny
                color: FiatGlossaTheme.secondaryText
                text: qsTr("Small instruments that each do one thing and leave the rest alone. They share a look, a palette and a stubbornness about staying on your own phone.")
            }

            // -- Version ---------------------------------------------------

            SectionLabel {
                x: Theme.horizontalPageMargin
                text: qsTr("Version")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                font.pixelSize: Theme.fontSizeSmall
                color: FiatGlossaTheme.primaryText
                text: typeof appVersion !== "undefined" ? appVersion : qsTr("unknown")
            }

            // -- Colophon --------------------------------------------------

            Item { width: 1; height: Theme.itemSizeExtraSmall }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.itemSizeSmall
                height: 1
                color: FiatGlossaTheme.innerBorder
            }

            Item { width: 1; height: Theme.paddingLarge }

            MunkstolenMark {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.itemSizeMedium
                frame: "ring"
                color: FiatGlossaTheme.makerMark
            }

            Item { width: 1; height: Theme.paddingSmall }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "munkstolen"
                font.pixelSize: Theme.fontSizeSmall
                font.family: FiatGlossaTheme.serif
                font.italic: true
                color: FiatGlossaTheme.makerMark
            }
        }

        VerticalScrollDecorator { }
    }
}
