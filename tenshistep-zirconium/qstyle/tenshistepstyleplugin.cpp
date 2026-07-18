#include <QStylePlugin>
#include "tenshistepstyle.h"

class TenshiSTEPZirconiumStylePlugin : public QStylePlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QStyleFactoryInterface_iid FILE "tenshistep.json")

public:
    QStyle *create(const QString &key) override
    {
        if (key.compare(QLatin1String("TenshiSTEP-zirconium"), Qt::CaseInsensitive) == 0)
            return new TenshiSTEPZirconiumStyle;
        return nullptr;
    }
};

#include "tenshistepstyleplugin.moc"
