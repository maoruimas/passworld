#include <QFile>
#include <QDir>
#include <QTcpSocket>
#include "handshake.h"
#include "mclient.h"
#include "mlog.h"

MClient::MClient(QObject *parent)
    : QObject(parent)
{
}

void MClient::setHostNameAndPort(const QString &hostName, quint16 port)
{
    m_hostName = hostName;
    m_port = port;
    MLog::log(QStringLiteral("Target server: %1:%2").arg(hostName).arg(port));
}

MClient::Result MClient::upload(const QString &localPath, const QString &remotePath)
{
    return upload(m_hostName, m_port, localPath, remotePath);
}

MClient::Result MClient::download(const QString &remotePath, const QString &localPath)
{
    return download(m_hostName, m_port, remotePath, localPath);
}

MClient::Result MClient::existsFile(const QString &remotePath)
{
    return existsFile(m_hostName, m_port, remotePath);
}

MClient::Result MClient::existsDir(const QString &remotePath)
{
    return existsDir(m_hostName, m_port, remotePath);
}

MClient::Result MClient::removeFile(const QString &remotePath)
{
    return removeFile(m_hostName, m_port, remotePath);
}

MClient::Result MClient::removeDir(const QString &remotePath)
{
    return removeDir(m_hostName, m_port, remotePath);
}

MClient::Result MClient::renameFile(const QString &remotePath)
{
    return renameFile(m_hostName, m_port, remotePath);
}

MClient::Result MClient::renameDir(const QString &remotePath)
{
    return renameDir(m_hostName, m_port, remotePath);
}

MClient::Result MClient::upload(const QString &hostName, quint16 port, const QString &localPath, const QString &remotePath)
{
    MLog::log(QStringLiteral("Upload %1 to %2 on %3:%4").arg(localPath).arg(remotePath).arg(hostName).arg(port));
    // connect to server
    QTcpSocket socket;
    socket.connectToHost(hostName, port);
    if(!socket.waitForConnected(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to connect to server"));
        return MClient::ConnectionFailure;
    }
    // read local file
    QFile file(localPath);
    if(!file.open(QIODevice::ReadOnly)){
        MLog::log(QStringLiteral("Fail to read local file"));
        return MClient::LocalError;
    }
    /******************** STEP 1 ********************/
    // send request
    socket.write(HandShake::buildRequest(remotePath, file.size()));
    if(!socket.waitForBytesWritten(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to send UPLOAD request to server"));
        file.close();
        return MClient::TimeOut;
    }
    /******************** STEP 2 ********************/
    // recieve response
    if(!socket.waitForReadyRead(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to recieve response from server"));
        file.close();
        return MClient::TimeOut;
    }
    Response response = HandShake::parseResponse(socket.readAll());
    if(!response.parseSucceed || (response.id != RES_OK && response.id != RES_NO)){
        MLog::log(QStringLiteral("Fail to parse response from server"));
        file.close();
        return MClient::UnknownError;
    }else if(response.id == RES_NO){
        MLog::log(QStringLiteral("Upload refused by server"));
        file.close();
        return MClient::Negative;
    }
    /******************** STEP 3 ********************/
    // upload file
    MLog::log(QStringLiteral("%1 bytes of data to upload").arg(file.size()));
    char buf[PAY_LOAD];
    qint64 uploadTotal = 0;
    qint64 uploaded;
    while((uploaded = file.read(buf, PAY_LOAD)) > 0){
        uploadTotal += uploaded;
        socket.write(buf, uploaded);
        if(!socket.waitForBytesWritten(TIME_OUT)){
            MLog::log(QStringLiteral("Network interruption during upload"));
            file.close();
            return MClient::TimeOut;
        }
    }
    file.close();
    /******************** STEP 4 ********************/
    // confirm with server
    if(!socket.waitForReadyRead(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to recieve confirm form server"));
        return MClient::TimeOut;
    }
    response = HandShake::parseResponse(socket.readAll());
    if(!response.parseSucceed || (response.id != RES_OK && response.id != RES_NO)){
        MLog::log(QStringLiteral("Fail to parse confirm form server"));
        return MClient::UnknownError;
    }else if(response.id == RES_NO){
        MLog::log(QStringLiteral("Server fail to recieve uploaded file"));
        return MClient::Negative;
    }
    MLog::log(QStringLiteral("Upload succeeded"));
    return MClient::Positive;
}

MClient::Result MClient::download(const QString &hostName, quint16 port, const QString &remotePath, const QString &localPath)
{
    MLog::log(QStringLiteral("Download %1 on %2:%3 to %4").arg(remotePath).arg(hostName).arg(port).arg(localPath));
    // connect to server
    QTcpSocket socket;
    socket.connectToHost(hostName, port);
    if(!socket.waitForConnected(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to connect to server"));
        return MClient::ConnectionFailure;
    }
    /******************** STEP 1 ********************/
    // send request
    socket.write(HandShake::buildRequest(remotePath, REQ_DOWNLOAD));
    if(!socket.waitForBytesWritten(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to send DOWNLOAD request to server"));
        return MClient::TimeOut;
    }
    /******************** STEP 2 ********************/
    // recieve response
    if(!socket.waitForReadyRead(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to recieve response from server"));
        return MClient::TimeOut;
    }
    Response response = HandShake::parseResponse(socket.readAll());
    if(!response.parseSucceed || (response.id != RES_FILE && response.id != RES_NO)){
        MLog::log(QStringLiteral("Fail to parse response from server"));
        return MClient::UnknownError;
    }else if(response.id == RES_NO){
        MLog::log(QStringLiteral("Download refused by server"));
        return MClient::Negative;
    }
    /******************** STEP 3 ********************/
    socket.write(HandShake::buildRequest());
    if(!socket.waitForBytesWritten(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to send OK request to server"));
        return MClient::TimeOut;
    }
    /******************** STEP 4 ********************/
    // prepare file
    QString dirPath = localPath.left(localPath.lastIndexOf('/') + 1);
    if(!dirPath.isEmpty()){
        QDir dir;
        if(!dir.mkpath(dirPath)){
            MLog::log(QStringLiteral("Fail to create necessary directories"));
            return MClient::LocalError;
        }
    }
    QFile dfile(localPath + ".download");
    if(!dfile.open(QIODevice::WriteOnly)){
        MLog::log(QStringLiteral("Fail to create .download file"));
        return MClient::LocalError;
    }
    // begin downloading
    MLog::log(QStringLiteral("%1 bytes of data to download").arg(response.fileSize));
    char buf[PAY_LOAD];
    qint64 downloadTotal = 0;
    qint64 downloaded;
    while(downloadTotal < response.fileSize){
        if(!socket.bytesAvailable() && !socket.waitForReadyRead(TIME_OUT)){
            MLog::log(QStringLiteral("Network interruption during download"));
            return MClient::TimeOut;
        }
        downloaded = socket.read(buf, PAY_LOAD);
        downloadTotal += downloaded;
        dfile.write(buf, downloaded);
    }
    dfile.close();
    // save data
    QFile file(localPath);
    if(file.exists() && !file.remove()){
        MLog::log(QStringLiteral("Fail to save downloaded data"));
        dfile.remove();
        return MClient::LocalError;
    }
    dfile.rename(localPath);
    MLog::log(QStringLiteral("Download succeeded"));
    /******************** STEP 5 ********************/
    socket.write(HandShake::buildRequest());
    if(!socket.waitForBytesWritten(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to send confirm to server"));
        return MClient::TimeOut;
    }
    return MClient::Positive;
}

MClient::Result MClient::existsFile(const QString &hostName, quint16 port, const QString &remotePath)
{
    MLog::log(QStringLiteral("Check existence of file %1 on %2:%3").arg(remotePath).arg(hostName).arg(port));
    // connect to server
    QTcpSocket socket;
    socket.connectToHost(hostName, port);
    if(!socket.waitForConnected(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to connect to server"));
        return MClient::ConnectionFailure;
    }
    /******************** STEP 1 ********************/
    // send request
    socket.write(HandShake::buildRequest(remotePath, REQ_EXFILE));
    if(!socket.waitForBytesWritten(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to send EXFILE request to server"));
        return MClient::TimeOut;
    }
    /******************** STEP 2 ********************/
    // recieve response
    if(!socket.waitForReadyRead(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to recieve response from server"));
        return MClient::TimeOut;
    }
    Response response = HandShake::parseResponse(socket.readAll());
    if(!response.parseSucceed || (response.id != RES_NO && response.id != RES_OK)){
        MLog::log(QStringLiteral("Fail to parse response from server"));
        return MClient::UnknownError;
    }
    if(response.id == RES_OK)
        MLog::log(QStringLiteral("File exists"));
    else
        MLog::log(QStringLiteral("File does not exist"));
    return response.id == RES_OK ? MClient::Positive : MClient::Negative;
}

MClient::Result MClient::existsDir(const QString &hostName, quint16 port, const QString &remotePath)
{
    // TODO
    return MClient::UnknownError;
}

MClient::Result MClient::removeFile(const QString &hostName, quint16 port, const QString &remotePath)
{
    MLog::log(QStringLiteral("Remove file %1 on %2:%3").arg(remotePath).arg(hostName).arg(port));
    // connect to server
    QTcpSocket socket;
    socket.connectToHost(hostName, port);
    if(!socket.waitForConnected(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to connect to server"));
        return MClient::ConnectionFailure;
    }
    /******************** STEP 1 ********************/
    // send request
    socket.write(HandShake::buildRequest(remotePath, REQ_RMFILE));
    if(!socket.waitForBytesWritten(TIME_OUT)){
        MLog::log(QStringLiteral("Fail to send RMFILE request to server"));
        return MClient::TimeOut;
    }
    /******************** STEP 2 ********************/
    // recieve response
    if(!socket.waitForReadyRead(TIME_OUT)){
        MLog::log(QStringLiteral("[0x%1] fail to recieve response from server"));
        return MClient::TimeOut;
    }
    Response response = HandShake::parseResponse(socket.readAll());
    if(!response.parseSucceed || (response.id != RES_OK && response.id != RES_NO)){
        MLog::log(QStringLiteral("[0x%1] fail to parse response from server"));
        return MClient::UnknownError;
    }
    if(response.id == RES_OK)
        MLog::log(QStringLiteral("[0x%1] remove file succeeded"));
    else
        MLog::log(QStringLiteral("[0x%1] remove file failed"));
    return response.id == RES_OK ? MClient::Positive : MClient::Negative;
}

MClient::Result MClient::removeDir(const QString &hostName, quint16 port, const QString &remotePath)
{
    // TODO
    return MClient::UnknownError;
}

MClient::Result MClient::renameFile(const QString &hostName, quint16 port, const QString &remotePath)
{
    // TODO
    return MClient::UnknownError;
}

MClient::Result MClient::renameDir(const QString &hostName, quint16 port, const QString &remotePath)
{
    // TODO
    return MClient::UnknownError;
}
