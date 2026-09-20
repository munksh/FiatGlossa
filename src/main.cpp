#include <QtQuick>
#include <sailfishapp.h>

#include "translator.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    // Declared before the view so it outlives the QML that binds to it.
    Translator translator;

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    // A context property, not qmlRegisterType: the cover is loaded by URL and
    // cannot see ids from the root QML, so this is how page and cover share
    // one instance.
    view->rootContext()->setContextProperty(QStringLiteral("glossa"), &translator);

    // The About page reads this as appVersion. Without it the page's guard
    // falls through to "unknown" -- correctly, because appVersion really is
    // undefined until someone hands it over. Set before setSource(): the QML
    // reads it at load time, not later.
    //
    // fromUtf8 rather than QStringLiteral(APP_VERSION): APP_VERSION only
    // exists once qmake's DEFINES substitutes it in, so this has to be a
    // plain runtime call rather than a literal the build step rewrites.
    view->rootContext()->setContextProperty(QStringLiteral("appVersion"), QString::fromUtf8(APP_VERSION));

    view->setSource(SailfishApp::pathTo(QStringLiteral("qml/harbour-fiatglossa.qml")));
    view->show();

    return app->exec();
}
