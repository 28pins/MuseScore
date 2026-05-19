#pragma once
#include <QObject>
#include <QString>
#include <functional>

class TouchBarReceiver : public QObject {
    Q_OBJECT
public:
    TouchBarReceiver(std::function<void(const QString&)> cb, QObject* parent = nullptr) : QObject(parent), m_cb(cb) {}
public slots:
    void onTouchBarAction(const QString& actionCode) { if (m_cb) m_cb(actionCode); }
private:
    std::function<void(const QString&)> m_cb;
};
