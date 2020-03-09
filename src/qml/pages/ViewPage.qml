import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../custom"

MyPage {
    id: root
    property bool viewable: false
    property var entryIndex

    function updateViewPage() {
        title = myData.titles[entryIndex].title
        descriptionText.text = myData.titles[entryIndex].description
        fieldsModel.init(myData.fields[entryIndex])
    }

    rightBarItem: Row {
        ToolButton {
            text: root.viewable ? "\uE823" : "\uE822"
            font.family: "fontello"
            onClicked: root.viewable = !root.viewable
        }
        ToolButton {
            text: "\uE82A"
            font.family: "fontello"
            onClicked: stack.push(editPage)
        }
    }

    Flickable {
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: viewBodyColumn.height
        ScrollBar.vertical: ScrollBar {}
        Column {
            id: viewBodyColumn
            width: parent.width - dp(40)
            anchors.horizontalCenter: parent.horizontalCenter
            MyLabel { text: qsTr("Description") }
            ItemDelegate {
                id: descriptionText
                width: parent.width
                onPressAndHold: clipBoard.copy(descriptionText.text)
            }
            Repeater {
                id: viewList
                width: parent.width
                model: fieldsModel
                delegate: Column {
                    width: viewList.width
                    Rectangle {
                        width: parent.width; height: 1
                        color: "lightgray"
                    }
                    MyLabel { text: name }
                    ItemDelegate {
                        width: parent.width
                        text: (viewable || root.viewable || content.length === 0) ? content : "●●●●●●"
                        onPressAndHold: clipBoard.copy(content)
                    }
                }
            }
        }
    }
    Component {
        id: editPage
        EditPage {}
    }
    Component.onCompleted: updateViewPage()
}
