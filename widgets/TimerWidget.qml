import QtQuick
import Quickshell
import Quickshell.Wayland


PanelWindow{
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: -1

    property int widgetX: 100
    property int widgetY: 250

    anchors {
        left: true
        top: true
    }

    margins {
        left: widgetX
        top: widgetY
    }

    property var currentDate: new Date().toDateString().split(" ")

    QtObject {
        id: barComponents
        readonly property color foregroundColor: "white"
        readonly property color transparentColor: "transparent"
        readonly property color panelColor: Qt.rgba(1, 1, 1, 0.1)
        readonly property string fontFamily: "JetBrainsMono Nerd Font"
        readonly property int fontSize: 16
    }

    FontLoader {
        id: geofont
        source: "fonts/BlackOpsOne-Regular.ttf"
    }

    id: timerWindow
    // title: "time-widget"
    width: 500
    height: 300
    // minimumSize: Qt.size(500, 400)
    // maximumSize: Qt.size(500, 400)
    color: Qt.rgba(0, 0, 0, 0.1)

    Rectangle{
    id: dateContainer
    width: parent.width / 1.6
    height: parent.height / 1.4
    border.width: 1
    border.color: "white"
    color: "transparent"

        Text{
            id: date
            text:currentDate[2]

            anchors.fill: parent
            font.pixelSize: parent.height
            fontSizeMode: Text.Fit
            minimumPixelSize: 1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: barComponents.foregroundColor
            font.family: geofont.name
            font.bold: true
            transform: Scale {
                origin.x: date.width / 2
                origin.y: date.height / 2
                yScale: date.paintedHeight > 0 ? (date.height / date.paintedHeight) * 1.5 : 1
            }
        }
    }
    Rectangle{
        id: yearContainer
        border.width: 1
        border.color: "white"
        height: parent.height / 7
        width: parent.width - parent.width / 1.6
        anchors{
            right: parent.right
            bottom: parent.bottom
            bottomMargin: parent.height - dateContainer.height
        }
        color: "transparent"
        Text{
            id: year
            text:currentDate[3]

            anchors.fill: parent
            font.pixelSize: parent.height
            fontSizeMode: Text.Fit
            minimumPixelSize: 1
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: barComponents.foregroundColor
            font.family: geofont.name
            font.bold: true
            transform: Scale {
                origin.x: year.width / 2
                origin.y: year.height / 2
                yScale: year.paintedHeight > 0 ? (year.height / year.paintedHeight) * 1.5 : 1
            }
        }
    }
    Rectangle{
        id: monthContainer
        border.width: 1
        border.color: "white"
        height: parent.height / 7
        width: parent.width - parent.width / 1.6
        anchors{
            right: parent.right
            bottom: parent.bottom
            bottomMargin: parent.height - dateContainer.height + yearContainer.height
        }
        color: "transparent"
        Text{
            id: month
            text:currentDate[1]

            anchors.fill: parent
            font.pixelSize: parent.height
            fontSizeMode: Text.Fit
            minimumPixelSize: 1
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: barComponents.foregroundColor
            font.family: geofont.name
            font.bold: true
            transform: Scale {
                origin.x: month.width / 2
                origin.y: month.height / 2
                yScale: month.paintedHeight > 0 ? (month.height / month.paintedHeight) * 1.5 : 1
            }
        }
    }
    Rectangle{
        id:dayContainer
        border.width: 1
        border.color: "white"
        height: parent.height / 7
        width: parent.width - parent.width / 1.6
        anchors{
            right: parent.right
            bottom: parent.bottom
            bottomMargin: parent.height - dateContainer.height + yearContainer.height + monthContainer.height
        }
        color: "transparent"
        Text{
            id: day
            text:currentDate[0]

            anchors.fill: parent
            font.pixelSize: parent.height
            fontSizeMode: Text.Fit
            minimumPixelSize: 1
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: barComponents.foregroundColor
            font.family: geofont.name
            font.bold: true
            transform: Scale {
                origin.x: day.width / 2
                origin.y: day.height / 2
                yScale: day.paintedHeight > 0 ? (day.height / day.paintedHeight) * 1.5 : 1
            }
        }
    }

    Rectangle{
        id: gifContainer
        border.width: 1
        border.color: "white"
        width: parent.width - parent.width / 1.6
        height: parent.height - 5 * (parent.height / 7)
        anchors{
            right: parent.right
        }
        z: 10
        color: "transparent"
        AnimatedImage{
            id: gif
            source: "/home/admin/.config/quickshell/logos/archlogo.svg"
            anchors.fill: parent
            anchors.margins: 5
            fillMode: Image.PreserveAspectFit
            playing: true
            loops: AnimatedImage.Infinite

        }
    }

    Rectangle{
        id:timeContainer
        border.width: 1
        border.color: "white"
        height: parent.height - dateContainer.height
        width: parent.width
        anchors{
            bottom: parent.bottom  
        }
        color: "transparent"
        Text{
            id: time
            text: new Date().toLocaleTimeString().split(" ")[0]
            color: "white"
            anchors.fill: parent
            font.pixelSize: parent.height
            fontSizeMode: Text.Fit
            minimumPixelSize: 1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: geofont.name
            font.bold: true
            transform: Scale {
                origin.x: time.width / 2
                origin.y: time.height / 2
                yScale: time.paintedHeight > 0 ? (time.height / time.paintedHeight) * 1.5 : 1
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            time.text = new Date().toLocaleTimeString().split(" ")[0]
            currentDate = new Date().toDateString().split(" ")
            date.text = currentDate[2]
            month.text = currentDate[1]
            year.text = currentDate[3]
            day.text = currentDate[0]
        }
    }

}