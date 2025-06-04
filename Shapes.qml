import QtQuick 2.0

Item {
    id: shape
    property int shapeName: 0
    property string pColor : colors.get(shapeName)
    property int curX: 0
    property int curY: 0
    property var curShape: shapes.get(shapeName)
    property var curPos: getPossition(curShape)

    Cell {
        id: cell1
        color: pColor
        labelText: shapeName
        border.width: 3
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            onPressed:
            {
                curX = parent.x
                curY = parent.y
                shape.z ++
            }
            onClicked: {
                for(var m=0;m<curShape.length;m++)
                {
                        curShape[m].reverse()
                }
                curPos=getPossition(curShape)
            }
            onReleased:
            {
                var count=0
                for(var i=0; i< grid.rows*grid.columns;i++)
                {
                    var cellGrid= grid.children[i];
                    if(parseInt(cellGrid.labelText)===parseInt(parent.labelText))
                        cellGrid.labelText=0;
                    if(parseInt(cellGrid.labelText) !==0)
                        continue
                    for(var j=0; j< shape.children.length;j++)
                    {
                        var shapeCell = shape.children[j]
                        if((Math.pow((shapeCell.mapToItem(grid, 0, 0).x-cellGrid.x),2)+Math.pow((shapeCell.mapToItem(grid, 0, 0).y-cellGrid.y),2))  < (cellSize*cellSize)/4)
                        {
                            cellGrid.labelText = parseInt(shapeCell.labelText)
                            count++
                            break
                        }
                    }
                    if(count===shape.children.length-1)
                    {
                        shape.visible=false
                        var val= parseInt(shape.children[0].labelText)
                        var index=usedShapeItems.indexOf(val)
                        if(index>-1)
                            usedShapeItems.splice(index, 1);
                        usedShapeItems.unshift(val);
                        setChanged()
                        break
                    }
                }
            }
        }
    }
    Repeater {
        model: curPos.length-1
        Cell {
            color: pColor
            labelText: shapeName
            x: cell1.x + (curPos[index+1][0]-curPos[0][0])*cellSize
            y: cell1.y + (curPos[index+1][1]-curPos[0][1])*cellSize
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
