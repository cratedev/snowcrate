pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick

Item {
    id: root

    property url source: "file:///home/matt/snowcrate/assets/wallpaper/30.png"
    anchors.fill: parent

    Image {
        id: wallpaperImage
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }
}

