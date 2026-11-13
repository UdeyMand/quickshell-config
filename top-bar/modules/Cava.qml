import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int barCount: 12
    property var barLevels: []

    readonly property string cavaConfig: [
        "[general]",
        "bars = " + root.barCount,
        "framerate = 60",
        "[output]",
        "method = raw",
        "raw_target = /dev/stdout",
        "data_format = ascii",
        "ascii_max_range = 1000",
        "bar_delimiter = 59"
    ].join("\n")

    Process {
        id: cavaProcess
        running: true
        command: ["bash", "-c", "printf '%b' " + JSON.stringify(root.cavaConfig) + " | cava -p /dev/stdin"]

        stdout: SplitParser {
            onRead: data => {
                const tokens = data.trim().split(";")
                const nextLevels = []

                for (let i = 0; i < root.barCount; i++) {
                    const rawAmplitude = i < tokens.length ? (parseFloat(tokens[i]) || 0) : 0
                    nextLevels.push(Math.max(0, Math.min(1, rawAmplitude / 1000)))
                }

                root.barLevels = nextLevels
            }
        }
    }
}
