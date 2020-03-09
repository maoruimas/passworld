#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
class Worker;

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);
    Q_INVOKABLE void setHostNameAndPort(const QString &hostName, int port);

signals:
    void signIn(const QString &username, const QString &password);
    void signUp(const QString &username, const QString &password);
    void refresh();
    void save(const QString &data);
    void changeUsername(const QString &password, const QString &newUsername);
    void changePassword(const QString &password, const QString &newPassword);
    void deleteAccount();
    void finished(bool succeeded, QString data);

public slots:
private:
    QThread *thread;
    Worker *worker;
};

#endif // BACKEND_H
