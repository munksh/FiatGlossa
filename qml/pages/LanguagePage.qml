import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"

// The language list, pushed from one of the two pickers on the main page.
//
// A page rather than a menu: there are 36 entries with variants, and an inline
// menu that long either runs off the screen or squashes the translation view
// it opened from. Here the list gets the whole screen and a search field, so
// Swedish is two keystrokes rather than thirty rows of scrolling.

Page {
    id: page
    allowedOrientations: Orientation.All

    // Set by the caller. The list carries each entry's index in the ORIGINAL
    // array, so filtering never changes what a row means.
    property var languages: []
    property int currentIndex: -1
    property string heading: ""

    signal selected(int index)

    property var shown: []

    function paint() { FiatGlossaTheme.applyPalette(page) }

    Component.onCompleted: {
        paint()
        refilter()
    }

    Connections {
        target: FiatGlossaTheme
        onAmbientChanged: page.paint()
    }

    function refilter() {
        var q = search.text.toLowerCase()
        var out = []
        for (var i = 0; i < languages.length; ++i) {
            var l = languages[i]
            if (q === ""
                || l.name.toLowerCase().indexOf(q) >= 0
                || l.code.toLowerCase().indexOf(q) >= 0)
                out.push({ name: l.name, code: l.code, index: i })
        }
        shown = out
    }

    Background { }

    // Glossa's PageHead takes a title and nothing else, so the direction goes
    // in the title rather than in a subtitle the component does not have.
    PageHead {
        id: head
        title: page.heading
    }

    // Outside the list rather than in its header: a SearchField in a header
    // loses focus every time the model is replaced, which is on every
    // keystroke here.
    SearchField {
        id: search
        anchors.top: head.bottom
        width: parent.width
        placeholderText: qsTr("Search")
        onTextChanged: page.refilter()
    }

    SilicaListView {
        id: list
        anchors.top: search.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        clip: true

        model: page.shown

        delegate: BackgroundItem {
            width: list.width
            height: Theme.itemSizeSmall
            highlightedColor: FiatGlossaTheme.highlightWash
            onClicked: {
                page.selected(modelData.index)
                pageStack.pop()
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.horizontalPageMargin * 2 - code.width - Theme.paddingMedium
                truncationMode: TruncationMode.Fade
                text: modelData.name
                font.pixelSize: Theme.fontSizeSmall
                color: modelData.index === page.currentIndex
                       ? FiatGlossaTheme.accent
                       : FiatGlossaTheme.primaryText
            }

            Label {
                id: code
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.code
                font.pixelSize: Theme.fontSizeExtraSmall
                color: FiatGlossaTheme.secondaryText
            }
        }

        ViewPlaceholder {
            enabled: page.shown.length === 0
            text: qsTr("No language by that name")
        }

        VerticalScrollDecorator { }
    }
}
