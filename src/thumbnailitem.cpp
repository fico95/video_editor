#include "include/thumbnailitem.h"

#include <QPainter>

ThumbnailItem::ThumbnailItem(QQuickItem* parent) : QQuickPaintedItem(parent)
{
  connect(this, &ThumbnailItem::widthChanged, this, [this]() { update(); });
}

void ThumbnailItem::setThumbnail(const QImage& thumbnail)
{
  // update current thumbnail with the provided one and call the repaint
  this->thumbnail = thumbnail.copy();
  update();
}

QImage ThumbnailItem::getThumbnail() const { return thumbnail; }

void ThumbnailItem::paint(QPainter* painter) { painter->drawImage(boundingRect(), thumbnail); }
