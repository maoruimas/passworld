import QtQuick.Window 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt.labs.settings 1.1

import "pages"
import "custom"

ApplicationWindow {
    id: app
    width: 300
    height: 600
    visible: true
    title: qsTr("Passworld")
    font {pixelSize: dp(20); family: fontFamily}

    property real dpScale: 1.0
    readonly property real pixelPerDp: Screen.pixelDensity * 25.4 / 160
    function dp(x) { return x * pixelPerDp * dpScale }

    Material.primary: dark ? "#202020" : "#F2F2F2"
    Material.theme: dark ? Material.Dark : Material.Light

    Settings {
        fileName: "settings.ini"
        property alias username: app.username
        property alias hostName: app.hostName
        property alias port: app.port
        property alias dark: app.dark
    }
    property string username
    property string hostName
    property int port
    property bool dark

    Logic {
        id: logic
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: mainPage
        pushEnter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "y"
                    from: stack.height/2
                    to: 0
                    duration: 100
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 100
                }
            }
        }
        pushExit: null
        popEnter: null
        popExit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "y"
                    from: 0
                    to: stack.height/2
                    duration: 100
                }
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 100
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: dp(200)
        height: parent.height
        padding: 0
        dragMargin: 0
        Rectangle {
            id: topRec
            width: drawer.width
            height: dp(100)
            Text {
                anchors.centerIn: parent
                color: "white"
                text: username
                font.pixelSize: dp(30)
                font.bold: true
            }
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {position: 0.0; color: Qt.lighter(dark ? "#607D8B" : "#00B0F0")}
                GradientStop {position: 1.0; color: dark ? "#607D8B" : "#00B0F0"}
            }
        }
        ListView {
            id: drawerList
            y: topRec.height
            width: drawer.width
            height: drawer.height - topRec.height
            clip: true
            currentIndex: 0
            model: ListModel {
                ListElement { title: qsTr("Password") }
                ListElement { title: qsTr("Account") }
            }
            delegate: ItemDelegate {
                width: drawer.width
                text: title
                Material.foreground: drawerList.currentIndex === index ? Material.Blue : Material.Grey
                highlighted: ListView.isCurrentItem
                onClicked: {
                    if(index === 0){
                        drawerList.currentIndex = index
                        stack.clear()
                        stack.push(mainPage)
                    }else if(index === 1){
                        drawerList.currentIndex = index
                        stack.clear()
                        stack.push(accountPage)
                    }
                    drawer.close()
                }
            }
            ScrollBar.vertical: ScrollBar {}
        }
        RoundButton {
            x: drawer.width-width; y: drawer.height-height
            text: dark ? "\uF185" : "\uF186"
            font.family: "fontello"
            Material.elevation: 1
            Material.background: Material.Indigo
            Material.foreground: "white"
            onClicked: dark = !dark
        }
    }

    LandingPage {
        id: landingPage
    }

    property bool dataPrepared: true
    property var myData
    MyListModel {
        id: titlesModel
    }
    MyListModel {
        id: fieldsModel
    }
    MyListModel {
        id: tmpModel
    }

    Component {
        id: mainPage
        MainPage {}
    }
    Component {
        id: searchPage
        SearchPage {}
    }
    Component {
        id: viewPage
        ViewPage {}
    }
    Component {
        id: addPage
        AddPage {}
    }
    Component {
        id: accountPage
        AccountPage {}
    }

    TipPopup {
        id: tip
    }
    ClipBoard {
        id: clipBoard
    }
}
