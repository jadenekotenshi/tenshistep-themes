import QtQuick 2.0

Rectangle {
    id: root
    width: 1024
    height: 768
    color: "#66788c"

    property int sessionIndex: 0
    property string sessionName: "Default"

    // login panel sits at 46% on widescreen; drop it further on
    // taller 4:3/5:4 panels (validated down to 1280x1024, the floor).
    property real panelFrac: (root.width / root.height) < 1.5 ? 0.52 : 0.46

    function cfg(k, d) {
        return (typeof config !== "undefined" && config[k] && ("" + config[k]).length) ? config[k] : d
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: root.cfg("backgroundTop", "#242730") }
        GradientStop { position: 1.0; color: root.cfg("backgroundBottom", "#101216") }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: root.cfg("background", "")
        visible: source != ""
    }

    // --- clock (top-right) ---
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

    // --- brand: big angel + title, high on screen so it clears the login box ---
    Image {
        id: brand
        source: "assets/logo.svg"
        width: Math.round(root.height * 0.26); height: width
        sourceSize.width: 512; sourceSize.height: 512
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.07)
    }
    Text {
        id: brandTitle
        anchors.horizontalCenter: parent.horizontalCenter
        y: brand.y + brand.height + Math.round(root.height * 0.015)
        text: "TenshiNET"
        color: "#e6e9ee"; font.family: "Helvetica"; font.bold: true
        font.pixelSize: Math.round(root.height * 0.048)
        style: Text.Raised; styleColor: "#40000000"
    }

    // --- hard drop shadow behind the login panel ---
    Rectangle {
        x: panel.x + 6; y: panel.y + 6; z: -1
        width: panel.width; height: panel.height; color: "#33000000"
    }

    // --- login panel (dropped below the brand) ---
    Panel {
        id: panel
        width: 404
        height: 58 + body.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * root.panelFrac)
        base: root.cfg("panelColor", "#3b4048")
        raised: true

        Rectangle {
            id: titleBar
            x: 2; y: 2; width: parent.width - 4; height: 26
            color: root.cfg("titleColor", "#6a5fd6")
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#ffffff"; opacity: 0.45 }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#0d0e11"; opacity: 0.35 }
            Text {
                anchors.centerIn: parent
                text: (typeof sddm !== "undefined" && sddm.hostName) ? sddm.hostName : "TenshiSTEP"
                color: "#ffffff"; font.family: "Helvetica"; font.pixelSize: 13; font.bold: true
            }
        }

        Column {
            id: body
            anchors.top: titleBar.bottom; anchors.topMargin: 14
            anchors.left: parent.left; anchors.right: parent.right
            anchors.leftMargin: 16; anchors.rightMargin: 16
            spacing: 12

            Column {
                spacing: 3; width: parent.width
                Text { text: "Name:"; color: "#dcdfe4"; font.family: "Helvetica"; font.pixelSize: 12; font.bold: true }
                NeXTField {
                    id: userField
                    width: parent.width
                    placeholder: "username"
                    text: (typeof userModel !== "undefined" && userModel.lastUser) ? userModel.lastUser : ""
                    onAccepted: passField.field.forceActiveFocus()
                }
            }

            Column {
                spacing: 3; width: parent.width
                Text { text: "Password:"; color: "#dcdfe4"; font.family: "Helvetica"; font.pixelSize: 12; font.bold: true }
                NeXTField {
                    id: passField
                    width: parent.width
                    placeholder: "password"
                    echoMode: TextInput.Password
                    onAccepted: root.doLogin()
                }
            }

            Text {
                id: err
                width: parent.width
                text: ""; visible: text != ""
                color: "#e06a5e"; font.family: "Helvetica"; font.pixelSize: 12; wrapMode: Text.WordWrap
            }

            Item {
                width: parent.width; height: 30
                NeXTButton {
                    id: sessionBtn
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    width: 190; height: 28
                    text: "▴  " + root.sessionName
                    onClicked: {
                        var pt = sessionBtn.mapToItem(root, 0, 0)
                        sessionPopup.x = pt.x
                        sessionPopup.y = pt.y - sessionPopup.height - 3
                        sessionPopup.visible = !sessionPopup.visible
                    }
                }
                NeXTButton {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    width: 118; height: 28
                    text: "Log In"
                    onClicked: root.doLogin()
                }
            }

            Item {
                width: parent.width; height: 3
                Rectangle { width: parent.width; height: 1; color: "#14161a" }
                Rectangle { y: 1; width: parent.width; height: 1; color: "#565d67" }
            }

            Row {
                width: parent.width
                spacing: 9
                NeXTButton {
                    width: 118; height: 28; text: "Sleep"; textColor: "#8f88e8"
                    visible: (typeof sddm !== "undefined") ? sddm.canSuspend : true
                    onClicked: if (typeof sddm !== "undefined") sddm.suspend()
                }
                NeXTButton {
                    width: 118; height: 28; text: "Restart"; textColor: "#d7a44a"
                    visible: (typeof sddm !== "undefined") ? sddm.canReboot : true
                    onClicked: if (typeof sddm !== "undefined") sddm.reboot()
                }
                NeXTButton {
                    width: 118; height: 28; text: "Shut Down"; textColor: "#e06a5e"
                    visible: (typeof sddm !== "undefined") ? sddm.canPowerOff : true
                    onClicked: if (typeof sddm !== "undefined") sddm.powerOff()
                }
            }
        }
    }

    Panel {
        id: sessionPopup
        parent: root
        visible: false
        raised: true; base: "#202226"
        width: 200
        height: sessCol.height + 6
        z: 10
        Column {
            id: sessCol
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 3
            Repeater {
                model: (typeof sessionModel !== "undefined") ? sessionModel : 0
                delegate: Rectangle {
                    width: sessCol.width; height: 24
                    color: sma.containsMouse ? "#6a5fd6" : "#202226"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter; x: 7
                        text: model.name
                        color: sma.containsMouse ? "#ffffff" : "#dcdfe4"
                        font.family: "Helvetica"; font.pixelSize: 13
                    }
                    MouseArea {
                        id: sma; anchors.fill: parent; hoverEnabled: true
                        onClicked: { root.sessionIndex = index; root.sessionName = model.name; sessionPopup.visible = false }
                    }
                    Component.onCompleted: if (index === root.sessionIndex) root.sessionName = model.name
                }
            }
        }
    }

    function doLogin() {
        err.text = ""
        if (typeof sddm !== "undefined")
            sddm.login(userField.text, passField.text, Math.max(0, root.sessionIndex))
    }

    Connections {
        target: (typeof sddm !== "undefined") ? sddm : null
        onLoginFailed: {
            err.text = "Authentication failed — please try again."
            passField.text = ""
            passField.field.forceActiveFocus()
        }
        onLoginSucceeded: err.text = ""
    }

    Component.onCompleted: {
        if (typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0)
            root.sessionIndex = sessionModel.lastIndex
        if (userField.text.length > 0)
            passField.field.forceActiveFocus()
        else
            userField.field.forceActiveFocus()
    }
}
