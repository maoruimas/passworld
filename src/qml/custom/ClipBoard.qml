import QtQuick 2.12

Item {
    visible: false
    function copy(str){
        if(str){
            textInput.text = str
            textInput.selectAll()
            textInput.copy()
            tip.show(qsTr("Copied"), "green")
        }
    }
    TextInput {
        visible: false
        id: textInput
    }
}
