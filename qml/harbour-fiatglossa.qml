import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "."
import "pages"

ApplicationWindow {
    id: app
    initialPage: Component { MainTranslationPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    // Necessary but not sufficient: a page pushed after the switch is thrown
    // carries the old palette, so every page paints itself as well.
    Component.onCompleted: FiatGlossaTheme.applyPalette(app)
    Connections {
        target: FiatGlossaTheme
        onAmbientChanged: FiatGlossaTheme.applyPalette(app)
    }

    // The key lives here and is handed to the backend. SettingsPage writes the
    // same key; dconf tells this value when it changes.
    ConfigurationValue {
        id: apiKeyConfig
        key: "/apps/harbour-fiatglossa/apikey"
        defaultValue: ""
    }
    // ts_server server api url config
    ConfigurationValue {
        id:tsServerConfig
        key: "/apps/harbour-fiatglossa/tsserver"
        defaultValue: ""
    }
    Binding { target: glossa; property: "apiKey"; value: apiKeyConfig.value }
    Binding { target: glossa; property: "tsServer"; value: tsServerConfig.value }
}
