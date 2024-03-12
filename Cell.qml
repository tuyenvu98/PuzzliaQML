import QtQuick 2.0

Rectangle {
    property alias labelText: textLabel.text
    id: cell
    color: "blanchedalmond"
    width: cellSize
    height: cellSize
    radius: cellSize/4
    border.color: labelText === "-1" ? "transparent":"black"
    property var textVisible: labelText === "-1" ? false:true
    Text {
        id: textLabel
        anchors.centerIn: parent
        color: "black"
        font.bold: true
        visible: textVisible
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            var oldX = shape.children[0].x
            var oldY = shape.children[0].y
            var dim = (mouse.button === Qt.RightButton) ? 1:-1
            var angle = 90*dim
            for(var i =0; i<shape.children.length;i++)
            {
                shape.children[i].rotation +=angle
            }
            shape.rotation -=angle
            if(dim===1)
            {
                shape.children[0].x=-oldY-cellSize
                shape.children[0].y=oldX
            }
            else
            {
                shape.children[0].x=oldY
                shape.children[0].y=-oldX-cellSize
            }
        }
        onDoubleClicked:
        {
            var intText =parseInt(labelText)
            if(usedShapeItems.includes(intText))
            {
                for(var i=0;i<items.count;i++ )
                {
                    var s = items.itemAt(i)
                    if(parseInt(s.children[0].labelText)===intText)
                    {
                        undoChanged(intText)
                        s.visible = true
                        break
                    }
                }
            }
        }
    }
}
