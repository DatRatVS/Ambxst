import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

Item {
    id: root

    required property ShellScreen targetScreen

    readonly property alias frameEnabled: frameContent.frameEnabled
    readonly property alias thickness: frameContent.thickness
    readonly property alias actualFrameSize: frameContent.actualFrameSize
    readonly property alias innerRadius: frameContent.innerRadius

    Item {
        id: noInputRegion
        width: 0
        height: 0
        visible: false
    }

    PanelWindow {
        id: topFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitHeight: root.actualFrameSize
        color: "transparent"
        anchors {
            left: true
            right: true
            top: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:screenFrame:top"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.actualFrameSize
        mask: Region { item: noInputRegion }
    }

    PanelWindow {
        id: bottomFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitHeight: root.actualFrameSize
        color: "transparent"
        anchors {
            left: true
            right: true
            bottom: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:screenFrame:bottom"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.actualFrameSize
        mask: Region { item: noInputRegion }
    }

    PanelWindow {
        id: leftFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitWidth: root.actualFrameSize
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:screenFrame:left"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.actualFrameSize
        mask: Region { item: noInputRegion }
    }

    PanelWindow {
        id: rightFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitWidth: root.actualFrameSize
        color: "transparent"
        anchors {
            top: true
            bottom: true
            right: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:screenFrame:right"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.actualFrameSize
        mask: Region { item: noInputRegion }
    }

    PanelWindow {
        id: frameOverlay
        screen: root.targetScreen
        visible: root.frameEnabled
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:screenFrame:overlay"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        mask: Region { item: noInputRegion }

        ScreenFrameContent {
            id: frameContent
            anchors.fill: parent
            targetScreen: root.targetScreen
        }
    }
}
