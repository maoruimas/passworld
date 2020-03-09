import QtQuick 2.12
import QtQuick.Controls 2.12

Popup {
    id: root
    property bool isQuit: false
    property bool isBusy: false
    function show(msg, color) {
        tipText.text = msg
        tipBg.color = color
        open()
        tipTimer.start()
    }
    function setBusy(bsy) {
        isBusy = bsy
        if(bsy)
            open()
        else
            close()
    }

    anchors.centerIn: parent
    padding: dp(10)
    contentWidth: isBusy ? 40 : tipText.width
    contentHeight: isBusy ? 40 : tipText.height
    dim: false
    modal: isBusy
    closePolicy: Popup.NoAutoClose
    background: Rectangle {
        id: tipBg
        radius: dp(5)
        opacity: isBusy ? 0.0 : 0.8
    }
    BusyIndicator {
        id: busyIndicator
        anchors.fill: parent
        visible: isBusy
        running: isBusy
    }
    Text {
        id: tipText
        anchors.centerIn: parent
        visible: !isBusy
        color: "white"
        font.bold: true
        font.pixelSize: dp(20)
    }
    Timer {
        id: tipTimer
        interval: 1000
        onTriggered: {
            isQuit = false
            close()
        }
    }
}
