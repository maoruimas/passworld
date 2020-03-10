import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import "../custom"

MyPage {
    title: qsTr("Account")
    leftBarItem: ToolButton {
        text: "\uF0C9"
        font.family: "fontello"
        onClicked: drawer.open()
    }
    Flickable {
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: bodyColumn.height
        ScrollBar.vertical: ScrollBar {}
        Column {
            id: bodyColumn
            width: parent.width
            ItemDelegate {
                width: parent.width
                text: qsTr("Change username")
                onClicked: stack.push(changeUsernamePage)
            }
            ItemDelegate {
                width: parent.width
                text: qsTr("Change password")
                onClicked: stack.push(changePasswordPage)
            }
            ItemDelegate {
                width: parent.width
                text: qsTr("Sign out")
                Material.foreground: Material.Blue
                onClicked: landingPage.load()
            }
            ItemDelegate {
                width: parent.width
                text: qsTr("Delete account")
                Material.foreground: Material.Red
                onClicked: deleteWarningDialog.open()
            }
        }
    }

    Popup {
        id: deleteWarningDialog
        anchors.centerIn: parent
        leftPadding: 20; rightPadding: 20; topPadding: 20; bottomPadding: 0
        modal: true
        Column {
            width: app.width-80
            Label {
                width: parent.width
                text: qsTr("Are you sure to delete your account?")
                wrapMode: Label.WrapAnywhere
            }
            Label {
                width: parent.width
                text: qsTr("This operation CANNOT be undone. Be cautious about your decision!")
                Material.foreground: Material.Red
                font.pixelSize: dp(16)
                wrapMode: Label.WrapAnywhere
            }
            Row {
                anchors.right: parent.right
                spacing: 5
                Button {
                    text: qsTr("Cancel")
                    flat: true
                    Material.foreground: Material.Grey
                    onClicked: deleteWarningDialog.close()
                }
                Button {
                    text: qsTr("Confirm")
                    flat: true
                    Material.foreground: Material.Blue
                    onClicked: logic.deleteAccount()
                }
            }
        }
    }

    Component {
        id: changeUsernamePage
        MyPage {
            title: qsTr("Change username")
            rightBarItem: ToolButton {
                text: qsTr("Save")
                enabled: passInput.text.length > 0 && userInput.text.length > 0
                onClicked: logic.changeUsername(passInput.text, userInput.text)
            }
            Column {
                width: parent.width - dp(40)
                anchors.horizontalCenter: parent.horizontalCenter
                MyLabel { text: qsTr("Current password") }
                MyTextField {
                    id: passInput
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - dp(60)
                    passwordMode: true
                }
                MyLabel { text: qsTr("New username") }
                MyTextField {
                    id: userInput
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - dp(60)
                    passwordMode: true
                }
            }
        }
    }
    Component {
        id: changePasswordPage
        MyPage {
            title: qsTr("Change password")
            rightBarItem: ToolButton {
                text: qsTr("Save")
                enabled: passInput.text.length > 0 && npInput.text.length > 0 && npInput.text === cpInput.text
                onClicked: logic.changePassword(passInput.text, npInput.text)
            }
            Column {
                width: parent.width - dp(40)
                anchors.horizontalCenter: parent.horizontalCenter
                MyLabel { text: qsTr("Current password") }
                MyTextField {
                    id: passInput
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - dp(60)
                    passwordMode: true
                }
                MyLabel { text: qsTr("New password") }
                MyTextField {
                    id: npInput
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - dp(60)
                    passwordMode: true
                }
                MyLabel { text: qsTr("Confirm password") }
                MyTextField {
                    id: cpInput
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - dp(60)
                    passwordMode: true
                }
            }
        }
    }
}
