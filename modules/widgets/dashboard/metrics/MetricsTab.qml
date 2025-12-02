pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: 400
    implicitHeight: 400

    // Load refresh interval from state
    Component.onCompleted: {
        const savedInterval = StateService.get("metricsRefreshInterval", 2000);
        SystemResources.updateInterval = Math.max(100, savedInterval);
        historyTimer.interval = SystemResources.updateInterval;
    }

    // History data for the chart
    property var cpuHistory: []
    property var ramHistory: []
    property var gpuHistory: []
    property int maxHistoryPoints: 50

    // Timer to update history
    Timer {
        id: historyTimer
        interval: SystemResources.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // Create new arrays with new data points
            let newCpuHistory = root.cpuHistory.slice();
            newCpuHistory.push(SystemResources.cpuUsage / 100);
            if (newCpuHistory.length > root.maxHistoryPoints) {
                newCpuHistory.shift();
            }
            root.cpuHistory = newCpuHistory;

            let newRamHistory = root.ramHistory.slice();
            newRamHistory.push(SystemResources.ramUsage / 100);
            if (newRamHistory.length > root.maxHistoryPoints) {
                newRamHistory.shift();
            }
            root.ramHistory = newRamHistory;

            if (SystemResources.gpuDetected) {
                let newGpuHistory = root.gpuHistory.slice();
                newGpuHistory.push(SystemResources.gpuUsage / 100);
                if (newGpuHistory.length > root.maxHistoryPoints) {
                    newGpuHistory.shift();
                }
                root.gpuHistory = newGpuHistory;
            }

            // Trigger repaint
            chartCanvas.requestPaint();
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // Left panel - Resources
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            color: "transparent"
            radius: Styling.radius(4)

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                // User avatar
                Rectangle {
                    id: avatarContainer
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 8
                    width: 140
                    height: 140
                    radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0
                    color: "transparent"

                    Image {
                        id: userAvatar
                        anchors.fill: parent
                        source: `file://${Quickshell.env("HOME")}/.face.icon`
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                        visible: status === Image.Ready

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskThresholdMin: 0.5
                            maskSpreadAtMin: 1.0
                            maskSource: ShaderEffectSource {
                                sourceItem: Rectangle {
                                    width: userAvatar.width
                                    height: userAvatar.height
                                    radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Icons.user
                        font.family: Icons.font
                        font.pixelSize: 64
                        color: Colors.overSurfaceVariant
                        visible: userAvatar.status !== Image.Ready
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 16
                    contentHeight: resourcesColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: resourcesColumn
                        width: parent.width
                        spacing: 12

                        // CPU
                        ResourceItem {
                            width: parent.width
                            icon: Icons.cpu
                            label: "CPU"
                            value: SystemResources.cpuUsage / 100
                            barColor: Colors.red
                        }

                        // RAM
                        ResourceItem {
                            width: parent.width
                            icon: Icons.ram
                            label: "RAM"
                            value: SystemResources.ramUsage / 100
                            barColor: Colors.blue
                        }

                        // GPU (if detected)
                        ResourceItem {
                            width: parent.width
                            visible: SystemResources.gpuDetected
                            icon: Icons.gpu
                            label: "GPU"
                            value: SystemResources.gpuUsage / 100
                            barColor: Colors.green
                        }

                        // Disks
                        Repeater {
                            id: diskRepeater
                            model: SystemResources.validDisks

                            ResourceItem {
                                required property string modelData
                                width: parent.width
                                icon: Icons.disk
                                label: modelData
                                value: SystemResources.diskUsage[modelData] ? SystemResources.diskUsage[modelData] / 100 : 0
                                barColor: Colors.yellow
                            }
                        }
                    }
                }
            }
        }

        // Separator
        Separator {
            Layout.fillHeight: true
            Layout.preferredWidth: 2
            vert: true
            gradient: null
            color: Colors.surface
        }

        // Right panel - Chart
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: Styling.radius(4)

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Chart area
                Canvas {
                    id: chartCanvas
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 8

                    onPaint: {
                        const ctx = getContext("2d");
                        const w = width;
                        const h = height;

                        // Clear canvas
                        ctx.clearRect(0, 0, w, h);

                        // Draw background grid lines
                        ctx.strokeStyle = Colors.surfaceBright;
                        ctx.lineWidth = 2;
                        ctx.setLineDash([4, 4]);

                        // Horizontal grid lines (25%, 50%, 75%)
                        for (let i = 1; i < 4; i++) {
                            const y = h * (i / 4);
                            ctx.beginPath();
                            ctx.moveTo(0, y);
                            ctx.lineTo(w, y);
                            ctx.stroke();
                        }

                        ctx.setLineDash([]);

                        if (root.cpuHistory.length < 2)
                            return;

                        const pointSpacing = w / (root.maxHistoryPoints - 1);

                        // Helper function to draw a line chart
                        function drawLine(history, color) {
                            if (history.length < 2)
                                return;

                            ctx.strokeStyle = color;
                            ctx.lineWidth = 2;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";
                            ctx.beginPath();

                            const startIndex = Math.max(0, root.maxHistoryPoints - history.length);

                            for (let i = 0; i < history.length; i++) {
                                const x = (startIndex + i) * pointSpacing;
                                const y = h - (history[i] * h);

                                if (i === 0) {
                                    ctx.moveTo(x, y);
                                } else {
                                    ctx.lineTo(x, y);
                                }
                            }

                            ctx.stroke();
                        }

                        // Draw CPU line (red)
                        drawLine(root.cpuHistory, Colors.red);

                        // Draw RAM line (blue)
                        drawLine(root.ramHistory, Colors.blue);

                        // Draw GPU line (green) if available
                        if (SystemResources.gpuDetected && root.gpuHistory.length > 0) {
                            drawLine(root.gpuHistory, Colors.green);
                        }
                    }
                }

                // Controls at bottom right
                RowLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    Layout.margins: 8
                    spacing: 12

                    // Decrease interval button
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        color: Colors.surface
                        radius: Styling.radius(3)
                        border.width: 1
                        border.color: Colors.surfaceBright

                        Text {
                            anchors.centerIn: parent
                            text: Icons.minus
                            font.family: Icons.font
                            font.pixelSize: 18
                            color: Colors.overBackground
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const newInterval = Math.max(100, SystemResources.updateInterval - 100);
                                SystemResources.updateInterval = newInterval;
                                historyTimer.interval = newInterval;
                                StateService.set("metricsRefreshInterval", newInterval);
                            }
                        }

                        Behavior on color {
                            enabled: Config.animDuration > 0
                            ColorAnimation {
                                duration: Config.animDuration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // Interval display
                    Text {
                        text: `${SystemResources.updateInterval}ms`
                        font.family: Config.theme.font
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Colors.overBackground
                    }

                    // Increase interval button
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        color: Colors.surface
                        radius: Styling.radius(3)
                        border.width: 1
                        border.color: Colors.surfaceBright

                        Text {
                            anchors.centerIn: parent
                            text: Icons.plus
                            font.family: Icons.font
                            font.pixelSize: 18
                            color: Colors.overBackground
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const newInterval = SystemResources.updateInterval + 100;
                                SystemResources.updateInterval = newInterval;
                                historyTimer.interval = newInterval;
                                StateService.set("metricsRefreshInterval", newInterval);
                            }
                        }

                        Behavior on color {
                            enabled: Config.animDuration > 0
                            ColorAnimation {
                                duration: Config.animDuration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
