import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.modules.theme
import qs.modules.services
import qs.modules.components
import qs.config
import "./NotificationAnimation.qml"
import "./NotificationAppIcon.qml"
import "./NotificationDismissButton.qml"
import "./NotificationActionButtons.qml"
import "./notification_utils.js" as NotificationUtils

Item {
    id: root
    property var notificationObject: null
    property var notifications: []
    property string summary: ""
    property bool expanded: false
    property real fontSize: Config.theme.fontSize
    property real padding: onlyNotification || expanded ? 8 : 0
    property bool onlyNotification: false
    property bool appNameAlreadyShown: false

    // Computed properties
    property var sortedNotifications: notifications.slice().sort((a, b) => a.time - b.time) // antiguo a reciente
    property var latestNotification: sortedNotifications.length > 0 ? sortedNotifications[sortedNotifications.length - 1] : notificationObject
    property var earliestNotification: sortedNotifications.length > 0 ? sortedNotifications[0] : notificationObject
    property bool multipleNotifications: notifications.length > 1
    property bool isValid: latestNotification && (latestNotification.summary || latestNotification.body)

    signal destroyRequested

    implicitHeight: background.height

    function destroyWithAnimation() {
        notificationAnimation.startDestroy();
    }

    NotificationAnimation {
        id: notificationAnimation
        targetItem: background
        dismissOvershoot: 20
        parentWidth: root.width

        onDestroyFinished: {
            if (root.notifications.length > 0) {
                // Discard multiple
                const ids = root.notifications.map(notif => notif.id);
                Notifications.discardNotifications(ids);
            } else if (root.notificationObject) {
                Notifications.discardNotification(root.notificationObject.id);
            }
        }
    }

    MouseArea {
        id: dragManager
        anchors.fill: root
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onPressed: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                root.destroyWithAnimation();
            }
        }
    }

    Rectangle {
        id: background
        width: parent.width
        height: contentColumn.implicitHeight
        radius: 8
        visible: root.isValid
        color: "transparent"

        Behavior on height {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }

        DiagonalStripePattern {
            id: stripeContainer
            anchors.fill: parent
            visible: latestNotification && latestNotification.urgency == NotificationUrgency.Critical
            radius: Config.roundness > 4 ? Config.roundness + 4 : 0
            animationRunning: visible
        }

        ColumnLayout {
            id: contentColumn
            width: parent.width
            anchors.fill: parent
            anchors.margins: 0
            spacing: onlyNotification ? 8 : (expanded ? 8 : 0)

            // Individual notification layout (like expanded popup)
            RowLayout {
                id: mainContentRow
                Layout.fillWidth: true
                implicitHeight: Math.max(onlyNotification ? 48 : 32, textColumn.implicitHeight)
                height: implicitHeight
                spacing: 8
                visible: onlyNotification

                // Contenido principal
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // App icon
                    NotificationAppIcon {
                        id: appIcon
                        Layout.preferredWidth: onlyNotification ? 48 : 32
                        Layout.preferredHeight: onlyNotification ? 48 : 32
                        Layout.alignment: Qt.AlignTop
                        size: onlyNotification ? 48 : 32
                        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                        visible: latestNotification && (latestNotification.appIcon !== "" || latestNotification.image !== "")
                        appIcon: latestNotification ? (latestNotification.cachedAppIcon || latestNotification.appIcon) : ""
                        image: latestNotification ? (latestNotification.cachedImage || latestNotification.image) : ""
                        summary: latestNotification ? latestNotification.summary : ""
                        urgency: latestNotification ? latestNotification.urgency : NotificationUrgency.Normal
                    }

                    // Textos de la notificación
                    Column {
                        id: textColumn
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: onlyNotification ? 4 : 0

                        // Fila del summary, app name y timestamp
                        RowLayout {
                            width: parent.width
                            spacing: 4

                            // Contenedor izquierdo para summary y app name
                            Row {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 4

                                Text {
                                    id: summaryText
                                    width: Math.min(implicitWidth, parent.width - (appNameText.visible ? appNameText.width + parent.spacing : 0))
                                    text: latestNotification ? latestNotification.summary : ""
                                    font.family: Config.theme.font
                                    font.pixelSize: Config.theme.fontSize
                                    font.weight: Font.Bold
                                    color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.primary
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    wrapMode: Text.NoWrap
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    id: appNameText
                                    width: Math.min(implicitWidth, Math.max(60, parent.width * 0.3))
                                    text: latestNotification ? "• " + latestNotification.appName : ""
                                    font.family: Config.theme.font
                                    font.pixelSize: Config.theme.fontSize
                                    font.weight: Font.Bold
                                    color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.outline
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    wrapMode: Text.NoWrap
                                    verticalAlignment: Text.AlignVCenter
                                    visible: text !== "" && !root.appNameAlreadyShown
                                }
                            }

                            // Timestamp a la derecha
                            Text {
                                id: timestampText
                                text: latestNotification ? NotificationUtils.getFriendlyNotifTimeString(latestNotification.time) : ""
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                font.weight: Font.Bold
                                color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.outline
                                verticalAlignment: Text.AlignVCenter
                                visible: text !== ""
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: latestNotification ? NotificationUtils.processNotificationBody(latestNotification.body, latestNotification.appName) : ""
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            font.weight: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Font.Bold : Font.Normal
                            color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.overBackground
                            wrapMode: onlyNotification ? Text.Wrap : Text.NoWrap
                            maximumLineCount: onlyNotification ? 3 : 1
                            elide: Text.ElideRight
                            visible: onlyNotification || text !== ""
                        }
                    }
                }

                // Botón de descartar
                Item {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignTop

                    NotificationDismissButton {
                        visibleWhen: onlyNotification
                        urgency: latestNotification ? latestNotification.urgency : NotificationUrgency.Normal
                        onClicked: root.destroyWithAnimation()
                    }
                }
            }

            // Grouped notification layout (original)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: !onlyNotification

                // Contenido principal
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    NotificationAppIcon {
                        id: groupedAppIcon
                        Layout.preferredWidth: expanded ? 48 : 32
                        Layout.preferredHeight: expanded ? 48 : 32
                        Layout.alignment: Qt.AlignTop
                        size: expanded ? 48 : 32
                        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                        visible: latestNotification && (latestNotification.appIcon !== "" || latestNotification.image !== "")
                        appIcon: latestNotification ? (latestNotification.cachedAppIcon || latestNotification.appIcon) : ""
                        image: latestNotification ? (latestNotification.cachedImage || latestNotification.image) : ""
                        summary: latestNotification ? latestNotification.summary : ""
                        urgency: latestNotification ? latestNotification.urgency : NotificationUrgency.Normal
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: expanded ? columnLayout.implicitHeight : rowLayout.implicitHeight

                        RowLayout {
                            id: columnLayout
                            width: parent.width
                            spacing: 8
                            visible: expanded

                            Column {
                                Layout.fillWidth: true
                                spacing: 4

                                // Fila del summary y timestamp
                                RowLayout {
                                    width: parent.width
                                    spacing: 4

                                    Text {
                                        Layout.maximumWidth: parent.width * 0.7
                                        text: root.summary || (latestNotification ? latestNotification.summary : "")
                                        font.family: Config.theme.font
                                        font.pixelSize: Config.theme.fontSize
                                        font.weight: Font.Bold
                                        color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.primary
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: latestNotification ? NotificationUtils.getFriendlyNotifTimeString(latestNotification.time) : ""
                                        font.family: Config.theme.font
                                        font.pixelSize: Config.theme.fontSize
                                        font.weight: Font.Bold
                                        color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.outline
                                        visible: text !== ""
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    }
                                }

                                // Mostrar todos los body ordenados antiguo a reciente con spacing 4
                                Column {
                                    width: parent.width
                                    spacing: 4

                                    Repeater {
                                        model: root.sortedNotifications

                                        Text {
                                            width: parent.width
                                            text: NotificationUtils.processNotificationBody(modelData.body || "", modelData.appName)
                                            font.family: Config.theme.font
                                            font.pixelSize: root.fontSize
                                            font.weight: modelData.urgency == NotificationUrgency.Critical ? Font.Bold : Font.Normal
                                            color: modelData.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.overBackground
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                            visible: text.length > 0
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            id: rowLayout
                            width: parent.width
                            spacing: 4
                            visible: !expanded

                            Text {
                                Layout.maximumWidth: parent.width * 0.4
                                text: root.summary || (latestNotification ? latestNotification.summary : "")
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                font.weight: Font.Bold
                                color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.primary
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "•"
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                font.weight: Font.Bold
                                color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.outline
                                visible: latestNotification && latestNotification.body && latestNotification.body.length > 0
                            }

                            Text {
                                text: latestNotification ? NotificationUtils.processNotificationBody(latestNotification.body || "").replace(/\n/g, ' ') : ""
                                font.family: Config.theme.font
                                font.pixelSize: root.fontSize
                                font.weight: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Font.Bold : Font.Normal
                                color: latestNotification && latestNotification.urgency == NotificationUrgency.Critical ? Colors.shadow : Colors.overBackground
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text.length > 0
                            }
                        }
                    }
                }

                // Botón de descartar
                Item {
                    Layout.preferredWidth: expanded ? 32 : 0
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignTop

                    NotificationDismissButton {
                        visibleWhen: expanded
                        urgency: latestNotification ? latestNotification.urgency : NotificationUrgency.Normal
                        onClicked: root.destroyWithAnimation()
                    }
                }
            }

            // Botones de acción (para notificaciones individuales o expandidas)
            NotificationActionButtons {
                showWhen: (onlyNotification || expanded) && latestNotification && latestNotification.actions.length > 0 && !latestNotification.isCached
                actions: latestNotification ? latestNotification.actions : []
                notificationObject: latestNotification
                urgency: latestNotification ? latestNotification.urgency : NotificationUrgency.Normal
            }
        }
    }
}
