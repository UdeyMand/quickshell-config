const ps2 = [11, 2, 3, 4, 5, 6, 7, 9, 0, 4, 3, 2, 1, 3, 33, 45, 66, 786, 43, 32, 24];

function findNearest(arr, num) {
    console.log("Nearest number to " + num + " is: " + arr.reduce((a, b) =>
        Math.abs(b - num) < Math.abs(a - num) ? b : a
    ));
    return arr.reduce((a, b) =>
        Math.abs(b - num) < Math.abs(a - num) ? b : a
    );
}

findNearest(ps2, 4.9);