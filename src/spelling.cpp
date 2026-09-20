#include "spelling.h"

#include <QHash>
#include <QRegularExpression>
#include <QStringList>

// British <-> American spelling, done on the phone.
//
// DeepL can translate between EN-GB and EN-US itself, but this costs no
// characters, answers instantly and works with no signal -- and it is the
// whole point of the "English (Traditional)" / "English (Simplified)" pair.

namespace {

enum Direction { ToUs = 1, ToUk = 2, Both = ToUs | ToUk };

struct Tables
{
    QHash<QString, QString> ukToUs;
    QHash<QString, QString> usToUk;

    void add(const QString &uk, const QString &us, int direction = Both)
    {
        if (direction & ToUs) ukToUs.insert(uk, us);
        if (direction & ToUk) usToUk.insert(us, uk);
    }

    // stem + middle + ending, where only the middle differs.
    void family(const char *stem, const char *ukMiddle, const char *usMiddle,
                const QStringList &endings)
    {
        for (const QString &end : endings)
            add(QString::fromLatin1(stem) + QLatin1String(ukMiddle) + end,
                QString::fromLatin1(stem) + QLatin1String(usMiddle) + end);
    }
};

Tables build()
{
    Tables t;

    // colour / color. No "-al" or "-ous": humoral and humorous are the same
    // on both sides of the Atlantic.
    const QStringList our = { "", "s", "ed", "ing", "ful", "able", "ably",
                              "less", "er", "ers", "y", "hood" };
    for (const char *stem : { "col", "hon", "lab", "neighb", "flav", "hum", "behavi",
                              "harb", "rum", "vap", "arm", "val", "splend", "rig",
                              "od", "savi", "sav", "clam", "fav", "vig", "endeav", "parl" })
        t.family(stem, "our", "or", our);

    // organise / organize. Explicit stems only, never a blanket -ise rule:
    // advise, surprise, exercise and promise would all break.
    const QStringList ise = { "e", "es", "ed", "ing", "er", "ers", "ation", "ations", "able" };
    for (const char *stem : { "organ", "real", "recogn", "apolog", "critic", "emphas",
                              "priorit", "summar", "categor", "minim", "maxim", "custom",
                              "optim", "final", "standard", "util", "special", "memor",
                              "visual", "author", "civil", "character", "capital",
                              "central", "normal", "local", "global", "modern", "symbol",
                              "harmon", "synchron", "legal", "familiar", "mobil",
                              "fertil", "stabil", "general", "patron", "agon", "sanit" })
        t.family(stem, "is", "iz", ise);

    // analyse / analyze. No "es": "analyses" is also the plural of analysis.
    for (const char *stem : { "analy", "paraly", "cataly" })
        t.family(stem, "s", "z", { "e", "ed", "ing", "er", "ers" });

    // centre / center
    for (const char *stem : { "cent", "theat", "fib", "lit", "calib", "somb",
                              "spect", "lust", "sab", "meag" })
        t.family(stem, "re", "er", { "", "s" });

    // travelled / traveled
    for (const char *stem : { "travel", "cancel", "model", "label", "fuel", "level",
                              "signal", "marvel", "quarrel", "dial", "jewel", "tunnel",
                              "counsel", "duel", "total", "channel", "panel" })
        t.family(stem, "l", "", { "ed", "ing", "er", "ers" });

    // one-offs
    t.add("grey", "gray");             t.add("greys", "grays");
    t.add("greyish", "grayish");       t.add("defence", "defense");
    t.add("offence", "offense");       t.add("pretence", "pretense");
    t.add("licence", "license");       t.add("licences", "licenses");
    t.add("catalogue", "catalog");     t.add("catalogues", "catalogs");
    t.add("analogue", "analog");       t.add("aluminium", "aluminum");
    t.add("plough", "plow");           t.add("sceptical", "skeptical");
    t.add("sceptic", "skeptic");       t.add("mum", "mom");
    t.add("mums", "moms");             t.add("aeroplane", "airplane");
    t.add("aeroplanes", "airplanes");  t.add("pyjamas", "pajamas");
    t.add("manoeuvre", "maneuver");    t.add("manoeuvres", "maneuvers");
    t.add("paediatric", "pediatric");  t.add("encyclopaedia", "encyclopedia");
    t.add("enrolment", "enrollment");  t.add("fulfilment", "fulfillment");
    t.add("skilful", "skillful");      t.add("jewellery", "jewelry");
    t.add("maths", "math");            t.add("favourite", "favorite");
    t.add("favourites", "favorites");  t.add("behavioural", "behavioral");
    t.add("marvellous", "marvelous");  t.add("centred", "centered");
    t.add("centring", "centering");    t.add("counsellor", "counselor");
    t.add("cosy", "cozy");             t.add("moustache", "mustache");
    t.add("doughnut", "donut");        t.add("ageing", "aging");
    t.add("judgement", "judgment");    t.add("anaemia", "anemia");

    // One way only: the reverse would be wrong half the time.
    t.add("whilst", "while", ToUs);      t.add("amongst", "among", ToUs);
    t.add("practise", "practice", ToUs); t.add("practised", "practiced", ToUs);
    t.add("practising", "practicing", ToUs);
    t.add("learnt", "learned", ToUs);    t.add("spelt", "spelled", ToUs);
    t.add("dreamt", "dreamed", ToUs);
    t.add("got", "gotten", ToUk);        // "gotten" becomes "got" under Traditional

    // British <-> American VOCABULARY: different words for the same thing,
    // not spelling variants of one word. convert() only ever looks up ONE
    // word at a time, so a source phrase of more than one word can never be
    // matched -- a pair where only one side is a phrase still works in the
    // direction where the single word is the thing being looked up, and is
    // just quietly inert in the other direction. A pair where BOTH sides are
    // phrases ("parking lot" / "car park", "driver's license" / "driving
    // licence", and a dozen more like them) isn't in this table at all: it
    // would never fire either way, so it would just be dead weight here.
    t.add("flat", "apartment");
    t.add("anaesthetist", "anesthesiologist");
    t.add("starter", "appetizer");
    t.add("barrister", "attorney");
    t.add("toilet", "bathroom");
    t.add("biscuit", "cookie");
    t.add("grill", "broil");
    t.add("grill", "broiler", ToUk);      // second American word for the same British "grill"; the British word always comes back as "broil"
    t.add("sweets", "candy");
    t.add("candyfloss", "cotton candy");  // one-directional: "cotton candy" is two words
    t.add("wardrobe", "closet");
    t.add("anticlockwise", "counterclockwise");
    t.add("cot", "crib");
    t.add("nappy", "diaper");
    t.add("chemist", "pharmacy");
    t.add("chemist", "drugstore", ToUk);  // second American word for the same British "chemist"; "chemist" itself always comes back as "pharmacy"
    t.add("rubber", "eraser");
    t.add("motorway", "expressway");
    t.add("motorway", "interstate", ToUk); // second American word for the same British "motorway"
    t.add("petrol", "gasoline");
    t.add("bonnet", "hood");
    t.add("chips", "French fries");
    t.add("crisps", "chips");             // the OTHER "chips" -- American "chips" (crisps) and British "chips" (French fries) are spelled alike and mean different food; each direction only ever produces one of them
    t.add("rubbish", "garbage");
    t.add("dustbin", "garbage can");      // one-directional: "garbage can" is two words
    t.add("postbox", "mailbox");
    t.add("cinema", "movie theater");     // one-directional: "movie theater" is two words
    t.add("flyover", "overpass");
    t.add("dummy", "pacifier");
    t.add("trousers", "pants");
    t.add("pavement", "sidewalk");
    t.add("trainers", "sneakers");
    t.add("football", "soccer");
    t.add("pushchair", "stroller");
    t.add("jumper", "sweater");
    t.add("takeaway", "takeout");
    t.add("drawing pin", "thumbtack");    // one-directional: "drawing pin" is two words
    t.add("tyre", "tire");
    t.add("telly", "tv");
    t.add("vest", "undershirt");
    t.add("windscreen", "windshield");
    t.add("spanner", "wrench");
    t.add("postcode", "zip code");        // one-directional: "zip code" is two words
    t.add("zip", "zipper");
    t.add("courgette", "zucchini");
    t.add("gear lever", "gearshift");     // one-directional: "gear lever" is two words
    t.add("dressing gown", "robe");       // one-directional: "dressing gown" is two words
    t.add("flatmate", "roommate");

    return t;
}

QString matchCase(const QString &original, const QString &replacement)
{
    if (original.size() > 1 && original == original.toUpper())
        return replacement.toUpper();
    if (original.at(0).isUpper()) {
        QString r = replacement;
        r[0] = r.at(0).toUpper();
        return r;
    }
    return replacement;
}

} // namespace

QString Spelling::convert(const QString &text, const QString &target)
{
    const bool toUk = (target == QLatin1String("EN-GB"));
    if (!toUk && target != QLatin1String("EN-US"))
        return text;

    static const Tables tables = build();
    const QHash<QString, QString> &map = toUk ? tables.usToUk : tables.ukToUs;

    static const QRegularExpression word(QStringLiteral("[A-Za-z]+"));

    QString out;
    out.reserve(text.size() + 16);
    int last = 0;

    QRegularExpressionMatchIterator it = word.globalMatch(text);
    while (it.hasNext()) {
        const QRegularExpressionMatch m = it.next();
        out += text.midRef(last, m.capturedStart() - last);
        const QString w = m.captured();
        const auto found = map.constFind(w.toLower());
        out += (found == map.constEnd()) ? w : matchCase(w, found.value());
        last = m.capturedEnd();
    }
    out += text.midRef(last);
    return out;
}
