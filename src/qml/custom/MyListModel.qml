import QtQuick 2.12

ListModel {
    function init(array) {
        clear()
        var n = array.length
        for(var i = 0; i < n; ++i)
            append(array[i])
    }
    function toJson() {
        var array = []
        for(var i = 0; i < count; ++i)
            array.push(get(i))
        return JSON.stringify(array)
    }
}
