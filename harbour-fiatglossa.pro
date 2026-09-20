TARGET = harbour-fiatglossa

CONFIG += sailfishapp c++11
QT += network

SOURCES += \
    src/main.cpp \
    src/translator.cpp \
    src/spelling.cpp

HEADERS += \
    src/translator.h \
    src/spelling.h

DISTFILES += \
    qml/harbour-fiatglossa.qml \
    qml/qmldir \
    qml/FiatGlossaTheme.qml \
    qml/components/Background.qml \
    qml/components/PageHead.qml \
    qml/components/MunkstolenMark.qml \
    qml/components/SectionLabel.qml \
    qml/components/Wordmark.qml \
    qml/cover/CoverPage.qml \
    qml/images/family/harbour-fiatagenda.png \
    qml/images/family/harbour-fiatmargo.png \
    qml/images/family/harbour-fiatglossa.png \
    qml/images/family/harbour-fiatvox.png \
    qml/images/family/harbour-fiatpons.png \
    qml/images/family/harbour-fiatlux.png \
    qml/images/family/harbour-fiatcor.png \
    qml/images/family/harbour-fiatpassus.png \
    qml/images/family/harbour-fiatmos.png \
    qml/pages/MainTranslationPage.qml \
    qml/pages/LanguagePage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/HelpPage.qml \
    qml/pages/AboutPage.qml \
    rpm/harbour-fiatglossa.spec \
    harbour-fiatglossa.desktop \
    README.md

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

REQUIRED_FILES = \
    $${TARGET}.desktop \
    qml/$${TARGET}.qml \
    qml/qmldir \
    qml/FiatGlossaTheme.qml \
    qml/components/Background.qml \
    qml/components/PageHead.qml \
    qml/components/Wordmark.qml \
    qml/pages/MainTranslationPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/HelpPage.qml \
    qml/pages/AboutPage.qml \
    qml/cover/CoverPage.qml \
    icons/86x86/$${TARGET}.png \
    icons/172x172/$${TARGET}.png

for(f, REQUIRED_FILES) {
    !exists($$PWD/$$f): error("Missing $$f -- expected it at $$PWD/$$f")
}

isEmpty(APP_VERSION) {
    APP_VERSION = 0.0.0-dev
}
DEFINES += APP_VERSION=\\\"$$APP_VERSION\\\"
