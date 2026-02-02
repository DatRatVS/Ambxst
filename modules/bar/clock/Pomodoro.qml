pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtMultimedia
import Quickshell
import qs.modules.theme
import qs.modules.components
import qs.config

Item {
    id: root
    implicitHeight: content.implicitHeight + 24
    width: 300

    // State
    property int timeLeft: Config.system.pomodoro.workTime
    property bool isRunning: false
    property bool isWorkSession: true
    property bool alarmActive: false

    function formatTime(seconds) {
        let m = Math.floor(seconds / 60);
        let s = seconds % 60;
        return m.toString().padStart(2, '0') + ":" + s.toString().padStart(2, '0');
    }

    function toggleTimer() {
        if (alarmActive) {
            stopAlarm();
            nextSession();
            return;
        }
        isRunning = !isRunning;
    }

    function resetTimer() {
        stopAlarm();
        isRunning = false;
        isWorkSession = true;
        timeLeft = Config.system.pomodoro.workTime;
    }

    function startAlarm() {
        isRunning = false;
        alarmActive = true;
        if (Config.system.pomodoro.autoStart) {
            alarmSound.loops = 4;
        } else {
            alarmSound.loops = SoundEffect.Infinite;
        }
        alarmSound.play();
    }

    function stopAlarm() {
        alarmSound.stop();
        alarmActive = false;
    }

    function nextSession() {
        isWorkSession = !isWorkSession;
        timeLeft = isWorkSession ? Config.system.pomodoro.workTime : Config.system.pomodoro.restTime;
        if (Config.system.pomodoro.autoStart) {
            isRunning = true;
        }
    }

    SoundEffect {
        id: alarmSound
        source: Quickshell.shellDir + "/assets/sound/polite-warning-tone.wav"
        onPlayingChanged: {
            if (!playing && alarmActive && Config.system.pomodoro.autoStart) {
                // If it was supposed to play 4 times and finished
                stopAlarm();
                nextSession();
            }
        }
    }

    Timer {
        id: countdownTimer
        interval: 1000
        running: root.isRunning && root.timeLeft > 0
        repeat: true
        onTriggered: {
            if (root.timeLeft > 0) {
                root.timeLeft--;
                if (root.timeLeft === 0) {
                    startAlarm();
                }
            }
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.isWorkSession ? "Work Session" : "Rest Session"
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                font.weight: Font.Medium
                color: root.isRunning ? Styling.srItem("overprimary") : Colors.overBackground
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "Pomodoro"
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(-1)
                color: Colors.outline
                opacity: 0.7
            }
        }

        // Timer Display
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.formatTime(root.timeLeft)
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(8)
            font.weight: Font.Bold
            color: root.alarmActive ? (Math.floor(Date.now() / 500) % 2 === 0 ? Styling.srItem("overprimary") : Colors.overBackground) : Colors.overBackground
            
            Timer {
                interval: 500
                running: root.alarmActive
                repeat: true
                onTriggered: parent.update()
            }
        }

        // Controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            // +1 Minute Button
            StyledRect {
                variant: "common"
                implicitWidth: 44
                implicitHeight: 32
                radius: Styling.radius(-4)
                property bool isHovered: false

                Text {
                    anchors.centerIn: parent
                    text: "+1m"
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(-1)
                    color: parent.isHovered ? Styling.srItem("overprimary") : Colors.overBackground
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.isHovered = true
                    onExited: parent.isHovered = false
                    onClicked: {
                        root.timeLeft += 60;
                        if (root.isWorkSession) Config.system.pomodoro.workTime += 60;
                        else Config.system.pomodoro.restTime += 60;
                    }
                }
            }

            // Play/Pause/Stop Alarm
            StyledRect {
                id: mainControlBtn
                variant: root.alarmActive ? "primary" : (root.isRunning ? "focus" : "common")
                implicitWidth: 80
                implicitHeight: 32
                radius: Styling.radius(-4)
                property bool isHovered: false

                Text {
                    anchors.centerIn: parent
                    text: root.alarmActive ? "Stop" : (root.isRunning ? "Pause" : "Start")
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(0)
                    font.weight: Font.Bold
                    color: mainControlBtn.item
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: mainControlBtn.isHovered = true
                    onExited: mainControlBtn.isHovered = false
                    onClicked: root.toggleTimer()
                }
            }

            // Reset
            StyledRect {
                id: resetBtn
                variant: "common"
                implicitWidth: 44
                implicitHeight: 32
                radius: Styling.radius(-4)
                property bool isHovered: false

                Text {
                    anchors.centerIn: parent
                    text: Icons.arrowCounterClockwise
                    font.family: Icons.font
                    font.pixelSize: 16
                    color: resetBtn.isHovered ? Styling.srItem("overprimary") : Colors.overBackground
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: resetBtn.isHovered = true
                    onExited: resetBtn.isHovered = false
                    onClicked: root.resetTimer()
                }
            }
        }

        Separator { Layout.fillWidth: true; opacity: 0.15 }

        // Settings
        GridLayout {
            columns: 2
            rowSpacing: 8
            columnSpacing: 12
            Layout.fillWidth: true

            Text {
                text: "Work Duration:"
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(-1)
                color: Colors.outline
            }

            RowLayout {
                spacing: 4
                Layout.alignment: Qt.AlignRight
                TimeInput {
                    id: workMinInput
                    value: Math.floor(Config.system.pomodoro.workTime / 60)
                    onValueUpdated: val => {
                        Config.system.pomodoro.workTime = val * 60 + (Config.system.pomodoro.workTime % 60);
                        if (!root.isRunning && root.isWorkSession) root.timeLeft = Config.system.pomodoro.workTime;
                    }
                }
                Text { text: ":"; color: Colors.outline; font.bold: true }
                TimeInput {
                    id: workSecInput
                    value: Config.system.pomodoro.workTime % 60
                    onValueUpdated: val => {
                        Config.system.pomodoro.workTime = Math.floor(Config.system.pomodoro.workTime / 60) * 60 + val;
                        if (!root.isRunning && root.isWorkSession) root.timeLeft = Config.system.pomodoro.workTime;
                    }
                }
            }

            Text {
                text: "Rest Duration:"
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(-1)
                color: Colors.outline
            }

            RowLayout {
                spacing: 4
                Layout.alignment: Qt.AlignRight
                TimeInput {
                    id: restMinInput
                    value: Math.floor(Config.system.pomodoro.restTime / 60)
                    onValueUpdated: val => {
                        Config.system.pomodoro.restTime = val * 60 + (Config.system.pomodoro.restTime % 60);
                        if (!root.isRunning && !root.isWorkSession) root.timeLeft = Config.system.pomodoro.restTime;
                    }
                }
                Text { text: ":"; color: Colors.outline; font.bold: true }
                TimeInput {
                    id: restSecInput
                    value: Config.system.pomodoro.restTime % 60
                    onValueUpdated: val => {
                        Config.system.pomodoro.restTime = Math.floor(Config.system.pomodoro.restTime / 60) * 60 + val;
                        if (!root.isRunning && !root.isWorkSession) root.timeLeft = Config.system.pomodoro.restTime;
                    }
                }
            }

            Text {
                text: "Autostart Cycles:"
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(-1)
                color: Colors.outline
            }

            // Custom minimalist checkbox
            Item {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignRight

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Config.system.pomodoro.autoStart ? Styling.srItem("overprimary") : Colors.surfaceBright
                    opacity: Config.system.pomodoro.autoStart ? 1.0 : 0.3

                    Rectangle {
                        x: Config.system.pomodoro.autoStart ? parent.width - width - 2 : 2
                        y: 2
                        width: 16
                        height: 16
                        radius: 8
                        color: Config.system.pomodoro.autoStart ? Colors.background : Colors.overBackground

                        Behavior on x {
                            NumberAnimation { duration: 200; easing.type: Easing.OutQuart }
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.system.pomodoro.autoStart = !Config.system.pomodoro.autoStart
                }
            }
        }
    }

    // Helper component for time input
    component TimeInput: TextField {
        id: timeIn
        property int value: 0
        signal valueUpdated(int newValue)
        
        text: value.toString().padStart(2, '0')
        onValueChanged: if (!activeFocus) text = value.toString().padStart(2, '0')
        
        selectByMouse: true
        font.family: Config.theme.monoFont
        font.pixelSize: Styling.fontSize(-1)
        color: Colors.overBackground
        background: StyledRect {
            variant: "common"
            radius: Styling.radius(-6)
            border.color: timeIn.activeFocus ? Styling.srItem("overprimary") : "transparent"
            border.width: 1
        }
        horizontalAlignment: TextInput.AlignHCenter
        maximumLength: 2
        validator: IntValidator { bottom: 0; top: 99 }
        
        onEditingFinished: {
            let val = parseInt(text) || 0;
            timeIn.valueUpdated(val);
        }
        
        Layout.preferredWidth: 36
        Layout.preferredHeight: 26
        padding: 0
        bottomPadding: 0
        topPadding: 0
    }
}
