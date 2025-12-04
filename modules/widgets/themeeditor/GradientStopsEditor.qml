pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config
import "../../../config/ConfigDefaults.js" as ConfigDefaults

GroupBox {
    id: root

    required property var colorNames
    required property var stops
    required property string variantId

    signal updateStops(var newStops)

    // Get the default gradient for this variant
    readonly property var defaultGradient: {
        const variantKey = "sr" + variantId.charAt(0).toUpperCase() + variantId.slice(1);
        const defaults = ConfigDefaults.data.theme[variantKey];
        if (defaults && defaults.gradient) {
            return defaults.gradient;
        }
        return [["surface", 0.0]];
    }

    title: "Gradient Stops (" + stops.length + "/20)"

    background: StyledRect {
        variant: "common"
    }

    label: Text {
        text: parent.title
        font.family: Styling.defaultFont
        font.pixelSize: Config.theme.fontSize
        font.bold: true
        color: Colors.primary
        leftPadding: 10
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Gradient preview bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: Styling.radius(-12)
            border.color: Colors.outline
            border.width: 1

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    property var stopData: root.stops[0] || ["surface", 0.0]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[1] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[2] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[3] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[4] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[5] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[6] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[7] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[8] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[9] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                id: addButton
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                enabled: root.stops.length < 20

                background: StyledRect {
                    variant: addButton.enabled ? (addButton.hovered ? "primaryfocus" : "primary") : "common"
                    opacity: addButton.enabled ? 1.0 : 0.5
                }

                contentItem: RowLayout {
                    spacing: 6

                    Text {
                        text: Icons.plus
                        font.family: Icons.font
                        font.pixelSize: 18
                        color: addButton.enabled ? Colors.overPrimary : Colors.overBackground
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Add Stop"
                        font.family: Styling.defaultFont
                        font.pixelSize: Config.theme.fontSize
                        color: addButton.enabled ? Colors.overPrimary : Colors.overBackground
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                onClicked: {
                    if (root.stops.length >= 20) return;

                    let newStops = root.stops.slice();
                    // Copy the last stop's color, position at 1.0
                    const lastColor = newStops[newStops.length - 1][0];
                    newStops.push([lastColor, 1.0]);
                    root.updateStops(newStops);
                }
            }

            Button {
                id: clearButton
                Layout.fillWidth: true
                Layout.preferredHeight: 32

                background: StyledRect {
                    variant: clearButton.hovered ? "errorfocus" : "error"
                }

                contentItem: RowLayout {
                    spacing: 6

                    Text {
                        text: Icons.broom
                        font.family: Icons.font
                        font.pixelSize: 18
                        color: Colors.overError
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Reset"
                        font.family: Styling.defaultFont
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.overError
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                onClicked: {
                    // Reset to default gradient for this variant
                    root.updateStops(root.defaultGradient.slice());
                }
            }
        }

        // Stops list
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(root.stops.length * 86, 350)
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 6

                Repeater {
                    model: root.stops

                    delegate: StyledRect {
                        id: stopDelegate

                        required property var modelData
                        required property int index

                        // Safe string conversion for color value
                        readonly property string colorStr: modelData[0] ? modelData[0].toString() : ""
                        readonly property bool isHex: colorStr.startsWith("#")
                        readonly property real positionValue: modelData[1]

                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        variant: "internalbg"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            // Top row: number, preview, combo, position, delete
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                // Stop number
                                Text {
                                    text: (stopDelegate.index + 1) + "."
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Config.theme.fontSize
                                    font.bold: true
                                    color: Colors.primary
                                    Layout.preferredWidth: 24
                                }

                                // Color preview
                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    radius: Styling.radius(-12)
                                    color: Config.resolveColor(stopDelegate.colorStr)
                                    border.color: Colors.outline
                                    border.width: 1
                                }

                                // Color selector
                                ComboBox {
                                    id: stopColorCombo
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32

                                    model: ["Custom"].concat(root.colorNames)
                                    currentIndex: {
                                        if (stopDelegate.isHex) return 0;
                                        const idx = root.colorNames.indexOf(stopDelegate.colorStr);
                                        return idx >= 0 ? idx + 1 : 0;
                                    }

                                    onActivated: idx => {
                                        if (idx === 0) return;
                                        let newStops = root.stops.slice();
                                        newStops[stopDelegate.index] = [root.colorNames[idx - 1], newStops[stopDelegate.index][1]];
                                        root.updateStops(newStops);
                                    }

                                    background: StyledRect {
                                        variant: stopColorCombo.hovered ? "focus" : "common"
                                    }

                                    contentItem: Text {
                                        text: stopDelegate.isHex ? "Custom" : stopDelegate.colorStr
                                        font.family: Styling.defaultFont
                                        font.pixelSize: Config.theme.fontSize
                                        color: Colors.overBackground
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 8
                                    }

                                    indicator: Text {
                                        x: stopColorCombo.width - width - 6
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Icons.caretDown
                                        font.family: Icons.font
                                        font.pixelSize: Config.theme.fontSize
                                        color: Colors.overBackground
                                    }

                                    popup: Popup {
                                        y: stopColorCombo.height + 2
                                        width: stopColorCombo.width
                                        implicitHeight: contentItem.implicitHeight > 200 ? 200 : contentItem.implicitHeight
                                        padding: 2

                                        background: StyledRect {
                                            variant: "pane"
                                            enableShadow: true
                                        }

                                        contentItem: ListView {
                                            clip: true
                                            implicitHeight: contentHeight
                                            model: stopColorCombo.popup.visible ? stopColorCombo.delegateModel : null
                                            currentIndex: stopColorCombo.highlightedIndex
                                            ScrollIndicator.vertical: ScrollIndicator {}
                                        }
                                    }

                                    delegate: ItemDelegate {
                                        id: colorDelegate
                                        required property var modelData
                                        required property int index

                                        width: stopColorCombo.width - 4
                                        height: 28

                                        background: StyledRect {
                                            variant: colorDelegate.highlighted ? "focus" : "common"
                                        }

                                        contentItem: RowLayout {
                                            spacing: 6

                                            Rectangle {
                                                Layout.preferredWidth: 18
                                                Layout.preferredHeight: 18
                                                radius: 2
                                                color: colorDelegate.index === 0 ? "transparent" : (Colors[root.colorNames[colorDelegate.index - 1]] || "transparent")
                                                border.color: Colors.outline
                                                border.width: colorDelegate.index === 0 ? 0 : 1
                                            }

                                            Text {
                                                text: colorDelegate.modelData
                                                font.family: Styling.defaultFont
                                                font.pixelSize: Config.theme.fontSize
                                                color: Colors.overBackground
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }

                                        highlighted: stopColorCombo.highlightedIndex === index
                                    }
                                }

                                // Position input
                                StyledRect {
                                    id: positionInputContainer
                                    Layout.preferredWidth: 70
                                    Layout.preferredHeight: 32
                                    variant: positionInput.activeFocus ? "focus" : "common"

                                    TextInput {
                                        id: positionInput
                                        anchors.fill: parent
                                        anchors.margins: 6

                                        // Only set text when not focused to avoid resetting while typing
                                        property bool initialized: false
                                        Component.onCompleted: {
                                            text = stopDelegate.positionValue.toFixed(3);
                                            initialized = true;
                                        }

                                        Connections {
                                            target: stopDelegate
                                            function onPositionValueChanged() {
                                                if (!positionInput.activeFocus && positionInput.initialized) {
                                                    positionInput.text = stopDelegate.positionValue.toFixed(3);
                                                }
                                            }
                                        }

                                        font.family: "monospace"
                                        font.pixelSize: Config.theme.fontSize
                                        color: Colors.overBackground
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        selectByMouse: true

                                        function applyValue() {
                                            let val = parseFloat(text);
                                            if (!isNaN(val)) {
                                                val = Math.max(0, Math.min(1, val));
                                                let newStops = root.stops.slice();
                                                newStops[stopDelegate.index] = [newStops[stopDelegate.index][0], val];
                                                root.updateStops(newStops);
                                                text = val.toFixed(3);
                                            }
                                        }

                                        Keys.onReturnPressed: applyValue()
                                        Keys.onEnterPressed: applyValue()
                                        onEditingFinished: applyValue()
                                    }
                                }

                                // Delete button
                                Button {
                                    id: deleteButton
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    enabled: root.stops.length > 1

                                    background: StyledRect {
                                        variant: deleteButton.enabled ? (deleteButton.hovered ? "error" : "common") : "common"
                                        opacity: deleteButton.enabled ? 1.0 : 0.3
                                    }

                                    contentItem: Text {
                                        text: Icons.trash
                                        font.family: Icons.font
                                        font.pixelSize: 18
                                        color: deleteButton.enabled ? (deleteButton.hovered ? Colors.overError : Colors.overBackground) : Colors.overBackground
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        if (root.stops.length <= 1) return;
                                        let newStops = root.stops.slice();
                                        newStops.splice(stopDelegate.index, 1);
                                        root.updateStops(newStops);
                                    }
                                }
                            }

                            // Bottom row: HEX input
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Item { Layout.preferredWidth: 24 } // Spacer to align with above

                                Text {
                                    text: "HEX:"
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Config.theme.fontSize
                                    color: Colors.overBackground
                                    opacity: 0.7
                                }

                                StyledRect {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 28
                                    variant: hexInput.activeFocus ? "focus" : "common"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        spacing: 2

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

                                            // Only set text when not focused
                                            property bool initialized: false
                                            Component.onCompleted: {
                                                updateDisplayText();
                                                initialized = true;
                                            }

                                            function updateDisplayText() {
                                                if (stopDelegate.isHex) {
                                                    text = stopDelegate.colorStr.replace("#", "").toUpperCase();
                                                } else {
                                                    const resolved = Config.resolveColor(stopDelegate.colorStr);
                                                    text = resolved.toString().replace("#", "").toUpperCase();
                                                }
                                            }

                                            Connections {
                                                target: stopDelegate
                                                function onColorStrChanged() {
                                                    if (!hexInput.activeFocus && hexInput.initialized) {
                                                        hexInput.updateDisplayText();
                                                    }
                                                }
                                            }

                                            font.family: "monospace"
                                            font.pixelSize: Config.theme.fontSize
                                            color: Colors.overBackground
                                            verticalAlignment: Text.AlignVCenter
                                            selectByMouse: true
                                            maximumLength: 8

                                            validator: RegularExpressionValidator {
                                                regularExpression: /[0-9A-Fa-f]{0,8}/
                                            }

                                            function applyHex() {
                                                let hex = text.trim();
                                                if (hex.length >= 6) {
                                                    let newStops = root.stops.slice();
                                                    newStops[stopDelegate.index] = ["#" + hex.toUpperCase(), newStops[stopDelegate.index][1]];
                                                    root.updateStops(newStops);
                                                }
                                            }

                                            Keys.onReturnPressed: applyHex()
                                            Keys.onEnterPressed: applyHex()
                                            onEditingFinished: applyHex()
                                        }
                                    }
                                }

                                Item { Layout.preferredWidth: 32 } // Spacer to align with delete button
                            }
                        }
                    }
                }
            }
        }
    }
}
