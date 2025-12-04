pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import qs.modules.theme
import qs.modules.components
import qs.config

Item {
    id: root

    required property var colorNames
    required property var currentValue

    signal colorChanged(string newColor)

    implicitHeight: 40

    // Convert currentValue to string safely
    readonly property string currentValueStr: currentValue ? currentValue.toString() : ""

    // Check if current value is a hex color
    readonly property bool isHexColor: currentValueStr.startsWith("#") || currentValueStr.startsWith("rgb")
    readonly property string displayHex: {
        if (isHexColor) {
            return currentValueStr;
        }
        // Get hex from Colors singleton
        const color = Colors[currentValueStr];
        if (color) {
            return color.toString();
        }
        return "#000000";
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        // Color dropdown
        ComboBox {
            id: colorDropdown
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            model: ["Custom"].concat(root.colorNames)
            currentIndex: {
                if (root.isHexColor) return 0; // "Custom"
                const idx = root.colorNames.indexOf(root.currentValueStr);
                return idx >= 0 ? idx + 1 : 0;
            }

            onActivated: index => {
                if (index === 0) {
                    // Custom selected, don't change anything
                    return;
                }
                const colorName = root.colorNames[index - 1];
                root.colorChanged(colorName);
            }

            background: StyledRect {
                variant: colorDropdown.hovered ? "focus" : "common"
            }

            contentItem: RowLayout {
                spacing: 10
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 32

                // Color preview square
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: Styling.radius(-12)
                    color: Config.resolveColor(root.currentValue)
                    border.color: Colors.outline
                    border.width: 1
                }

                Text {
                    text: root.isHexColor ? "Custom" : root.currentValueStr
                    font.family: Styling.defaultFont
                    font.pixelSize: Config.theme.fontSize
                    color: Colors.overBackground
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                }
            }

            indicator: Text {
                x: colorDropdown.width - width - 10
                anchors.verticalCenter: parent.verticalCenter
                text: Icons.caretDown
                font.family: Icons.font
                font.pixelSize: 18
                color: Colors.overBackground
            }

            popup: Popup {
                y: colorDropdown.height + 4
                width: colorDropdown.width
                implicitHeight: contentItem.implicitHeight > 300 ? 300 : contentItem.implicitHeight
                padding: 4

                background: StyledRect {
                    variant: "pane"
                    enableShadow: true
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: colorDropdown.popup.visible ? colorDropdown.delegateModel : null
                    currentIndex: colorDropdown.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }

            delegate: ItemDelegate {
                id: delegateItem
                required property var modelData
                required property int index

                width: colorDropdown.width - 8
                height: 36

                background: StyledRect {
                    variant: delegateItem.highlighted ? "focus" : "common"
                }

                contentItem: RowLayout {
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: Styling.radius(-12)
                        color: {
                            if (delegateItem.index === 0) return "transparent";
                            return Colors[root.colorNames[delegateItem.index - 1]] || "transparent";
                        }
                        border.color: Colors.outline
                        border.width: delegateItem.index === 0 ? 0 : 1

                        // Diagonal line for "Custom"
                        Rectangle {
                            visible: delegateItem.index === 0
                            width: parent.width * 1.2
                            height: 2
                            color: Colors.error
                            anchors.centerIn: parent
                            rotation: 45
                        }
                    }

                    Text {
                        text: delegateItem.modelData
                        font.family: Styling.defaultFont
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.overBackground
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                highlighted: colorDropdown.highlightedIndex === index
            }
        }

        // HEX input
        StyledRect {
            id: hexInputContainer
            Layout.preferredWidth: 110
            Layout.preferredHeight: 40
            variant: hexInput.activeFocus ? "focus" : "common"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 4

                Text {
                    text: "#"
                    font.family: "monospace"
                    font.pixelSize: Config.theme.fontSize
                    color: Colors.overBackground
                    opacity: 0.6
                }

                TextInput {
                    id: hexInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: root.displayHex.replace("#", "").toUpperCase()
                    font.family: "monospace"
                    font.pixelSize: Config.theme.fontSize
                    color: Colors.overBackground
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true
                    maximumLength: 8 // RRGGBBAA

                    validator: RegularExpressionValidator {
                        regularExpression: /[0-9A-Fa-f]{0,8}/
                    }

                    Keys.onReturnPressed: {
                        let hex = text.trim();
                        if (hex.length >= 6) {
                            root.colorChanged("#" + hex);
                        }
                    }

                    Keys.onEnterPressed: {
                        let hex = text.trim();
                        if (hex.length >= 6) {
                            root.colorChanged("#" + hex);
                        }
                    }

                    onEditingFinished: {
                        let hex = text.trim();
                        if (hex.length >= 6) {
                            root.colorChanged("#" + hex);
                        }
                    }

                    onTextChanged: {
                        // Auto-apply when 6 or 8 characters
                        if (text.length === 6 || text.length === 8) {
                            applyTimer.restart();
                        }
                    }

                    Timer {
                        id: applyTimer
                        interval: 500
                        onTriggered: {
                            if (hexInput.text.length >= 6) {
                                root.colorChanged("#" + hexInput.text);
                            }
                        }
                    }
                }
            }
        }

        // Color picker button
        Button {
            id: pickerButton
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40

            background: StyledRect {
                variant: pickerButton.hovered ? "focus" : "common"
            }

            contentItem: Text {
                text: Icons.xeyes
                font.family: Icons.font
                font.pixelSize: 18
                color: Colors.overBackground
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: colorDialog.open()

            ToolTip.visible: hovered
            ToolTip.text: "Open color picker"
            ToolTip.delay: 500
        }
    }

    ColorDialog {
        id: colorDialog
        title: "Select Color"
        selectedColor: Config.resolveColor(root.currentValueStr)

        onAccepted: {
            root.colorChanged(selectedColor.toString());
        }
    }
}
