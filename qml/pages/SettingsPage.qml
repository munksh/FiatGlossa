import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
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

    // Same key as the root file; dconf carries the change to the backend.
    ConfigurationValue {
        id: apiKeyConfig
        key: "/apps/harbour-fiatglossa/apikey"
        defaultValue: ""
    }
    ConfigurationValue {
        id: tsServerConfig
        key: "/apps/harbour-fiatglossa/tsserver"
        defaultValue: "https://ts.poetaster.de/v1/engines/nllb200_3.3B_q8"
    }
    function save() {
        apiKeyConfig.value = keyField.text.trim()
        tsServerConfig.value  = tsServerField.text.trim()
    }

    // Swiping back does not always take focus from a field first, so save on
    // the way out as well.
    onStatusChanged: if (status === PageStatus.Deactivating) save()

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
                text: "How to get a key"
                color: FiatGlossaTheme.primaryText
                onClicked: pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
            }
            MenuItem {
                text: "Check the key"
                color: FiatGlossaTheme.primaryText
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

            TextField {
                id: keyField
                width: parent.width
                label: "DeepL API key"
                placeholderText: "paste the key here"
                text: apiKeyConfig.value
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                    page.save()
                    glossa.refreshUsage()
                }
            }
            TextField {
                id: tsServerField
                width: parent.width
                label: "A ts_server URL"
                placeholderText: "https://ts.poetaster.de/v1/engines/nllb200_3.3B"
                text: tsServerConfig.value
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                    tsServerConfig.value  = tsServerField.text.trim()
                }
            }
            // A well, not a card: this is a readout.
            Rectangle {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: usage.height + Theme.paddingLarge
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
                              ? glossa.charactersUsed + " of " + glossa.characterLimit + " characters used"
                              : glossa.charactersUsed + " characters used"
                }

            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
                text: "The key is yours, not the app's: fiat glossa has no account and no server of its "
                    + "own. It is kept unencrypted in the phone's settings, like a wifi password. "
                    + "Translating between the two Englishes never touches DeepL at all."
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "How to get a key"
                onClicked: pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
            }
        }

        VerticalScrollDecorator { }
    }
}
