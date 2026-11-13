import QtQuick
import Quickshell

QtObject {
    readonly property color foregroundColor: "white"
    readonly property color transparentColor: "transparent"
    readonly property color panelColor: Qt.rgba(1, 1, 1, 0.1)
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 16

    component Separator: Rectangle {
        required property color separatorColor

        width: 1
        height: 20
        color: separatorColor
        anchors.verticalCenter: parent.verticalCenter
    }
}