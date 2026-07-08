import QtQuick 2.5

// KSplash QML greeter. The engine sizes this root to the screen and bumps
// `stage` from 0 to 6 as the session starts up.
Rectangle {
    id: root
    property int stage

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#242730" }
        GradientStop { position: 1.0; color: "#14161a" }
    }

    Column {
        anchors.centerIn: parent
        spacing: 22

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/logo.svg"
            width: 96; height: 96
            sourceSize.width: 96; sourceSize.height: 96
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "TenshiSTEP-darkmode"
            color: "#ffffff"; font.family: "Helvetica"; font.pixelSize: 26; font.bold: true
            style: Text.Raised; styleColor: "#40000000"
        }

        // recessed groove with a filling steel-blue bar
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 260; height: 16

            Rectangle {
                anchors.fill: parent
                color: "#4a4f57"; border.color: "#dcdfe4"; border.width: 1
                Rectangle { x: 1; y: 1; width: parent.width - 2; height: 1; color: "#14161a" } // inset top shadow
                Rectangle { x: 1; y: parent.height - 2; width: parent.width - 2; height: 1; color: "#ffffff" }
            }
            Rectangle {
                x: 2; y: 2; height: parent.height - 4
                width: Math.max(0, (parent.width - 4) * Math.min(1, root.stage / 6.0))
                color: "#6a5fd6"
                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#ffffff"; opacity: 0.5 }
            }
        }
    }
}
