pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell

Singleton {

    readonly property ListModel years: ListModel {
        id: yearsModel
    }

    readonly property ListModel months: ListModel {
        id: monthsModel
        ListElement {
            label: 'January'
            value: Calendar.January
        }
        ListElement {
            label: 'February'
            value: Calendar.February
        }
        ListElement {
            label: 'March'
            value: Calendar.March
        }
        ListElement {
            label: 'April'
            value: Calendar.April
        }
        ListElement {
            label: 'May'
            value: Calendar.May
        }
        ListElement {
            label: 'June'
            value: Calendar.June
        }
        ListElement {
            label: 'July'
            value: Calendar.July
        }
        ListElement {
            label: 'August'
            value: Calendar.August
        }
        ListElement {
            label: 'September'
            value: Calendar.September
        }
        ListElement {
            label: 'October'
            value: Calendar.October
        }
        ListElement {
            label: 'November'
            value: Calendar.November
        }
        ListElement {
            label: 'December'
            value: Calendar.December
        }
    }

    function populateYears() {
        if (yearsModel.count > 0) {
            return;
        }

        const currentYear = new Date().getFullYear();
        const end = currentYear + 10;

        for (let i = 1; i <= end; i++) {
            yearsModel.append({
                label: (i - 1).toString(),
                value: i - 1
            });
        }
    }

    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
}
