import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import QtQuick.Pdf
Window {
    visible: true
    width: 800
    height: 600
    title: "Word File Viewer"

    /*PdfMultiPageView {
        anchors.fill: parent
        document: PdfDocument { source: "text/Guidelines.pdf" }
    }*/
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        Text {
            text: "To save what you have done, use File-> Save or File->Save As.\n
To import a map from external source, use File-> Import.\n
To change settings, use Options->Setting.\n
To see Log, use Options->Log.\n
How to play?\n
- Right click normal cell to rotate the shape counterclockwise.\n
- Left click normal cell to rotate the shape clockwise.\n
- Left click special cell to reverse the shape.\n
To move the shape press the special cell and move wherever you want.\n
When you added the shape to the board, double click to the shape to undo it.\n"
            color: "darkred"
            anchors.topMargin: 15
            anchors.top: parent.top
            anchors.bottomMargin: 15
            font.pixelSize: 14
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
    }
}
