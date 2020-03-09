import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import "../custom"

Page {
    width: app.width; height: app.height
    function load() {
        visible = true
        pwInput.clear()
    }

    Column {
        id: bodyColumnLayout
        anchors.centerIn: parent
        width: Math.min(dp(300), parent.width - dp(60))
        spacing: dp(5)
        MyTextField {
            id: unInput
            width: parent.width
            icon: "\uE81F"
            text: username
            showClearButton: true
            placeholderText: qsTr("Username")
        }
        MyTextField {
            id: pwInput
            width: parent.width
            icon: "\uE80b"
            passwordMode: true
            placeholderText: qsTr("Password")
        }
        Button {
            id: signInButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sign in")
            onClicked: logic.signIn(unInput.text, pwInput.text)
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            flat: true
            text: qsTr("Sign up")
            onClicked: logic.signUp(unInput.text, pwInput.text)
        }
    }
    RoundButton {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        flat: true
        text: "\uE839"
        font.family: "fontello"
        onClicked: settingsPopup.open()
    }

    Popup {
        id: settingsPopup
        anchors.centerIn: parent
        leftPadding: 20; rightPadding: 20; topPadding: 20; bottomPadding: 0
        contentWidth: bodyColumnLayout.width
        contentHeight: bodyColumn.height
        modal: true
        Column {
            id: bodyColumn
            width: parent.width
            GridLayout {
                width: parent.width
                columns: 2; rows: 2
                Label { text: qsTr("IP") }
                MyTextField {
                    id: ipInput
                    Layout.fillWidth: true
                    text: hostName
                    showClearButton: true
                }
                Label { text: qsTr("Port") }
                MyTextField {
                    id: portInput
                    Layout.fillWidth: true
                    text: port
                    showClearButton: true
                    validator: IntValidator {bottom: 1; top: 65536}
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                RadioButton {
                    text: qsTr("Dark theme")
                    checked: dark
                    onClicked: dark = true
                }
                RadioButton {
                    text: qsTr("Light theme")
                    checked: !dark
                    onClicked: dark = false
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Button {
                    text: qsTr("Cancel")
                    flat: true
                    Material.foreground: Material.Grey
                    onClicked: {
                        settingsPopup.close()
                        ipInput.text = hostName
                        portInput.text = port
                    }
                }
                Button {
                    text: qsTr("Confirm")
                    flat: true
                    Material.foreground: Material.Blue
                    onClicked: {
                        hostName = ipInput.text
                        port = parseInt(portInput.text)
                        settingsPopup.close()
                    }
                }
            }
        }
    }
}
