import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."

// The house page header. Right-aligned title, optional line under it.
//
// Not Silica's PageHeader, which draws its title in Theme.highlightColor --
// light text on light paper under Fiat colours plus a dark ambience.
//
// The title HANGS FROM THE TOP of the band, it is not centred in it and it is
// not aligned from the bottom. That matters more than it sounds: with bottom
// alignment a page that has a second line pushes its title up, so every page
// sits at a slightly different height. Anchored to the top, every title in the
// app is on the same line whether or not anything follows it, and the header
// is only as tall as what it holds.
Item {
    id: root

    property string title: ""
    property string subtitle: ""

    width: parent ? parent.width : 0
    height: FiatGlossaTheme.headerTopInset + col.height + Theme.paddingLarge

    Column {
        id: col
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.top: parent.top
        anchors.topMargin: FiatGlossaTheme.headerTopInset
        width: parent.width - Theme.horizontalPageMargin * 2

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            truncationMode: TruncationMode.Fade
            text: root.title
            font.pixelSize: Theme.fontSizeLarge
            font.family: FiatGlossaTheme.serif
            font.italic: true
            color: FiatGlossaTheme.primaryText
        }

        Label {
            width: parent.width
            visible: root.subtitle !== ""
            horizontalAlignment: Text.AlignRight
            truncationMode: TruncationMode.Fade
            text: root.subtitle
            font.pixelSize: Theme.fontSizeExtraSmall
            color: FiatGlossaTheme.secondaryText
        }
    }
}
