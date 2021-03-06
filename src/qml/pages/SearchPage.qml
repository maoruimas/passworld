import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import "../custom"

Page {
    header: ToolBar {
        focus: true
        RowLayout {
            anchors.fill: parent
            ToolButton {
                id: backButton
                text: "\uE857"
                font.family: "fontello"
                onClicked: stack.pop()
            }
            MyTextField {
                focus: true
                Layout.rightMargin: dp(5)
                Layout.fillWidth: true
                icon: "\uE802"
                showClearButton: true
                placeholderText: qsTr("Search")
                onTextChanged: {
                    searchList.model.clear()
                    if(text) {
                        var n = myData.titles.length
                        for(var i = 0; i < n; ++i){
                            var t = myData.titles[i].a
                            var d = myData.titles[i].b
                            var pt = t.toLowerCase().indexOf(text.toLowerCase())
                            var pd = d.toLowerCase().indexOf(text.toLowerCase())
                            if(pt >= 0 || pd >= 0){
                                if(pt >= 0) t = t.slice(0, pt) + '<font color="red">' + t.substr(pt, text.length) + '</font>' + t.slice(pt + text.length)
                                if(pd >= 0) d = d.slice(0, pd) + '<font color="red">' + d.substr(pd, text.length) + '</font>' + d.slice(pd + text.length)
                                searchList.model.append({"a": t, "b": d, "entryIndex": i})
                            }
                        }
                    }
                }
                onEditingFinished: {
                    if(searchList.count === 1)
                        stack.replace(viewPage, {entryIndex: searchList.model.get(0).entryIndex})
                }
            }
        }
    }

    ListView {
        id: searchList
        anchors.fill: parent
        model: ListModel {}
        delegate: ItemDelegate {
            width: parent.width
            height: implicitContentHeight+2*topPadding
            topPadding: 12; bottomPadding: topPadding
            onClicked: stack.replace(viewPage, {entryIndex: entryIndex})
            contentItem: Column {
                Label {
                    width: parent.width
                    text: a
                    wrapMode: Text.WrapAnywhere
                }
                Label {
                    width: text ? parent.width : 0
                    text: b
                    Material.foreground: Material.Grey
                    font.pixelSize: dp(16)
                    wrapMode: Text.WrapAnywhere
                }
            }
        }
    }
    Label {
        anchors.centerIn: parent
        visible: searchList.count === 0
        text: qsTr("No results")
    }
    Keys.onBackPressed: stack.pop()
}
