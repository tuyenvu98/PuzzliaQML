import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
Window {
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
            font.bold:true
            text: " \u{1F4BB} Auto Solve            \u{27A1} "
            font.pixelSize: 20
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
            font.bold:true
            text: " \u{1F4D0} Triangle Mode     \u{27A1} "
            font.pixelSize: 20
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
            font.bold:true
            text: " \u{1F532} Cell Size                 \u{27A1} "
            font.pixelSize: 20
        }
        Rectangle{
            width: 35
            height: 25
            border.color: "black"
            anchors.verticalCenter: lblSize.verticalCenter
            anchors.left: cbMode.left
            TextInput {
                id:txtSize
                width:parent.width
                height:parent.height
                inputMethodHints: Qt.ImhDigitsOnly
                font.bold: true
                font.pixelSize: 16
                validator: IntValidator {
                    bottom: 0
                    top: 99
                }
                text: cellSize
            }
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
                close()
            }
        }

        Text {
            text: "Can't change auto solve mode \nwhen still running."
            color: "darkred"
            anchors.bottom: btnOK.top
            anchors.bottomMargin: 20
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
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
