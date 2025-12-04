pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.config

FloatingWindow {
    id: root

    visible: GlobalStates.themeEditorVisible
    title: "Theme Editor"
    color: "transparent"

    minimumSize: Qt.size(800, 600)

    property string selectedVariant: ""

    StyledRect {
        id: background
        anchors.fill: parent
        variant: "bg"
        enableShadow: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            // Left side: Vertical tabs
            StyledRect {
                id: tabsContainer
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                variant: "pane"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: "Settings"
                        font.family: Styling.defaultFont
                        font.pixelSize: Config.theme.fontSize
                        font.bold: true
                        color: Colors.primary
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 8
                    }

                    Repeater {
                        model: [
                            { name: "Theme", icon: Icons.cube },
                            { name: "Bar", icon: Icons.gear },
                            { name: "Hyprland", icon: Icons.gear }
                        ]

                        delegate: Button {
                            id: tabButton
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredHeight: 40

                            readonly property bool isSelected: tabStack.currentIndex === index

                            background: StyledRect {
                                variant: tabButton.isSelected ? "primary" : (tabButton.hovered ? "focus" : "common")

                                Behavior on opacity {
                                    enabled: Config.animDuration > 0
                                    NumberAnimation { duration: Config.animDuration / 2 }
                                }
                            }

                            contentItem: RowLayout {
                                spacing: 8

                                Text {
                                    text: tabButton.modelData.icon
                                    font.family: Icons.font
                                    font.pixelSize: 18
                                    color: tabButton.isSelected ? Colors.overPrimary : Colors.overBackground
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: tabButton.modelData.name
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Config.theme.fontSize
                                    color: tabButton.isSelected ? Colors.overPrimary : Colors.overBackground
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            onClicked: tabStack.currentIndex = index
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Close button
                    Button {
                        id: closeButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        background: StyledRect {
                            variant: closeButton.hovered ? "error" : "common"
                        }

                        contentItem: RowLayout {
                            spacing: 8

                            Text {
                                text: Icons.cancel
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: closeButton.hovered ? Colors.overError : Colors.overBackground
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: "Close"
                                font.family: Styling.defaultFont
                                font.pixelSize: Config.theme.fontSize
                                color: closeButton.hovered ? Colors.overError : Colors.overBackground
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        onClicked: GlobalStates.themeEditorVisible = false
                    }
                }
            }

            // Right side: Content area
            StackLayout {
                id: tabStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                // Theme tab
                ThemeTab {
                    id: themeTab
                }

                // Bar tab (placeholder)
                StyledRect {
                    variant: "pane"

                    Text {
                        anchors.centerIn: parent
                        text: "Bar Settings (Coming Soon)"
                        font.family: Styling.defaultFont
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.overBackground
                    }
                }

                // Hyprland tab (placeholder)
                StyledRect {
                    variant: "pane"

                    Text {
                        anchors.centerIn: parent
                        text: "Hyprland Settings (Coming Soon)"
                        font.family: Styling.defaultFont
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.overBackground
                    }
                }
            }
        }
    }
}
