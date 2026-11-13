import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

Rectangle {
    BarComponents {
        id: barComponents
    }

    id: rightPanel

    implicitHeight: 40
    implicitWidth: Math.min(networkRow.implicitWidth + 20, Screen.width * 0.3)
    
    anchors
    {
        right: parent.right
        rightMargin: 5
    }

    radius: 10
    color: barComponents.panelColor

    Row{
        id: networkRow

        spacing: 10

        anchors{
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 5
        }

        // Separator {}

        Text {            
            id : date
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor
            Process{
                command: ["date" , "+%d-%b-%Y %A"]

                running: true

                stdout: StdioCollector {
                    onStreamFinished: date.text = this.text
                }
            }
        }

        BarComponents.Separator {
            separatorColor: barComponents.foregroundColor
        }

        Text {
            id: time

            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor

            Process {
                id: dateProc
                command: ["date", "+%I:%M %p"]

                running: true

                stdout: StdioCollector {
                    onStreamFinished: time.text = this.text.trim()
                }
            }

            Timer {
                interval: 60000
                running: true
                repeat: true

                onTriggered: dateProc.running = true
            }
}

        BarComponents.Separator {
            separatorColor: barComponents.foregroundColor
        }

        Text {
            id: activeapps
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            font.pixelSize: 20
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor
        }

        Text {
            id: volume
            anchors.verticalCenter: parent.verticalCenter

            text: Pipewire.defaultAudioSink?.audio?.muted ? "󰖁" : "󰕾"

            font.pixelSize: 20
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor

            PwObjectTracker {
                objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (Pipewire.defaultAudioSink?.audio)
                        Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
                }

                onWheel: (event) => {
                    let audio = Pipewire.defaultAudioSink?.audio

                    if (!audio)
                        return

                    let change = event.angleDelta.y > 0 ? 0.05 : -0.05

                    audio.volume = Math.max(0, Math.min(1, audio.volume + change))

                    event.accepted = true
                }
            }

                Text {
                text: Pipewire.defaultAudioSink?.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "N/A"

                          font.pixelSize: 10
                font.family: barComponents.fontFamily
                font.bold: true
                color: barComponents.foregroundColor

                anchors {
                    top: parent.bottom
                    horizontalCenter: parent.right
                    topMargin: -5
                    horizontalCenterOffset: 5
                }
    }
        }

        Text {
            id: bluetooth 
    text: {
        const adapter = Bluetooth.defaultAdapter;

        if (!adapter || !adapter.enabled)
            return "󰂲";

        if (adapter.devices.values.some(device => device.connected))
            return "";

        return "󰂯";
    }

            font.pixelSize: 20
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    Quickshell.execDetached([
                        "sh", "-c",
                         "if pgrep -x blueman-manager >/dev/null; then pkill -x blueman-manager; else blueman-manager; fi"
                    ])
                }
            }    
            
            Text {
                id: batteryPercentage

                text: {
                    const device = Bluetooth.defaultAdapter?.devices.values.find(device => device.batteryAvailable)
                    return device?.battery ? device.battery * 100 + "%" : "N/A"
                }

                font.pixelSize: 10
                font.family: barComponents.fontFamily
                font.bold: true
                color: barComponents.foregroundColor

                anchors {
                    top: parent.bottom
                    horizontalCenter: parent.right
                    topMargin: -5
                    horizontalCenterOffset: 10
                }
            }
        }

   

        Text {
            id: wifi
            text: ""
            font.pixelSize: 20
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    Quickshell.execDetached([
                        "sh", "-c",
                         "if pgrep -x rofi >/dev/null; then pkill -x rofi; else networkmanager_dmenu; fi"
                    ])
                }
            }

            Process {
                id: wifiWatcher
                command: ["sh", "-c", "nmcli -f STATE g status | grep -q disconnected && echo 1 || echo 0"]

                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        wifi.text = this.text.trim() === "1" ? "" : ""
                    }
                }
            }
            Timer{
                    interval: 5000
                    running: true
                    repeat: true

                    onTriggered: {
                        wifiWatcher.running = true
                    }
                }
        }


        BarComponents.Separator {
            separatorColor: barComponents.foregroundColor
        }

        Text {
            id: power
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor
            
            Process {
                id: batteryWatcher
                command: ["sh", "-c", "printf '%s|%s' \"$(cat /sys/class/power_supply/BAT1/capacity)\" \"$(cat /sys/class/power_supply/BAT1/status)\""]

                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        const values = this.text.trim().split("|")
                        const charging = values[1] === "Charging" || values[1] === "Not charging"
                        power.text = (charging ? " " : "") + values[0] + "%"
                    }
                }
            }

            Timer {
                interval: 5000
                running: true
                repeat: true
                onTriggered: {
                    batteryWatcher.running = true
                }
            }

        }

        Text {
            id: battery
            text: "⏻"
            font.pixelSize: 20
            font.family: barComponents.fontFamily
            font.bold: true
            color: barComponents.foregroundColor
            

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    Quickshell.execDetached([
                        "sh", "-c",
                        "hyprlock"
                    ])
                }
            }
        }
    }
}