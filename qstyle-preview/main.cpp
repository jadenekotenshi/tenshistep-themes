// TenshiSTEP QStyle preview harness.
//
// Loads a compiled TenshiSTEP style plugin, applies it to a panel of common
// widgets, and renders the result to a PNG -- so you can eyeball a style change
// without installing the plugin or applying it to a live Plasma session.
//
//   styletest <plugin.so> <styleKey> <out.png> [light|dark|zirconium]
//
// e.g.
//   styletest ../tenshistep-plasma/qstyle/build/libtenshistepstyle.so \
//             TenshiSTEP out.png light
//
// Notes:
//  * Uses the offscreen QPA platform, so no display/X server is needed.
//  * Pass an ABSOLUTE path to the plugin .so -- QPluginLoader resolves relative
//    paths against the current directory and otherwise just reports
//    "The shared library was not found."
//  * Style keys: "TenshiSTEP" (light), "TenshiSTEP-darkmode" (dark),
//    "TenshiSTEP-zirconium" (brushed-metal light variant).

#include <QApplication>
#include <QPluginLoader>
#include <QStylePlugin>
#include <QStyle>
#include <QPushButton>
#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <QSpinBox>
#include <QLineEdit>
#include <QSlider>
#include <QProgressBar>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QWidget>
#include <QPixmap>
#include <QPalette>

// Approximate each theme's palette so the widgets render in context (the plugin
// itself hard-codes most control colours; these mainly set field/window/text).
static QPalette themePalette(const QString &variant)
{
    QPalette pal;
    if (variant == QLatin1String("dark")) {
        pal.setColor(QPalette::Window,     QColor(0x2b, 0x2e, 0x34));
        pal.setColor(QPalette::WindowText, QColor(0xdc, 0xdf, 0xe4));
        pal.setColor(QPalette::Base,       QColor(0x20, 0x22, 0x26));
        pal.setColor(QPalette::Text,       QColor(0xdc, 0xdf, 0xe4));
        pal.setColor(QPalette::Button,     QColor(0x3b, 0x40, 0x48));
        pal.setColor(QPalette::ButtonText, QColor(0xdc, 0xdf, 0xe4));
    } else if (variant == QLatin1String("zirconium")) {
        pal.setColor(QPalette::Window,     QColor(0xc4, 0xc7, 0xcb));
        pal.setColor(QPalette::WindowText, QColor(0x1a, 0x1a, 0x1a));
        pal.setColor(QPalette::Base,       QColor(0xff, 0xff, 0xff));
        pal.setColor(QPalette::Text,       QColor(0x1a, 0x1a, 0x1a));
        pal.setColor(QPalette::Button,     QColor(0xca, 0xcd, 0xd1));
        pal.setColor(QPalette::ButtonText, QColor(0x1a, 0x1a, 0x1a));
    } else {
        pal.setColor(QPalette::Window,     QColor(0xa0, 0xa7, 0xb2));
        pal.setColor(QPalette::WindowText, QColor(0x1a, 0x1a, 0x1a));
        pal.setColor(QPalette::Base,       QColor(0xff, 0xff, 0xff));
        pal.setColor(QPalette::Text,       QColor(0x1a, 0x1a, 0x1a));
        pal.setColor(QPalette::Button,     QColor(0xa6, 0xad, 0xb8));
        pal.setColor(QPalette::ButtonText, QColor(0x1a, 0x1a, 0x1a));
    }
    return pal;
}

int main(int argc, char **argv)
{
    if (argc < 4) {
        qWarning("usage: %s <plugin.so> <styleKey> <out.png> [light|dark|zirconium]", argv[0]);
        return 64;
    }
    qputenv("QT_QPA_PLATFORM", "offscreen");
    QApplication app(argc, argv);

    QPluginLoader loader(argv[1]);
    QObject *inst = loader.instance();
    if (!inst) { qWarning("plugin load failed: %s", qPrintable(loader.errorString())); return 1; }
    auto *sp = qobject_cast<QStylePlugin *>(inst);
    QStyle *style = sp ? sp->create(argv[2]) : nullptr;
    if (!style) { qWarning("style create '%s' failed", argv[2]); return 2; }

    const QString variant = argc > 4 ? QString(argv[4]) : QString();
    const QPalette pal = themePalette(variant);
    app.setStyle(style);
    app.setPalette(pal);

    QWidget win;
    win.setAutoFillBackground(true);
    win.setPalette(pal);
    auto *root = new QHBoxLayout(&win);
    root->setContentsMargins(18, 18, 18, 18);
    root->setSpacing(24);
    auto *colA = new QVBoxLayout; colA->setSpacing(12);
    auto *colB = new QVBoxLayout; colB->setSpacing(12);
    root->addLayout(colA);
    root->addLayout(colB);

    auto *pb    = new QPushButton("Push button");
    auto *cbOn  = new QCheckBox("Checkbox on");  cbOn->setChecked(true);
    auto *cbOff = new QCheckBox("Checkbox off");
    auto *rbOn  = new QRadioButton("Radio on");  rbOn->setChecked(true);
    auto *rbOff = new QRadioButton("Radio off");
    colA->addWidget(pb);
    colA->addWidget(cbOn);
    colA->addWidget(cbOff);
    colA->addWidget(rbOn);
    colA->addWidget(rbOff);
    colA->addStretch();

    auto *combo = new QComboBox; combo->addItems({"Combo box", "Item 2"});
    auto *spin  = new QSpinBox;  spin->setRange(0, 999); spin->setValue(42);
    auto *edit  = new QLineEdit("Line edit");
    auto *slid  = new QSlider(Qt::Horizontal); slid->setValue(60);
    auto *prog  = new QProgressBar; prog->setValue(55);
    colB->addWidget(combo);
    colB->addWidget(spin);
    colB->addWidget(edit);
    colB->addWidget(slid);
    colB->addWidget(prog);
    colB->addStretch();

    const auto kids = win.findChildren<QWidget *>();
    for (QWidget *k : kids) k->setPalette(pal);
    win.setPalette(pal);

    win.resize(460, 210);
    win.show();
    app.processEvents();
    app.processEvents();
    win.grab().save(argv[3]);
    return 0;
}
