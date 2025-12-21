pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.services
import qs.modules.components
import qs.modules.theme
import qs.modules.globals
import qs.config

Item {
    id: root

    required property var bar

    property bool vertical: bar.orientation === "vertical"
    property bool isHovered: false
    property bool layerEnabled: true

    // Popup visibility state
    property bool popupOpen: batteryPopup.isOpen

    Layout.preferredWidth: 36
    Layout.preferredHeight: 36
    Layout.fillWidth: vertical
    Layout.fillHeight: !vertical

    visible: Battery.available

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    // Main button with circular progress
    StyledRect {
        id: buttonBg
        variant: root.popupOpen ? "primary" : "bg"
        anchors.fill: parent
        enableShadow: root.layerEnabled

        // Background highlight on hover
        Rectangle {
            anchors.fill: parent
            color: Colors.primary
            opacity: root.popupOpen ? 0 : (root.isHovered ? 0.25 : 0)
            radius: parent.radius ?? 0

            Behavior on opacity {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                }
            }
        }

        // Circular progress indicator
        Item {
            id: progressCanvas
            anchors.centerIn: parent
            width: 32
            height: 32

            property real angle: Battery.percentage * 360
            property real radius: 12
            property real lineWidth: 3

            Canvas {
                id: canvas
                anchors.fill: parent
                antialiasing: true

                onPaint: {
                    let ctx = getContext("2d");
                    ctx.reset();

                    let centerX = width / 2;
                    let centerY = height / 2;
                    let radius = progressCanvas.radius;
                    let lineWidth = progressCanvas.lineWidth;

                    ctx.lineCap = "round";

                    // Base start angle (top)
                    let baseStartAngle = -Math.PI / 2;
                    let progressAngleRad = progressCanvas.angle * Math.PI / 180;

                    // Draw background track
                    ctx.strokeStyle = Colors.outlineVariant;
                    ctx.lineWidth = lineWidth;
                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
                    ctx.stroke();

                    // Draw progress
                    if (progressCanvas.angle > 0) {
                        ctx.strokeStyle = Colors.green;
                        ctx.lineWidth = lineWidth;
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, baseStartAngle, baseStartAngle + progressAngleRad, false);
                        ctx.stroke();
                    }
                }

                Connections {
                    target: progressCanvas
                    function onAngleChanged() {
                        canvas.requestPaint();
                    }
                }
                
                Connections {
                    target: Battery
                    function onPercentageChanged() {
                        canvas.requestPaint();
                    }
                }
            }

            Behavior on angle {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Central icon
        Text {
            anchors.centerIn: parent
            text: Battery.isCharging ? Icons.plug : Icons.lightning
            font.family: Icons.font
            font.pixelSize: 14
            color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
            
            Behavior on color {
                enabled: Config.animDuration > 0
                ColorAnimation { duration: Config.animDuration / 2 }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: batteryPopup.toggle()
        }

        StyledToolTip {
            visible: root.isHovered && !root.popupOpen
            tooltipText: "Battery: " + Math.round(Battery.percentage * 100) + "%" + (Battery.isCharging ? " (Charging)" : "")
        }
    }

    // Battery popup with Power Profiles
    BarPopup {
        id: batteryPopup
        anchorItem: buttonBg
        bar: root.bar

        contentWidth: Math.max(200, profilesRow.implicitWidth + batteryPopup.popupPadding * 2)
        contentHeight: profilesRow.implicitHeight + batteryPopup.popupPadding * 2

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "Power Profiles"
                font.family: Styling.defaultFont
                font.pixelSize: Styling.fontSize(-1)
                font.bold: true
                color: Colors.overSurfaceVariant
                Layout.alignment: Qt.AlignHCenter
            }

            Row {
                id: profilesRow
                spacing: 4
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: PowerProfile.availableProfiles

                    delegate: StyledRect {
                        id: profileButton
                        required property string modelData
                        required property int index

                        readonly property bool isSelected: PowerProfile.currentProfile === modelData
                        property bool buttonHovered: false

                        variant: isSelected ? "primary" : (buttonHovered ? "focus" : "common")
                        enableShadow: false
                        width: profileLabel.implicitWidth + 40
                        height: 36
                        radius: Styling.radius(0)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: PowerProfile.getProfileIcon(profileButton.modelData)
                                font.family: Icons.font
                                font.pixelSize: 14
                                color: profileButton.itemColor
                            }

                            Text {
                                id: profileLabel
                                text: PowerProfile.getProfileDisplayName(profileButton.modelData)
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: profileButton.itemColor
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: profileButton.buttonHovered = true
                            onExited: profileButton.buttonHovered = false

                            onClicked: {
                                PowerProfile.setProfile(profileButton.modelData);
                            }
                        }
                    }
                }
            }
        }
    }
}
