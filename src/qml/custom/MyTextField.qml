import QtQuick 2.12
import QtQuick.Controls 2.12

TextField {
    property bool showClearButton: false
    property bool passwordMode: false
    property bool passwordVisible: false
    property string icon: ""

    selectByMouse: true
    // left
    Label {
        id: leftItem
        width: icon ? parent.height : 0; height: parent.height
        text: icon
        font {family: "fontello"; pixelSize: height*0.4}
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    leftPadding: icon ? leftItem.width : 5
    //right
    Button {
        id: rightItem
        focusPolicy: Qt.NoFocus
        visible: (showClearButton && parent.activeFocus && parent.text) || passwordMode
        anchors.right: parent.right
        width: parent.height; height: parent.height
        flat: true
        text: (passwordMode && passwordVisible) ? "\uE823" :
              (passwordMode && !passwordVisible) ? "\uE822" :
              showClearButton ? "\uE811" : ""
        font {family: "fontello"; pixelSize: height*0.4}
        onClicked: {
            if(passwordMode)
                passwordVisible = !passwordVisible
            else if(showClearButton)
                clear()
        }
    }
    rightPadding: rightItem.text ? rightItem.width : 5
    // password mode
    echoMode: (passwordMode && !passwordVisible) ? TextInput.Password : TextInput.Normal
    passwordMaskDelay: 500
}
