import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: screenCorners

    visible: Config.theme.enableCorners && Config.roundness > 0

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:screenCorners"
    WlrLayershell.layer: WlrLayer.Overlay
    mask: Region {
        item: null
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    ScreenCornersContent {
        id: cornersContent
        anchors.fill: parent
    }
}
