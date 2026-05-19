#include "touchbar_client.h"
#include "TouchBar/touchbarbridge.h"
#include <QBuffer>
#include <QImage>
#include <QPixmap>
#include <QMetaObject>

static QObject* g_receiver = nullptr;
static void tb_callback(const char* code, void*) {
    if (!g_receiver) return;
    QMetaObject::invokeMethod(g_receiver,"onTouchBarAction",Qt::QueuedConnection,Q_ARG(QString,QString::fromUtf8(code)));
}
void tbClientInit(QObject* r){ g_receiver=r; tb_bridge_set_callback(&tb_callback,nullptr); tb_bridge_create(); }
static QByteArray iconToPng(const QIcon& icon){ if(icon.isNull())return{}; QPixmap pm=icon.pixmap(icon.availableSizes().isEmpty()?QSize(32,32):icon.availableSizes().first()); QByteArray b; QBuffer buf(&b); buf.open(QIODevice::WriteOnly); pm.toImage().save(&buf,"PNG"); return b; }
void tbClientAddButton(const QString& c,const QString& t,const QIcon& ic){ QByteArray p=iconToPng(ic); tb_bridge_add_button(c.toUtf8().constData(), t.toUtf8().constData(), p.isEmpty()?nullptr:p.constData(), (size_t)p.size()); }
void tbClientRemoveButton(const QString& c){ tb_bridge_remove_button(c.toUtf8().constData()); }
void tbClientSetEnabled(const QString& c,bool e){ tb_bridge_set_enabled(c.toUtf8().constData(), e); }
void tbClientSetChecked(const QString& c,bool checked){ tb_bridge_set_enabled(c.toUtf8().constData(), checked); }
void tbClientShowForWindow(){ tb_bridge_show_for_window(nullptr); }
