import QtQuick
import Quickshell
import Quickshell.Wayland
import "."
import qs.config

PanelWindow {
    id: screenCorners

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:screenCorners"
    mask: Region {
        item: null
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    RoundCorner {
        id: topLeft
        size: Configuration.roundness > 0 ? Configuration.roundness + 4 : 0
        anchors.left: parent.left
        anchors.top: parent.top
        corner: RoundCorner.CornerEnum.TopLeft
    }

    RoundCorner {
        id: topRight
        size: Configuration.roundness > 0 ? Configuration.roundness + 4 : 0
        anchors.right: parent.right
        anchors.top: parent.top
        corner: RoundCorner.CornerEnum.TopRight
    }

    RoundCorner {
        id: bottomLeft
        size: Configuration.roundness > 0 ? Configuration.roundness + 4 : 0
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        corner: RoundCorner.CornerEnum.BottomLeft
    }

    RoundCorner {
        id: bottomRight
        size: Configuration.roundness > 0 ? Configuration.roundness + 4 : 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        corner: RoundCorner.CornerEnum.BottomRight
    }
}
