import QtQuick
import Quickshell

Rectangle {
    id: visualizerPanel
    implicitWidth: 60
    implicitHeight: 30
    radius: 10
    color: Qt.rgba(0.1, 0.1, 0.1, 0.8)

    Cava {
        id: cava
    }

    Row {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 3

        Repeater {
            model: cava.barLevels

            Item {
                height: parent.height
                width: (parent.width - parent.spacing * (cava.barCount - 1)) / cava.barCount

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(2, parent.height * modelData)
                    color: "white"
                    radius: width

                    Behavior on height {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.InOutCubic
                        }
                    }
                }
            }
        }
    }
}
