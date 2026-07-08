import QtQuick 2.15
import "../components"

// ─────────────────────────────────────────────────────────────────────────
// EXPERIMENTAL TenshiSTEP-darkmode lock screen (kscreenlocker greeter).
//
// Uses the documented kscreenlocker contract: the greeter injects an
// `authenticator` context object; the password is submitted with
// `authenticator.respond(password)` and the result arrives via the
// onSucceeded / onFailed / on*MessageChanged signals.
//
// NOT verified on a live Plasma session; third-party lockscreens drift across
// Plasma versions. Imports are minimal and the Connections block is defensive.
//
// RECOVERY if it ever fails to unlock: switch to a TTY (Ctrl+Alt+F2), log in,
// run `loginctl unlock-sessions`, then revert the Global Theme with
// `lookandfeeltool -a org.kde.breeze.desktop` (or delete this lockscreen/ dir).
// ─────────────────────────────────────────────────────────────────────────
Item {
    id: root

    property string message: ""

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#242730" }
            GradientStop { position: 1.0; color: "#14161a" }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.round(parent.height * 0.16)
        spacing: 2
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#eef2f6"; font.family: "Helvetica"; font.pixelSize: 64; font.bold: true
            text: Qt.formatTime(new Date(), "h:mm")
        }
        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#aab0ba"; font.family: "Helvetica"; font.pixelSize: 20
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            clock.text = Qt.formatTime(new Date(), "h:mm")
            dateLabel.text = Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }

    Panel {
        id: dialog
        anchors.centerIn: parent
        width: 380
        height: 40 + col.implicitHeight
        base: "#3b4048"
        raised: true

        Rectangle {
            id: titleBar
            x: 2; y: 2; width: parent.width - 4; height: 26; color: "#6a5fd6"
            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: "#ffffff"; opacity: 0.45
            }
            Text {
                anchors.centerIn: parent; text: "Locked — squirrel"
                color: "#ffffff"; font.family: "Helvetica"; font.pixelSize: 13; font.bold: true
            }
        }

        Column {
            id: col
            anchors.top: titleBar.bottom; anchors.topMargin: 16
            anchors.left: parent.left; anchors.right: parent.right
            anchors.leftMargin: 16; anchors.rightMargin: 16
            spacing: 12

            Text {
                text: "Password:"
                color: "#dcdfe4"; font.family: "Helvetica"; font.pixelSize: 13; font.bold: true
            }
            NeXTField {
                id: pw
                width: parent.width
                echoMode: TextInput.Password
                onAccepted: root.submit()
            }
            Text {
                text: root.message
                visible: root.message !== ""
                color: "#d67a6f"; font.family: "Helvetica"; font.pixelSize: 12
                wrapMode: Text.Wrap; width: parent.width
            }
            NeXTButton {
                width: 120; height: 30; text: "Unlock"; textColor: "#dcdfe4"
                onClicked: root.submit()
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
