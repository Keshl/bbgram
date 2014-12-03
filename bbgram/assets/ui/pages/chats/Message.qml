import bb.cascades 1.2

Container {
    id: me
    
    property bool incoming: !ListItemData.our
    property string text: ListItemData.text
    property variant date: ListItemData.dateTime
    property bool unread: ListItemData.unread
    
    property bool selected : false
    onSelectedChanged: {
        overlay.visible = me.selected
    }
    
    property bool withHeader: ListItem.indexInSection == ListItem.sectionSize - 1
    
    layout: StackLayout {        
    }
    Container {
        visible: me.withHeader
        topPadding: me.withHeader ? 25 : 0
        horizontalAlignment: HorizontalAlignment.Center
        layout: DockLayout {            
        }
        ImageView {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            imageSource: "asset:///images/date.amd"
        }
        Container {            
            leftPadding: 20
            rightPadding: 20
            topPadding: 4
            bottomPadding: 8
            Label {
                text: Qt.formatDate(date, "MMMM d")
                textStyle.color: Color.White
            }
        }
        bottomMargin: 25
        
    }
    Container {
        layout: DockLayout {
        }
        Container {
            minHeight: 100
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10
            preferredWidth: Infinity
            Container {
                horizontalAlignment: me.incoming ? HorizontalAlignment.Left : HorizontalAlignment.Right
                layout: DockLayout {}
                rightPadding: me.incoming ? 80 : 0
                leftPadding: me.incoming ? 0 : 80
                ImageView {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    imageSource: incoming ? "asset:///images/msg_in.amd" : "asset:///images/msg_out.amd"
                }
                Container {            
                    leftPadding: me.incoming ? 40 : 20
                    rightPadding: me.incoming ? 20 : 25
                    topPadding: 10
                    bottomPadding: 14
                    layout: DockLayout {}
                    Label {
                        text: me.text + (incoming ? "<b>            &nbsp;</b>" : "<b>                 &nbsp;</b>")
                        multiline: true
                        textFormat: TextFormat.Html
                        attachedObjects: [
                            LayoutUpdateHandler {
                                onLayoutFrameChanged: {
                                }
                            
                            }
                        ]
                    }
                    Container {
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Bottom
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        Label {
                            text: Qt.formatDateTime(me.date, "hh:mm")
                            
                            textStyle {
                                color: me.incoming ? Color.Gray : Color.create('#75B166')
                                fontSize: FontSize.XSmall
                            }
                            verticalAlignment: VerticalAlignment.Center
                            rightMargin: 0
                        }
                        ImageView {
                            visible: !incoming
                            imageSource: unread ? "asset:///images/check_green.png" : "asset:///images/check_2_green.png"
                            
                            verticalAlignment: VerticalAlignment.Center
                            leftMargin: 0
                        }
                    }
                }
            
            }
        }
        
        Container {
            id: overlay
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create('#31A3DD')
            opacity: 0.2
            visible: false
        }
    }
}