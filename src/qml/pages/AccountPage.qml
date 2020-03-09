import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
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

    MessageDialog {
        id: deleteWarningDialog
        title: qsTr("Delete account?")
        icon: StandardIcon.Warning
        text: qsTr("Are you sure to delete your account?")
        detailedText: qsTr("This operation CANNOT be undone. Be cautious about your decision!")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: logic.deleteAccount()
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
