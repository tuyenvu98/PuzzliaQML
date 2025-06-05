#ifndef BOARD_H
#define BOARD_H

#include <QObject>
#include <QMap>
#include <QSet>
#include <QMutex>
#include "imageprocessor.h"

class Board : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<QVector<int>> map READ getMap WRITE setMap NOTIFY mapChanged)
public:
    explicit Board(QObject *parent = nullptr);
    QVector<QVector<int>> getMap() const;
    void setActiveShapes(QSet<int> usedShapes);
    bool canPlaceShape( int shapeIndex,int rotation, int x, int y);
    void placeShape(int shapeIndex,int rotation, int row, int col);
    void fillMapRecursive();
    void setMap(QVector<QVector<int>>);
    void Reset();
    void init();
signals:
    void mapChanged(QString message);
public slots:
    void loadMap(QString fileName);
    void loadMapImage(QString path);
    void solve();
    void setRun();
    void viewResult();
    void resetMap();
    void setMapQML(QVector<QVector<int>>);
    void setMode(bool);
    QVector<int> getActiveShapes();
    void saveMap();
    void importMap(const QString&);
    QStringList getMapList();
    void cancel();
private:
    static QMutex resultMutex;
    QVector<QVector<int>> map;
    QVector<QVector<int>> startMap;
    QVector<QVector<QVector<int>>> result;
    QMap<int,QVector<QVector<int>>> tetrisShapes;
    ImageProcessor imageprocessor;
    QMap<int,QVector<QVector<int>>> rectangleShapes;
    QMap<int,QVector<QVector<int>>> triangleShapes;
    QMap<int,QVector<int>> rotationTypes;
    QMap<int,QVector<QVector<int>>> activeShapes;
    QStringList mapList;
    bool run;
    bool cancelled;
    QSet<int>  unavailableIndex;
    bool triangleMode;
};

#endif // BOARD_H
