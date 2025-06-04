import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
Window {
    id:mainwindow
    visible: true
    width: Screen.width
    height: Screen.height
    title: qsTr("Puzzlia")
    property var colors: {
        let colors = new Map()
        colors.set(3, "darkviolet").set(4, "steelblue").set(5, "yellow").set(6, "blue")
                .set(7, "lawngreen").set(8, "red").set(9, "darkorange").set(10, "darksalmon")
                .set(13, "saddlebrown").set(14, "indigo").set(15, "darkgreen").set(16, "cyan")
                .set(1, "grey").set(2, "green").set(11, "saddlebrown").set(12, "cornflowerblue")
                .set(0, "white").set(-1, "transparent")
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
    property int cellSize: mapArea.height/7 < mainwindow.width/11 ? mapArea.height/7 : mainwindow.width/11
    property int buttonSize: 40
    property string status: Qt.formatTime(new Date(), "hh:mm:ss")+": Ready... \n"
    onTriangleModeChanged:
    {
        if(triangleMode)
            if(mapArea.height/11<cellSize)
                cellSize=mapArea.height/11
    }
    FontLoader
    {
        id:lemonadaFont
        source: "/fonts/Lemonada.ttf"
    }
    FontLoader
    {
        id:jaroFont
        source: "/fonts/Jaro-Regular.ttf"
    }
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
                var index = cbShapeName.model.indexOf(items.itemAt(m).shapeName)
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
            font.family: jaroFont.name
            Menu {
                title: "File"
                MenuItem {
                    text: "\u{2B07} Save"
                    font.family: lemonadaFont.name
                    font.pixelSize: 14
                    onTriggered: {
                        board.saveMap()
                    }
                }
                MenuItem {
                    text: "\u{2712} Save As"
                    font.family: lemonadaFont.name
                    font.pixelSize: 14
                    onTriggered: {
                    }
                }
                MenuItem {
                    text: "\u{2B06} Import"
                    font.family: lemonadaFont.name
                    font.pixelSize: 14
                    onTriggered: {
                        txtFileDialog.open()
                    }
                }
            }
            Menu {
                title: "Options"
                MenuItem {
                    text: "\u{2699} Setting"
                    font.family: lemonadaFont.name
                    font.pixelSize: 14
                    onTriggered: {
                        var component = Qt.createComponent("Setting.qml");
                        if (component.status === Component.Ready) {
                            var window = component.createObject(parent);
                            window.show();
                        }
                    }
                }
                MenuItem {
                    text: "\u{270F} Log"
                    font.family: lemonadaFont.name
                    font.pixelSize: 14
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
            color: "darkred"
            font.italic: true
            anchors.top: parent.top
            anchors.right: btnHelp.left
            anchors.rightMargin: 20
            text: ""
            font.pixelSize: buttonSize/2
            font.family: jaroFont.name

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
            width: buttonSize
            height:buttonSize*0.8
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.right: parent.right
            text: "\u{2139}"
            font.pixelSize: buttonSize*0.8
            font.family: jaroFont.name
            z: z++
            background: Rectangle {
                radius: 15
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#3366cc" }
                    GradientStop { position: 1.0; color: "#3B82F6" }
                }
            }
            hoverEnabled: false
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
            text: (platform === "PC") ? "Reset":"\u{1F501}"
            width: buttonSize*2
            height: buttonSize
            font.pixelSize: buttonSize*0.4
            font.family: jaroFont.name
            enabled: btnSolve.enabled
            z: z++
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#E53935" }
                    GradientStop { position: 1.0; color: "#EF5350" }
                }
            }
            hoverEnabled: false
            MouseArea
            {
                anchors.fill: parent
                onClicked: {
                    resetMap()
                    board.resetMap()
                }
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
            text: (platform === "PC") ? "Load":"\u{1F4E4}"
            width: buttonSize *2
            height: buttonSize
            font.pixelSize: buttonSize*0.4
            font.family: jaroFont.name
            enabled: btnSolve.enabled
            z: z++
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4CAF50" }
                    GradientStop { position: 1.0; color: "#8BC34A" }
                }
            }
            hoverEnabled: false
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
            text: (platform === "PC") ? "Image":"\u{1F4F7}"
            width: buttonSize *2
            height: buttonSize
            font.family: jaroFont.name
            font.pixelSize: buttonSize*0.4
            enabled: btnSolve.enabled
            z: z++
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4CAF50" }
                    GradientStop { position: 1.0; color: "#8BC34A" }
                }
            }
            hoverEnabled: false
            onClicked: {
                resetMap()
                imageFileDialog.open()
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
            width: buttonSize*2
            height: buttonSize
            font.pixelSize: buttonSize*0.3
            font.family: lemonadaFont.name
            popup.height: model.length >5 ? 150 : model.length*30
            popup.font.family: font.family
            popup.font.pixelSize: font.pixelSize
            popup.background: Rectangle {
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#ff9966" }
                    GradientStop { position: 1.0; color: "#ffcc99" }
                }
            }
            model: board.getMapList()
            background: Rectangle {
                radius: 15
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#ff9966" }
                    GradientStop { position: 1.0; color: "#ffcc99" }
                }
            }
        }


        Button {
            id: btnNext
            text: (platform === "PC") ?"Next":"\u{23E9}"
            width: buttonSize*2
            height: buttonSize
            font.pixelSize: buttonSize*0.4
            font.family: jaroFont.name
            visible: autoSolveMode
            z: z++
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4CAF50" }
                    GradientStop { position: 1.0; color: "#8BC34A" }
                }
            }
            hoverEnabled: false
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
        Button {
            id: btnCancel
            text: (platform === "PC") ? "Cancel":"\u{274C}"
            width: buttonSize*2
            height: buttonSize
            visible: !btnSolve.enabled
            font.pixelSize: buttonSize*0.4
            font.family: jaroFont.name
            z: z++
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#E53935" }
                    GradientStop { position: 1.0; color: "#EF5350" }
                }
            }
            hoverEnabled: false
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
            text: (platform === "PC") ? "Solve":"\u{1F50D}"
            width: buttonSize*2
            height: buttonSize
            visible: autoSolveMode
            font.pixelSize: buttonSize*0.4
            font.family: jaroFont.name
            z: z++
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4CAF50" }
                    GradientStop { position: 1.0; color: "#8BC34A" }
                }
            }
            hoverEnabled: false
            onClicked: {
                board.solve()
                setEnableButtons(false)
                status += Qt.formatTime(new Date(), "hh:mm:ss")+": Start solving \u{23F3}\n"
            }
            anchors.right: btnReview.right
            anchors.bottom: btnReview.top
            anchors.bottomMargin: 15
        }
        Button {
            text: (platform === "PC") ? "Review":"\u{23EA}"
            id: btnReview
            width: buttonSize*2
            height: buttonSize
            font.pixelSize: buttonSize*0.4
            font.family: jaroFont.name
            visible: autoSolveMode
            z: z++
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4CAF50" }
                    GradientStop { position: 1.0; color: "#8BC34A" }
                }
            }
            hoverEnabled: false
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
            anchors.bottom: btnNext.top
            anchors.bottomMargin: 15
        }
        Rectangle
        {
            id: mapArea
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: mainwindow.height < mainwindow.width ? cbMapList.top :btnReset.top
            anchors.top: createArea.bottom
            color:"transparent"
            Grid {
                id:grid
                anchors.centerIn: parent
                rows: board.map.length
                columns: board.map[0].length
                enabled: btnSolve.enabled
                spacing: 1
                Repeater {
                    model: parent.rows * parent.columns
                    Cell {
                        labelText: 0
                        border.width:2
                        MouseArea
                        {
                            anchors.fill: parent
                            onDoubleClicked:
                            {
                                if(usedShapeItems.includes(labelText))
                                {
                                    for(var i=0;i<items.count;i++ )
                                    {
                                        var s = items.itemAt(i)
                                        if(s.shapeName===labelText)
                                        {
                                            undoChanged(labelText)
                                            s.visible = true
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle{
            id: createArea
            height: mainwindow.height/4
            border.color: "black"
            border.width: 3
            radius:20
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
                anchors.topMargin: 3
                anchors.left:parent.left
                anchors.leftMargin: 3
                radius: 10
                border.color: "black"
                MouseArea{
                    anchors.fill: parent
                    onClicked: createShape()
                }
                Shapes {
                    shapeName: cbShapeName.model[cbShapeName.currentIndex]
                    anchors.centerIn: parent
                    scale: 8/cellSize
                    enabled: false
                    visible:shapeModel.enabled
                }
            }

            ComboBox {
                id: cbShapeName
                anchors.top: shapeModel.top
                anchors.left: shapeModel.right
                width: buttonSize*1.6
                height: buttonSize*0.8
                popup.height: 150
                font.pixelSize: buttonSize*0.25
                font.family: lemonadaFont.name
                background: Rectangle {
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ff9966" }
                        GradientStop { position: 1.0; color: "#ffcc99" }
                    }
                }
                popup.font.family: font.family
                popup.font.pixelSize: font.pixelSize
                popup.background: Rectangle {
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ff9966" }
                        GradientStop { position: 1.0; color: "#ffcc99" }
                    }
                }
                model: ListModel {
                }
            }

            Repeater {
                id: items
                model: shapeList
                Shapes {
                    shapeName: (shapeName !==0 ) ? shapeName:cbShapeName.model[cbShapeName.currentIndex]
                    x: (createArea.width/30)*shapeName
                    y: createArea.height/4
                }
            }
            ListModel {
                id: shapeList
            }

            Button {
                id:btnEdit
                text: "\u{2702}"
                width: buttonSize
                height: buttonSize
                font.bold: true
                font.pixelSize: buttonSize*0.6
                enabled: btnSolve.enabled
                z: z++
                background: Rectangle {
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#3366cc" }
                        GradientStop { position: 1.0; color: "#3B82F6" }
                    }
                }
                hoverEnabled: false
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
                anchors.rightMargin: 3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
            }
        }
    }
    function undoChanged(text)  {
        var qmlMap = []
        //usedShapeItems = usedShapeItems.filter(value => value !== text);
        for(var i=0;i<grid.rows;i++)
        {
            var tmp=[]
            for(var j=0;j<grid.columns;j++)
            {
                var c = grid.children[i*grid.columns+j];
                var val = c.labelText;
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
            if(!usedShapeItems.includes(items.itemAt(i).shapeName))
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
                tmp.push(grid.children[i*grid.columns+j].labelText)
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
            cell.border.color= (value=== -1) ? "transparent":"black"
        }
    }
}
