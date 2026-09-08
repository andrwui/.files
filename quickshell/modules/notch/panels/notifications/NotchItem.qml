import QtQuick
import qs.components
import qs.state

Rectangle {
    color: 'transparent'

    CustomIcon {
        iconName: NotificationsState.silent ? 'notifications/notifications-silenced' : NotificationsState.unreadCount > 0 ? 'notifications/notifications-pending' : 'notifications/notifications'
        height: 15
        width: 15
    }
}
