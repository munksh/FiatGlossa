import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."

CoverBackground {
    id: cover

    // ---- paper ----

    Rectangle {
        anchors.fill: parent
        visible: !FiatGlossaTheme.ambient
        gradient: Gradient {
            GradientStop { position: 0.0; color: FiatGlossaTheme.backgroundHigh }
            GradientStop { position: 1.0; color: FiatGlossaTheme.backgroundLow }
        }
    }

    // ---- wordmark ----

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: FiatGlossaTheme.coverWordmarkTop
        text: "fiat glossa"
        color: FiatGlossaTheme.secondaryText
        font.pixelSize: Theme.fontSizeTiny
        font.family: FiatGlossaTheme.serif
        font.italic: true
    }

    // ---- figure ----

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: FiatGlossaTheme.coverSideMargin
        anchors.rightMargin: FiatGlossaTheme.coverSideMargin
        anchors.topMargin: cover.height * FiatGlossaTheme.coverFigureFraction
        spacing: Theme.paddingSmall

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            // The C++ backend's result wins; otherwise the worker output the
            // page published via the theme channel; a quiet "Aa" when empty.
            readonly property string figure:
                glossa.translation !== "" ? glossa.translation : FiatGlossaTheme.coverText
            text: figure !== "" ? figure : "Aa"
            color: FiatGlossaTheme.accent
            font.family: FiatGlossaTheme.serif
            font.pixelSize: figure !== "" ? Theme.fontSizeMedium
                                          : FiatGlossaTheme.coverFigureSize
            wrapMode: Text.Wrap
            maximumLineCount: 5
            elide: Text.ElideRight
        }
    }
}
