import QtQuick 2.12

Item {
    function signIn(un, pw) {
        tip.setBusy(true)
        _._username = un
        backend.setHostNameAndPort(hostName, port)
        backend.signIn(un, pw)
        backend.finished.connect(_.landFinished)
    }
    function signUp(un, pw) {
        tip.setBusy(true)
        _._username = un
        backend.setHostNameAndPort(hostName, port)
        backend.signUp(un, pw);
        backend.finished.connect(_.landFinished)
    }
    function removeEntry(index) {
        tip.setBusy(true)
        _.entryIndex = index
        var copiedData = JSON.parse(JSON.stringify(myData))
        copiedData.titles.splice(index, 1)
        copiedData.fields.splice(index, 1)
        backend.save(JSON.stringify(copiedData))
        backend.finished.connect(_.removeEntryFinished)
    }
    function add(title, description) {
        tip.setBusy(true)
        _.title = title
        _.description = description
        // save modification in a copied object
        var copiedData = JSON.parse(JSON.stringify(myData))
        copiedData.titles.push({"a": title, "b": description})
        copiedData.fields.push(JSON.parse(tmpModel.toJson()))
        // commit modification
        backend.save(JSON.stringify(copiedData))
        backend.finished.connect(_.addFinished)
    }
    function edit(index, title, description) {
        _.entryIndex = index
        // check modification
        _.titleModified = false
        _.descriptionModified = false
        _.fieldsModified = false
        if(title !== titlesModel.get(_.entryIndex).a)
            _.titleModified = true
        if(description !== titlesModel.get(_.entryIndex).b)
            _.descriptionModified = true
        if(fieldsModel.count !== tmpModel.count || fieldsModel.toJson() !== tmpModel.toJson())
            _.fieldsModified = true
        if(_.titleModified || _.descriptionModified || _.fieldsModified){
            tip.setBusy(true)
            _.title = title
            _.description = description
            // save modification in a copied object
            var copiedData = JSON.parse(JSON.stringify(myData))
            if(_.titleModified)
                copiedData.titles[_.entryIndex].a = title
            if(_.descriptionModified)
                copiedData.titles[_.entryIndex].b = description
            if(_.fieldsModified)
                copiedData.fields[_.entryIndex] = JSON.parse(tmpModel.toJson())
            // commit modification
            backend.save(JSON.stringify(copiedData))
            backend.finished.connect(_.editFinished)
        }else
            tip.show(qsTr("Nothing to save"), "green")
    }
    function changeUsername(ps, un) {
        tip.setBusy(true)
        _._username = un
        backend.changeUsername(ps, un)
        backend.finished.connect(_.changeUsernameFinished)
    }
    function changePassword(ps, nps) {
        tip.setBusy(true)
        backend.changePassword(ps, nps)
        backend.finished.connect(_.changePasswordFinished)
    }
    function deleteAccount() {
        tip.setBusy(true)
        backend.deleteAccount()
        backend.finished.connect(_.deleteAccountFinished)
    }
    function refresh() {
        dataPrepared = false
        backend.refresh()
        backend.finished.connect(_.refreshFinished)
    }
    // private data
    Item {
        id: _
        property int entryIndex
        property string _username
        property string title
        property string description
        property bool titleModified
        property bool descriptionModified
        property bool fieldsModified
        function landFinished(succeeded, data) {
            tip.setBusy(false)
            if(succeeded) {
                try {
                    myData = JSON.parse(data)
                } catch(e) {
                    tip.show(qsTr("Wrong password"), "red")
                    backend.finished.disconnect(landFinished)
                    return
                }
                username = _username
                titlesModel.init(myData.titles)
                dataPrepared = true
                drawerList.currentIndex = 0
                stack.clear()
                stack.push(mainPage)
                stack.forceActiveFocus()
                landingPage.visible = false
                tip.show(qsTr("Welcome, ") + username, "green")
            } else
                tip.show(data, "red")
            backend.finished.disconnect(landFinished)
        }
        function removeEntryFinished(succeeded, data) {
            tip.setBusy(false)
            if(succeeded) {
                myData.titles.splice(entryIndex, 1)
                myData.fields.splice(entryIndex, 1)
                titlesModel.remove(entryIndex)
                tip.show(qsTr("Removed"), "green")
            } else
                tip.show(data, "red")
            backend.finished.disconnect(removeEntryFinished)
        }
        function addFinished(succeeded, data) {
            tip.setBusy(false)
            if(succeeded) {
                titlesModel.append({"a": title, "b": description});
                myData.titles.push({"a": title, "b": description})
                myData.fields.push(JSON.parse(tmpModel.toJson()))
                stack.pop()
                tip.show(qsTr("Added"), "green")
            } else
                tip.show(data, "red")
            backend.finished.disconnect(addFinished)
        }
        function editFinished(succeeded, data) {
            tip.setBusy(false)
            if(succeeded) {
                if(titleModified){
                    titlesModel.get(entryIndex).a = title
                    myData.titles[entryIndex].a = title
                }
                if(descriptionModified){
                    titlesModel.get(entryIndex).b = description
                    myData.titles[entryIndex].b = description
                }
                if(fieldsModified)
                    myData.fields[entryIndex] = JSON.parse(tmpModel.toJson())
                tip.show(qsTr("Edited"), "green")
            }else
                tip.show(data, "red")
            backend.finished.disconnect(editFinished)
        }
        function changeUsernameFinished(succeeded, data) {
            tip.setBusy(false)
            if(succeeded) {
                username = _username
                tip.show(qsTr("Username changed"), "green")
                stack.pop()
            } else
                tip.show(data, "red")
            backend.finished.disconnect(changeUsernameFinished)
        }
        function changePasswordFinished(succeeded, data) {
            tip.setBusy(false)
            if(succeeded) {
                tip.show(qsTr("Password changed"), "green")
                stack.pop()
            } else
                tip.show(data, "red")
            backend.finished.disconnect(changePasswordFinished)
        }
        function deleteAccountFinished(succeeded, data) {
            tip.setBusy(false)
            if(succeeded) {
                tip.show(qsTr("Account deleted"), "green")
                username = ""
                landingPage.load()
            } else
                tip.show(data, "red")
            backend.finished.disconnect(deleteAccountFinished)
        }
        function refreshFinished(succeeded, data) {
            dataPrepared = true
            if(succeeded) {
                try{
                    myData = JSON.parse(data)
                }catch(e){
                    tip.show(qsTr("Password changed"), "red")
                    landingPage.load()
                    return
                }
                titlesModel.init(myData.titles)
                tip.show(qsTr("Refreshed"), "green")
            } else
                tip.show(data, "red")
            backend.finished.disconnect(refreshFinished)
        }
    }
}
