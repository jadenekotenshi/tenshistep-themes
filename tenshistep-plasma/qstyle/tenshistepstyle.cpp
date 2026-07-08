#include "tenshistepstyle.h"

#include <QPainter>
#include <QPainterPath>
#include <QPolygonF>
#include <QLinearGradient>
#include <QStyleOption>
#include <QStyleOptionSlider>
#include <QStyleOptionButton>
#include <QStyleOptionProgressBar>
#include <QStyleOptionComboBox>
#include <QStyleOptionSpinBox>

// --- OPENSTEP-muted palette constants ---------------------------------------
static const QColor kDark  (0x1a, 0x1a, 0x1a);
static const QColor kHi    (0xff, 0xff, 0xff);
static const QColor kSh    (0x5c, 0x62, 0x6b);
static const QColor kBlue  (0x4a, 0x3f, 0xa0);
static const QColor kButton(0xa6, 0xad, 0xb8);
static const QColor kWindow(0xa0, 0xa7, 0xb2);
static const QColor kGroove(0x8f, 0x96, 0xa1);
static const QColor kGreen (0x4a, 0x7a, 0x3a);
static const QColor kRadio (0x24, 0x1d, 0x58);

// --- helpers ----------------------------------------------------------------

// Chiselled bevel: fill + 1px dark frame + white top/left highlight and dark
// bottom/right shadow (inverted when sunken). `fill` may be a gradient brush.
static void paintBevel(QPainter *p, const QRect &r, const QBrush &fill,
                       bool sunken, const QColor &frame = kDark, bool edges = true)
{
    if (r.width() < 2 || r.height() < 2) { p->fillRect(r, fill); return; }
    p->save();
    p->setRenderHint(QPainter::Antialiasing, false);
    p->fillRect(r, fill);
    const int L = r.left(), T = r.top(), R = r.right(), B = r.bottom();
    p->setPen(frame);                       // outer frame
    p->drawRect(QRect(L, T, r.width() - 1, r.height() - 1));
    if (edges) {                            // chiselled bevel (omit -> flat, no highlight)
        p->setPen(sunken ? kSh : kHi);      // inner highlight (top/left)
        p->drawLine(L + 1, T + 1, R - 1, T + 1);
        p->drawLine(L + 1, T + 1, L + 1, B - 1);
        p->setPen(sunken ? kHi : kSh);      // inner shadow (bottom/right)
        p->drawLine(L + 1, B - 1, R - 1, B - 1);
        p->drawLine(R - 1, T + 1, R - 1, B - 1);
    }
    p->restore();
}

static void drawArrow(QPainter *p, const QRect &r, Qt::ArrowType dir,
                      const QColor &col = kDark, qreal grow = 1.0)
{
    const qreal h = qMax(3.0, qMin(r.width(), r.height()) / 4.0) * grow;
    const QPointF c = r.center();
    QPolygonF poly;
    switch (dir) {
    case Qt::UpArrow:    poly << QPointF(c.x(), c.y() - h) << QPointF(c.x() - h, c.y() + h) << QPointF(c.x() + h, c.y() + h); break;
    case Qt::DownArrow:  poly << QPointF(c.x() - h, c.y() - h) << QPointF(c.x() + h, c.y() - h) << QPointF(c.x(), c.y() + h); break;
    case Qt::LeftArrow:  poly << QPointF(c.x() - h, c.y()) << QPointF(c.x() + h, c.y() - h) << QPointF(c.x() + h, c.y() + h); break;
    case Qt::RightArrow: poly << QPointF(c.x() - h, c.y() - h) << QPointF(c.x() - h, c.y() + h) << QPointF(c.x() + h, c.y()); break;
    default: return;
    }
    p->save();
    p->setRenderHint(QPainter::Antialiasing, true);
    p->setPen(Qt::NoPen);
    p->setBrush(col);
    p->drawPolygon(poly);
    p->restore();
}

static QLinearGradient metalFill(const QRect &r)
{
    QLinearGradient g(r.topLeft(), r.bottomLeft());
    g.setColorAt(0.00, QColor(0xa7, 0x9c, 0xec));
    g.setColorAt(0.12, QColor(0xd2, 0xca, 0xf7));   // specular sheen
    g.setColorAt(0.50, QColor(0x4a, 0x3f, 0xa0));
    g.setColorAt(0.54, QColor(0x45, 0x3a, 0x97));
    g.setColorAt(0.90, QColor(0x31, 0x2a, 0x7a));
    g.setColorAt(1.00, QColor(0x24, 0x1d, 0x58));
    return g;
}

static QLinearGradient metalGroove(const QRect &r)
{
    QLinearGradient g(r.topLeft(), r.bottomLeft());
    g.setColorAt(0.00, QColor(0x8a, 0x95, 0xa1));
    g.setColorAt(0.18, QColor(0xc4, 0xce, 0xd8));
    g.setColorAt(0.55, QColor(0xa6, 0xb0, 0xba));
    g.setColorAt(1.00, QColor(0xb8, 0xc2, 0xcc));
    return g;
}

static void applyPalette(QPalette &pal)
{
    pal.setColor(QPalette::Window,          kWindow);
    pal.setColor(QPalette::Base,            QColor(Qt::white));
    pal.setColor(QPalette::AlternateBase,   QColor(0xee, 0xee, 0xee));
    pal.setColor(QPalette::Button,          kButton);
    pal.setColor(QPalette::Light,           kHi);
    pal.setColor(QPalette::Midlight,        QColor(0xbc, 0xc2, 0xcc));
    pal.setColor(QPalette::Mid,             kSh);
    pal.setColor(QPalette::Dark,            kDark);
    pal.setColor(QPalette::Shadow,          kDark);
    pal.setColor(QPalette::WindowText,      kDark);
    pal.setColor(QPalette::Text,            kDark);
    pal.setColor(QPalette::ButtonText,      kDark);
    pal.setColor(QPalette::ToolTipBase,     QColor(0xe9, 0xe7, 0xdb));
    pal.setColor(QPalette::ToolTipText,     kDark);
    pal.setColor(QPalette::Highlight,       kBlue);
    pal.setColor(QPalette::HighlightedText, QColor(Qt::white));
    pal.setColor(QPalette::Link,            QColor(0x2a, 0x2a, 0x8a));
    pal.setColor(QPalette::LinkVisited,     QColor(0x55, 0x55, 0x7a));
    pal.setColor(QPalette::Disabled, QPalette::WindowText, QColor(0x7a, 0x7a, 0x7a));
    pal.setColor(QPalette::Disabled, QPalette::Text,       QColor(0x7a, 0x7a, 0x7a));
    pal.setColor(QPalette::Disabled, QPalette::ButtonText, QColor(0x7a, 0x7a, 0x7a));
}

// --- style ------------------------------------------------------------------

TenshiSTEPStyle::TenshiSTEPStyle() : QProxyStyle(QStringLiteral("Fusion")) {}

void TenshiSTEPStyle::polish(QPalette &palette) { applyPalette(palette); }

QPalette TenshiSTEPStyle::standardPalette() const
{
    QPalette pal = QProxyStyle::standardPalette();
    applyPalette(pal);
    return pal;
}

int TenshiSTEPStyle::pixelMetric(PixelMetric m, const QStyleOption *o, const QWidget *w) const
{
    switch (m) {
    case PM_ScrollBarExtent:    return 16;
    case PM_ScrollBarSliderMin: return 28;
    default:                    return QProxyStyle::pixelMetric(m, o, w);
    }
}

void TenshiSTEPStyle::drawPrimitive(PrimitiveElement pe, const QStyleOption *opt,
                                       QPainter *p, const QWidget *w) const
{
    switch (pe) {
    case PE_PanelButtonCommand:
    case PE_PanelButtonBevel:
    case PE_PanelButtonTool: {
        const bool sunken = opt->state & (State_Sunken | State_On);
        paintBevel(p, opt->rect, opt->palette.button().color(), sunken);
        return;
    }
    case PE_PanelLineEdit: {
        const bool focus = opt->state & State_HasFocus;
        paintBevel(p, opt->rect, opt->palette.base().color(), true, focus ? kBlue : kDark);
        return;
    }
    case PE_FrameLineEdit:
        return; // the panel already draws the recessed frame
    case PE_IndicatorCheckBox: {
        // NeXT-style: grey RAISED bevel with a darker silvery-grey check
        paintBevel(p, opt->rect, QColor(0xc4, 0xc9, 0xd0), false,
                   (opt->state & State_HasFocus) ? kBlue : kDark);
        if (opt->state & State_On) {
            const QRect r = opt->rect.adjusted(3, 3, -3, -3);
            QPainterPath path;
            path.moveTo(r.left(), r.center().y());
            path.lineTo(r.left() + r.width() * 0.42, r.bottom());
            path.lineTo(r.right(), r.top());
            p->save();
            p->setRenderHint(QPainter::Antialiasing, true);
            QPen pen(kSh, 2.2); pen.setCapStyle(Qt::RoundCap); pen.setJoinStyle(Qt::RoundJoin);
            p->setPen(pen); p->setBrush(Qt::NoBrush); p->drawPath(path);
            p->restore();
        } else if (opt->state & State_NoChange) {
            p->save(); p->setPen(QPen(kSh, 2));
            const QRect r = opt->rect;
            p->drawLine(r.left() + 4, r.center().y(), r.right() - 4, r.center().y());
            p->restore();
        }
        return;
    }
    case PE_IndicatorRadioButton: {
        const QRectF r = QRectF(opt->rect).adjusted(0.5, 0.5, -0.5, -0.5);
        p->save();
        p->setRenderHint(QPainter::Antialiasing, true);
        p->setBrush(QColor(Qt::white));
        p->setPen(QPen((opt->state & State_HasFocus) ? kBlue : kDark, 1));
        p->drawEllipse(r);
        if (opt->state & State_On) {
            p->setPen(Qt::NoPen); p->setBrush(kRadio);
            p->drawEllipse(r.adjusted(r.width() * 0.3, r.height() * 0.3,
                                      -r.width() * 0.3, -r.height() * 0.3));
        }
        p->restore();
        return;
    }
    case PE_Frame:
    case PE_FrameGroupBox:
    case PE_FrameTabWidget:
    case PE_FrameDockWidget:
        paintBevel(p, opt->rect, Qt::NoBrush, true);
        return;
    case PE_FrameMenu:
    case PE_PanelMenu:
        paintBevel(p, opt->rect, kButton, false);
        return;
    default:
        QProxyStyle::drawPrimitive(pe, opt, p, w);
    }
}

void TenshiSTEPStyle::drawControl(ControlElement ce, const QStyleOption *opt,
                                     QPainter *p, const QWidget *w) const
{
    switch (ce) {
    case CE_PushButtonBevel: {
        const auto *b = qstyleoption_cast<const QStyleOptionButton *>(opt);
        const bool sunken = opt->state & (State_Sunken | State_On);
        const QColor frame = (b && (b->features & QStyleOptionButton::DefaultButton)) ? kBlue : kDark;
        paintBevel(p, opt->rect, opt->palette.button().color(), sunken, frame);
        return;
    }
    case CE_ProgressBarGroove:
        paintBevel(p, opt->rect, metalGroove(opt->rect), true);
        return;
    case CE_ProgressBarContents: {
        const auto *pb = qstyleoption_cast<const QStyleOptionProgressBar *>(opt);
        if (!pb) return;
        const QRect r = opt->rect;
        double frac = 0.0;
        if (pb->maximum > pb->minimum)
            frac = double(pb->progress - pb->minimum) / double(pb->maximum - pb->minimum);
        frac = qBound(0.0, frac, 1.0);
        QRect fill(r.left(), r.top(), int(r.width() * frac), r.height());
        if (fill.width() < 1) return;
        p->save();
        p->fillRect(fill, metalFill(fill));
        p->setPen(QColor(0xe4, 0xde, 0xfc));            // top sheen
        p->drawLine(fill.left(), fill.top() + 1, fill.right(), fill.top() + 1);
        p->setPen(QColor(0x19, 0x13, 0x41));            // dark bottom edge
        p->drawLine(fill.left(), fill.bottom(), fill.right(), fill.bottom());
        p->restore();
        return;
    }
    default:
        QProxyStyle::drawControl(ce, opt, p, w);
    }
}

QRect TenshiSTEPStyle::subControlRect(ComplexControl cc, const QStyleOptionComplex *opt,
                                         SubControl sc, const QWidget *w) const
{
    if (cc == CC_ScrollBar) {
        if (const auto *s = qstyleoption_cast<const QStyleOptionSlider *>(opt)) {
            const QRect r = s->rect;
            const bool horiz = s->orientation == Qt::Horizontal;
            const int bw = proxy()->pixelMetric(PM_ScrollBarExtent, opt, w);
            QRect sub, add, groove;
            if (horiz) {                                  // both arrows at the right
                add    = QRect(r.right() - bw + 1, r.top(), bw, r.height());
                sub    = QRect(r.right() - 2 * bw + 1, r.top(), bw, r.height());
                groove = QRect(r.left(), r.top(), r.width() - 2 * bw, r.height());
            } else {                                      // both arrows at the bottom
                add    = QRect(r.left(), r.bottom() - bw + 1, r.width(), bw);
                sub    = QRect(r.left(), r.bottom() - 2 * bw + 1, r.width(), bw);
                groove = QRect(r.left(), r.top(), r.width(), r.height() - 2 * bw);
            }
            switch (sc) {
            case SC_ScrollBarSubLine: return sub;
            case SC_ScrollBarAddLine: return add;
            case SC_ScrollBarGroove:  return groove;
            case SC_ScrollBarSlider: {
                const int span = horiz ? groove.width() : groove.height();
                const int minLen = proxy()->pixelMetric(PM_ScrollBarSliderMin, opt, w);
                int len;
                if (s->maximum != s->minimum && s->pageStep > 0) {
                    const int range = s->maximum - s->minimum;
                    len = int(qint64(s->pageStep) * span / (range + s->pageStep));
                    len = qBound(minLen, len, span);
                } else {
                    len = span;
                }
                const int pos = sliderPositionFromValue(s->minimum, s->maximum,
                                                        s->sliderPosition, span - len, s->upsideDown);
                if (horiz) return QRect(groove.left() + pos, groove.top(), len, groove.height());
                return QRect(groove.left(), groove.top() + pos, groove.width(), len);
            }
            case SC_ScrollBarSubPage: {
                const QRect sl = subControlRect(cc, opt, SC_ScrollBarSlider, w);
                if (horiz) return QRect(groove.left(), groove.top(), sl.left() - groove.left(), groove.height());
                return QRect(groove.left(), groove.top(), groove.width(), sl.top() - groove.top());
            }
            case SC_ScrollBarAddPage: {
                const QRect sl = subControlRect(cc, opt, SC_ScrollBarSlider, w);
                if (horiz) return QRect(sl.right(), groove.top(), groove.right() - sl.right(), groove.height());
                return QRect(groove.left(), sl.bottom(), groove.width(), groove.bottom() - sl.bottom());
            }
            default: break;
            }
        }
    }
    return QProxyStyle::subControlRect(cc, opt, sc, w);
}

void TenshiSTEPStyle::drawComplexControl(ComplexControl cc, const QStyleOptionComplex *opt,
                                            QPainter *p, const QWidget *w) const
{
    if (cc == CC_ScrollBar) {
        const auto *s = qstyleoption_cast<const QStyleOptionSlider *>(opt);
        if (!s) { QProxyStyle::drawComplexControl(cc, opt, p, w); return; }
        const bool horiz = s->orientation == Qt::Horizontal;
        const QRect groove = subControlRect(cc, opt, SC_ScrollBarGroove, w);
        const QRect slider = subControlRect(cc, opt, SC_ScrollBarSlider, w);
        const QRect sub    = subControlRect(cc, opt, SC_ScrollBarSubLine, w);
        const QRect add    = subControlRect(cc, opt, SC_ScrollBarAddLine, w);

        // recessed track
        p->fillRect(groove, kGroove);
        p->setPen(kDark);
        p->drawRect(opt->rect.adjusted(0, 0, -1, -1));

        // twin arrow buttons grouped at the far end (sub = up/left, add = down/right)
        const bool subSunk = (s->activeSubControls & SC_ScrollBarSubLine) && (opt->state & State_Sunken);
        const bool addSunk = (s->activeSubControls & SC_ScrollBarAddLine) && (opt->state & State_Sunken);
        paintBevel(p, sub, kButton, subSunk);
        drawArrow(p, sub, horiz ? Qt::LeftArrow : Qt::UpArrow);
        paintBevel(p, add, kButton, addSunk);
        drawArrow(p, add, horiz ? Qt::RightArrow : Qt::DownArrow);

        // handle with a centre indentation (the NeXT scroller knob)
        if (s->maximum > s->minimum && slider.isValid() && !slider.isEmpty()) {
            paintBevel(p, slider, kButton, false);
            p->save();
            if (!horiz) {
                const int cy = slider.center().y();
                const int x1 = slider.left() + 4, x2 = slider.right() - 4;
                p->setPen(kSh); p->drawLine(x1, cy - 1, x2, cy - 1);
                p->setPen(kHi); p->drawLine(x1, cy, x2, cy);
            } else {
                const int cx = slider.center().x();
                const int y1 = slider.top() + 4, y2 = slider.bottom() - 4;
                p->setPen(kSh); p->drawLine(cx - 1, y1, cx - 1, y2);
                p->setPen(kHi); p->drawLine(cx, y1, cx, y2);
            }
            p->restore();
        }
        return;
    }

    if (cc == CC_ComboBox) {
        const auto *cb = qstyleoption_cast<const QStyleOptionComboBox *>(opt);
        const bool editable = cb && cb->editable;
        const bool sunken = opt->state & (State_On | State_Sunken);
        // body: editable combo -> recessed field; pop-up button -> raised bevel
        if (editable) paintBevel(p, opt->rect, opt->palette.base(), true);
        else          paintBevel(p, opt->rect, kButton, false);
        // NeXT pop-up: a raised inset button holds the arrow (sinks when pressed),
        // so it reads as a raised control rather than a recessed well.
        QRect ar = subControlRect(cc, opt, SC_ComboBoxArrow, w);
        QRect well = ar.adjusted(0, 3, -3, -3);
        if (well.width() > 4 && well.height() > 4) {
            paintBevel(p, well, kButton, sunken);
            drawArrow(p, well.translated(0, sunken ? 1 : 0), Qt::DownArrow);
        }
        return;
    }

    if (cc == CC_Slider) {
        const auto *sl = qstyleoption_cast<const QStyleOptionSlider *>(opt);
        const bool horiz = !sl || sl->orientation == Qt::Horizontal;
        const QRect groove = subControlRect(cc, opt, SC_SliderGroove, w);
        const QRect handle = subControlRect(cc, opt, SC_SliderHandle, w);
        // recessed groove
        const QRect g = horiz ? QRect(groove.left(), groove.center().y() - 2, groove.width(), 4)
                              : QRect(groove.center().x() - 2, groove.top(), 4, groove.height());
        paintBevel(p, g, kGroove, true);
        // raised handle with a centre inset bar (matches the scroller knob)
        paintBevel(p, handle, kButton, false);
        p->save();
        // vertical centre inset bar
        {
            const int cx = handle.center().x();
            const int y1 = handle.top() + 4, y2 = handle.bottom() - 4;
            p->setPen(kSh); p->drawLine(cx - 1, y1, cx - 1, y2);
            p->setPen(kHi); p->drawLine(cx, y1, cx, y2);
        }
        p->restore();
        return;
    }

    if (cc == CC_SpinBox) {
        // Fusion-like: recessed field + a solid button-grey arrow column, so the
        // recessed field's white never shows as a border around the arrows. A rule
        // splits it from the text field and divides the up/down halves; the pressed
        // half darkens.
        const auto *sb = qstyleoption_cast<const QStyleOptionSpinBox *>(opt);
        paintBevel(p, opt->rect, opt->palette.base(), true);
        const QRect up   = subControlRect(cc, opt, SC_SpinBoxUp,   w);
        const QRect down = subControlRect(cc, opt, SC_SpinBoxDown, w);
        const bool upSunk   = sb && (sb->activeSubControls & SC_SpinBoxUp)   && (opt->state & State_Sunken);
        const bool downSunk = sb && (sb->activeSubControls & SC_SpinBoxDown) && (opt->state & State_Sunken);
        const QRect colR(up.left(), opt->rect.top() + 1,
                         opt->rect.right() - up.left(), opt->rect.height() - 2);
        if (colR.width() > 4 && colR.height() > 6) {
            const int midY = up.bottom();
            p->save();
            p->fillRect(colR, kButton);
            if (upSunk)   p->fillRect(QRect(colR.left(), colR.top(), colR.width(), midY - colR.top() + 1), kGroove);
            if (downSunk) p->fillRect(QRect(colR.left(), midY + 1, colR.width(), colR.bottom() - midY), kGroove);
            p->setPen(kSh);
            p->drawLine(colR.left(), colR.top(), colR.left(), colR.bottom());   // rule vs text field
            p->drawLine(colR.left(), midY, colR.right(), midY);                 // up / down divider
            p->restore();
            drawArrow(p, up.translated(0,   upSunk   ? 1 : 0), Qt::UpArrow,   kDark, 1.4);
            drawArrow(p, down.translated(0, downSunk ? 1 : 0), Qt::DownArrow, kDark, 1.4);
        }
        return;
    }
    QProxyStyle::drawComplexControl(cc, opt, p, w);
}
