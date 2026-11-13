
import QtQuick
import Quickshell

ShellRoot {
    id: root

    property bool expanded: false

    // // Your normal bar
    // PanelWindow {
    //     id: bar

    //     anchors {
    //         top: true
    //         left: true
    //         right: true
    //     }

    //     implicitHeight: 40
    //     color: "#181825"

    //     Rectangle {
    //         anchors.fill: parent
    //         color: "#181825"

    //         Text {
    //             anchors.right: parent.right
    //             anchors.verticalCenter: parent.verticalCenter
    //             anchors.rightMargin: 20

    //             text: "󰖩"
    //             color: "white"
    //             font.pixelSize: 22

    //             MouseArea {
    //                 anchors.fill: parent
    //                 onClicked: root.expanded = !root.expanded
    //             }
    //         }
    //     }
    // }

    // // Dynamic Island overlay
    PanelWindow {
        id: island

        anchors.top: true
        margins.top: 8

        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        focusable: false

        color: "transparent"

        width: root.expanded ? 360 : 150
        height: root.expanded ? 180 : 40

        Rectangle {
            anchors.fill: parent
            radius: root.expanded ? 25 : 22
            color: "#11111b"
            border.color: "#45475a"
            border.width: 1

            Behavior on radius {
                NumberAnimation { duration: 100 }
            }

            Column {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.expanded
                          ? "Network settings"
                          : "󰖩  Wi-Fi"
                    color: "white"
                    font.pixelSize: 16
                }

                Text {
                    visible: root.expanded
                    text: "Connected to Wi-Fi"
                    color: "#a6adc8"
                }

                Text {
                    visible: root.expanded
                    text: "Internet connection active"
                    color: "#a6adc8"
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.expanded = !root.expanded
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
