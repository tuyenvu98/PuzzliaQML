#include "imageprocessor.h"
#include <QImage>
ImageProcessor::ImageProcessor(QObject *parent)
    : QObject{parent}
{

}

QVector<QVector<int>> ImageProcessor::GetMap()
{
    return map;
}

bool ImageProcessor::Init(QString path)
{
    QImage photo(path);
    map.clear();
    if (photo.isNull())
        return false;
    photo = photo.convertToFormat(QImage::Format_Grayscale8);
    int downscaleFactor=photo.height()/9;
    float deviation=35;
    while(downscaleFactor>1)
    {
        int count=0;
        QVector<int> input;
        int height = photo.height() / downscaleFactor;
        int width= photo.width() / downscaleFactor;
        int sumCen = 0;
        for (int dy = 0; dy < downscaleFactor; ++dy) {
            for (int dx = 0; dx < downscaleFactor; ++dx) {
                QColor pixelColor(photo.pixel(photo.width()/2  + dx, photo.height()/2 + dy));
                sumCen += pixelColor.value();
            }
        }

        for (int y = 0; y < height; ++y)
        {
            for (int x = 0; x < width; ++x)
            {
                int sum=0;
                for (int dy = 0; dy < downscaleFactor; ++dy) {
                    for (int dx = 0; dx < downscaleFactor; ++dx) {
                        QColor pixelColor(photo.pixel(x * downscaleFactor + dx, y * downscaleFactor + dy));
                        sum += pixelColor.value();
                    }
                }

                if( abs(sumCen-sum)< (float)downscaleFactor* downscaleFactor*deviation)
                {
                    input.push_back(0);
                    count++;
                }
                else
                    input.push_back(-1);
            }
        }
        if(count<cellNum||deviation<5)
        {
            downscaleFactor--;
            continue;
        }
        if(count>cellNum)
        {
            deviation-=0.5;
            continue;
        }
        for (int i = 0; i < input.size(); i+=photo.width()/downscaleFactor)
        {
            QVector<int> tmp =input.mid(i, photo.width()/downscaleFactor);
            if(tmp.contains(0))
                map.push_back(tmp);
        }
        break;
    }
    if(map.isEmpty())
        return false;
    else
        return true;
}

void ImageProcessor::setTriangleMode(bool mode)
{
    if(mode)
        cellNum=55;
    else
        cellNum=60;
}
