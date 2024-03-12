import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Pdf
Window {
    visible: true
    width: 800
    height: 600
    title: "Word File Viewer"

    PdfMultiPageView {
        anchors.fill: parent
        document: PdfDocument { source: "text/Guidelines.pdf" }
    }
    Button {
        id: btnOK
        text: "\u{2705}"
        width: buttonSize*1.4
        height: buttonSize
        font.pixelSize: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        onClicked: {
            close()
        }
    }
}
