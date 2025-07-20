import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../workspaces"
import "../theme"
import "../launcher"

PanelWindow {
    id: notchPanel

    anchors {
        top: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: GlobalStates.launcherOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore

    implicitHeight: notchContainer.implicitHeight
    implicitWidth: notchContainer.implicitWidth

    // Default view component - user@host text
    Component {
        id: defaultViewComponent
        Item {
            width: userHostText.implicitWidth + 24
            height: 28

            Text {
                id: userHostText
                anchors.centerIn: parent
                text: `${Quickshell.env("USER")}@${Quickshell.env("HOSTNAME")}`
                color: Colors.foreground
                font.family: Styling.defaultFont
                font.pixelSize: 14
                font.weight: Font.Bold
            }
        }
    }

    // Launcher view component
    Component {
        id: launcherViewComponent
        Item {
            width: 480
            height: Math.min(launcherSearch.implicitHeight, 400)

            LauncherSearch {
                id: launcherSearch
                anchors.fill: parent

                onItemSelected: {
                    GlobalStates.launcherOpen = false;
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.launcherOpen = false;
                        event.accepted = true;
                    }
                }

                Component.onCompleted: {
                    clearSearch();
                    Qt.callLater(() => {
                        forceActiveFocus();
                    });
                }
            }
        }
    }

    // Center notch
    Notch {
        id: notchContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        defaultViewComponent: defaultViewComponent
        launcherViewComponent: launcherViewComponent
    }

    // Listen for launcher state changes
    Connections {
        target: GlobalStates
        function onLauncherOpenChanged() {
            if (GlobalStates.launcherOpen) {
                notchContainer.stackView.push(launcherViewComponent);
                Qt.callLater(() => {
                    notchPanel.requestActivate();
                    notchPanel.forceActiveFocus();
                });
            } else {
                if (notchContainer.stackView.depth > 1) {
                    notchContainer.stackView.pop();
                }
            }
        }
    }

    // Handle global keyboard events
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape && GlobalStates.launcherOpen) {
            GlobalStates.launcherOpen = false;
            event.accepted = true;
        }
    }
}
