import QtQuick 2.15
import "../components"

// ─────────────────────────────────────────────────────────────────────────
// TenshiSTEP-darkmode lock screen (kscreenlocker greeter) — laid out to echo
// the SDDM greeter: brand angel high-centre, a small top-right clock, and a
// central NeXT box whose bottom holds the control buttons.
//
// Auth uses the documented kscreenlocker contract: the greeter injects an
// `authenticator` context object; the password is submitted with
// `authenticator.respond(password)` and results arrive via the
// onSucceeded / onFailed / on*MessageChanged signals. Imports are kept minimal
// (QtQuick + local NeXT components only) and every context lookup is guarded, so
// a missing object degrades gracefully rather than failing to load.
//
// RECOVERY if it ever fails to unlock: switch to a TTY (Ctrl+Alt+F2), log in,
// and run `loginctl unlock-sessions`; then revert the Global Theme with
// `lookandfeeltool -a org.kde.breeze.desktop` (or delete this lockscreen/ dir
// from the installed package).
// ─────────────────────────────────────────────────────────────────────────
Item {
    id: root

    property string message: ""
    property string userName: (typeof kscreenlocker_userName !== "undefined" && kscreenlocker_userName)
                              ? ("" + kscreenlocker_userName) : "Screen Locked"

    // dimmed gunmetal backdrop (matches the SDDM greeter)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#242730" }
            GradientStop { position: 1.0; color: "#14161a" }
        }
    }

    // clock, top-right (as on the greeter)
    Text {
        id: clock
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 26
        color: "#eef2f6"; font.family: "Helvetica"; font.pixelSize: 17; font.bold: true
        style: Text.Raised; styleColor: "#40000000"
    }
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "dddd  MMMM d      h:mm AP")
    }

    // brand: angel + title, high on screen so it clears the box
    Image {
        id: brand
        source: "../splash/images/logo.svg"
        width: Math.round(root.height * 0.24); height: width
        sourceSize.width: 512; sourceSize.height: 512
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.09)
    }
    Text {
        id: brandTitle
        anchors.horizontalCenter: parent.horizontalCenter
        y: brand.y + brand.height + Math.round(root.height * 0.015)
        text: "TenshiNET"
        color: "#eef2f6"; font.family: "Helvetica"; font.bold: true
        font.pixelSize: Math.round(root.height * 0.046)
        style: Text.Raised; styleColor: "#40000000"
    }

    // hard drop shadow behind the box
    Rectangle {
        x: dialog.x + 6; y: dialog.y + 6; z: -1
        width: dialog.width; height: dialog.height; color: "#55000000"
    }

    // central NeXT unlock box
    Panel {
        id: dialog
        width: 404
        height: 58 + body.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.50)
        base: "#3b4048"
        raised: true

        Rectangle {
            id: titleBar
            x: 2; y: 2; width: parent.width - 4; height: 26; color: "#6a5fd6"
            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: "#ffffff"; opacity: 0.40
            }
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: "#1a1a1a"; opacity: 0.40
            }
            Text {
                anchors.centerIn: parent; text: root.userName
                color: "#ffffff"; font.family: "Helvetica"; font.pixelSize: 13; font.bold: true
            }
        }

        Column {
            id: body
            anchors.top: titleBar.bottom; anchors.topMargin: 16
            anchors.left: parent.left; anchors.right: parent.right
            anchors.leftMargin: 16; anchors.rightMargin: 16
            spacing: 12

            Text {
                text: "Password:"
                color: "#dcdfe4"; font.family: "Helvetica"; font.pixelSize: 12; font.bold: true
            }
            NeXTField {
                id: pw
                width: parent.width
                echoMode: TextInput.Password
                onAccepted: root.submit()
            }
            Text {
                id: err
                width: parent.width
                text: root.message; visible: root.message !== ""
                color: "#d67a6f"; font.family: "Helvetica"; font.pixelSize: 12; wrapMode: Text.Wrap
            }

            // NeXT groove separator
            Item {
                width: parent.width; height: 3
                Rectangle { width: parent.width; height: 1; color: "#14161a" }
                Rectangle { y: 1; width: parent.width; height: 1; color: "#565d67" }
            }

            // control buttons, bottom of the box
            Item {
                width: parent.width; height: 30
                NeXTButton {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    width: 120; height: 28; text: "Cancel"; textColor: "#9aa0a8"
                    onClicked: { pw.text = ""; root.message = ""; pw.field.forceActiveFocus() }
                }
                NeXTButton {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    width: 120; height: 28; text: "Unlock"; textColor: "#dcdfe4"
                    onClicked: root.submit()
                }
            }
        }
    }

    function submit() {
        root.message = ""
        if (typeof authenticator !== "undefined" && authenticator
                && typeof authenticator.respond === "function") {
            authenticator.respond(pw.text)
        } else {
            root.message = "Authentication backend unavailable."
        }
    }

    Connections {
        target: (typeof authenticator !== "undefined") ? authenticator : null
        ignoreUnknownSignals: true
        function onSucceeded() { /* greeter dismisses the lock screen */ }
        function onFailed() {
            root.message = "Incorrect password."
            pw.text = ""
            pw.field.forceActiveFocus()
        }
        function onErrorMessageChanged() {
            if (authenticator.errorMessage) root.message = authenticator.errorMessage
        }
        function onInfoMessageChanged() {
            if (authenticator.infoMessage) root.message = authenticator.infoMessage
        }
    }

    Keys.onEscapePressed: { pw.text = ""; root.message = "" }
    Component.onCompleted: pw.field.forceActiveFocus()
}
