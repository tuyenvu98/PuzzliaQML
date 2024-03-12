import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtMultimedia
Window {
    id:mainwindow
    visible: true
    width: 400
    height: 650
    title: qsTr("Puzzlia")
    property var colors: {
        let colors = new Map()
        colors.set(3, "darkviolet").set(4, "azure").set(5, "yellow").set(6, "blue")
                .set(7, "lawngreen").set(8, "red").set(9, "darkorange").set(10, "peru")
                .set(13, "saddlebrown").set(14, "lightgray").set(15, "darkgreen").set(16, "cyan")
                .set(1, "grey").set(2, "green").set(11, "saddlebrown").set(12, "cornflowerblue")
                .set(0, "blanchedalmond").set(-1, "transparent")
        return colors
    }
    property var shapes: {
        let shapes = new Map()
        shapes.set(1, [[0,1],[1,1]]).set(2, [[1,0],[1,0],[1,1]]).set(11, [[1,1],[1,1]]).set(12, [[1],[1],[1],[1]])
        .set(3, [[0,1],[0,1],[0,1],[1,1]]).set(4, [[1,0],[1,0],[1,1],[1,0]]).set(5, [[0,1],[0,1],[1,1],[1,0]])
        .set(6, [[0,0,1],[0,0,1],[1,1,1]]).set(7, [[1,1],[1,0],[1,1]]).set(8,[[0,0,1],[0,1,1],[1,1,0]])
        .set(9, [[0,1,0],[1,1,1],[0,1,0]]).set(10, [[1,1,1],[1,1,0]]).set(13, [[0,0,1],[1,1,1],[1,0,0]])
        .set(14, [[0,1,0],[0,1,1],[1,1,0]]).set(15,[[0,1,0],[0,1,0],[1,1,1]]).set(16, [[1],[1],[1],[1],[1]])
        return shapes
    }
    property var usedShapeItems: []
    property bool triangleMode: false
    property bool autoSolveMode: true
    property int cellSize: platform==="Android" ? mapArea.width/12 :mapArea.width/12
    property int buttonSize: 50
    property string status: Qt.formatTime(new Date(), "hh:mm:ss")+": Ready... \n"
    Connections {
        target: board
        onMapChanged: {
            txtBlink.text=message
            blinkAnimation.running=true
            if(message.includes("Failed"))
                return
            if(message.includes("Import"))
            {
                cbMapList.model=board.getMapList()
                return
            }
            cbShapeName.model= board.getActiveShapes()
            var m=0
            while(m<items.count)
            {
                var index = cbShapeName.model.indexOf(parseInt(items.itemAt(m).children[0].labelText))
                if(index>-1)
                    cbShapeName.model.splice(index, 1)
                else
                    m++
            }
            if(message.includes("YOU WIN"))
            {
                message= "\u{1F381} \u{1F389} \u{1F37A} \u{1F4AF}"+message+"\u{1F4AF} \u{1F37A} \u{1F389} \u{1F381}\n";
                var component = Qt.createComponent("Win.qml");
                if (component.status === Component.Ready) {
                    var window = component.createObject(mainwindow);
                    window.show()
                    return
                }
            }
            if(!message.includes("Set map"))
                status += Qt.formatTime(new Date(), "hh:mm:ss")+ ": " +message
            if(message.includes("Done"))
            {
                setEnableButtons(true)
            }
            fillMaptoGrid()
        }
    }

    Rectangle{
        anchors.fill:parent
        gradient: Gradient {
              GradientStop { position: 0.0; color: "lightskyblue" }
              GradientStop { position: 1.0; color: "lightcyan" }
          }
        FileDialog {
            id: txtFileDialog
            title: "Choose a File"
            nameFilters: ["Text files (*.txt)", "All files (*)"]
            onAccepted: {
                if (selectedFiles.length > 0) {
                    var filename = selectedFiles[0].toString()
                    let sourcePath = filename.replace("file:///","")
                    board.importMap(sourcePath)
                }
            }
        }
        MenuBar {
            id:menuBar
            height:35
            Menu {
                title: "File"
                MenuItem {
                    text: "\u{1F4BE} Save"
                    onTriggered: {
                        board.saveMap()
                    }
                }
                MenuItem {
                    text: "\u{1F4BD} Save As"
                    onTriggered: {
                    }
                }
                MenuItem {
                    text: "\u{1F4C2} Import"
                    onTriggered: {
                        txtFileDialog.open()
                    }
                }
            }
            Menu {
                title: "Options"
                MenuItem {
                    text: "\u{2699} Setting"
                    onTriggered: {
                        var component = Qt.createComponent("Setting.qml");
                        if (component.status === Component.Ready) {
                            var window = component.createObject(parent);
                            window.show();
                        }
                    }
                }
                MenuItem {
                    text: "\u{1F4CB} Log"
                    onTriggered: {
                        var component = Qt.createComponent("Log.qml");
                        if (component.status === Component.Ready) {
                            var window = component.createObject(parent);
                            window.show();
                        }
                    }
                }
            }
        }
        Text {
            id: txtBlink
            font.bold:true
            font.italic: true
            anchors.top: parent.top
            anchors.right: btnHelp.left
            anchors.rightMargin: 20
            text: ""
            font.pixelSize: 16

            PropertyAnimation {
                id: blinkAnimation
                target: txtBlink
                property: "opacity"
                from: 1
                to: 0
                duration: 2000
            }

        }
        Button {
            id: btnHelp
            width: 35
            height:35
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.right: parent.right
            text: "\u{2753}"
            font.pixelSize: 20
            z: z++
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    var component = Qt.createComponent("Help.qml");
                    if (component.status === Component.Ready) {
                        var window = component.createObject(parent);
                        window.show();
                    }
                }
            }
        }

        Button {
            id:btnReset
            text: "\u{1F501}"
            width: buttonSize*1.4
            height: buttonSize
            font.pixelSize: 18
            enabled: btnSolve.enabled
            z: z++
            Text {
                id :txtReset
                x: parent.x +20
                text: "Reset"
                color:  "blue"
                visible: false
            }
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    resetMap()
                    board.resetMap()
                }
                onEntered: txtReset.visible=true
                onExited: txtReset.visible=false
            }

            anchors.left: btnLoad.left
            anchors.bottom: btnLoadImage.top
            anchors.bottomMargin: 15
        }

        FileDialog {
            id: imageFileDialog
            title: "Choose a File"
            nameFilters: ["Image files (*.png *.jpg *.jpeg)", "All files (*)"]
            onAccepted: {
                if (selectedFiles.length > 0) {
                    var filename = selectedFiles[0].toString()
                    let path = filename.replace("file:///","")
                    board.loadMapImage(path)
                }
            }
        }

        Button {
            id:btnLoad
            text: "\u{1F4E4}"
            width: buttonSize *1.4
            height: buttonSize
            font.pixelSize: 20
            enabled: btnSolve.enabled
            z: z++
            onClicked: {
                resetMap()
                let mapName = cbMapList.currentText+".txt"
                board.loadMap(mapName)
            }
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
        }

        Button {
            id:btnLoadImage
            text: "\u{1F4F7}"
            width: buttonSize *1.4
            height: buttonSize
            font.bold: true
            font.pixelSize: 20
            enabled: btnSolve.enabled
            z: z++
            onClicked: {
                camera.start();
                //resetMap()
                //imageFileDialog.open()
            }
            anchors.left: btnLoad.left
            anchors.bottom: btnLoad.top
            anchors.bottomMargin: 15
        }
        ComboBox {
            id: cbMapList
            anchors.top: btnLoad.top
            anchors.topMargin: 1
            anchors.left: btnLoad.right
            width: 100
            height: 50
            font.pixelSize: 12
            popup.height: model.length >5 ? 150 : model.length*30
            model: board.getMapList()
        }


        Button {
            id: btnNext
            text: "\u{23E9}"
            width: buttonSize*1.4
            height: buttonSize
            font.pixelSize: 20
            visible: autoSolveMode
            z: z++
            Text {
                id :txtNext
                x: parent.x +20
                text: "Next"
                color:  "blue"
                visible: false
            }
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    board.setRun()
                }
                onEntered: txtReview.visible=true
                onExited: txtReview.visible=false
            }
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.rightMargin: 15
        }
        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }
        Rectangle {
            width: 640
            height: 480

            Camera {
                id: camera
            }

        }
        Button {
            id: btnCancel
            text: "\u{274C}"
            width: buttonSize*1.4
            height: buttonSize
            visible: !btnSolve.enabled
            font.pixelSize: 20
            z: z++
            onClicked: {
                board.cancel()
                setEnableButtons(true)
            }
            anchors.right: btnSolve.left
            anchors.bottom: btnSolve.bottom
            anchors.rightMargin: 15
        }
        Button {
            id: btnSolve
            text: "\u{1F50D}"
            width: buttonSize*1.4
            height: buttonSize
            visible: autoSolveMode
            font.pixelSize: 20
            z: z++
            onClicked: {
                board.solve()
                setEnableButtons(false)
                status += Qt.formatTime(new Date(), "hh:mm:ss")+": Start solving \u{23F3}\n"
            }
            anchors.right: btnNext.right
            anchors.bottom: btnNext.top
            anchors.bottomMargin: 15
        }
        Button {
            text: "\u{23EA}"
            id: btnReview
            width: buttonSize*1.4
            height: buttonSize
            font.pixelSize: 20
            visible: autoSolveMode
            z: z++
            Text {
                id :txtReview
                x: parent.x +20
                text: "Review"
                color:  "blue"
                visible: false
            }
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    board.viewResult()
                }
                onEntered: txtReview.visible=true
                onExited: txtReview.visible=false
            }

            anchors.left: btnNext.left
            anchors.bottom: btnSolve.top
            anchors.bottomMargin: 15
        }
        Rectangle
        {
            id: mapArea
            anchors.top: createArea.bottom
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.topMargin: 20
            anchors.bottom: btnReview.top
            anchors.bottomMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 5
            color:"transparent"
            Flickable {
                anchors.fill: parent
                contentWidth: grid.width+50
                contentHeight: grid.height+50
                Grid {
                    id:grid
                    anchors.centerIn: parent
                    rows: board.map.length
                    columns: board.map[0].length
                    enabled: btnSolve.enabled
                    Repeater {
                        model: parent.rows * parent.columns
                        Cell {
                            labelText: "0"
                        }
                    }
                }
            }
        }

        Rectangle{
            id: createArea
            height: mainwindow.height/4
            border.color: "black"
            anchors.top: menuBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.topMargin: 10
            Rectangle{
                id: shapeModel
                width:45
                height:width
                color: "whitesmoke"
                anchors.top: parent.top
                border.color: "black"
                MouseArea{
                    anchors.fill: parent
                    onClicked: createShape()
                }
                Shapes {
                    shapeName: cbShapeName.model[cbShapeName.currentIndex]
                    x: parent.x+3
                    y: parent.y+20
                    scale: 8/cellSize
                    enabled: false
                }
            }

            ComboBox {
                    id: cbShapeName
                    anchors.top: shapeModel.top
                    anchors.left: shapeModel.right
                    width: 65
                    height: 40
                    popup.height: 150
                    model: ListModel {
                    }
            }

            Repeater {
                id: items
                model: shapeList
                Shapes {
                    shapeName: (shapeName !==0 ) ? shapeName:cbShapeName.model[cbShapeName.currentIndex]
                    anchors.centerIn: parent
                }
            }
            ListModel {
                id: shapeList
            }

            Button {
                id:btnEdit
                text: "\u{1F528}"
                width: buttonSize*1.4
                height: 40
                font.bold: true
                font.pixelSize: 16
                enabled: btnSolve.enabled
                z: z++
                Text {
                    id :txtEdit
                    x: parent.x +20
                    text: "Edit"
                    color:  "blue"
                    visible: false
                }
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        var component = Qt.createComponent("CustomMap.qml");
                        if (component.status === Component.Ready) {
                            var window = component.createObject(parent);
                            window.show();
                        }
                    }
                    onEntered: txtEdit.visible=true
                    onExited: txtEdit.visible=false
                }
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }
    function undoChanged(text)  {
        var qmlMap = []
        usedShapeItems = usedShapeItems.filter(value => value !== text);
        for(var i=0;i<grid.rows;i++)
        {
            var tmp=[]
            for(var j=0;j<grid.columns;j++)
            {
                var c = grid.children[i*grid.columns+j];
                var val = parseInt(c.labelText);
                if(val!==text)
                    tmp.push(val)
                else
                {
                    tmp.push(0)
                    c.labelText=0
                }
            }
            qmlMap.push(tmp)
        }
        board.setMapQML(qmlMap)
    }
    function createShape() {
        shapeList.append({});
        cbShapeName.model.splice(cbShapeName.currentIndex, 1)
        if(cbShapeName.model.length===0)
            shapeModel.enabled=false
    }
    function resetMap(){
        shapeList.clear()
        usedShapeItems= []
        shapeModel.enabled=true
        btnSolve.enabled=true
    }

    function setEnableButtons(isEnable){
        shapeModel.enabled=isEnable
        btnSolve.enabled=isEnable
        for(var i=0; i<items.count;i++)
        {
            if(!usedShapeItems.includes(parseInt(items.itemAt(i).children[0].labelText)))
                items.itemAt(i).visible=isEnable
        }
    }
    function setChanged()  {
        var qmlMap = grid2Vector()
        board.setMapQML(qmlMap)
    }
    function grid2Vector()
    {
        var qmlMap = []
        for(var i=0;i<grid.rows;i++)
        {
            var tmp=[]
            for(var j=0;j<grid.columns;j++)
            {
                tmp.push(parseInt(grid.children[i*grid.columns+j].labelText))
            }
            qmlMap.push(tmp)
        }
        return qmlMap
    }
    function vector2Grid(vec)
    {
        grid.rows = vec.length
        grid.columns = vec[0].length
        for(var i=0;i<grid.rows*grid.columns;i++)
        {
            var row = Math.floor(i/grid.columns)
            var col = i%grid.columns
            grid.children[i].labelText=vec[row][col];
        }
    }
    function fillMaptoGrid()
    {
        grid.rows=board.map.length
        grid.columns=board.map[0].length
        for(var i=0;i<grid.columns* grid.rows;i++)
        {
            var cell=grid.children[i]
            var row = Math.floor(i/grid.columns)
            var col = i%grid.columns
            var value= board.map[row][col]
            cell.color= colors.get(value)
            cell.labelText= value
        }
    }
}
