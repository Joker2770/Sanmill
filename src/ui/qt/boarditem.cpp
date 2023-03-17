// This file is part of Sanmill.
// Copyright (C) 2019-2023 The Sanmill developers (see AUTHORS file)
//
// Sanmill is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Sanmill is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "boarditem.h"
#include "graphicsconst.h"
#include "types.h"
#include <QPainter>

BoardItem::BoardItem(const QGraphicsItem *parent)
    : size(BOARD_SIZE)
{
    Q_UNUSED(parent)
    setPos(0, 0);

    for (int f = 0; f < FILE_NB; f++) {
        const int p = (f + 1) * LINE_INTERVAL;
        const int pt[][2] = {{0, -p}, {p, -p}, {p, 0},  {p, p},
                             {0, p},  {-p, p}, {-p, 0}, {-p, -p}};

        for (int r = 0; r < RANK_NB; r++) {
            position[f * RANK_NB + r].rx() = pt[r][0];
            position[f * RANK_NB + r].ry() = pt[r][1];
        }
    }
}

BoardItem::~BoardItem() = default;

QRectF BoardItem::boundingRect() const
{
    return QRectF(-size / 2, -size / 2, size + sizeShadow, size + sizeShadow);
}

QPainterPath BoardItem::shape() const
{
    QPainterPath path;
    path.addRect(boundingRect());
    return path;
}

int BoardItem::type() const noexcept
{
    return BoardItemType;
}

void BoardItem::setDiagonal(bool arg)
{
    hasDiagonalLine = arg;
    update(boundingRect());
}

QPointF BoardItem::nearestPosition(const QPointF &pos)
{
    QPointF nearestPos(0, 0);
    for (auto i : position) {
        if (QLineF(pos, i).length() < PIECE_SIZE / 2) {
            nearestPos = i;
            break;
        }
    }
    return nearestPos;
}

QPointF BoardItem::polar2pos(File f, Rank r) const
{
    return position[(static_cast<int>(f) - 1) * RANK_NB + static_cast<int>(r) -
                    1];
}

bool BoardItem::pos2polar(const QPointF &pos, File &f, Rank &r) const
{
    for (int sq = 0; sq < SQUARE_NB; sq++) {
        if (QLineF(pos, position[sq]).length() < (qreal)PIECE_SIZE / 6) {
            f = static_cast<File>(sq / RANK_NB + 1);
            r = static_cast<Rank>(sq % RANK_NB + 1);
            return true;
        }
    }
    return false;
}

void BoardItem::paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
                      QWidget *widget)
{
    Q_UNUSED(option)
    Q_UNUSED(widget)

#ifndef QT_MOBILE_APP_UI
    QColor shadowColor(128, 42, 42);
    shadowColor.setAlphaF(0.3);
    painter->fillRect(boundingRect(), QBrush(shadowColor));
#endif

#ifdef QT_MOBILE_APP_UI
    painter->setPen(Qt::NoPen);
    painter->setBrush(QColor(239, 239, 239));
    painter->drawRect(-size / 2, -size / 2, size, size);
#else
    painter->drawPixmap(-size / 2, -size / 2, size, size,
                        QPixmap(":/image/resources/image/board.png"));
#endif /* QT_MOBILE_APP_UI */

#ifdef QT_MOBILE_APP_UI
    QPen pen(QBrush(QColor(241, 156, 159)), LINE_WEIGHT, Qt::SolidLine,
             Qt::SquareCap, Qt::BevelJoin);
#else
    const QPen pen(QBrush(QColor(178, 34, 34)), LINE_WEIGHT, Qt::SolidLine,
                   Qt::SquareCap, Qt::BevelJoin);
#endif
    painter->setPen(pen);
    painter->setBrush(Qt::NoBrush);

    for (uint8_t f = 0; f < FILE_NB; f++) {
        painter->drawPolygon(f * RANK_NB + position, RANK_NB);
    }

    for (int r = 0; r < RANK_NB; r += 2) {
        painter->drawLine(position[r], position[(FILE_NB - 1) * RANK_NB + r]);
    }

    if (hasDiagonalLine) {
        for (int r = 1; r < RANK_NB; r += 2) {
            painter->drawLine(position[r],
                              position[(FILE_NB - 1) * RANK_NB + r]);
        }
    }

#ifdef PLAYER_DRAW_SEAT_NUMBER
    QPen fontPen(QBrush(Qt::white), LINE_WEIGHT, Qt::SolidLine, Qt::SquareCap,
                 Qt::BevelJoin);
    painter->setPen(fontPen);
    QFont font;
    font.setPointSize(4);
    font.setFamily("Arial");
    font.setLetterSpacing(QFont::AbsoluteSpacing, 0);
    painter->setFont(font);

    for (int i = 0; i < RANK_NB; i++) {
        char cSeat = '1' + i;
        QString strSeat(cSeat);
        painter->drawText(position[(FILE_NB - 1) * RANK_NB + i], strSeat);
    }

#endif // PLAYER_DRAW_SEAT_NUMBER
}
