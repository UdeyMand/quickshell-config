import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "modules" as Modules

Rectangle {
    id: middlePanel

    BarComponents {
        id: barComponents
    }

    property bool expanded: false
    implicitHeight: 40
    implicitWidth: expanded ? lyricsLoader.width + 10 : middleRow.implicitWidth + 10
    color: barComponents.panelColor
    radius: 10
    clip: true

    Row {
        id: middleRow
        spacing: 10
        height: 40
        anchors.top: parent.top
        x: expanded ? middlePanel.width : (middlePanel.width - width) / 2
        opacity: expanded ? 0 : 1

        Behavior on x {
            NumberAnimation {
                duration: 280
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 280
                easing.type: Easing.InOutCubic
            }
        }

        Text {
            id: musicIcon
            text: "󰎇"
            font.pixelSize: barComponents.fontSize + 5
            color: barComponents.foregroundColor
            font.family: barComponents.fontFamily
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: musicIconTooltip
                text: lyricsLoader.item?.available ? "" : ""
                font.pixelSize: 10
                font.family: barComponents.fontFamily
                font.bold: true
                color: barComponents.foregroundColor

                anchors {
                    top: parent.bottom
                    horizontalCenter: parent.right
                    topMargin: -10
                    horizontalCenterOffset: 0
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: middlePanel.expanded = !middlePanel.expanded
            }
        }

        Modules.Visualizer {
            width: 80
            height: parent.height
            color: barComponents.transparentColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: musicTitleRect
            width: 170
            height: 30
            radius: 10
            color: barComponents.transparentColor
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Item {
                id: musicTitleViewport
                anchors.fill: parent

                Row {
                    id: musicTitleReel
                    x: 5
                    height: parent.height
                    spacing: 10

                    Text {
                        id: musicTitle
                        width: musicTitleMetrics.width
                        height: parent.height
                        text: Mpris.players.values[0]?.trackTitle || "No music playing"
                        anchors.top: parent.top
                        anchors.verticalCenterOffset: -10
                        font.pixelSize: barComponents.fontSize
                        color: barComponents.foregroundColor
                        font.family: barComponents.fontFamily
                        font.bold: true
                    }

                    Text {
                        width: musicTitleMetrics.width
                        height: parent.height
                        text: musicTitle.text
                        font: musicTitle.font
                        color: musicTitle.color
                        visible: musicTitleMetrics.width > musicTitleRect.width - 5
                    }

                    SequentialAnimation on x {
                        id: titleMarquee
                        running: musicTitleMetrics.width > musicTitleRect.width - 5
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 5
                            to: -(musicTitleMetrics.width + musicTitleReel.spacing)
                            duration: Math.max(1400, (musicTitleMetrics.width + musicTitleReel.spacing) * 35)
                            easing.type: Easing.Linear
                        }

                        PauseAnimation {
                            duration: 1000
                        }
                    }

                    Connections {
                        target: musicTitle
                        function onTextChanged() {
                            musicTitleReel.x = 5;
                            if (musicTitleMetrics.width > musicTitleRect.width - 5)
                                titleMarquee.restart();
                        }
                    }
                }

                Item {
                    id: artistViewport
                    x: 5
                    y: 17
                    width: musicTitleRect.width - 10
                    height: 13
                    clip: true

                    Row {
                        id: artistLine
                        height: parent.height
                        spacing: 10

                        Text {
                            id: musicTime

                            property int length: Mpris.players.values[0]?.length
                            property int position: 0

                            text: Math.floor(position / 60) + ":" + (position % 60 < 10 ? "0" : "") + position % 60 + " / " + Math.floor(length / 60) + ":" + (length % 60 < 10 ? "0" : "") + length % 60
                            font.pixelSize: 12
                            color: barComponents.foregroundColor
                            font.family: barComponents.fontFamily

                            Timer {
                                interval: 500
                                repeat: true
                                running: true
                                triggeredOnStart: true
                                onTriggered: musicTime.position = Mpris.players.values[0]?.position ?? 0
                            }
                        }

                        Item {
                            id: artistNameViewport
                            width: Math.max(0, artistViewport.width - musicTime.width - artistLine.spacing)
                            height: parent.height
                            clip: true

                            Row {
                                id: artistReel
                                height: parent.height
                                spacing: 10

                                Text {
                                    id: artstName
                                    width: artistMetrics.width
                                    height: parent.height
                                    text: Mpris.players.values[0]?.trackArtist || "N/A"
                                    color: barComponents.foregroundColor
                                    font.pixelSize: 12
                                    opacity: 0.8
                                    font.family: barComponents.fontFamily
                                    font.bold: true
                                }

                                Text {
                                    id: artistDuplicate
                                    width: artistMetrics.width
                                    height: parent.height
                                    text: artstName.text
                                    font: artstName.font
                                    color: artstName.color
                                    opacity: artstName.opacity
                                    visible: artistMetrics.width > artistNameViewport.width
                                }

                                SequentialAnimation on x {
                                    id: artistMarquee
                                    running: artistMetrics.width > artistNameViewport.width
                                    loops: Animation.Infinite

                                    NumberAnimation {
                                        from: 0
                                        to: -(artistMetrics.width + artistReel.spacing)
                                        duration: Math.max(1400, (artistMetrics.width + artistReel.spacing) * 35)
                                        easing.type: Easing.Linear
                                    }

                                    PauseAnimation {
                                        duration: 1000
                                    }
                                }

                                Connections {
                                    target: artstName
                                    function onTextChanged() {
                                        artistReel.x = 0;
                                        if (artistMetrics.width > artistNameViewport.width)
                                            artistMarquee.restart();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            TextMetrics {
                id: musicTitleMetrics
                text: musicTitle.text
                font: musicTitle.font
            }

            TextMetrics {
                id: artistMetrics
                text: artstName.text
                font: artstName.font
            }
        }

        Text {
            id: previous
            text: "󰒮"
            font.pixelSize: barComponents.fontSize + 9
            color: barComponents.foregroundColor
            font.family: barComponents.fontFamily
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (Mpris.players.values.length > 0) {
                        Mpris.players.values[0].previous();
                    }
                }
            }
        }

        Text {
            id: playpause
            text: Mpris.players.values[0]?.isPlaying ? "" : ""
            font.pixelSize: barComponents.fontSize + 1
            color: barComponents.foregroundColor
            font.family: barComponents.fontFamily
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (Mpris.players.values.length > 0) {
                        Mpris.players.values[0].togglePlaying();
                    }
                }
            }
        }

        Text {
            id: next
            text: "󰒭"
            font.pixelSize: barComponents.fontSize + 9
            color: barComponents.foregroundColor
            font.family: barComponents.fontFamily
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (Mpris.players.values.length > 0) {
                        Mpris.players.values[0].next();
                    }
                }
            }
        }
    }

    Loader {
        id: lyricsLoader
        source: "modules/lyrics.qml"
        width: Math.min(lyricsLoader.item?.preferredWidth ?? 120, Screen.width * 0.3)
        height: parent.height
        x: middlePanel.expanded ? (middlePanel.width - width) / 2 : middlePanel.width
        opacity: middlePanel.expanded ? 1 : 0
        active: true

        Behavior on opacity {
            NumberAnimation {
                duration: 280
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on x {
            NumberAnimation {
                duration: 280
                easing.type: Easing.InOutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: middlePanel.expanded = false
        }
    }
}
