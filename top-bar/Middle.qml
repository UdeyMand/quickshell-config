import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    BarComponents {
        id: barComponents
    }

    id: middlePanel

    implicitHeight: 40
    implicitWidth: Math.min(middleRow.implicitWidth + 10, Screen.width * 0.8)
    color: barComponents.panelColor
    radius: 10

    Row {
        id: middleRow
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: cpuText

            property var previous: null
            property real usage: 0

            text: " : " + usage.toFixed(1) + "%"
            font.pixelSize: 16
            color: barComponents.foregroundColor
            font.family: barComponents.fontFamily
            font.bold: true

            

            Process {
                id: cpuProcess

                command: ["cat", "/proc/stat"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        const values = this.text.trim().split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
                        const idle = values[3] + values[4]
                        const total = values.reduce((sum, value) => sum + value, 0)

                        if (cpuText.previous !== null) {
                            const totalDiff = total - cpuText.previous.total
                            const idleDiff = idle - cpuText.previous.idle

                            if (totalDiff > 0)
                                cpuText.usage = (totalDiff - idleDiff) / totalDiff * 100
                        }

                        cpuText.previous = {
                            total: total,
                            idle: idle
                        }
                    }
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: cpuProcess.running = true
            }
        } 


        BarComponents.Separator{
            separatorColor: barComponents.foregroundColor
        }

        Text {
            id:cputemp
            color: barComponents.foregroundColor
            font.pixelSize: barComponents.fontSize
            font.family: barComponents.fontFamily
            font.bold: true

            Process {
                id: tempProcess

                command: ["sh", "-c", "sensors | awk '/Package id 0:/ { print $4 }' | tr -d '+'"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        cputemp.text = " : " + this.text.trim()
                    }
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: tempProcess.running = true
            }

        }

        BarComponents.Separator{
            separatorColor: barComponents.foregroundColor
        }

        Text {
            id: ramUsage
            color: barComponents.foregroundColor
            font.pixelSize: barComponents.fontSize
            font.family: barComponents.fontFamily
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter

            Process {
                id: ramProcess

                command: ["sh", "-c", "awk '/MemTotal:/ { total = $2 } /MemAvailable:/ { available = $2 } END { printf \"%.1f\", (total - available) / 1024 / 1024 }' /proc/meminfo"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        ramUsage.text = ": " + this.text.trim() + " GiB"
                    }
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: ramProcess.running = true
            }
    }
        BarComponents.Separator{
            separatorColor: barComponents.foregroundColor
        }

        Text {
            id: storageUsage
            color: barComponents.foregroundColor
            font.pixelSize: barComponents.fontSize
            font.family: barComponents.fontFamily
            font.bold: true

            Process {
                id: storageProcess

                command: ["sh", "-c", "df --output=used / | tail -n 1 | awk '{ printf \"%.1f\", $1 / 1024 / 1024 }'"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        storageUsage.text = "󰋊 : " + this.text.trim() + " GiB"
                    }
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: storageProcess.running = true
            }
        }
}
}