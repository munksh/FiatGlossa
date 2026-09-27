import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import ".."
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    readonly property string communityServer:
        "https://ts.poetaster.de/v1/engines/nllb200_3.3B"

    property bool ready: false

    function paint() {
        FiatGlossaTheme.applyPalette(page)
    }

    function providerIndex() {
        if (providerConfig.value === "community")
            return 1
        if (providerConfig.value === "custom")
            return 2

        // Recognize settings saved before the provider picker existed.
        if (providerConfig.value === "") {
            if (tsServerConfig.value === communityServer)
                return 1
            if (tsServerConfig.value !== "")
                return 2
        }

        return 0
    }

    function selectProvider(index) {
        if (!ready)
            return

        if (index === 0) {
            providerConfig.value = "deepl"
            tsServerConfig.value = ""
        } else if (index === 1) {
            providerConfig.value = "community"
            tsServerConfig.value = communityServer
        } else {
            providerConfig.value = "custom"
            tsServerConfig.value = customServerField.text.trim()
        }
    }

    function save() {
        if (!ready)
            return

        apiKeyConfig.value = keyField.text.trim()

        if (providerPicker.currentIndex === 0) {
            providerConfig.value = "deepl"
            tsServerConfig.value = ""
        } else if (providerPicker.currentIndex === 1) {
            providerConfig.value = "community"
            tsServerConfig.value = communityServer
        } else {
            providerConfig.value = "custom"
            customServerConfig.value = customServerField.text.trim()
            tsServerConfig.value = customServerField.text.trim()
        }
    }

    Component.onCompleted: {
        paint()
        providerPicker.currentIndex = providerIndex()
        ready = true
        selectProvider(providerPicker.currentIndex)
    }

    Connections {
        target: FiatGlossaTheme
        onAmbientChanged: page.paint()
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating)
            save()
    }

    ConfigurationValue {
        id: providerConfig
        key: "/apps/harbour-fiatglossa/provider"
        defaultValue: ""
    }

    ConfigurationValue {
        id: apiKeyConfig
        key: "/apps/harbour-fiatglossa/apikey"
        defaultValue: ""
    }

    ConfigurationValue {
        id: tsServerConfig
        key: "/apps/harbour-fiatglossa/tsserver"
        defaultValue: ""
    }

    ConfigurationValue {
        id: customServerConfig
        key: "/apps/harbour-fiatglossa/customTsServer"
        defaultValue: ""
    }

    Background { }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: "About"
                color: FiatGlossaTheme.primaryText
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: "Check the DeepL key"
                color: FiatGlossaTheme.primaryText
                visible: providerPicker.currentIndex === 0
                enabled: keyField.text.trim() !== ""
                onClicked: {
                    page.save()
                    glossa.refreshUsage()
                }
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHead { title: "settings" }

            Rectangle {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: providerPicker.height
                radius: Theme.paddingMedium
                color: FiatGlossaTheme.recessFill
                border.color: FiatGlossaTheme.accent
                border.width: 1

                ComboBox {
                    id: providerPicker
                    width: parent.width
                    label: "Translation service"
                    valueColor: "transparent"

                    menu: ContextMenu {
                        MenuItem { text: "DeepL" }
                        MenuItem { text: "Community server" }
                        MenuItem { text: "My own TextSynth server" }
                    }

                    onCurrentIndexChanged: page.selectProvider(currentIndex)
                }

                Row {
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingLarge
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    spacing: Theme.paddingSmall

                    Label {
                        text: providerPicker.currentIndex === 0
                              ? "DeepL"
                              : providerPicker.currentIndex === 1
                                ? "Community server"
                                : "Own server"
                        color: FiatGlossaTheme.accent
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                    }

                    Label {
                        text: "▼"
                        color: FiatGlossaTheme.accent
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            Label {
                visible: providerPicker.currentIndex === 0
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: FiatGlossaTheme.secondaryText
                font.pixelSize: Theme.fontSizeSmall
                text: "DeepL is fast and requires your own API key. Text is sent to DeepL for translation."
            }

            TextField {
                id: keyField
                visible: providerPicker.currentIndex === 0
                width: parent.width
                label: "DeepL API key"
                placeholderText: "Paste the key here"
                text: apiKeyConfig.value
                inputMethodHints: Qt.ImhNoAutoUppercase
                                  | Qt.ImhNoPredictiveText
                                  | Qt.ImhSensitiveData

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                    page.save()
                    glossa.refreshUsage()
                }
            }

            Rectangle {
                visible: providerPicker.currentIndex === 0
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: visible ? usage.height + Theme.paddingLarge : 0
                radius: Theme.paddingMedium
                color: FiatGlossaTheme.recessFill
                border.color: FiatGlossaTheme.recessBorder
                border.width: 1

                Label {
                    id: usage
                    anchors.centerIn: parent
                    width: parent.width - 2 * Theme.paddingLarge
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: FiatGlossaTheme.primaryText
                    font.pixelSize: Theme.fontSizeSmall
                    text: !glossa.hasKey
                          ? "No key yet"
                          : !glossa.usageKnown
                            ? "Key not checked yet"
                            : glossa.characterLimit > 0
                              ? glossa.charactersUsed + " of "
                                + glossa.characterLimit + " characters used"
                              : glossa.charactersUsed + " characters used"
                }
            }

            Label {
                visible: providerPicker.currentIndex === 0
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: FiatGlossaTheme.secondaryText
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "Your key is stored unencrypted in the phone's settings. Fiat Glossa has no DeepL account of its own."
            }

            Button {
                visible: providerPicker.currentIndex === 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: "How to get a DeepL key"
                onClicked: pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
            }

            Label {
                visible: providerPicker.currentIndex === 1
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: FiatGlossaTheme.primaryText
                font.pixelSize: Theme.fontSizeMedium
                text: "Poetaster's community server"
            }

            Label {
                visible: providerPicker.currentIndex === 1
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: FiatGlossaTheme.secondaryText
                font.pixelSize: Theme.fontSizeSmall
                text: "No account or API key is required. The service is temporarily provided by Poetaster and may be slower, unavailable or discontinued. Text is sent to this community server for translation."
            }

            Label {
                visible: providerPicker.currentIndex === 1
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: FiatGlossaTheme.secondaryText
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "The server address is managed by Fiat Glossa and does not need to be entered here."
            }

            Button {
                visible: providerPicker.currentIndex === 1
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Donate to Poetaster"
                onClicked: Qt.openUrlExternally("https://liberapay.com/poetaster")
            }

            Label {
                visible: providerPicker.currentIndex === 2
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: FiatGlossaTheme.secondaryText
                font.pixelSize: Theme.fontSizeSmall
                text: "Use a compatible TextSynth server operated by you or someone you trust."
            }

            TextField {
                id: customServerField
                visible: providerPicker.currentIndex === 2
                width: parent.width
                label: "TextSynth engine URL"
                placeholderText: "https://example.org/v1/engines/model"
                text: customServerConfig.value
                inputMethodHints: Qt.ImhUrlCharactersOnly
                                  | Qt.ImhNoAutoUppercase
                                  | Qt.ImhNoPredictiveText

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                    page.save()
                }
            }

            Label {
                visible: providerPicker.currentIndex === 2
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: FiatGlossaTheme.secondaryText
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "Enter the engine URL without /translate or a trailing slash. Fiat Glossa adds the translation route automatically."
            }

            Button {
                visible: providerPicker.currentIndex === 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: "TextSynth server manual"
                onClicked: Qt.openUrlExternally("https://ts.poetaster.de/ts_server.html")
            }
        }

        VerticalScrollDecorator { }
    }
}
