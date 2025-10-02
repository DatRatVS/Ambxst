import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications
import qs.modules.theme
import qs.config

Button {
    id: root
    property bool visibleWhen: true
    property int urgency: NotificationUrgency.Normal

    anchors.fill: parent
    hoverEnabled: true
    visible: visibleWhen

    background: Rectangle {
        color: urgency == NotificationUrgency.Critical ? Colors.redSource : (parent.pressed ? Colors.error : (parent.hovered ? Colors.surfaceBright : Colors.surface))
        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
        border.width: urgency == NotificationUrgency.Critical ? 4 : 0
        border.color: urgency == NotificationUrgency.Critical ? Colors.shadow : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: Config.animDuration
            }
        }
    }

    contentItem: Text {
        text: Icons.cancel
        font.family: Icons.font
        font.pixelSize: 16
        color: urgency == NotificationUrgency.Critical ? Colors.shadow : (parent.pressed ? Colors.overError : (parent.hovered ? Colors.overBackground : Colors.error))
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
            }
        }
    }
}