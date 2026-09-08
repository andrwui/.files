pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property var notifications: []
    property bool silent: false

    readonly property int unreadCount: notifications.reduce((count, n) => count + (n.read ? 0 : 1), 0)

    function addNotification(notification) {
        notification.read = false;
        notifications = notifications.concat([notification]);
        console.log(`notification added: "${notification.title}" total: ${notifications.length}`);
    }

    function removeNotification(index) {
        if (index < 0 || index >= notifications.length)
            return;
        notifications = notifications.slice(0, index).concat(notifications.slice(index + 1));
    }

    function markAllRead() {
        if (unreadCount === 0)
            return;
        notifications.forEach(n => n.read = true);
        notifications = notifications.slice();
    }
}
