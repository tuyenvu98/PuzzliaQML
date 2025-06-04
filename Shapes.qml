import QtQuick 2.0

Item {
    id: shape
    property int shapeName: 0
    property string pColor : colors.get(shapeName)
    property var curShape: shapes.get(shapeName)
    property var curPos: getPossition(curShape)
    width: cellSize*curShape.length
    height: cellSize*curShape[0].length
    MouseArea {
        anchors.fill: parent
        drag.target: parent
        onPressed:
        {
            shape.z ++
        }
        onReleased:
        {
            var count=0
            shape.z --
            for(var i=0; i< grid.rows*grid.columns;i++)
            {
                var cellGrid= grid.children[i];
                if(cellGrid.labelText===shapeName)
                    cellGrid.labelText=0;
                if(cellGrid.labelText !==0)
                    continue
                for(var j=0; j< rptCells.count;j++)
                {
                    var shapeCell = rptCells.itemAt(j)
                    if((Math.pow((shapeCell.mapToGlobal(0, 0).x-cellGrid.mapToGlobal(0, 0).x),2)+Math.pow((shapeCell.mapToGlobal(0, 0).y-cellGrid.mapToGlobal(0, 0).y),2))  < (cellSize*cellSize)/4)
                    {
                        cellGrid.labelText = shapeCell.labelText
                        count++
                        break
                    }
                }
                if(count===rptCells.count)
                {
                    shape.visible=false
                    var index=usedShapeItems.indexOf(shapeName)
                    if(index>-1)
                        usedShapeItems.splice(index, 1);
                    usedShapeItems.unshift(shapeName);
                    setChanged()
                    break
                }
            }
        }
        Timer {
            id: clickTimer
            interval: 100
            repeat: false
            onTriggered: {
                for(var i =0; i<rptCells.count;i++)
                {
                    rptCells.itemAt(i).rotation -=90
                }
                shape.rotation+=90
            }
        }
        onClicked: {
            clickTimer.start()
        }
        onDoubleClicked: {
            clickTimer.stop()
            for(var m=0;m<curShape.length;m++)
            {
                    curShape[m].reverse()
            }
            curPos=getPossition(curShape)
            doubleClickFlag=false
        }
    }
    Repeater {
        id:rptCells
        model: curPos.length
        Cell {
            color: pColor
            labelText: shapeName
            x: curPos[index][0]*cellSize
            y: curPos[index][1]*cellSize
        }
    }

    function getPossition(shapeVec)
    {
        var vectorPos= [[]]
        for(var i=0;i<shapeVec.length;i++)
        {
            for(var j=0;j<shapeVec[0].length;j++)
            {
                if(shapeVec[i][j]===1)
                    vectorPos.push([i,j])
            }
        }
        vectorPos.shift()
        return vectorPos;
    }
}
