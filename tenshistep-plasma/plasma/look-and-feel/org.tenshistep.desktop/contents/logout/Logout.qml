import QtQuick 2.5
import "../components"

// ksmserver logout greeter. The theme root declares the signals the greeter
// connects to, and reads the can* properties it sets.
Item {
    id: root

    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal cancelRequested()
    signal lockScreenRequested()

    property bool canLogout: true
    property bool canShutdown: true
    property bool canReboot: true
    property bool canSuspend: true
    property bool canHibernate: true
    property int sdtype: 0

    anchors.fill: parent

    // dimmed OPENSTEP-blue backdrop; click outside cancels
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#93a6ba" }
            GradientStop { position: 1.0; color: "#5f7186" }
        }
        opacity: 0.9
        MouseArea { anchors.fill: parent; onClicked: root.cancelRequested() }
    }

    Panel {
        id: dialog
        anchors.centerIn: parent
        width: 420
        height: 40 + col.implicitHeight
        base: "#a6adb8"
        raised: true

        Rectangle {
            id: title
            x: 2; y: 2; width: parent.width - 4; height: 26; color: "#4a3fa0"
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#ffffff"; opacity: 0.45 }
            Text { anchors.centerIn: parent; text: "Leave squirrel"; color: "#ffffff"; font.family: "Helvetica"; font.pixelSize: 13; font.bold: true }
        }

        Column {
            id: col
            anchors.top: title.bottom; anchors.topMargin: 16
            anchors.left: parent.left; anchors.right: parent.right
            anchors.leftMargin: 16; anchors.rightMargin: 16
            spacing: 16

            Text {
                text: "Do you want to end your session?"
                color: "#1a1a1a"; font.family: "Helvetica"; font.pixelSize: 15; font.bold: true
            }

            Grid {
                width: parent.width
                columns: 3; spacing: 10
                NeXTButton { width: 118; height: 30; text: "Sleep"; textColor: "#241d58"; visible: root.canSuspend; onClicked: root.suspendRequested(2) }
                NeXTButton { width: 118; height: 30; text: "Restart"; textColor: "#8a5a15"; visible: root.canReboot; onClicked: root.rebootRequested() }
                NeXTButton { width: 118; height: 30; text: "Shut Down"; textColor: "#8f2218"; visible: root.canShutdown; onClicked: root.haltRequested() }
                NeXTButton { width: 118; height: 30; text: "Log Out"; textColor: "#1a1a1a"; visible: root.canLogout; onClicked: root.logoutRequested() }
                NeXTButton { width: 118; height: 30; text: "Lock"; textColor: "#3a3a3a"; onClicked: root.lockScreenRequested() }
                NeXTButton { width: 118; height: 30; text: "Cancel"; textColor: "#1a1a1a"; onClicked: root.cancelRequested() }
            }
        }
    }

    Keys.onEscapePressed: root.cancelRequested()
    Component.onCompleted: forceActiveFocus()
}
