// Runs in a WorkerScript thread, separate from the UI. The page splits the
// text, paces the lines, and reassembles the result; this trades one line
// for its translation, one request at a time.
//
// In from the page:  { serial, index, engine, targetLang, line }
//                    { cancel: true }
// Out to the page:   { serial, index, line }   the line, translated
//                    { serial, index, error }  this line failed
//
// serial is the page's run counter and index the line's position in the
// original text; together they let the page put each answer in its place
// and drop any that belong to a run it has already moved past.

var inFlight = false;   // a request is out there
var flight = null;      // that request

WorkerScript.onMessage = function (message) {
    if (!message)
        return;

    if (message.cancel === true) {
        // Disowned before aborting: the answer the abort still raises sees
        // request !== flight and stays quiet.
        var dead = flight;
        flight = null;
        inFlight = false;
        if (dead)
            dead.abort();
        return;
    }

    if (message.line === undefined)
        return;

    // The page sends one line at a time; if one is still out there, this
    // message belongs to a run the page has already moved past.
    if (inFlight)
        return;

    inFlight = true;
    var serial = message.serial;
    var index = message.index;

    var request = new XMLHttpRequest();
    flight = request;
    request.onreadystatechange = function () {
        if (request.readyState !== 4 || request !== flight)
            return;              // cancelled, or superseded
        flight = null;
        inFlight = false;

        var line = "";
        var got = false;
        var error = "";
        if (request.status === 0)
            error = "Could not reach the TextSynth server.";
        else if (request.status < 200 || request.status >= 300)
            error = "The TextSynth server answered " + request.status + ".";
        else {
            try {
                var answer = JSON.parse(request.responseText);
                var translations = answer ? answer.translations : null;
                if (translations && translations.length > 0) {
                    line = translations[0].text;
                    got = true;
                }
            } catch (e) {
            }
            if (!got)
                error = "The TextSynth server sent an answer that could not be read.";
        }

        if (error !== "")
            WorkerScript.sendMessage({ serial: serial, index: index, error: error });
        else
            WorkerScript.sendMessage({ serial: serial, index: index, line: line });
    };

    request.open("POST", message.engine + "/translate", true);
    request.setRequestHeader("Content-Type", "application/json");
    request.send(JSON.stringify({
        text: [message.line],
        target_lang: message.targetLang,
        source_lang: "auto"
    }));
};
