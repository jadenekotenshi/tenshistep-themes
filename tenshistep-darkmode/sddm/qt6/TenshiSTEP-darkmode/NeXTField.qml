import QtQuick

// Recessed white NeXT text field. Frame turns steel-blue while focused.
Panel {
    id: f
    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias field: input
    property string placeholder: ""
    signal accepted()

    base: "#202226"
    raised: false
    frame: input.activeFocus ? "#6a5fd6" : "#dcdfe4"
    height: 28

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 8; anchors.rightMargin: 8
        verticalAlignment: TextInput.AlignVCenter
        font.family: "Helvetica"; font.pixelSize: 14
        color: "#dcdfe4"
        selectionColor: "#6a5fd6"
        clip: true
        selectByMouse: true
        onAccepted: f.accepted()
    }
    Text {
        anchors.left: parent.left; anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        text: f.placeholder; color: "#7a808a"
        font.family: "Helvetica"; font.pixelSize: 14
        visible: input.text.length === 0 && !input.activeFocus
    }
}
