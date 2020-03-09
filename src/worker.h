#ifndef WORKER_H
#define WORKER_H

#include <QObject>
class MClient;

class Worker : public QObject
{
    Q_OBJECT
public:
    explicit Worker(QObject *parent = nullptr);
    void setHostNameAndPort(const QString &hostName, int port);

signals:
    void finished(bool succeeded, QString data);

public slots:
    void signIn(const QString &username, const QString &password);
    void signUp(const QString &username, const QString &password);
    void refresh();
    void save(const QString &data);
    void changeUsername(const QString &password, const QString &newUsername);
    void changePassword(const QString &password, const QString &newPassword);
    void deleteAccount();

private:
    QString decrypt(const QByteArray &data);
    QByteArray encrypt(const QString &text);
    QString localFilePath(const QString &username);
    QString remoteFilePath(const QString &username);
    void setUsername(const QString &username);
    void setPassword(const QString &password);
    MClient *client;
    QString m_data;
    QString m_username, m_password;
    QByteArray m_hashKey, m_hashIV;
};

#endif // WORKER_H
