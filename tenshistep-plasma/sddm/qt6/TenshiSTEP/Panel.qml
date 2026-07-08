import QtQuick

// Chiselled NeXT bevel container.
//   raised = true  -> highlight top/left, shadow bottom/right (a raised button/panel)
//   raised = false -> inset (recessed text field)
// Add child items directly; they stack above the bevel edges.
Item {
    id: p
    property color base: "#a6adb8"
    property color frame: "#1a1a1a"
    property bool raised: true
    property color _tl: raised ? "#ffffff" : "#8a8f96"
    property color _br: raised ? "#5c626b" : "#ffffff"

    Rectangle { anchors.fill: parent; color: p.base; border.color: p.frame; border.width: 1 }
    Rectangle { x: 1; y: 1; width: p.width - 2; height: 1; color: p._tl }
    Rectangle { x: 1; y: 1; width: 1; height: p.height - 2; color: p._tl }
    Rectangle { x: 1; y: p.height - 2; width: p.width - 2; height: 1; color: p._br }
    Rectangle { x: p.width - 2; y: 1; width: 1; height: p.height - 2; color: p._br }
}
