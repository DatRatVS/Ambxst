import QtQuick
import qs.config
import qs.modules.theme

Item {
    id: root
    property real amplitudeMultiplier: 0.5
    property real frequency: 6
    property color color: Colors.primaryFixed
    property real lineWidth: 4
    property real fullLength: width
    property real speed: 2.4

    ShaderEffect {
        id: wavyShader
        anchors.fill: parent
        visible: Config.performance.wavyLine

        property real phase: 0
        property real amplitude: root.lineWidth * root.amplitudeMultiplier
        property real frequency: root.frequency
        property vector4d shaderColor: Qt.vector4d(root.color.r, root.color.g, root.color.b, root.color.a)
        property real lineWidth: root.lineWidth
        property real canvasWidth: root.width
        property real canvasHeight: root.height
        property real fullLength: root.fullLength

        vertexShader: "wavyline.vert.qsb"
        fragmentShader: "wavyline.frag.qsb"

        Component.onCompleted: {
            animationTimer.start();
        }

        Timer {
            id: animationTimer
            interval: 16
            running: Config.performance.wavyLine
            repeat: true
            onTriggered: {
                var deltaTime = interval / 1000.0;
                wavyShader.phase += root.speed * deltaTime;
            }
        }
    }

    Rectangle {
        id: simpleRect
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        visible: !Config.performance.wavyLine
        color: root.color
        radius: 2
    }

    function requestPaint() {
    // Mantenido por compatibilidad
    }
}
