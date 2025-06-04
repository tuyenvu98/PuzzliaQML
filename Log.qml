import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
Window {
    id: logWindow
    visible: true
    width: 300
    height: 600
    title: "Log"
    color: "lightblue"
    Text {
        id: labelStatus
        text: "Status:"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15
        anchors.topMargin: 10
        font.pixelSize: 25
        font.family: jaroFont.name
        font.underline: true
    }
    Button {
        id: btnClear
        text: (platform === "PC") ?"Clear":"\u{1F5D1}"
        width: buttonSize*2
        height: buttonSize
        font.family: jaroFont.name
        font.pixelSize: 20
        Text {
            id :txtClear
            x: parent.x +30
            text: "Clear"
            color:  "blue"
            visible: false
        }
        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: status= Qt.formatTime(new Date(), "hh:mm:ss")+": Ready... \n"
            onEntered: txtClear.visible=true
            onExited: txtClear.visible=false
        }
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        background: Rectangle {
            radius: 25
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#E53935" }
                GradientStop { position: 1.0; color: "#EF5350" }
            }
        }
        hoverEnabled: false
    }
    ScrollView {
        anchors.top:labelStatus.bottom
        anchors.bottom:btnClear.top
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 10
        width: parent.width
        TextArea {
            id: statusArea
            font.family: lemonadaFont.name
            width: parent.width
            height: contentHeight
            text: status
            font.pixelSize: 14
            readOnly: true
            wrapMode: TextEdit.WordWrap
            cursorPosition: text.length
        }
    }
    Button {
        id: btnOK
        text: "\u{2714}"
        width: buttonSize*1.4
        height: buttonSize
        font.pixelSize: 30
        font.bold: true
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        onClicked: {
            logWindow.destroy()
        }
        background: Rectangle {
            radius: 25
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#4CAF50" }
                GradientStop { position: 1.0; color: "#8BC34A" }
            }
        }
        hoverEnabled: false
    }
}
