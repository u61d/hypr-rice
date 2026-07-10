import QtQuick
Rectangle {
    width: 100
    height: 100
    property bool testBool: false
    Rectangle {
        width: 50; height: 50
        MouseArea {
            anchors.fill: parent
            onClicked: testBool = !testBool
        }
    }
}
