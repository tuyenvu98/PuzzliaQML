import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
Window {
    visible: true
    width: 300
    height: 600
    title: "Log"
    Text {
        id: labelStatus
        text: "Status:"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 10
        font.pixelSize: 18
        font.bold: true
        font.underline: true
    }
    Button {
        id: btnClear
        text: "\u{1F5D1}"
        width: buttonSize*1.4
        height: buttonSize
        font.bold: true
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
    }
    ScrollView {
        anchors.top:labelStatus.bottom
        anchors.bottom:btnClear.top
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        width: parent.width
        TextArea {
            id: statusArea
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
        text: "\u{2705}"
        width: buttonSize*1.4
        height: buttonSize
        font.pixelSize: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        onClicked: {
            close()
        }
    }
}
