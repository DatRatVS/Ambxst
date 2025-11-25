pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    readonly property int gridRows: 3
    readonly property int gridColumns: 5
    readonly property int separatorWidth: 2
    readonly property int spacing: 8
    readonly property int adjustmentPadding: 8
    readonly property int wallpaperMargin: 4

    function calculateLeftPanelWidth(containerWidth, containerHeight, containerSpacing) {
        var actualSpacing = containerSpacing !== undefined ? containerSpacing : spacing;
        var remainingWidth = containerWidth - actualSpacing * 2 - separatorWidth;
        var wallpaperHeight = (containerHeight + 4 * 2) / gridRows;
        var rightPanelWidth = (wallpaperHeight * gridColumns) - adjustmentPadding;
        return remainingWidth - rightPanelWidth;
    }

    function calculateRightPanelWidth(containerHeight) {
        var wallpaperHeight = (containerHeight + 4 * 2) / gridRows;
        return (wallpaperHeight * gridColumns) - adjustmentPadding;
    }
}
