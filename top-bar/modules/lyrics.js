// .pragma library

function getLyrics(artist, track, duration) {
    return new Promise((resolve, reject) => {
        searchLyrics(artist, track, duration, resolve, reject);
    });
}

function searchLyrics(artist, track, duration, resolve, reject) {
    const url = "https://lrclib.net/api/search?q="
        + encodeURIComponent(artist + " " + track);

    requestJson(url, results => {
        const matches = [];

        console.log("LRCLIB results:", results.length);

        for (let i = 0; i < results.length; i++) {
            const result = results[i];
            const lyrics = parseLyrics(result.syncedLyrics);
            const requestedArtist = artist.toLowerCase();
            const artistMatch = result.artistName.toLowerCase() === requestedArtist
                || result.artistName
                    .split(/\s*(?:,|;|&|\bfeat\.?\b|\bft\.?\b)\s*/i)
                    .some(name => name.toLowerCase() === requestedArtist);
            const trackMatch = result.trackName === track;
            const durationMatch = Number.isFinite(duration)
                && duration > 0
                && Number.isFinite(result.duration)
                && Math.abs(result.duration - duration) <= 1;
            const hasSyncedLyrics = lyrics.length > 0;

            console.log("Result", i + 1,
                        "artist:", result.artistName,
                        "track:", result.trackName,
                        "duration:", result.duration,
                        "artistMatch:", artistMatch,
                        "trackMatch:", trackMatch,
                        "durationMatch:", durationMatch,
                        "synced:", hasSyncedLyrics);

            if (artistMatch && trackMatch && durationMatch && hasSyncedLyrics)
                matches.push({ lyrics: lyrics, index: i + 1 });
        }

        const selected = matches[1] ?? matches[0];
        if (!selected) {
            console.log("No matching synced lyrics result");
            resolve([]);
            return;
        }

        console.log("Using synced lyrics result:", selected.index);
        resolve(selected.lyrics);
    }, reject);
}

function requestJson(url, onSuccess, onFailure) {
    const request = new XMLHttpRequest();
    request.open("GET", url);

    request.onreadystatechange = function() {
        if (request.readyState !== XMLHttpRequest.DONE)
            return;

        if (request.status < 200 || request.status >= 300) {
            onFailure(new Error("HTTP " + request.status));
            return;
        }

        try {
            onSuccess(JSON.parse(request.responseText));
        } catch (error) {
            onFailure(error);
        }
    };

    request.onerror = function() {
        onFailure(new Error("Lyrics request failed"));
    };

    request.send();
}

function parseLyrics(rawLyrics) {
    if (!rawLyrics)
        return [];

    const parsedLyrics = [];
    for (let line of rawLyrics.split("\n")) {
        const match = line.match(/^\[(\d{2}):(\d{2}(?:\.\d+)?)\](.*)$/);
        if (!match)
            continue;

        parsedLyrics.push({
            time: Number(match[1]) * 60 + Number(match[2]),
            lyric: match[3].trim()
        });
    }

    return parsedLyrics
        .filter(line => Number.isFinite(line.time))
        .sort((a, b) => a.time - b.time);
}
