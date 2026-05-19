#pragma once
#include <QString>
#include <QIcon>
#include <QObject>

void tbClientInit(QObject* receiver);
void tbClientAddButton(const QString& actionCode, const QString& title, const QIcon& icon);
void tbClientRemoveButton(const QString& actionCode);
void tbClientSetEnabled(const QString& actionCode, bool enabled);
void tbClientSetChecked(const QString& actionCode, bool checked);
void tbClientShowForWindow();
