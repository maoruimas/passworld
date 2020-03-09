#ifndef MLOG_H
#define MLOG_H

#include <QObject>

class MLog : public QObject
{
    Q_OBJECT
public:
    explicit MLog(QObject *parent = nullptr);

    static bool log(const QString &msg);

signals:

public slots:
};

#endif // MLOG_H
