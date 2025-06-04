import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    visible: true
    width: 800
    height: 600
    color: "lightblue"

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        Text {
            text: "To save what you have done, use File-> Save or File->Save As.
To import a map from external source, use File-> Import.
To change settings, use Options->Setting.
To see Log, use Options->Log.
How to play?
- Right click normal cell to rotate the shape counterclockwise.
- Left click normal cell to rotate the shape clockwise.
- Left click special cell to reverse the shape.
To move the shape press the special cell and move wherever you want.
When you added the shape to the board, double click to the shape to undo it."
            color: "darkred"
            anchors.topMargin: 15
            anchors.top: parent.top
            anchors.bottomMargin: 15
            font.pixelSize: 14
            font.family: lemonadaFont.name
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAnywhere
            Layout.fillWidth: true
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
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        onClicked: {
            close()
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
