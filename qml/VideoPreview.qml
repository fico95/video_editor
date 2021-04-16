import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtMultimedia 5.12

import VideoModel 1.0
import VideoThread 1.0

Item {
    id: root

    anchors.fill: parent

    signal backTriggered()
    signal loadVideoTriggered()

    property variant model: model

    PathView {
        id: pathView

        anchors.fill: parent
        anchors.topMargin: buttonBack.y + buttonBack.height / 2

        pathItemCount: 9
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange

        model: root.model

        delegate: Rectangle {
            id: item

            height: parent.height * 0.5
            width: parent.width * 0.25

            color: "transparent"

            z: PathView.iconOrder
            scale: PathView.iconScale

            Rectangle {
                width: parent.width
                height: parent.height * 0.7

                anchors.top: parent.top

                color: "darkgrey"
                border.color: "black"
                border.width: 1

                Label {
                    text: fileName(path)

                    width: parent.width * 0.8
                    height: parent.height * 0.8

                    anchors.centerIn: parent

                    wrapMode: "Wrap"

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    font.pointSize: 72
                    fontSizeMode: Text.Fit

                    function fileName(str)
                    {
                        return (str.slice(str.lastIndexOf("/")+1))
                    }
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: video.startPlaying(path)
                }
            }

            Button {
                visible: pathView.model.editable && pathView.currentIndex == index

                Label {
                    text: "Edit"

                    width: parent.width * 0.8
                    height: parent.height * 0.8

                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    font.pointSize: 72
                    fontSizeMode: Text.Fit
                }

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: parent.width / 3.0
                height: parent.height * 0.2

                onClicked: {
                    var popup = popupFactory.createObject(root, {});
                    popup.open();
                }
            }
        }

        path: Path {
            startX: 0
            startY: parent.height / 2
            PathAttribute {
                name: "iconScale"
                value: 0.3
            }
            PathAttribute {
                name: "iconOrder"
                value: 0
            }

            PathLine {
                x: parent.width / 2
                y: parent.height / 2
            }
            PathAttribute {
                name: "iconScale"
                value: 1.2
            }
            PathAttribute {
                name: "iconOrder"
                value: 10
            }

            PathLine {
                x: parent.width
                y: parent.height / 2
            }
        }
    }

    RoundButton {
        id: buttonBack
        x: 20
        y: 20

        text: "Back"

        onClicked: backTriggered()
    }

    RoundButton {
        id: buttonLoadVideo

        x: parent.width - 20 - width
        y: 20

        visible: model.editable

        text: "Load video"

        onClicked: loadVideoTriggered()
    }

    Video {
        id: video
        visible: false

        anchors.fill: parent

        fillMode: VideoOutput.Stretch

        muted: true

        MouseArea {
            anchors.fill: parent

            onClicked: {
                video.stopPlaying();
            }
        }
        Keys.onEscapePressed: {
            video.stopPlaying();
            event.accepted = true;
        }

        function startPlaying(path) {
            video.source = path;
            video.visible = true;
            video.play();
            video.z = 999;
        }
        function stopPlaying() {
            video.stop();
            video.source = "";
            video.visible = false;
            video.z = -1;
        }
    }

    Component {
        id: popupFactory

        VideoOverlaysPopup {
            onOpened: root.enabled = false;
            onClosed: root.enabled = true;

            onOverlaysApplyTriggered:
            {
                var videoThread = videoThreadFactory.createObject(root, {});
                videoThread.setVideoPath(root.model.getPath(pathView.currentIndex))
                for (let i=0; i <overlays.length; ++i)
                {
                    videoThread.setOverlay(overlays[i][0], overlays[i][1], overlays[i][2]);
                }
                videoThread.start()

                videoThread.videoEditingFinished.connect(videoThread.destroy);
            }
        }
    }
    Component {
        id: videoThreadFactory

        VideoThread {
            //onVideoEditingFinished: destroy()
        }
    }
}
