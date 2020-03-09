#ifndef MCLIENT_H
#define MCLIENT_H

#include <QObject>

class MClient : public QObject
{
    Q_OBJECT
public:
    enum Result {
        Positive, Negative, UnknownError, ConnectionFailure, TimeOut, LocalError
    };

    explicit MClient(QObject *parent = nullptr);
    void setHostNameAndPort(const QString &hostName, quint16 port);
    Result upload(const QString &localPath, const QString &remotePath);
    Result download(const QString &remotePath, const QString &localPath);
    Result existsFile(const QString &remotePath);
    Result existsDir(const QString &remotePath);
    Result removeFile(const QString &remotePath);
    Result removeDir(const QString &remotePath);
    Result renameFile(const QString &remotePath);
    Result renameDir(const QString &remotePath);
    static Result upload(const QString &hostName, quint16 port, const QString &localPath, const QString &remotePath);
    static Result download(const QString &hostName, quint16 port, const QString &remotePath, const QString &localPath);
    static Result existsFile(const QString &hostName, quint16 port, const QString &remotePath);
    static Result existsDir(const QString &hostName, quint16 port, const QString &remotePath);
    static Result removeFile(const QString &hostName, quint16 port, const QString &remotePath);
    static Result removeDir(const QString &hostName, quint16 port, const QString &remotePath);
    static Result renameFile(const QString &hostName, quint16 port, const QString &remotePath);
    static Result renameDir(const QString &hostName, quint16 port, const QString &remotePath);

private:
    QString m_hostName;
    quint16 m_port;
};

#endif // MCLIENT_H
