import QtQuick 2.0

Rectangle {
    property int labelText: -1
    id: cell
    color: "white"
    width: cellSize
    height: cellSize
    radius: cellSize/4
    border.color: labelText  === -1 ? "transparent":"black"
}
