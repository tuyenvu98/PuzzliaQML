import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
Window {
    id: settingWindow
    visible: true
    width: 350
    height: 450
    title: "Setting"
    modality: Qt.WindowModal
    Rectangle {
        color: "lightblue"
        anchors.fill: parent

        Label{
            id: lblSolveMode
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.topMargin: 50
            font.family: jaroFont.name
            text: " \u{26A1} Auto Solve            \u{27A1} "
            font.pixelSize: 25
            enabled: btnSolve.enabled
        }
        CheckBox {
            id:cbSolveMode
            checked: autoSolveMode
            anchors.verticalCenter: lblSolveMode.verticalCenter
            anchors.leftMargin: 30
            anchors.left: lblSolveMode.right
            enabled: btnSolve.enabled
        }

        Label{
            id: lblMode
            anchors.left: parent.left
            anchors.top: lblSolveMode.bottom
            anchors.leftMargin: 20
            anchors.topMargin: 20
            font.family: jaroFont.name
            text: " \u{25C0} Triangle Mode     \u{27A1} "
            font.pixelSize: 25
        }
        CheckBox {
            id:cbMode
            checked: triangleMode
            anchors.verticalCenter: lblMode.verticalCenter
            anchors.left: cbSolveMode.left
            onClicked: {
                warningChange.open()
            }
        }
        Label{
            id: lblSize
            anchors.left: lblMode.left
            anchors.top: lblMode.bottom
            anchors.topMargin: 20
            font.family: jaroFont.name
            text: " \u{25FC} Cell Size                 \u{27A1} "
            font.pixelSize: 25
        }
        Rectangle
        {
            width: 35
            height: 25
            border.color: "black"
            anchors.verticalCenter: lblSize.verticalCenter
            anchors.left: cbMode.left
            TextInput {
                id:txtSize
                font.family: jaroFont.name
                width:parent.width
                height:parent.height
                inputMethodHints: Qt.ImhDigitsOnly
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                validator: IntValidator {
                    bottom: 0
                    top: 99
                }
                text: cellSize
            }
        }

        Button {
            id: btnOK
            text: "\u{2714}"
            width: buttonSize*1.4
            height: buttonSize
            font.pixelSize: 30
            font.bold: true
            anchors.rightMargin: 10
            anchors.right: btnCancel.left
            anchors.bottom: btnCancel.bottom
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4CAF50" }
                    GradientStop { position: 1.0; color: "#8BC34A" }
                }
            }
            hoverEnabled: false
            onClicked: {
                if(cbMode.checked!=triangleMode)
                {
                    triangleMode=!triangleMode
                    resetMap()
                    board.setMode(triangleMode)
                }
                autoSolveMode = cbSolveMode.checked
                var s =parseInt(txtSize.text)
                if(s<1)
                    s=40
                cellSize= parseInt(txtSize.text)
                settingWindow.destroy()
            }
        }

        Button {
            id: btnCancel
            text: "\u{2716}"
            width: buttonSize*1.4
            height: buttonSize
            font.pixelSize: 30
            anchors.rightMargin: 20
            anchors.bottomMargin: 20
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            onClicked: {
               settingWindow.destroy()
            }
            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#E53935" }
                    GradientStop { position: 1.0; color: "#EF5350" }
                }
            }
            hoverEnabled: false
        }

        Text {
            text: "Can't change auto solve mode \nwhen still running."
            color: "darkred"
            anchors.bottom: btnOK.top
            anchors.bottomMargin: 20
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: jaroFont.name
        }
        Dialog {
            id: warningChange
            x: parent.x+20
            title: "Warning"
            standardButtons: Dialog.Ok
            Text {
                text: "\u{26A0}Change mode will reset\n the whole map!"
            }
        }

    }
}
