#include <QThread>
#include "worker.h"
#include "backend.h"

Backend::Backend(QObject *parent)
    : QObject(parent)
    , thread(new QThread)
    , worker(new Worker)
{
    connect(this, SIGNAL(signIn(const QString &, const QString &)), worker, SLOT(signIn(const QString &, const QString &)));
    connect(this, SIGNAL(signUp(const QString &, const QString &)), worker, SLOT(signUp(const QString &, const QString &)));
    connect(this, SIGNAL(refresh()), worker, SLOT(refresh()));
    connect(this, SIGNAL(save(const QString &)), worker, SLOT(save(const QString &)));
    connect(this, SIGNAL(changeUsername(const QString &, const QString &)), worker, SLOT(changeUsername(const QString &, const QString &)));
    connect(this, SIGNAL(changePassword(const QString &, const QString &)), worker, SLOT(changePassword(const QString &, const QString &)));
    connect(this, SIGNAL(deleteAccount()), worker, SLOT(deleteAccount()));
    connect(worker, SIGNAL(finished(bool, const QString &)), this, SIGNAL(finished(bool, const QString &)));
    worker->moveToThread(thread);
    thread->start();
}

void Backend::setHostNameAndPort(const QString &hostName, int port)
{
    worker->setHostNameAndPort(hostName, port);
}
