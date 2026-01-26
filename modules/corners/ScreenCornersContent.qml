import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.corners
import qs.modules.theme
import qs.config

Item {
    id: root

    readonly property bool frameEnabled: Config.bar?.frameEnabled ?? false
    readonly property int thickness: {
        const value = Config.bar?.frameThickness;
        if (typeof value !== "number")
            return 6;
        return Math.max(1, Math.min(Math.round(value), 40));
    }

    readonly property int cornerSize: Styling.radius(4) + (frameEnabled ? thickness : 0)

    anchors.fill: parent

    RoundCorner {
        id: topLeft
        size: root.cornerSize
        anchors.left: parent.left
        anchors.top: parent.top
        corner: RoundCorner.CornerEnum.TopLeft
    }

    RoundCorner {
        id: topRight
        size: root.cornerSize
        anchors.right: parent.right
        anchors.top: parent.top
        corner: RoundCorner.CornerEnum.TopRight
    }

    RoundCorner {
        id: bottomLeft
        size: root.cornerSize
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        corner: RoundCorner.CornerEnum.BottomLeft
    }

    RoundCorner {
        id: bottomRight
        size: root.cornerSize
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        corner: RoundCorner.CornerEnum.BottomRight
    }
}
