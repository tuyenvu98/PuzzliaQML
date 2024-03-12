#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QQmlContext>
#include <QDebug>
#include <QIcon>
#include <QDir>
#include "board.h"
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    QGuiApplication::setWindowIcon(QIcon(":image/icons/windowIcon.ico"));
    QQmlApplicationEngine engine;
    Board board;
    engine.rootContext()->setContextProperty("board", &board);
#ifdef Q_OS_ANDROID
    engine.rootContext()->setContextProperty("platform", "Android");
#else
    engine.rootContext()->setContextProperty("platform", "PC");
#endif
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    board.init();

    return app.exec();
}
