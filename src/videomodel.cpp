#include "include/videomodel.h"

VideoModel::VideoModel(QObject* parent) : QAbstractListModel(parent) {}

QVariant VideoModel::data(const QModelIndex& index, int role) const
{
  if (!index.isValid())
  {
    return QVariant();
  }
  if (index.row() < 0 || index.row() >= videos.size())
  {
    return QVariant();
  }
  switch (role)
  {
  case PathRole:
    return QVariant(videos.at(index.row()).path);
  case ThumbnailRole:
    return QVariant(videos.at(index.row()).thumbnail);
  default:
    return QVariant();
  }
}

bool VideoModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
  Q_UNUSED(index)
  Q_UNUSED(value)
  Q_UNUSED(role)
  return false;
}

QHash<int, QByteArray> VideoModel::roleNames() const
{
  QHash<int, QByteArray> roles;
  roles[PathRole] = "path";
  roles[ThumbnailRole] = "thumbnail";
  return roles;
}

int VideoModel::rowCount(const QModelIndex& parent) const
{
  Q_UNUSED(parent)
  return videos.size();
}

bool VideoModel::getEditable() const { return editable; }

void VideoModel::setEditable(bool value) { emit editableChanged(editable = value); }

QString VideoModel::getPath(int index)
{
  if (index < 0 || index >= videos.size())
  {
    return QString();
  }
  return videos[index].path;
}

void VideoModel::addVideo(QString path)
{
  Video video;
  if (!path.startsWith("file://"))
  {
    path.insert(0, "file://");
  }
  video.path = path;
  // TODO: add thumbnail setup
  addVideo(video);
}

void VideoModel::addVideo(const Video& video)
{
  beginInsertRows(QModelIndex(), videos.size(), videos.size());

  videos.push_back(std::move(video));

  endInsertRows();
  emit dataChanged(QModelIndex(), QModelIndex());
}
