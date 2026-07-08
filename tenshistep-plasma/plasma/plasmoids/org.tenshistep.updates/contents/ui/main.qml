/*
 * TenshiSTEP Updates — a small panel applet that runs tenshistep-update-notifier
 * --print periodically, shows the matching themed status icon + count, and opens
 * Discover on click. Targets Plasma 6 (PlasmoidItem / Plasma5Support / Kirigami).
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property int updateCount: 0
    property bool security: false
    property string statusIcon: "update-none"
    property string statusText: i18n("Checking for updates…")

    readonly property string notifier: "$HOME/.local/bin/tenshistep-update-notifier --print"

    function refreshIcon() {
        if (security) statusIcon = "security-high"
        else if (updateCount === 0) statusIcon = "update-none"
        else if (updateCount < 10) statusIcon = "update-low"
        else if (updateCount < 50) statusIcon = "update-medium"
        else statusIcon = "update-high"
    }

    P5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            var out = ("" + (data["stdout"] || "")).trim()
            exec.disconnectSource(source)
            if (out.length === 0) return
            root.statusText = out
            root.security = out.toLowerCase().indexOf("security") !== -1
            var m = out.match(/(\d+)/)
            root.updateCount = m ? parseInt(m[1]) : 0
            root.refreshIcon()
        }
        function check() { connectSource(root.notifier) }
        function run(cmd) { connectSource(cmd) }
    }

    Timer {
        interval: 1800000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: exec.check()
    }

    Plasmoid.icon: statusIcon
    toolTipMainText: i18n("Software Updates")
    toolTipSubText: statusText

    compactRepresentation: MouseArea {
        hoverEnabled: true
        onClicked: exec.run("plasma-discover --mode update")
        Kirigami.Icon {
            anchors.fill: parent
            source: root.statusIcon
            active: parent.containsMouse
        }
    }

    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            Kirigami.Icon { source: root.statusIcon; implicitWidth: Kirigami.Units.iconSizes.large; implicitHeight: width }
            ColumnLayout {
                PC3.Label { text: i18n("Software Updates"); font.bold: true }
                PC3.Label { text: root.statusText; opacity: 0.8; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            PC3.Button { text: i18n("Check now"); icon.name: "view-refresh"; onClicked: exec.check() }
            PC3.Button { text: i18n("Open Discover"); icon.name: "system-software-update"; onClicked: exec.run("plasma-discover --mode update") }
        }
    }
}
