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
    }
}
