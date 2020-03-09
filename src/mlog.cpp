#include <QDateTime>
#include <QFile>
#include "mlog.h"

MLog::MLog(QObject *parent) : QObject(parent)
{
}

bool MLog::log(const QString &msg)
{
    QFile file("log");
    if(!file.open(QIODevice::Append))
        return false;
    QString text = QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss.zzz ") + msg + "\n";
    file.write(text.toUtf8());
    file.close();
    return true;
}
