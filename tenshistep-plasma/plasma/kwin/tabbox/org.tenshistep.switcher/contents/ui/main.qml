/*
 * TenshiSTEP window switcher (light) — NeXT/OPENSTEP idiom.
 *
 * KWin provides the `tabBox` context object (model, currentIndex).
 * If this theme fails to load, KWin silently falls back to its
 * built-in switcher, so there is no risk of a keyboard lockout.
 */
import QtQuick 2.15

Item {
    id: root

    // Written by KWin so the theme can size relative to the screen.
    property int screenWidth: 800
    property int screenHeight: 600

    // NeXT bevel palette (light).
    readonly property color colBase:      "#a6adb8"
    readonly property color colFrame:     "#1a1a1a"
    readonly property color colHighlight: "#ffffff"
    readonly property color colShadow:    "#5c626b"
    readonly property color colAccent:    "#4a3fa0"
    readonly property color colText:      "#101010"
    readonly property color colTextSel:   "#ffffff"

    readonly property int cellHeight: 42
    readonly property int iconSize:   32
    readonly property int cellPadding: 10

    // Overall panel size is driven by its content (the ListView).
    width: Math.min(panel.implicitWidth, screenWidth * 0.9)
    height: cellHeight + 2 * (frame.border.width + inner.anchors.margins) + 12

    // --- Outer 1px dark frame -------------------------------------------
    Rectangle {
        id: frame
        anchors.fill: parent
        color: root.colBase
        border.color: root.colFrame
        border.width: 1
        radius: 0

        // --- Bevel highlight (top / left) -------------------------------
        Rectangle {
            anchors {
                left: parent.left; top: parent.top; right: parent.right
                leftMargin: 1; topMargin: 1; rightMargin: 1
            }
            height: 2
            color: root.colHighlight
        }
        Rectangle {
            anchors {
                left: parent.left; top: parent.top; bottom: parent.bottom
                leftMargin: 1; topMargin: 1; bottomMargin: 1
            }
            width: 2
            color: root.colHighlight
        }

        // --- Bevel shadow (bottom / right) ------------------------------
        Rectangle {
            anchors {
                left: parent.left; right: parent.right; bottom: parent.bottom
                leftMargin: 1; rightMargin: 1; bottomMargin: 1
            }
            height: 2
            color: root.colShadow
        }
        Rectangle {
            anchors {
                top: parent.top; right: parent.right; bottom: parent.bottom
                topMargin: 1; rightMargin: 1; bottomMargin: 1
            }
            width: 2
            color: root.colShadow
        }

        // --- Inner content area -----------------------------------------
        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: 6

            ListView {
                id: panel
                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 4
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                implicitWidth: contentWidth + leftMargin + rightMargin
                leftMargin: 2
                rightMargin: 2

                model: tabBox.model
                currentIndex: tabBox.currentIndex
                onCurrentIndexChanged: tabBox.currentIndex = currentIndex

                delegate: Item {
                    id: delegateItem
                    height: root.cellHeight
                    width: iconEl.width + captionEl.implicitWidth
                           + root.cellPadding * 3

                    readonly property bool selected:
                        panel.currentIndex === index

                    Rectangle {
                        anchors.fill: parent
                        color: delegateItem.selected ? root.colAccent
                                                     : "transparent"
                    }

                    Image {
                        id: iconEl
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: root.cellPadding
                        width: root.iconSize
                        height: root.iconSize
                        sourceSize.width: root.iconSize
                        sourceSize.height: root.iconSize
                        fillMode: Image.PreserveAspectFit
                        source: model.icon
                        asynchronous: true
                    }

                    Text {
                        id: captionEl
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: iconEl.right
                        anchors.leftMargin: root.cellPadding
                        text: model.caption !== undefined ? model.caption : ""
                        elide: Text.ElideRight
                        color: delegateItem.selected ? root.colTextSel
                                                     : root.colText
                        font.family: "Helvetica"
                        font.pixelSize: 13
                        font.bold: delegateItem.selected
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            panel.currentIndex = index;
                            tabBox.currentIndex = index;
                        }
                    }
                }
            }
        }
    }
}
