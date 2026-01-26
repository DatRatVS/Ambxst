import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

Item {
    id: root

    required property ShellScreen screen
    
    // States from Bar and Dock
    property bool barEnabled: true
    property string barPosition: "top"
    property bool barPinned: true
    property bool barReveal: true
    property bool barFullscreen: false
    property int barHeight: Config.showBackground ? 44 : 40

    property bool dockEnabled: true
    property string dockPosition: "bottom"
    property bool dockPinned: true
    property bool dockReveal: true
    property bool dockFullscreen: false
    property int dockHeight: (Config.dock?.height ?? 56) + (Config.dock?.margin ?? 8) + (isDefaultDock ? 0 : (Config.dock?.margin ?? 8))
    property bool isDefaultDock: (Config.dock?.theme ?? "default") === "default"

    property bool frameEnabled: Config.bar?.frameEnabled ?? false
    property int frameThickness: {
        const value = Config.bar?.frameThickness;
        if (typeof value !== "number") return 6;
        return Math.max(1, Math.min(Math.round(value), 40));
    }
    readonly property int actualFrameSize: frameEnabled ? frameThickness : 0

    // Helper to check if a component is active for exclusive zone on a specific side
    function getExtraZone(side) {
        let zone = actualFrameSize;
        
        // Bar zone
        if (barEnabled && barPosition === side && barPinned && barReveal && !barFullscreen) {
            zone += barHeight;
        }
        
        // Dock zone
        if (dockEnabled && dockPosition === side && dockPinned && dockReveal && !dockFullscreen) {
            zone += dockHeight;
        }
        
        return zone;
    }

    Item {
        id: noInputRegion
        width: 0
        height: 0
        visible: false
    }

    PanelWindow {
        id: topWindow
        screen: root.screen
        visible: true
        implicitHeight: 1 // Minimal height
        color: "transparent"
        anchors { left: true; right: true; top: true }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:top"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.getExtraZone("top")
        mask: Region { item: noInputRegion }
    }

    PanelWindow {
        id: bottomWindow
        screen: root.screen
        visible: true
        implicitHeight: 1
        color: "transparent"
        anchors { left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:bottom"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.getExtraZone("bottom")
        mask: Region { item: noInputRegion }
    }

    PanelWindow {
        id: leftWindow
        screen: root.screen
        visible: true
        implicitWidth: 1
        color: "transparent"
        anchors { top: true; bottom: true; left: true }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:left"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.getExtraZone("left")
        mask: Region { item: noInputRegion }
    }

    PanelWindow {
        id: rightWindow
        screen: root.screen
        visible: true
        implicitWidth: 1
        color: "transparent"
        anchors { top: true; bottom: true; right: true }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:right"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: root.getExtraZone("right")
        mask: Region { item: noInputRegion }
    }
}
