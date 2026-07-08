// TenshiSTEP-darkmode — a native NeXTSTEP/OPENSTEP QStyle.
// Derives from QProxyStyle("Fusion") for metrics/layout, and overrides the
// primitives that carry the NeXT look: chiselled bevels, recessed fields,
// the twin-arrows-at-the-bottom scrollbar with a centre-dimpled knob, and
// 3D metallic progress bars.
#pragma once

#include <QProxyStyle>

class TenshiSTEPDarkmodeStyle : public QProxyStyle
{
public:
    TenshiSTEPDarkmodeStyle();

    void polish(QPalette &palette) override;
    QPalette standardPalette() const override;

    int pixelMetric(PixelMetric metric, const QStyleOption *option = nullptr,
                    const QWidget *widget = nullptr) const override;

    void drawPrimitive(PrimitiveElement pe, const QStyleOption *opt,
                       QPainter *p, const QWidget *w = nullptr) const override;
    void drawControl(ControlElement ce, const QStyleOption *opt,
                     QPainter *p, const QWidget *w = nullptr) const override;
    void drawComplexControl(ComplexControl cc, const QStyleOptionComplex *opt,
                            QPainter *p, const QWidget *w = nullptr) const override;
    QRect subControlRect(ComplexControl cc, const QStyleOptionComplex *opt,
                         SubControl sc, const QWidget *w = nullptr) const override;
};
