import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import "../custom"

MyPage {
    title: qsTr("Password")
    leftBarItem: ToolButton {
        text: "\uF0C9"
        font.family: "fontello"
        enabled: dataPrepared
        onClicked: drawer.open()
    }
    rightBarItem: Row {
        ToolButton {
            text: "\uE802"
            font.family: "fontello"
            enabled: dataPrepared
            onClicked: stack.push(searchPage)
        }
        ToolButton {
            text: "\uE810"
            font.family: "fontello"
            enabled: dataPrepared
            onClicked: stack.push(addPage)
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        enabled: dataPrepared
        boundsBehavior: Flickable.DragOverBounds
        boundsMovement: Flickable.StopAtBounds
        //pressDelay: 100

        Label {
            id: busyLabel
            anchors.horizontalCenter: parent.horizontalCenter
            property int minY: -height
            property int maxY: 100
            y: Math.min(minY-parent.verticalOvershoot, maxY)
            rotation: y*5
            width: 30; height: 30
            background: Rectangle {radius: parent.height/2}
            text: "\uE860"
            font.family: "fontello"
            Material.foreground: Material.accent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
        }
        Rectangle {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            width: 30; height: 30; radius: 15
            BusyIndicator {
                anchors.fill: parent
                running: true
            }
        }
        NumberAnimation {
            id: ani1
            target: busyIndicator
            property: "y"
            from: busyLabel.y
            to: 50
            duration: 100
            onStarted: {
                busyLabel.visible = false
                busyIndicator.visible = true
            }
            onFinished: logic.refresh()
        }
        NumberAnimation {
            id: ani2
            target: busyIndicator
            property: "opacity"
            from: 1
            to: 0
            duration: 100
            onFinished: {
                busyIndicator.visible = false
                busyIndicator.opacity = 1
                busyLabel.visible = true
            }
        }
        Connections {
            target: app
            onDataPreparedChanged: {
                if(dataPrepared && busyIndicator.visible)
                    ani2.start()
            }
        }
        onDraggingChanged: {
            if(!dragging) {
                if(verticalOvershoot <= -80)
                    ani1.start()
            }
        }

        model: titlesModel
        delegate: SwipeDelegate {
            id: swipeDelegate
            clip: true
            width: parent.width
            height: implicitContentHeight+2*topPadding
            topPadding: 12; bottomPadding: topPadding
            onClicked: stack.push(viewPage, {entryIndex: index})
            ListView.onRemove: SequentialAnimation {
                PropertyAction {
                    target: swipeDelegate
                    property: "ListView.delayRemove"
                    value: true
                }
                NumberAnimation {
                    target: swipeDelegate
                    property: "height"
                    to: 0
                    easing.type: Easing.InOutQuad
                }
                PropertyAction {
                    target: swipeDelegate
                    property: "ListView.delayRemove"
                    value: false
                }
            }
            contentItem: Column {
                id: column
                Label {
                    id: t1
                    width: parent.width
                    text: title
                    wrapMode: Text.WrapAnywhere
                }
                Label {
                    id: t2
                    width: text ? parent.width : 0
                    text: description
                    font.pixelSize: dp(16)
                    Material.foreground: Material.Grey
                    wrapMode: Text.WrapAnywhere
                }
            }
            swipe.right: Label {
                id: deleteLabel
                anchors.right: parent.right
                width: dp(50)
                height: parent.height
                text: "\uF1F8"
                font.family: "fontello"
                color: "white"
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
                SwipeDelegate.onClicked: logic.removeEntry(index)
                background: Rectangle { color: deleteLabel.SwipeDelegate.pressed ? Qt.lighter("red") : "red" }
            }
        }
        ScrollBar.vertical: ScrollBar {}
    }
}
