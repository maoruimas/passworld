import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../custom"

MyPage {
    title: qsTr("Add")

    rightBarItem: ToolButton {
        text: qsTr("Save")
        onClicked: logic.add(titleInput.text, descriptionInput.text)
    }

    Flickable {
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: addBodyColumn.height
        ScrollBar.vertical: ScrollBar {}
        Column {
            id: addBodyColumn
            width: parent.width - dp(40)
            anchors.horizontalCenter: parent.horizontalCenter
            MyLabel { text: qsTr("Title") }
            MyTextField {
                id: titleInput
                width: parent.width
                showClearButton: true
            }
            MyLabel { text: qsTr("Description") }
            MyTextField {
                id: descriptionInput
                width: parent.width
                showClearButton: true
            }
            Repeater {
                model: tmpModel
                Column {
                    width: addBodyColumn.width
                    Row {
                        width: parent.width
                        TextInput {
                            width: parent.width - dp(90)
                            text: name
                            color: dark ? "white" : "black"
                            clip: true
                            topPadding: dp(10)
                            bottomPadding: dp(10)
                            font { pixelSize: dp(20); bold: true }
                            onTextEdited: name = text
                        }
                        Button {
                            width: dp(30)
                            text: "\uE855"
                            font.family: "fontello"
                            flat: true
                            Material.foreground: Material.Blue
                            onClicked: tmpModel.insert(index, {"name": "", "content": "", viewable: true})
                        }
                        Button {
                            width: dp(30)
                            text: "\uE852"
                            font.family: "fontello"
                            flat: true
                            Material.foreground: Material.Blue
                            onClicked: tmpModel.insert(index + 1, {"name": "", "content": "", viewable: true})
                        }
                        Button {
                            width: dp(30)
                            text: "\uE869"
                            font.family: "fontello"
                            flat: true
                            Material.foreground: Material.Red
                            onClicked: tmpModel.remove(index)
                        }
                    }
                    MyTextField {
                        width: parent.width
                        text: content
                        passwordMode: true
                        onPasswordVisibleChanged: viewable = passwordVisible
                        onTextEdited: content = text
                    }
                }
            }
        }
    }
    Component.onCompleted: tmpModel.init([{"name": qsTr("Username"), "content": "", "viewable": true}, {"name": qsTr("Password"), "content": "", "viewable": false}])
}
