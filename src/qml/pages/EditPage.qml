import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../custom"

MyPage {
    title: qsTr("Edit")
    rightBarItem: ToolButton {
        text: qsTr("Save")
        onClicked: {
            if(isAdd)
                logic.add(titleInput.text, descriptionInput.text)
            else
                logic.edit(entryIndex, titleInput.text, descriptionInput.text)
        }
    }
    property bool isAdd
    property int entryIndex

    Flickable {
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: editBodyColumn.height
        ScrollBar.vertical: ScrollBar {}
        Column {
            id: editBodyColumn
            width: parent.width - dp(40)
            anchors.horizontalCenter: parent.horizontalCenter
            MyLabel { text: qsTr("Title") }
            MyTextField {
                id: titleInput
                width: parent.width
                text: isAdd ? "" : titlesModel.get(entryIndex).a
                showClearButton: true
            }
            MyLabel { text: qsTr("Description") }
            MyTextField {
                id: descriptionInput
                width: parent.width
                text: isAdd ? "" : titlesModel.get(entryIndex).b
                showClearButton: true
            }
            Repeater {
                model: tmpModel
                Column {
                    width: editBodyColumn.width
                    Row {
                        width: parent.width
                        TextInput {
                            width: parent.width - dp(90)
                            text: a
                            color: dark ? "white" : "black"
                            clip: true
                            topPadding: dp(10)
                            bottomPadding: dp(10)
                            font { pixelSize: dp(20); bold: true }
                            onTextEdited: a = text
                        }
                        Button {
                            width: dp(30)
                            text: "\uE855"
                            font.family: "fontello"
                            flat: true
                            Material.foreground: Material.Blue
                            onClicked: tmpModel.insert(index, {"a": "", "b": "", "c": true})
                        }
                        Button {
                            width: dp(30)
                            text: "\uE852"
                            font.family: "fontello"
                            flat: true
                            Material.foreground: Material.Blue
                            onClicked: tmpModel.insert(index + 1, {"a": "", "b": "", "c": true})
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
                        text: b
                        passwordMode: true
                        passwordVisible: c
                        onPasswordVisibleChanged: c = passwordVisible
                        onTextEdited: b = text
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        if(isAdd)
            tmpModel.init([{"a": qsTr("Username"), "b": "", "c": true}, {"a": qsTr("Password"), "b": "", "c": false}])
        else
            tmpModel.init(myData.fields[entryIndex])
    }
}
