import QtQuick

// Recessed white NeXT text field. Frame turns steel-blue while focused.
Panel {
    id: f
    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias field: input
    property string placeholder: ""
    signal accepted()

    base: "#ffffff"
    raised: false
    frame: input.activeFocus ? "#4a3fa0" : "#1a1a1a"
    height: 28

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 8; anchors.rightMargin: 8
        verticalAlignment: TextInput.AlignVCenter
        font.family: "Helvetica"; font.pixelSize: 14
        color: "#1a1a1a"
        selectionColor: "#4a3fa0"
        clip: true
        selectByMouse: true
        onAccepted: f.accepted()
    }
    Text {
        anchors.left: parent.left; anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        text: f.placeholder; color: "#9aa0a6"
        font.family: "Helvetica"; font.pixelSize: 14
        visible: input.text.length === 0 && !input.activeFocus
    }
}
