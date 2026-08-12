pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property var notifications: []

    function addNotification(notification) {
        notifications = notifications.concat([notification]);
        console.log(`notification added: "${notification.title}" total: ${notifications.length}`);
    }
}
