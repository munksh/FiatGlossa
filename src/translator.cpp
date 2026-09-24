#include "translator.h"
#include "spelling.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QTimer>

namespace {

const int TimeoutMs = 15000;

bool isEnglishVariant(const QString &code)
{
    return code == QLatin1String("EN-GB") || code == QLatin1String("EN-US");
}

// Languages are identified everywhere by their DeepL TARGET code, because
// that is the code that distinguishes the variants -- and the variants are
// the whole point of this app. DeepL's source_lang has no variants, so it is
// derived here rather than carried around as a second code per language.
QString engineSource(const QString &code)
{
    if (isEnglishVariant(code))
        return QStringLiteral("EN");
    if (code.startsWith(QLatin1String("ZH")))
        return QStringLiteral("ZH");
    if (code.startsWith(QLatin1String("PT")))
        return QStringLiteral("PT");
    return code;
}

// ...and the reverse, for what DeepL says it detected: a bare "EN" has to
// become one of the two Englishes before it can be selected in the list.
QString identityFor(const QString &detected)
{
    if (detected == QLatin1String("EN")) return QStringLiteral("EN-US");
    if (detected == QLatin1String("ZH")) return QStringLiteral("ZH-HANS");
    if (detected == QLatin1String("PT")) return QStringLiteral("PT-PT");
    return detected;
}

// Anything that is not a JSON object becomes an empty object, so an HTML
// error page or a captive portal cannot crash the parse.
QJsonObject parseObject(const QByteArray &body)
{
    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(body, &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject())
        return QJsonObject();
    return doc.object();
}

} // namespace

Translator::Translator(QObject *parent)
    : QObject(parent)
    , m_nam(new QNetworkAccessManager(this))
    , m_timeout(new QTimer(this))
{
    m_timeout->setSingleShot(true);
    m_timeout->setInterval(TimeoutMs);
    connect(m_timeout, &QTimer::timeout, this, [this]() {
        if (m_reply) {
            m_timedOut = true;
            m_reply->abort();       // abort emits finished(), which reports it
        }
    });
}

void Translator::setApiKey(const QString &key)
{
    const QString k = key.trimmed();
    if (k == m_apiKey)
        return;
    m_apiKey = k;
    emit apiKeyChanged();

    m_usageKnown = false;
    m_used = 0;
    m_limit = -1;
    emit usageChanged();
    refreshUsage();
}
void Translator::setTsServer(const QString &server)
{
    const QString k = server.trimmed();
    if (k == m_tsServer)
        return;

    m_tsServer = k;
    emit tsServerChanged() ;

    m_usageKnown = false;
    m_used = 0;
    m_limit = -1;
    emit usageChanged();
    refreshUsage();
}
QUrl Translator::endpoint(const char *path) const
{
    // if a tsServer is given, just use the configured engine url + endpoint
    if ( ! m_tsServer.isEmpty()) {
       qDebug() << "url: " << m_tsServer.toLatin1() ;
        return QUrl(m_tsServer.toLatin1() + QLatin1String(path));
       }
    // A free-tier key ends in ":fx" and only works on the free host.
    const QString host = m_apiKey.endsWith(QLatin1String(":fx"))
        ? QStringLiteral("https://api-free.deepl.com")
        : QStringLiteral("https://api.deepl.com");
    return QUrl(host + "/v2" +QLatin1String(path));
}

// ------------------------------------------------------------- translation --

void Translator::translate(const QString &text, const QString &source, const QString &target)
{
    qDebug() << "text: " << text ;
    abortTranslation();

    if (text.trimmed().isEmpty()) {
        finishOk(QString(), false, QString(), 0);
        return;
    }
    if (target.isEmpty()) {
        finishError(tr("Choose a language to translate into."));
        return;
    }

    // Between the two Englishes the difference is spelling, and the phone
    // knows the spelling. No request, no characters spent, works offline.
    if (isEnglishVariant(source) && isEnglishVariant(target)) {
        finishOk(Spelling::convert(text, target), true, QString(), 0);
        return;
    }
    if (!source.isEmpty() && source == target) {
        finishOk(text, true, QString(), 0);
        return;
    }
    if (m_apiKey.isEmpty() &&  m_tsServer.isEmpty()) {
        finishError(tr("No DeepL key yet. Settings has a page on how to get one."));
        return;
    }

    QJsonArray texts;
    texts.append(text);
    QJsonObject body;
    body.insert(QStringLiteral("text"), texts);

    // ts_server expects _ISO_639-1_codes which are lower case
    if ( ! m_tsServer.isEmpty()) {
        body.insert(QStringLiteral("target_lang"), target.toLower());
    } else {
        body.insert(QStringLiteral("target_lang"), target);
    }
    // use input source designator unless it's a TSserver
    if ( ! source.isEmpty() )
        body.insert(QStringLiteral("source_lang"), engineSource(source));

    // default to auto source for now when using ts_server
    if ( ! m_tsServer.isEmpty())
        body.insert(QStringLiteral("source_lang"), QStringLiteral("auto"));



    QNetworkRequest request(endpoint("/translate"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    request.setRawHeader("Authorization", "DeepL-Auth-Key " + m_apiKey.toUtf8());
    // we have a ts_server, use it instead
    if ( ! m_tsServer.isEmpty() ) {
        qDebug() << "got to set request";
        QNetworkRequest request(endpoint("/translate"));
        request.setRawHeader("Authorization", "Bearer " + m_apiKey.toUtf8());
    }
    request.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("harbour-fiatglossa/1.0"));

    m_target = target;
    m_autoSource = source.isEmpty();
    setBusy(true);

    QNetworkReply *reply = m_nam->post(request, QJsonDocument(body).toJson(QJsonDocument::Compact));
    m_reply = reply;
    m_timeout->start();

    const quint64 serial = m_serial;
    connect(reply, &QNetworkReply::finished, this, [this, reply, serial]() {
        onTranslateFinished(reply, serial);
    });
}

void Translator::cancel()
{
    abortTranslation();
    setBusy(false);
}

void Translator::abortTranslation()
{
    // Bump first: the finished() that abort() emits then sees a stale serial.
    ++m_serial;
    m_timeout->stop();
    m_timedOut = false;
    if (m_reply) {
        QNetworkReply *reply = m_reply;
        m_reply = nullptr;
        reply->abort();
    }
}

void Translator::onTranslateFinished(QNetworkReply *reply, quint64 serial)
{
    reply->deleteLater();
    if (serial != m_serial)
        return;                     // superseded, or cancelled

    m_timeout->stop();
    m_reply = nullptr;
    const bool timedOut = m_timedOut;
    m_timedOut = false;

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    qDebug() << "status: " << status;
    const QJsonObject obj = parseObject(reply->readAll());


    qDebug() << "status: " << obj;

    const QJsonArray translations = obj.value(QStringLiteral("translations")).toArray();
    if (!translations.isEmpty()) {
        const QJsonObject first = translations.at(0).toObject();
        const QString text = first.value(QStringLiteral("text")).toString();
        const int billed = first.value(QStringLiteral("billed_characters")).toInt();
        QString detected;
        if (m_autoSource)
            detected = identityFor(first.value(QStringLiteral("detected_source_language")).toString().toUpper());
        finishOk(text, false, detected, billed);
        refreshUsage();             // keep the counter in Settings honest
        return;
    }

    if (timedOut) {
        finishError(tr("DeepL took too long to answer."));
        return;
    }
    finishError(messageFor(status, obj));
}

// DeepL returns {"message": "..."} for most failures. The status code is the
// part worth translating into something a person can act on.
QString Translator::messageFor(int status, const QJsonObject &obj)
{
    const QString detail = obj.value(QStringLiteral("message")).toString();

    switch (status) {
    case 403:
        return tr("DeepL did not accept the key. Check it in Settings.");
    case 456:
        return tr("This month's DeepL characters are used up.");
    case 429:
        return tr("Too many requests at once. Wait a moment.");
    case 413:
        return tr("That text is too long to send in one go.");
    case 400:
        return detail.isEmpty() ? tr("DeepL rejected the request.")
                                : tr("DeepL rejected the request: %1").arg(detail);
    default:
        break;
    }
    if (status >= 500)
        return tr("DeepL is having trouble. Try again shortly.");
    if (!detail.isEmpty())
        return detail;
    return tr("Could not reach DeepL.");
}

// ------------------------------------------------------------------- usage --

void Translator::refreshUsage()
{
    ++m_usageSerial;
    if (m_usageReply) {
        QNetworkReply *reply = m_usageReply;
        m_usageReply = nullptr;
        reply->abort();
    }
    if (m_apiKey.isEmpty())
        return;

    QNetworkRequest request(endpoint("/v2/usage"));
    request.setRawHeader("Authorization", "DeepL-Auth-Key " + m_apiKey.toUtf8());

    QNetworkReply *reply = m_nam->get(request);
    m_usageReply = reply;
    const quint64 serial = m_usageSerial;

    connect(reply, &QNetworkReply::finished, this, [this, reply, serial]() {
        reply->deleteLater();
        if (serial != m_usageSerial)
            return;
        m_usageReply = nullptr;

        const QJsonObject obj = parseObject(reply->readAll());
        const QJsonValue used = obj.value(QStringLiteral("character_count"));
        if (!used.isDouble())
            return;                 // a bad key shows up on the next translation

        m_used = static_cast<qint64>(used.toDouble());
        const QJsonValue limit = obj.value(QStringLiteral("character_limit"));
        m_limit = limit.isDouble() ? static_cast<qint64>(limit.toDouble()) : -1;
        m_usageKnown = true;
        emit usageChanged();
    });
}

// ----------------------------------------------------------------- results --

void Translator::finishOk(const QString &text, bool local, const QString &detected, int billed)
{
    m_translation = text;
    m_local = local;
    m_detected = detected;
    m_billed = billed;
    emit translationChanged();
    setError(QString());
    setBusy(false);
}

void Translator::finishError(const QString &message)
{
    m_translation.clear();
    m_local = false;
    m_detected.clear();
    m_billed = 0;
    emit translationChanged();
    setError(message);
    setBusy(false);
}

void Translator::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void Translator::setError(const QString &error)
{
    if (m_error == error)
        return;
    m_error = error;
    emit errorChanged();
}
