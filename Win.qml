import QtQuick 2.15
import QtQuick.Controls 2.15
Window {
    id: winWindow
    visible: true
    width: 450
    height: 350
    modality: Qt.WindowModal
    color: "#34495e"
    FontLoader
    {
        id:protestFont
        source: "/fonts/ProtestGuerrilla.ttf"
    }
    Rectangle {
        id: congratsWindow
        width: parent.width * 0.85
        height: parent.height * 0.75
        anchors.centerIn: parent
        radius: 20
        border.color: "#ffffff"
        border.width: 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ff9a9e" }
            GradientStop { position: 1.0; color: "#fad0c4" }
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            // "Congrats!" Title
            Text {
                text: "Congratulations!"
                font.pixelSize: 32
                font.bold: true
                font.family: protestFont.name
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            AnimatedImage {
                source: {
                    var num= Math.floor(Math.random()*4);
                    if(num===4) num=3
                    return "qrc:/image/gifs/win"+ num+ ".gif"
                }
                width: 250
                height: 250
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "You are the champion!"
                font.pixelSize: 20
                font.family: protestFont.name
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: "Awesome!"
                font.pixelSize: 18
                width: 140
                height: 50
                font.family: jaroFont.name
                background: Rectangle {
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#4CAF50" }
                        GradientStop { position: 1.0; color: "#8BC34A" }
                    }
                }
                onClicked: {
                   winWindow.close();
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
