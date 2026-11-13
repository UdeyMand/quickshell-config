import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: leftPanel

    property bool expanded: false

    BarComponents {
        id: barComponents
    }
    implicitHeight: mainRect.implicitHeight + 5
    implicitWidth: Math.min(mainRect.implicitWidth + 10, Screen.width * 0.3)
    color: barComponents.transparentColor

    Rectangle {
        id: mainRect

        implicitHeight: 40
        implicitWidth: contentRow.implicitWidth + 30

        radius: 10
        color: barComponents.panelColor

        PopupWindow {
            id: applicationsPopup
            width: 400
            height: 400

            anchor.window: leftPanel
            anchor.rect.x: parentWindow.width / 2 - width / 2
            anchor.rect.y: parentWindow.height
            visible: true
        }

        Row {
            id: contentRow

            anchors.centerIn: parent
            spacing: 10

            Image {
                source: "../logos/archlogo.svg"
                anchors.verticalCenter: parent.verticalCenter
                height: 22
                width: 22
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        Quickshell.execDetached(["sh", "-c", "if pgrep -x rofi >/dev/null; then pkill -x rofi; else rofi -show drun -theme simple-tokyonight; fi"]);
                    }
                }
            }

            // Workspace indicators
            Row {
                id: workspaceRow
                spacing: 8

                Repeater {
                    model: Hyprland.workspaces

                    Rectangle {
                        required property var modelData

                        width: 15
                        height: 30
                        color: barComponents.transparentColor

                        Text {
                            anchors.centerIn: parent
                            text: modelData.id
                            font.pixelSize: modelData.active ? 20 : 15
                            font.family: barComponents.fontFamily
                            font.bold: true
                            color: barComponents.foregroundColor
                        }

                        Rectangle {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }

                            width: parent.width
                            height: 2
                            radius: 5
                            color: modelData.active ? barComponents.foregroundColor : barComponents.transparentColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.activate()
                        }
                    }
                }
            }

            BarComponents.Separator {
                separatorColor: barComponents.foregroundColor
            }

            // Focused window title
            Text {
                width: 190
                anchors.verticalCenter: parent.verticalCenter

                text: (Hyprland.activeToplevel?.title ?? "Desktop").split(" - ")[0]
                font.pixelSize: 15
                font.family: barComponents.fontFamily
                font.bold: true
                color: barComponents.foregroundColor

                elide: Text.ElideRight
            }
        }
    }
}
