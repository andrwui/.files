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
            label: 'january'
            value: Calendar.January
        }
        ListElement {
            label: 'february'
            value: Calendar.February
        }
        ListElement {
            label: 'march'
            value: Calendar.March
        }
        ListElement {
            label: 'april'
            value: Calendar.April
        }
        ListElement {
            label: 'may'
            value: Calendar.May
        }
        ListElement {
            label: 'june'
            value: Calendar.June
        }
        ListElement {
            label: 'july'
            value: Calendar.July
        }
        ListElement {
            label: 'august'
            value: Calendar.August
        }
        ListElement {
            label: 'september'
            value: Calendar.September
        }
        ListElement {
            label: 'october'
            value: Calendar.October
        }
        ListElement {
            label: 'november'
            value: Calendar.November
        }
        ListElement {
            label: 'december'
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

    function init() {
        populateYears();
    }

    function reset() {
        currentMonth = new Date().getMonth();
        currentYear = new Date().getFullYear();
    }

    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
}
