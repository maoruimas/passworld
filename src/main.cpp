#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QQuickStyle>
#include <QTranslator>
#include "backend.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/fonts/fontello.ttf");
    int fontId = QFontDatabase::addApplicationFont(":/fonts/wqywmh.ttf");
    QGuiApplication::setFont(QFont(QFontDatabase::applicationFontFamilies(fontId).at(0)));

    QTranslator translator;
    translator.load(":/zh_CN.qm");
    app.installTranslator(&translator);

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;
    Backend backend;
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("fontFamily", QFontDatabase::applicationFontFamilies(fontId).at(0));

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
