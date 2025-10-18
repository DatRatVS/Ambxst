import QtQuick
import qs.config
import qs.modules.theme

Rectangle {
    property bool vert: false
     property color lineColor: Colors[Config.theme.separatorColor]

    color: lineColor

    radius: Config.roundness

    width: vert ? 20 : 2
    height: vert ? 2 : 20
}
