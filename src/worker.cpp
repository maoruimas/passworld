#include <QFile>
#include <QCryptographicHash>
#include "worker.h"
#include "mclient.h"
#include "qaesencryption.h"

Worker::Worker(QObject *parent)
        : QObject(parent)
        , client(new MClient)
{
}

void Worker::setHostNameAndPort(const QString &hostName, int port)
{
    client->setHostNameAndPort(hostName, quint16(port));
}

void Worker::signIn(const QString &username, const QString &password)
{
    if(username.isEmpty() || password.isEmpty())
        emit finished(false, tr("Username and password should be nonempty"));
    else {
        setUsername(username);
        setPassword(password);
        refresh();
    }
}

void Worker::signUp(const QString &username, const QString &password)
{
    if(username.isEmpty() || password.isEmpty()){
        emit finished(false, tr("Username and password should be nonempty"));
        return;
    }
    QString remotePath = remoteFilePath(username);
    MClient::Result result = client->existsFile(remotePath);
    if(result == MClient::Negative){
        setUsername(username);
        setPassword(password);
        save("{\"titles\":[],\"fields\":[]}");
    }else if(result == MClient::Positive)
        emit finished(false, tr("User exists"));
    else
        emit finished(false, tr("Network error"));
}

void Worker::refresh()
{
    QString localPath = localFilePath(m_username);
    QString remotePath = remoteFilePath(m_username);
    MClient::Result result = client->download(remotePath, localPath);

    if(result != MClient::Positive){
        if(client->existsFile(remotePath) == MClient::Negative)
            emit finished(false, tr("User not exists"));
        else
            emit finished(false, tr("Network error"));
        return;
    }

    QFile fin(localPath);
    if(!fin.open(QIODevice::ReadOnly))
        emit finished(false, tr("Fail to access file"));
    else {
        QByteArray encrypted = fin.readAll();
        fin.close();
        m_data = decrypt(encrypted);
        emit finished(true, m_data);
    }
}

void Worker::save(const QString &data)
{
    QString localPath = localFilePath(m_username);
    QFile fout(localPath);
    if(!fout.open(QIODevice::WriteOnly)){
        emit finished(false, tr("Fail to access file"));
        return;
    }
    fout.write(encrypt(data));
    fout.close();

    QString remotePath = remoteFilePath(m_username);
    MClient::Result result = client->upload(localPath, remotePath);
    if(result == MClient::Positive){
        m_data = data;
        emit finished(true, data);
    }else if(result == MClient::Negative)
        emit finished(false, tr("Fail to save due to rejection"));
    else
        emit finished(false, tr("Fail to save due to network error"));
}

void Worker::changeUsername(const QString &password, const QString &newUsername)
{
    if(password != m_password)
        emit finished(false, tr("Wrong password"));
    else if(newUsername.isEmpty())
        emit finished(false, tr("Username should be nonempty"));
    else if(newUsername == m_username)
        emit finished(false, tr("Username not changed"));
    else{
        QString remotePath = remoteFilePath(newUsername);
        if(client->existsFile(remotePath) == MClient::Negative){
            // remove remote file
            remotePath = remoteFilePath(m_username);
            if(client->removeFile(remotePath) == MClient::Positive){
                // remove local file
                QString localPath = localFilePath(m_username);
                QFile file(localPath);
                if(file.remove()){
                    setUsername(newUsername);
                    save(m_data);
                }else
                    emit finished(false, tr("Fail to remove local file"));
            }else
                emit finished(false, tr("Fail to remove file on server"));
        }else
            emit finished(false, tr("User exists or network error"));
    }
}

void Worker::changePassword(const QString &password, const QString &newPassword)
{
    if(password != m_password)
        emit finished(false, tr("Wrong password"));
    else if(newPassword.isEmpty())
        emit finished(false, tr("Password should be nonempty"));
    else if(newPassword == m_password)
        emit finished(false, tr("Password not changed"));
    else{
        setPassword(newPassword);
        save(m_data);
    }
}

void Worker::deleteAccount()
{
    QString remotePath = remoteFilePath(m_username);
    // remove remote file
    remotePath = remoteFilePath(m_username);
    if(client->removeFile(remotePath) == MClient::Positive){
        // remove local file
        QString localPath = localFilePath(m_username);
        QFile file(localPath);
        if(file.remove())
            emit finished(true, "");
        else
            emit finished(false, tr("Fail to remove local file"));
    }else
        emit finished(false, tr("Fail to remove file on server"));
}

QString Worker::decrypt(const QByteArray &data) {
    QByteArray decrypted = QAESEncryption::Decrypt(QAESEncryption::AES_256, QAESEncryption::CBC,
                                                   data, m_hashKey, m_hashIV);
    return QString::fromUtf8(QAESEncryption::RemovePadding(decrypted));
}

QByteArray Worker::encrypt(const QString &text) {
    return QAESEncryption::Crypt(QAESEncryption::AES_256, QAESEncryption::CBC,
                                 text.toUtf8(), m_hashKey, m_hashIV);
}

QString Worker::localFilePath(const QString &username) {
    return username + ".pw";
}

QString Worker::remoteFilePath(const QString &username) {
    return "passworld/" + username + ".pw";
}

void Worker::setUsername(const QString &username) {
    m_username = username;
    m_hashIV = QCryptographicHash::hash(username.toUtf8(), QCryptographicHash::Md5);
}

void Worker::setPassword(const QString &password) {
    m_password = password;
    m_hashKey = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
}
