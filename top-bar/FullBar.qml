import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: mainPanel


    BarComponents {
        id: barComponents
    }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Math.max(leftSide.implicitHeight, rightSide.implicitHeight, midrow.height)
    color: barComponents.transparentColor
    exclusiveZone: Math.max(leftSide.implicitHeight, rightSide.implicitHeight, midrow.height)

    LeftSide {
        id: leftSide    
        anchors {
            left: parent.left
            top: parent.top
        }
    }
    property bool middleVisible: true

    Row {
        id: midrow
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        height: middleVisible ? middleSide2.implicitHeight : middleSide.implicitHeight

        Text {
            id: next
            text: ""
            font.pixelSize: 30
            color: barComponents.foregroundColor
            MouseArea {
                anchors.fill: parent
                onClicked: middleVisible = !middleVisible
            }
        }

        Item {
            id: middleViewport

            width:middleVisible ? Math.min(middleSide2.implicitWidth + 10, Screen.width * 0.3) : Math.min(middleSide.implicitWidth + 10, Screen.width * 0.3)
            height: middleVisible ? middleSide2.implicitHeight : middleSide.implicitHeight
            // clip: true

            Behavior on width {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.InOutCubic
                }
            }

            Middle {
                id: middleSide
                width: middleViewport.width
                y: middleVisible ? -middleViewport.height : 0
                opacity: middleVisible ? 0 : 1

                Behavior on y {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.InOutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 180 }
                }
            }

            Middle2 {
                id: middleSide2
                width: middleViewport.width
                y: middleVisible ? 0 : middleViewport.height
                opacity: middleVisible ? 1 : 0

                Behavior on y {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.InOutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 180 }
                }
            }
        }

        Text {
            id: next2
            text: ""
            font.pixelSize: 30
            color: barComponents.foregroundColor
            MouseArea {
                anchors.fill: parent
                onClicked: middleVisible = !middleVisible
            }
        }
    }

    RightSide {
        id: rightSide
        anchors {
            right: parent.right
            top: parent.top
        }
    }
}
