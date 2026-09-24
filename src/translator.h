#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject>
#include <QPointer>
#include <QUrl>

class QJsonObject;
class QNetworkAccessManager;
class QNetworkReply;
class QTimer;

// Talks to DeepL with the user's own API key. Everything is asynchronous:
// calls return at once and results arrive through the NOTIFY signals, so the
// Silica UI thread never waits on the network.
//
// Two hosts: keys ending in ":fx" belong to the free tier and must go to
// api-free.deepl.com; everything else goes to api.deepl.com. The user never
// sees this -- the key itself says which.
class Translator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(bool hasKey READ hasKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString tsServer READ tsServer WRITE setTsServer NOTIFY tsServerChanged)
    Q_PROPERTY(bool hasTsServer READ hasTsServer NOTIFY tsServerChanged)

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    // One result, one signal: these four always change together.
    Q_PROPERTY(QString translation READ translation NOTIFY translationChanged)
    Q_PROPERTY(bool local READ local NOTIFY translationChanged)
    Q_PROPERTY(QString detectedSource READ detectedSource NOTIFY translationChanged)
    Q_PROPERTY(int billedCharacters READ billedCharacters NOTIFY translationChanged)

    // From GET /v2/usage. limit is -1 when the plan has no cap.
    Q_PROPERTY(bool usageKnown READ usageKnown NOTIFY usageChanged)
    Q_PROPERTY(qint64 charactersUsed READ charactersUsed NOTIFY usageChanged)
    Q_PROPERTY(qint64 characterLimit READ characterLimit NOTIFY usageChanged)

public:
    explicit Translator(QObject *parent = nullptr);

    QString apiKey() const { return m_apiKey; }
    void setApiKey(const QString &key);
    bool hasKey() const { return !m_apiKey.isEmpty(); }
    QString tsServer() const { return m_tsServer; }
    void setTsServer(const QString &server);
    bool hasTsServer() const { return !m_tsServer.isEmpty(); }

    bool busy() const { return m_busy; }
    QString error() const { return m_error; }
    QString translation() const { return m_translation; }
    bool local() const { return m_local; }
    QString detectedSource() const { return m_detected; }
    int billedCharacters() const { return m_billed; }

    bool usageKnown() const { return m_usageKnown; }
    qint64 charactersUsed() const { return m_used; }
    qint64 characterLimit() const { return m_limit; }

    // source is "" for "detect". The two English pseudo-codes are handled
    // here: between them nothing leaves the phone.
    Q_INVOKABLE void translate(const QString &text, const QString &source, const QString &target);
    Q_INVOKABLE void cancel();
    Q_INVOKABLE void refreshUsage();

signals:
    void apiKeyChanged();
    void tsServerChanged();
    void busyChanged();
    void errorChanged();
    void translationChanged();
    void usageChanged();

private:
    void abortTranslation();
    void onTranslateFinished(QNetworkReply *reply, quint64 serial);
    void finishOk(const QString &text, bool local, const QString &detected, int billed);
    void finishError(const QString &message);
    void setBusy(bool busy);
    void setError(const QString &error);
    QUrl endpoint(const char *path) const;
    static QString messageFor(int status, const QJsonObject &obj);

    QNetworkAccessManager *m_nam;
    QTimer *m_timeout;

    QString m_apiKey;
    QString m_tsServer;
    QPointer<QNetworkReply> m_reply;
    QPointer<QNetworkReply> m_usageReply;
    quint64 m_serial = 0;
    quint64 m_usageSerial = 0;
    bool m_timedOut = false;
    QString m_target;
    bool m_autoSource = false;

    bool m_busy = false;
    bool m_local = false;
    int m_billed = 0;
    QString m_error;
    QString m_translation;
    QString m_detected;

    bool m_usageKnown = false;
    qint64 m_used = 0;
    qint64 m_limit = -1;
};

#endif // TRANSLATOR_H
