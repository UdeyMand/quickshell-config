import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "lyrics.js" as Lyrics

Item {
    id: lyricsPanel
    clip: true

    implicitHeight: 200
    implicitWidth: 400

    property var player: Mpris.players.values[0]

    property string artist: player?.trackArtist ?? ""

    property string albumArtist: player?.trackAlbumArtist ?? ""

    property string track: player?.trackTitle ?? ""

    property real duration: player?.length ?? 0

    property bool isYouTube: (player?.trackUrl ?? "").indexOf("youtube.com") >= 0
        || (player?.trackUrl ?? "").indexOf("youtu.be") >= 0
        || ((player?.identity ?? "").toLowerCase().indexOf("brave") >= 0
            && track.indexOf(" - ") >= 0)
        || ((player?.identity ?? "").toLowerCase().indexOf("chrome") >= 0
            && track.indexOf(" - ") >= 0)
        || ((player?.identity ?? "").toLowerCase().indexOf("firefox") >= 0
            && track.indexOf(" - ") >= 0)
        || (track.indexOf(" - ") >= 0
            && !track.startsWith(artist + " - "))

    property string searchArtist: isYouTube ? youtubeArtist() : artist
    
    property string searchTrack: isYouTube ? youtubeTrack() : track

    property real time: 0

    property var lyrics: []
    property var currentLyric: findCurrentLyric()
    property bool available: true
    property int requestId: 0
    property real preferredWidth: Math.min(Math.max(lyricsMetrics.width + 20, 120), 500)

    function cleanTrackTitle(title) {
        return title.replace(/\s*\[\s*explicit\s*\]\s*/gi, " ").replace(/\s+/g, " ").trim();
    }

    function youtubeArtist() {
        const separator = track.indexOf(" - ");
        return separator >= 0 ? track.slice(0, separator).trim() : artist;
    }

    function youtubeTrack() {
        const separator = track.indexOf(" - ");
        const title = separator >= 0 ? track.slice(separator + 3) : track;
        return title
            .replace(/\s*\((?:official|lyrical|music|audio|video)[^)]*\)/gi, "")
            .replace(/\s*\|\s*.*$/, "")
            .trim();
    }

    function cleanLogName(name) {
        return name.replace(/[^\p{L}\p{N}\s]/gu, "").replace(/\s+/g, " ").trim();
    }

    function fetchLyrics() {
        const requestArtist = searchArtist.trim();
        const requestTrack = cleanTrackTitle(searchTrack);
        const id = requestId;

        if (!requestArtist || !requestTrack) {
            available = false;
            return;
        }

        console.log("Searching lyrics for:", cleanLogName(requestArtist), cleanLogName(requestTrack));

        Lyrics.getLyrics(requestArtist, requestTrack, Number(duration)).then(result => {
            if (id !== requestId)
                return;

            lyrics = Array.isArray(result) ? result.filter(line => line && Number.isFinite(line.time) && typeof line.lyric === "string") : [];
            available = lyrics.length > 0;
        }).catch(error => {
            if (id !== requestId)
                return;

            available = false;
            console.log("Lyrics error:", error);
        });
    }

    function scheduleLyricsFetch() {
        requestId++;
        lyrics = [];
        available = false;
        lyricsFetchTimer.restart();
    }

    function updateTime() {
        const position = Number(player?.position);
        time = Number.isFinite(position) && position >= 0 ? position : 0;
    }

    onPlayerChanged: scheduleLyricsFetch()
    onTrackChanged: scheduleLyricsFetch()
    onArtistChanged: scheduleLyricsFetch()
    onDurationChanged: scheduleLyricsFetch()

    function findCurrentLyric() {
        let current = null;

        for (let line of lyrics) {
            if (line.time > time)
                break;

            if (!current || line.time >= current.time)
                current = line;
        }

        return current;
    }

    Component.onCompleted: scheduleLyricsFetch()

    Timer {
        id: lyricsFetchTimer
        interval: 150
        repeat: false
        onTriggered: lyricsPanel.fetchLyrics()
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: lyricsPanel.updateTime()
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Text {
            id: lyricsText
            anchors.fill: parent
            text: lyricsPanel.available ? (lyricsPanel.currentLyric?.lyric?.trim() ? lyricsPanel.currentLyric.lyric : "󰎇") : "No lyrics available"
            font.pixelSize: 16
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            color: "white"
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.NoWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            onTextChanged: {
                y = lyricsPanel.height;
                lyricAnimation.restart();
            }

            NumberAnimation {
                id: lyricAnimation
                target: lyricsText
                property: "y"
                to: 0
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        TextMetrics {
            id: lyricsMetrics
            text: lyricsText.text
            font: lyricsText.font
        }
    }
}
