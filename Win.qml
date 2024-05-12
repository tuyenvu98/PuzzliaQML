import QtQuick 2.15
import QtQuick.Controls 2.15

Window {
    width: 400
    height: 300
    Rectangle {
        width: parent.width
        height: parent.height
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            text: "\u{1F389} \u{1F37A} \u{1F4AF} YOU WON \u{1F4AF} \u{1F37A} \u{1F389}"
            font.pixelSize: 20
        }

        AnimatedImage {
            source: "qrc:/image/gifs/firework.gif"
            width: 250
            height: 100
            anchors.centerIn: parent
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
                close()
            }
        }
    }
}
