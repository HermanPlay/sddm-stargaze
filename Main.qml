import QtQuick 6.9
import QtQuick.Controls 6.9
import SddmComponents 2.0 as Sddm

Rectangle {
    id: container
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.currentIndex

    Sddm.TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }

        onLoginFailed: {
            password.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
        onInformationMessage: {
            errorMessage.color = "red"
            errorMessage.text = message
        }
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Sddm.Clock {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter

            y: (rectangle.y / 2) - (height / 2)

            color: "white"
            timeFont.family: "Oxygen"
        }

        Rectangle {
            id: rectangle
            anchors.centerIn: parent
            width: Math.max(320, mainColumn.implicitWidth + 50)
            height: Math.min(320, mainColumn.implicitHeight + 50)


            color: "#60FFFFFF"
            radius: 16

            Column {
                id: mainColumn
                anchors.centerIn: parent
                spacing: 12
                width: parent.width * 0.7
                Column {
                    width: parent.width
                    spacing: 4
                    Text {
                        id: lblName
                        width: parent.width
                        text: textConstants.userName
                        font.bold: true
                        font.pixelSize: 12
                    }

                    Sddm.TextBox {
                        id: name
                        width: parent.width; height: 30
                        text: userModel.lastUser
                        font.pixelSize: 14

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing : 4
                    Text {
                        id: lblPassword
                        width: parent.width
                        text: textConstants.password
                        font.bold: true
                        font.pixelSize: 12
                    }

                    Sddm.PasswordBox {
                        id: password
                        width: parent.width; height: 30
                        font.pixelSize: 14

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing : 4
                    Row {

                        spacing: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        property int btnWidth: Math.max(loginButton.implicitWidth, 80) + 8
                        Button {
                            id: loginButton
                            text: textConstants.login
                            width: parent.btnWidth

                            onClicked: sddm.login(name.text, password.text, sessionIndex)

                            KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                        }
                            
                    }
                }

                Row {
                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int btnWidth: Math.max(loginButton.implicitWidth,
                                                    shutdownButton.implicitWidth,
                                                    rebootButton.implicitWidth, 80) + 8

                    RoundButton {
                        id: shutdownButton
                        icon.source: config.powerIcon
                        background: Rectangle {
                            radius: 10
                            color: "#FF0000" 
                            opacity: shutdownButton.hovered ? 0.5 : 0.2
                            border.color: "#FF000000"
                            border.width: 1
                        }

                        onClicked: sddm.powerOff()

                        KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                    }

                    RoundButton {
                        id: rebootButton
                        icon.source: config.rebootIcon
                        background: Rectangle {
                            radius: 10
                            color: "#FFFF00" 
                            opacity: rebootButton.hovered ? 0.5 : 0.2
                            border.color: "#FF000000"
                            border.width: 1
                        }

                        onClicked: sddm.reboot()

                        KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                    }
                }
            }
        }


        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 16
            width: 240
            spacing: 4
            z: 100

            Column { // Session Column
                width: parent.width * 0.65 // Approx 182px
                spacing : 4
                z: 100

                Text {
                    id: lblSession
                    width: parent.width
                    text: textConstants.session
                    wrapMode: TextEdit.WordWrap
                    font.bold: true
                    font.pixelSize: 11
                    color: "white"
                }

                ComboBox {
                    id: session
                    width: parent.width; height: 20
                    font.pixelSize: 11
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex
                    textRole: "name"
                    delegate: ItemDelegate {
                            id: delegate
                            required property var model
                            required property int index

                            contentItem: Text {
                                font.pointSize: 8
                                text: delegate.model[session.textRole]
                                color: "#000000"
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: session.highlightedIndex === index
                    }
                    KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                }
            }

            Column { // Layout Column
                width: parent.width * 0.35 // Approx 98px
                spacing : 4
                z: 101

            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
