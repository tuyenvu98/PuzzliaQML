#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <QObject>

class ImageProcessor : public QObject
{
    Q_OBJECT
public:
    explicit ImageProcessor(QObject *parent = nullptr);
    QVector<QVector<int>> GetMap();
    bool Init(QString path);
    void setTriangleMode(bool);
private:
    QVector<QVector<int>> map;
    int cellNum=60;
signals:

};

#endif // IMAGEPROCESSOR_H
