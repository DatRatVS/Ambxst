pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.config

Item {
    id: root

    property string icon: ""
    property string label: ""
    property real value: 0.0
    property color barColor: Colors.primary

    implicitHeight: 24

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // Icon
        Text {
            text: root.icon
            font.family: Icons.font
            font.pixelSize: 18
            color: Colors.overBackground
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 20
        }

        // Progress bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            Layout.alignment: Qt.AlignVCenter
            radius: Styling.radius(1)
            color: Colors.surfaceDim

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.value))
                height: parent.height
                radius: parent.radius
                color: root.barColor

                Behavior on width {
                    enabled: Config.animDuration > 0
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // Percentage text
        Text {
            visible: false
            text: `${Math.round(root.value * 100)}%`
            font.family: Config.theme.font
            font.pixelSize: Config.theme.fontSize
            font.weight: Font.Medium
            color: Colors.overSurfaceVariant
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 35
            horizontalAlignment: Text.AlignRight
        }
    }
}
