import QtQuick 2.15
import "../components"

// ─────────────────────────────────────────────────────────────────────────
// TenshiSTEP-zirconium lock screen (kscreenlocker greeter) — laid out to echo the SDDM
// greeter: brand angel high-centre, a small top-right clock, and a central
// NeXT box whose bottom holds the control buttons.
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

    // dimmed brushed-steel backdrop (matches the SDDM greeter)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#a8abae" }
            GradientStop { position: 1.0; color: "#6e7173" }
        }
    }

    // clock, top-right (as on the greeter)
    Text {
        id: clock
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 26
        color: "#ffffff"; font.family: "Helvetica"; font.pixelSize: 17; font.bold: true
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
        color: "#ffffff"; font.family: "Helvetica"; font.bold: true
        font.pixelSize: Math.round(root.height * 0.046)
        style: Text.Raised; styleColor: "#40000000"
    }

    // hard drop shadow behind the box
    Rectangle {
        x: dialog.x + 6; y: dialog.y + 6; z: -1
        width: dialog.width; height: dialog.height; color: "#33000000"
    }

    // central NeXT unlock box
    Panel {
        id: dialog
        width: 404
        height: 58 + body.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.50)
        base: "#9a9d9f"
        raised: true

        // literal brushed-aluminum streak across the panel body
        Column {
            x: 2; y: 30; width: parent.width - 4
            spacing: 2
            Repeater {
                model: Math.max(0, Math.floor((dialog.height - 32) / 3))
                delegate: Rectangle { width: dialog.width - 4; height: 1; color: "#ffffff"; opacity: 0.16 }
            }
        }

        Rectangle {
            id: titleBar
            x: 2; y: 2; width: parent.width - 4; height: 26; color: "#487697"
            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: "#ffffff"; opacity: 0.45
            }
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: "#1a1a1a"; opacity: 0.35
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
                color: "#1a1a1a"; font.family: "Helvetica"; font.pixelSize: 12; font.bold: true
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
                color: "#8f2218"; font.family: "Helvetica"; font.pixelSize: 12; wrapMode: Text.Wrap
            }

            // NeXT groove separator
            Item {
                width: parent.width; height: 3
                Rectangle { width: parent.width; height: 1; color: "#5c5e60" }
                Rectangle { y: 1; width: parent.width; height: 1; color: "#ffffff" }
            }

            // control buttons, bottom of the box
            Item {
                width: parent.width; height: 30
                NeXTButton {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    width: 120; height: 28; text: "Cancel"; textColor: "#5c5e60"
                    onClicked: { pw.text = ""; root.message = ""; pw.field.forceActiveFocus() }
                }
                NeXTButton {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    width: 120; height: 28; text: "Unlock"; textColor: "#487697"
                    onClicked: root.submit()
                }
            }
        }
    }

    // Guards against a single Enter press (or Unlock click) resulting in
    // more than one authenticator.respond() call. This is the actual root
    // cause found live: on some systems Return key-repeat fires TextInput's
    // accepted() several times in quick succession; PAM only expects one
    // answer per outstanding prompt, and multiple respond() calls for the
    // same prompt corrupted/hung the conversation until the watchdog forced
    // a restart. The stock greeter avoids this by disabling its password
    // field while a response is in flight -- this does the same via a flag.
    property bool authInFlight: false

    function submit() {
        if (root.authInFlight) {
            return
        }
        root.message = ""
        if (typeof authenticator !== "undefined" && authenticator
                && typeof authenticator.respond === "function") {
            root.authInFlight = true
            authenticator.respond(pw.text)
            submitWatchdog.restart()
        } else {
            root.message = "Authentication backend unavailable."
        }
    }

    // Self-healing backstop: if a submitted response produces neither
    // onSucceeded nor onFailed within a few seconds -- the PAM conversation
    // went stale (e.g. this screen sat idle a while after a timeout-lock,
    // as opposed to an immediate manual unlock) -- re-arm and let the user
    // try again instead of leaving the screen stuck with no feedback.
    Timer {
        id: submitWatchdog
        interval: 4000
        onTriggered: {
            root.authInFlight = false
            root.message = "Reconnecting — please try again."
            pw.text = ""
            pw.field.forceActiveFocus()
            root.startAuth()
        }
    }

    // Begin/restart the PAM conversation — required before respond() does anything.
    function startAuth() {
        if (typeof authenticator !== "undefined" && authenticator
                && typeof authenticator.startAuthenticating === "function")
            authenticator.startAuthenticating()
    }

    Connections {
        target: (typeof authenticator !== "undefined") ? authenticator : null
        ignoreUnknownSignals: true
        function onSucceeded() {
            // this UI only supports password auth (no fingerprint/smartcard flow to
            // fall back to), so any success -- prompted or not -- means unlock now. The
            // stock greeter's hadPrompt-gated branch left this silently doing nothing
            // when hadPrompt was false, hanging the screen after a correct password.
            root.authInFlight = false
            submitWatchdog.stop()
            Qt.quit()
        }
        function onFailed(kind) {
            if (kind !== undefined && kind !== 0) return   // ignore non-interactive authenticators
            root.authInFlight = false
            submitWatchdog.stop()
            root.message = "Authentication failed — please try again."
            pw.text = ""
            pw.field.forceActiveFocus()
            root.startAuth()                                // re-arm PAM for the next attempt
        }
        function onInfoMessageChanged() {
            if (authenticator.infoMessage) root.message = authenticator.infoMessage
        }
        function onErrorMessageChanged() {
            if (authenticator.errorMessage) root.message = authenticator.errorMessage
        }
        function onPromptChanged() {
            if (authenticator.prompt) root.message = authenticator.prompt
        }
        function onPromptForSecretChanged() {
            pw.field.forceActiveFocus()
        }
    }

    Keys.onEscapePressed: { pw.text = ""; root.message = "" }
    // Found live (journalctl-confirmed) that the PAM/kwallet conversation
    // started at load goes idle-stale if the screen sits locked a real few
    // minutes (the normal case for a timeout-lock, vs. an immediate manual
    // unlock): pam_kwallet5's slower unwrap/setcred path silently never
    // completes for the first respond() after a long gap, while a FRESH
    // startAuthenticating() issued right before an attempt always works
    // instantly. Neither call timing (synchronous vs. deferred) nor
    // duplicate-call suppression changed this -- it is server-side kwallet/
    // PAM idle behaviour, not a QML sequencing bug. Rather than reactively
    // detecting and retrying (the submitWatchdog below still does that as a
    // backstop), proactively keep the conversation warm with a periodic
    // re-arm while locked and idle, so it's never more than 30s stale by
    // the time a real attempt happens.
    Component.onCompleted: { root.startAuth(); pw.field.forceActiveFocus() }
    Timer {
        interval: 30000; running: true; repeat: true
        onTriggered: if (!root.authInFlight) root.startAuth()
    }
}
