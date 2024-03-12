import QtQuick 2.15
import QtQuick.Controls 2.15
Window {
    visible: true
    width: mainwindow.width
    height: mainwindow.height
    title: "Custom map"
    modality: Qt.WindowModal
    property int cellNum: triangleMode ? 55:60
    property int count: cellNum

    onVisibleChanged: {
        if (!visible) {
            count=cellNum
            fillMaptoGrid()
        }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width+50
        contentHeight: parent.height+50
        Grid {
            id:gridEdit
            anchors.centerIn: parent
            rows: grid.rows
            columns: grid.columns
            Repeater {
                model: parent.rows * parent.columns  // Number of rectangles in the board
                Rectangle {
                    id: cell
                    width: cellSize
                    height: cellSize
                    radius: cellSize/4
                    border.color: "black"
                    color: {
                        if(index >= grid.children.length)
                            return "transparent"
                        return grid.children[index].labelText==="0"? "blanchedalmond":"lightgray"
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: {
                            if((mouse.button === Qt.LeftButton))
                            {
                                var tmp=grid.children[index].labelText
                                if(tmp==="0")
                                {
                                    grid.children[index].labelText="-1";
                                    count--;
                                }
                                else
                                {
                                    grid.children[index].labelText=0;
                                    count++
                                }
                            }
                            else
                            {
                            }
                        }
                    }
                }
            }
        }
        Button {
            id: btnAddFirstRow
            text: "\u{2795}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.left: gridEdit.left
            anchors.bottom: gridEdit.top
            anchors.bottomMargin: 10
            onClicked: {
                var gridVec=grid2Vector()
                let addVector = Array(10).fill(-1);
                gridVec.unshift(addVector)
                vector2Grid(gridVec)
            }
        }
        Button {
            id: btnDeleteFirstRow
            text: "\u{2796}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.right: gridEdit.right
            anchors.bottom: btnAddFirstRow.bottom
            onClicked: {
                var gridVec=grid2Vector()
                var row= gridVec[0]
                for(var i=0;i<row.length;i++)
                {
                    if(row[i]===0)
                        count--
                }
                gridVec.shift()
                vector2Grid(gridVec)
            }
        }
        Button {
            id: btnAddLastRow
            text: "\u{2795}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.left: gridEdit.left
            anchors.top: gridEdit.bottom
            anchors.topMargin: 10
            onClicked: {
                var gridVec=grid2Vector()
                let addVector = Array(10).fill(-1);
                gridVec.push(addVector)
                vector2Grid(gridVec)
            }
        }
        Button {
            id: btnDeleteLastRow
            text: "\u{2796}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.right: gridEdit.right
            anchors.bottom: btnAddLastRow.bottom
            onClicked: {
                var gridVec=grid2Vector()
                var row= gridVec[gridVec.length-1]
                for(var i=0;i<row.length;i++)
                {
                    if(row[i]===0)
                        count--
                }
                gridVec.pop()
                vector2Grid(gridVec)
            }
        }

        Button {
            id: btnAddFirstCol
            text: "\u{2795}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.right: gridEdit.left
            anchors.top: gridEdit.top
            anchors.rightMargin: 10
            onClicked: {
                var gridVec=grid2Vector()
                for(var i=0;i<gridVec.length;i++ )
                {
                    gridVec[i].unshift(-1)
                }
                vector2Grid(gridVec)
            }
        }
        Button {
            id: btnDeleteFirstCol
            text: "\u{2796}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.left: btnAddFirstCol.left
            anchors.bottom: gridEdit.bottom
            onClicked: {
                var gridVec=grid2Vector()
                for(var i=0;i<gridVec.length;i++)
                {
                    if(gridVec[i][0]===0)
                        count--
                    gridVec[i].shift()
                }
                vector2Grid(gridVec)
            }
        }
        Button {
            id: btnAddLastCol
            text: "\u{2795}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.left: gridEdit.right
            anchors.top: gridEdit.top
            anchors.leftMargin: 10
            onClicked: {
                var gridVec=grid2Vector()
                for(var i=0;i<gridVec.length;i++ )
                {
                    gridVec[i].push(-1)
                }
                vector2Grid(gridVec)
            }
        }
        Button {
            id: btnDeleteLastCol
            text: "\u{2796}"
            width: cellSize
            height: cellSize
            font.pixelSize: 20
            anchors.left: btnAddLastCol.left
            anchors.bottom: gridEdit.bottom
            onClicked: {
                var gridVec=grid2Vector()
                var sz= gridVec[0].length
                for(var i=0;i<gridVec.length;i++)
                {
                    if(gridVec[i][sz-1]===0)
                        count--
                    gridVec[i].pop()
                }
                vector2Grid(gridVec)
            }
        }
    }
    Button {
        id: btnRevert
        text: "\u{21A9}"
        width: buttonSize*1.4
        height: buttonSize
        font.pixelSize: 20
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        onClicked: {
            count=cellNum
            fillMaptoGrid()
        }
    }

    Label{
        id: lblCount
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: btnRevert.top
        anchors.bottomMargin: 20
        font.bold: true
        color: count===cellNum ? "darkgreen":"red"
        text: "Cells: "+count
        font.pixelSize: 16
    }

    Button {
        id: btnOK
        text: "\u{2705}"
        width: buttonSize*1.4
        height: buttonSize
        font.pixelSize: 20
        anchors.rightMargin: 10
        anchors.right: btnCancel.left
        anchors.bottom: btnCancel.bottom
        onClicked: {
            if(count !== cellNum)
            {
                warningChange.open()
                return
            }
            setChanged()
            close()
        }
    }
    Button {
        id: btnCancel
        text: "\u{274C}"
        width: buttonSize*1.4
        height: buttonSize
        font.pixelSize: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onClicked: {
            count=cellNum
            fillMaptoGrid()
            close()
        }
    }
    Dialog {
        id: warningChange
        anchors.centerIn: parent
        title: "Warning"
        standardButtons: Dialog.Ok
        Text {
            text: "\u{274C}Number of cell is NOT equal to " + cellNum + "!!."
        }
    }
}
