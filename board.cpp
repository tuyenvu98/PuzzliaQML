#include "board.h"
#include <qDebug>
#include <qFile>
#include <QCoreApplication>
#include <QTime>
#include <QtConcurrent>

QMutex Board::resultMutex;

Board::Board(QObject *parent)
    : QObject{parent}
{
    rectangleShapes = {
        {3,{{0,1},{0,1},{0,1},{1,1}}},
        {4,{{1,0},{1,0},{1,1},{1,0}}},
        {5,{{0,1},{0,1},{1,1},{1,0}}},
        {6,{{0,0,1},{0,0,1},{1,1,1}}},
        {7,{{1,1},{1,0},{1,1}}},
        {8,{{0,0,1},{0,1,1},{1,1,0}}},
        {9,{{0,1,0},{1,1,1},{0,1,0}}},
        {10,{{1,1,1},{1,1,0}}},
        {13,{{0,0,1},{1,1,1},{1,0,0}}},
        {14,{{0,1,0},{0,1,1},{1,1,0}}},
        {15,{{0,1,0},{0,1,0},{1,1,1}}},
        {16,{{1},{1},{1},{1},{1}}}
    };
    triangleShapes = {
        {1,{{0,1},{1,1}}},
        {2,{{0,1},{0,1},{1,1}}},
        {3,{{0,1},{0,1},{0,1},{1,1}}},
        {4,{{1,0},{1,0},{1,1},{1,0}}},
        {5,{{0,1},{0,1},{1,1},{1,0}}},
        {6,{{0,0,1},{0,0,1},{1,1,1}}},
        {7,{{1,1},{1,0},{1,1}}},
        {8,{{0,0,1},{0,1,1},{1,1,0}}},
        {9,{{0,1,0},{1,1,1},{0,1,0}}},
        {10,{{1,1,1},{1,1,0}}},
        {11,{{1,1},{1,1}}},
        {12,{{1},{1},{1},{1}}}
    };
    rotationTypes={
       {1,{0,1,2,3}},
       {2,{0,1,2,3,4,5,6,7}},
       {3,{0,1,2,3,4,5,6,7}},
       {4,{0,1,2,3,4,5,6,7}},
       {5,{0,1,2,3,4,5,6,7}},
       {6,{0,1,2,3}},
       {7,{0,1,2,3}},
       {8,{0,1,2,3}},
       {9,{0}},
       {10,{0,1,2,3,4,5,6,7}},
       {11,{0}},
       {12,{0}},
       {13,{0,1,4,5}},
       {14,{0,1,2,3,4,5,6,7}},
       {15,{0,1,2,3}},
       {16,{0,1}},
    };
    run=true;
    triangleMode=false;
    cancelled=false;

    QDir exDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    QStringList fileList = exDir.entryList(QDir::Files);
    QDir inDir(":/text/maps");
    fileList += inDir.entryList(QDir::Files);
    foreach (QString name, fileList)
        mapList.append(name.replace(".txt",""));
}
void Board::init()
{
    int rows = triangleMode ? 10:6 ;
    int cols = 10;
    QVector<QVector<int>> defaultMap(rows, QVector<int>(cols, 0));
    if(triangleMode)
    {
        tetrisShapes = triangleShapes;
        for (int i = 0; i < rows; ++i) {
            for (int j = i+1; j < cols; ++j) {
                defaultMap[i][j] = -1;
            }
        }
    }
    else
        tetrisShapes = rectangleShapes;
    activeShapes = tetrisShapes;
    setMap(defaultMap);
}
QVector<QVector<int>> rotateShape(QVector<QVector<int>> shape) {
    int rows = shape.size();
    int cols = shape[0].size();

    QVector<QVector<int>> rotatedShape(cols, QVector<int>(rows, 0));

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            rotatedShape[j][rows - i - 1] = shape[i][j];
        }
    }
    return rotatedShape;
}

QVector<QVector<int>> rotateShapeNTimes(QVector<QVector<int>> shape,int rotation) {
    QVector<QVector<int>> rotatedShape = shape;
    for (int r = 0; r < rotation; ++r) {
        // Rotate the shape
        rotatedShape = rotateShape(rotatedShape);
    }
    return rotatedShape;
}

QVector<QVector<int>> reverseShape( QVector<QVector<int>>& shape) {
    QVector<QVector<int>> reversedShape = shape;

    for (QVector<int>& row : reversedShape) {
        std::reverse(row.begin(), row.end());
    }

    return reversedShape;
}

void Board::Reset()
{
    map.clear();
    result.clear();
    unavailableIndex.clear();
    imageprocessor.setTriangleMode(triangleMode);
    cancelled=false;
}

void Board::resetMap()
{
    Reset();
    init();
}

void Board::loadMap(QString fileName)
{
    Reset();
    QString fullFileName;
    if(fileName.contains("#"))
        fullFileName=QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)+"/"+fileName;
    else
        fullFileName=":/text/maps/"+fileName;
    QFile input(fullFileName);
    if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Failed to open the file:" << input.errorString();
        emit mapChanged("Failed to open the input file \n");
        return ;
    }
    QSet<int> usedShape;
    QTextStream in(&input);
    while (!in.atEnd()) {
        QString line = in.readLine();
        QStringList row = line.split(',');
        QVector<int> intVector;
        foreach(QString str, row)
        {
            bool ok;
            int intValue = str.toInt(&ok);
            if (ok) {
                if(intValue >16)
                {
                    qDebug() << "There is no shape with number " << str;
                    emit mapChanged("Failed: There is no shape with number " + str+ "\n");
                    return;
                }
                /*if(intValue<0 && !triangleMode)
                {
                    emit mapChanged("Failed:Input is not the same shape \nwith mode!");
                    return;
                }*/
                intVector.append(intValue);
                usedShape.insert(intValue);
            } else {
                qDebug() << "Failed to convert string to integer:" << str;
                emit mapChanged("Failed to convert string to integer:" + str +"\n");
                return;
            }
        }
        if(map.size() >0 && map[0].size()!=intVector.size())
        {
            qDebug() << "Different numbers of element in rows. Check input file again";
            emit mapChanged("Failed: Different numbers of element in rows. Check input file again \n");
            return ;
        }

        map.push_back(intVector);
    }
    input.close();
    /*int rotation = 0;
    int tl=0;
    int tr=0;
    int br = 0;
    int bl = 0;
    int rows= map.size();
    int cols= map[0].size();
    for(int i=0;i< rows;i++)
    {
        for(int j=0;j< cols;j++)
        {
            if(map[i][j]!=0)
            {
                if(i<rows/2)
                {
                    if(j<cols/2)
                        tl++;
                    else
                        tr++;
                }
                else
                {
                    if(j<cols/2)
                        bl++;
                    else
                        br++;
                }
            }
        }
    }
    int max = qMax(tl,qMax(tr,qMax(br,bl)));
    if(tr==max)
        rotation=3;
    else if(br==max)
        rotation=2;
    else if(bl==max)
        rotation=1;
    map = rotateShapeNTimes(map,rotation);*/

    setActiveShapes(usedShape);
    emit mapChanged("Loaded map \n");
}

void Board::loadMapImage(QString path)
{
    if(imageprocessor.Init(path))
    {
        Reset();
        activeShapes=tetrisShapes;
        map=imageprocessor.GetMap();
        emit mapChanged("Loaded map from image. \n");
    }
    else
        emit mapChanged("Failed to load image.\n");
}

QVector<int> Board::getActiveShapes()
{
    return activeShapes.keys();
}

void Board::setActiveShapes(QSet<int> usedShapes)
{
    activeShapes.clear();
    for (auto it = tetrisShapes.constBegin(); it != tetrisShapes.constEnd(); ++it)
    {
        if(usedShapes.contains(it.key()))
            continue;

        activeShapes.insert(it.key() ,it.value());
    }
}

void Board::saveMap()
{
    //QString writablePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString writablePath="/home/images/";
    QDir().mkpath(writablePath);
    QString inputFile =writablePath+"/#Saved.txt";
    QFile input(inputFile);
    if (!input.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Failed to open the file:" << input.errorString();
        emit mapChanged("Failed to open the input file \n");
        return ;
    }
    QTextStream out(&input);
    foreach(auto row,map)
    {
        QString tmp;
        foreach(auto element,row)
            tmp+=QString::number(element)+",";
        tmp.chop(1);
        out << tmp <<"\n";
    }
    input.close();
    emit mapChanged("Wrote map into file. \n"+ writablePath);
}

void Board::importMap(const QString& sourcePath)
{
    QFile sourceFile(sourcePath);
    QDir destinationDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    if (!destinationDir.exists()) {
        emit mapChanged("Failed: Directory does not exist. \n");
        return;
    }
    QString newFile ="#"+QFileInfo(sourcePath).fileName();
    QString destinationPath = destinationDir.filePath(newFile);
    QFile destinationFile(destinationPath);
    if (sourceFile.open(QIODevice::ReadOnly) && destinationFile.open(QIODevice::WriteOnly)) {
        destinationFile.write(sourceFile.readAll());
        newFile.replace(".txt","");
        if(!mapList.contains(newFile))
            mapList.prepend(newFile);
        emit mapChanged("Imported successfully. \n");
    } else {
        emit mapChanged("Failed to import. \n");
    }
}

// Function to check if a shape can be placed at a specific position
bool Board::canPlaceShape(int shapeIndex,int rotation, int x, int y)
{
    auto shape = rotateShapeNTimes(activeShapes.values()[shapeIndex],rotation%4);
    if(rotation/4)
        shape = reverseShape(shape);
    for(int i=0;i<shape.size();i++)
    {
        for(int j=0;j<shape[0].size();j++)
        {
            if(x+i >=map.size() ||y+j >= map[0].size())
                return false;
            if(map[x+i][y+j]!=0 && shape[i][j]!=0)
                return false;
        }
    }
    return true;
}

// Function to place a shape at a specific position
void Board::placeShape(int shapeIndex,int rotation, int row, int col) {
    auto shape = rotateShapeNTimes(activeShapes.values()[shapeIndex],rotation%4);
    if(rotation/4)
        shape = reverseShape(shape);
    for (int i = 0; i < shape.size(); ++i) {
        for (int j = 0; j < shape[i].size(); ++j) {
            if (shape[i][j] == 1) {
                map[row + i][col + j] = activeShapes.keys()[shapeIndex];
            }
        }
    }
}

bool hasZeroElement(const QVector<QVector<int>>& map) {
    for (const QVector<int>& row : map) {
        for (int element : row) {
            if (element == 0) {
                return true; // Found an element equal to 0
            }
        }
    }
    return false; // No element equal to 0 found
}


void Board::fillMapRecursive() {

    if(cancelled)
        return;
    if(!hasZeroElement(map))
    {
        result.push_back(map);
        qDebug() << "Found a solution !!!";
        emit mapChanged("Found a solution !!!\n");
        run=false;
        while(!run)
        {}
        return;
    }
    int cols = map[0].size();
    int rows = map.size();
    for (int col = 0; col < cols; ++col) {
        for (int row = 0; row < rows; ++row) {
            int count =0;
            for (int currow = row; currow < rows; currow++) {
                if(map[currow][col]==0)
                    count ++;
            }
            for (int m = col+1; m < cols; m++)
            {
                for (int n = 0; n < rows; n++)
                {
                    if(map[n][m]==0)
                        count ++;
                }
            }
            int sum=0;
            for(int index=0; index <activeShapes.size(); index ++)
            {
                if(unavailableIndex.contains(index))
                    continue;
                int key = activeShapes.keys()[index];
                if(key==1)
                    sum+=3;
                else if(key==11||key==12||key==2)
                    sum+=4;
                else sum+=5;
            }
            if(sum!=count)
            {
                if(unavailableIndex.size()==0)
                {
                    QString msg = "Done! No more solutions found.\n";
                    qDebug() << msg;
                    emit mapChanged(msg);
                }
                return;
            }
            for(int index=0; index <activeShapes.size(); index ++)
            {
                if(unavailableIndex.contains(index))
                    continue;

                foreach (int rotation, rotationTypes[activeShapes.keys()[index]]) {
                    if (canPlaceShape(index,rotation, row, col)) {
                        auto tmpMap = map;
                        placeShape( index,rotation, row, col);
                        unavailableIndex.insert(index);
                        fillMapRecursive();
                        // Backtrack if placing the current shape is not successful
                        unavailableIndex.remove(index);
                        map =tmpMap;
                    }
                }
            }
        }
    }
}

void Board::solve() {
    cancelled=false;
    startMap=map;
    QtConcurrent::run(std::bind(&Board::fillMapRecursive,this));
}

QVector<QVector<int>> Board::getMap() const
{
    return map;
}

void Board::setMap(QVector<QVector<int>> value)
{
    if (map != value)
    {
        map=value;
        emit mapChanged("Set map \n");
    }
}
QStringList Board::getMapList()
{
    return mapList;
}

void Board::setMode(bool mode)
{
    triangleMode=mode;
    resetMap();
}

void Board::cancel()
{
    cancelled=true;
    map=startMap;
    result.clear();
    unavailableIndex.clear();
    emit mapChanged("Cancelled resolving. \n");
}

void Board::setMapQML(QVector<QVector<int>> value)
{
    int rows=value.size();
    int cols=value[0].size();
    QSet<int> usedShapes;
    for(int i=0;i<rows;i++ )
    {
        QVector<int>tmp= value[i];
        for(int j=0;j<cols;j++)
            if(tmp[j]!=0)
                usedShapes.insert(tmp[j]);
    }
    setActiveShapes(usedShapes);
    if (map != value)
    {
        map=value;
        QString msg="Set map \n";
        if(!hasZeroElement(map))
            msg="YOU WIN";
        emit mapChanged(msg);
    }
}

void Board::setRun()
{
    run=true;
}

void Board::viewResult()
{
    static int index = 0;
    int size=result.size();
    if(size==0)
    {
        emit mapChanged("No solution found.\n");
        return;
    }
    if(index>=size)
        index=0;
    map=result[index];
    emit mapChanged("Showing solution "+ QString::number(index+1)+ "/" + QString::number(size)+"\n");
    index++;
}

