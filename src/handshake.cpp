#include <QDataStream>
#include "handshake.h"

HandShake::HandShake(QObject *parent) : QObject(parent)
{
}

Request HandShake::parseRequest(QByteArray block)
{
    QDataStream in(&block, QIODevice::ReadOnly);
    in.setVersion(QDataStream::Qt_4_0);
    Request req;
    req.parseSucceed = false;
    if(block.size() >= int(sizeof (qint8)))
        in >> req.id;
    else return req;
    qint64 pathSize;
    if(req.id == REQ_OK){
        if(block.size() == int(sizeof(qint8)))
            req.parseSucceed = true;
        return req;
    }if(req.id == REQ_UPLOAD){
        if(block.size() >= int(sizeof(qint8) + 2*sizeof(qint64)))
            in >> pathSize >> req.fileSize;
        else return req;
    }else if(req.id <= qint8(0x08)){ // check this line if you want to modify requests
        if(block.size() >= int(sizeof(qint8) + sizeof(qint64)))
            in >> pathSize;
        else return req;
    }else return req;
    QByteArray raw;
    in >> raw;
    if(raw.size() == int(pathSize)){
        req.parseSucceed = true;
        req.path = QString::fromUtf8(raw);
    }
    return req;
}

QByteArray HandShake::buildResponse(bool ok)
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);
    out << (ok ? RES_OK : RES_NO);
    return block;
}

QByteArray HandShake::buildResponse(qint64 fileSize)
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);
    out << RES_FILE << fileSize;
    return block;
}

Response HandShake::parseResponse(QByteArray block)
{
    QDataStream in(&block, QIODevice::ReadOnly);
    in.setVersion(QDataStream::Qt_4_0);
    Response res;
    res.parseSucceed = false;
    if(block.size() >= int(sizeof (qint8)))
        in >> res.id;
    else return res;
    if(res.id == RES_NO || res.id == RES_OK)
        res.parseSucceed = block.size() == int(sizeof (qint8));
    else if(res.id == RES_FILE){ // check this line if you want to modify responses
        if(block.size() == int(sizeof(qint8) + sizeof(qint64)))
            in >> res.fileSize;
        else return res;
        res.parseSucceed = true;
    }
    return res;
}

QByteArray HandShake::buildRequest()
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);
    out << REQ_OK;
    return block;
}

QByteArray HandShake::buildRequest(const QString &filePath, qint64 fileSize)
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);
    out << REQ_UPLOAD;
    QByteArray raw = filePath.toUtf8();
    out << qint64(raw.size()) << fileSize << raw;
    return block;
}

QByteArray HandShake::buildRequest(const QString &path, qint8 id)
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);
    out << id;
    QByteArray raw = path.toUtf8();
    out << qint64(raw.size()) << raw;
    return block;
}
