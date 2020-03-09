/*
 * Upload      [4 steps]:	C(REQ_UPLOAD, path, fileSize) -> S(RES_NO)/(RES_OK)             -> C=>S      -> S(REQ_OK)
 * Download    [5 steps]:	C(REQ_DOWNLOAD, path)         -> S(RES_NO)/(RES_FILE, fileSize) -> C(REQ_OK) -> S=>C      -> C(REQ_OK)
 * Exists file [2 steps]:	C(REQ_EXFILE, path)           -> S(RES_NO)/(RES_YES)
 * Remove file [2 steps]:	C(REQ_RMFILE, path)           -> S(RES_NO)/(RES_YES)
 */


#ifndef HANDSHAKE_H
#define HANDSHAKE_H

#include <QObject>

#define TIME_OUT 3000
#define PAY_LOAD 64 * 1024

#define REQ_OK qint8(0x00)
#define REQ_UPLOAD qint8(0x01)
#define REQ_DOWNLOAD qint8(0x02)
#define REQ_EXFILE qint8(0x03) // exists
#define REQ_EXDIR qint8(0x04)
#define REQ_RMFILE qint8(0x05) // remove
#define REQ_RMDIR qint8(0x06)
#define REQ_RNFILE qint8(0x07) // rename
#define REQ_RNDIR qint8(0x08)

#define RES_NO qint8(0x00)
#define RES_OK qint8(0x01)
#define RES_FILE qint8(0x02)

typedef struct {
    bool parseSucceed;
    qint8 id;
    QString path;
    qint64 fileSize;
} Request;

typedef struct {
    bool parseSucceed;
    qint8 id;
    qint64 fileSize;
} Response;

class HandShake : public QObject
{
    Q_OBJECT
public:
    explicit HandShake(QObject *parent = nullptr);

    // server part
    static Request parseRequest(QByteArray block);
    static QByteArray buildResponse(bool ok); // ok or no response
    static QByteArray buildResponse(qint64 fileSize); // file response

    // client part
    static Response parseResponse(QByteArray block);
    static QByteArray buildRequest(); // ok request
    static QByteArray buildRequest(const QString &filePath, qint64 fileSize); // upload request
    static QByteArray buildRequest(const QString &path, qint8 id); // other requests

signals:

};

#endif // HANDSHAKE_H
