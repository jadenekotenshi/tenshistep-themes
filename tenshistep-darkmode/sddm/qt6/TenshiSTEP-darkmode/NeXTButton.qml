import QtQuick

// Raised beveled square button; inverts its bevel while pressed.
Panel {
    id: b
    property alias text: lbl.text
    property color textColor: "#dcdfe4"
    signal clicked()

    base: "#3b4048"
    raised: !ma.pressed
    height: 28

    Text {
        id: lbl
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: ma.pressed ? 1 : 0
        anchors.verticalCenterOffset: ma.pressed ? 1 : 0
        font.family: "Helvetica"; font.pixelSize: 13; font.bold: true
        color: b.textColor
    }
    MouseArea { id: ma; anchors.fill: parent; onClicked: b.clicked() }
}
