import bb.cascades 1.2
import bbgram.types.lib 0.1

import "settings"
import "contacts"

Page {
    property User user
    property bool muted: user ? user.muted : false
    
    actions: [
        ActionItem {
            title: "Edit"
            imageSource: "asset:///images/menu_bar_edit.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            function updateContactName(user, firstName, lastName){
                _owner.renameContact(firstName, lastName, user.phone)
            }
            
            onTriggered: {
                var sheet = editContactSheetDef.createObject();
                sheet.user = user;
                sheet.caption = "Edit Contact";
                sheet.done.connect(updateContactName);
                sheet.open();
            }
        },
        ActionItem {
            title: "Send Message"
            imageSource: "asset:///images/menu_bar_chat.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                Application.scene.openChat(user)
            }
        },
        ActionItem {
            title: "Start Secret Chat"
            imageSource: "asset:///images/menu_secretchat.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        ActionItem {
            title: "Share Contact"
            imageSource: "asset:///images/menu_contactshare.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        ActionItem {
            title: "Shared Media"
            imageSource: "asset:///images/menu_sharedmedia.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        ActionItem {
            title: "Block Contact"
            imageSource: "asset:///images/menu_contactblock.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        ActionItem {
            title: "Delete Contact"
            imageSource: "asset:///images/menu_bin.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            
            onTriggered: {
                enabled = false
                _owner.deleteContact(user)
            }
        }
    ]
    
    ScrollView {
        Container {
            Container {
                leftPadding: 20
                topPadding: 20
                rightPadding: 20
                bottomPadding: 20
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                ImageView {
                    verticalAlignment: VerticalAlignment.Center
                    
                    imageSource: user ? user.photo : ""
                    //imageSource: "asset:///images/placeholders/user_placeholder_purple.png"
                    scalingMethod: ScalingMethod.Fill
                    preferredHeight: 200
                    preferredWidth: 200
                }
                
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.TopToBottom
                    }
                    verticalAlignment: VerticalAlignment.Center
                    
                    Label {
                        text: user ? user.name : ""
                        //text: "firstName lastName"
                        textStyle {
                            fontSize: FontSize.Large
                        }
                    }
                    
                    Label {
                        text: user ? user.lastSeenFormatted : ""
                        //text: "last seen ..."
                        textStyle {
                            color: Color.Gray
                            fontSize: FontSize.Large
                        }
                    }
                }
            }
            
            Container {
                layout: StackLayout {
                }
                horizontalAlignment: HorizontalAlignment.Fill
                
                SettingsHeader {
                    text: "Phone"
                }
                
                Container {
                    ContactPhoneNumber {
                        phone: user ? "+" + user.phone : ""
                        //phone:"+7 927 7777777"
                        type: "Mobile"
                    }
                }
                
                SettingsHeader {
                    text: "Settings"
                }
                SettingsToggleButton {
                    text: "Notifications"
                    checked: !muted
                    onCheckedChanged: {
                        if (muted == checked)
                            user.mute(!checked)
                    }
                }
                SettingsRow {
                    text: "Shared Media"
                }
            }
        }
    }
    attachedObjects: ComponentDefinition {
        id: editContactSheetDef
        source: "contacts/EditContact.qml"
    }
}
