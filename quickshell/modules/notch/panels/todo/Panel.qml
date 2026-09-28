pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtCore
import qs.components
import qs.config
import qs.modules.notch.panels.components

Rectangle {
    id: root
    color: 'transparent'

    // NOTE: no anchors.fill here on purpose – this item is placed directly
    // in notchStack and explicit width/height are set in Panels.qml.

    // NOTE: StandardPaths returns file:// URLs (FileView accepts those,
    // but raw shell commands do not), so build the path from $HOME.
    readonly property string storeDir: `${Quickshell.env("HOME")}/.local/share/quickshell`
    readonly property string storePath: `${root.storeDir}/todos.json`

    property var categories: []
    property var labels: ({})
    property var todos: []

    property string selectedTab: ''
    property bool showingDetail: false

    // detail draft state
    property int editingIndex: -1
    property string detailCat: ''
    property var detailLabels: []
    property bool managingLabels: false
    property var draftItems: []

    // inline category editing in the tabs row: null | 'new' | <categoryId>
    property var editingCat: null
    property string catDraft: ''

    // inline label editing in detail: null | { name: '__new__' } | { name: <old> }
    property var editingLabel: null
    property string labelDraft: ''
    property string labelDraftColor: '#7aa2f7'

    readonly property var colorDots: ['#7aa2f7', '#9ece6a', '#e0af68', '#ff5555', '#bb9af7', '#7dcfff']

    readonly property var legacyLabelColors: {
        'work': '#7aa2f7',
        'personal': '#9ece6a',
        'urgent': '#ff5555',
        'idea': '#e0af68'
    }

    function labelsFor(catId) {
        var list = root.labels[catId];
        return Array.isArray(list) ? list : [];
    }

    function labelColor(catId, name) {
        var list = root.labelsFor(catId);
        for (var i = 0; i < list.length; i++) {
            if (list[i].name === name)
                return list[i].color;
        }
        if (root.legacyLabelColors[name])
            return root.legacyLabelColors[name];
        return Config.colors.secondaryLight;
    }

    function catName(catId) {
        for (var i = 0; i < root.categories.length; i++) {
            if (root.categories[i].id === catId)
                return root.categories[i].name;
        }
        return '';
    }

    ListModel {
        id: listModel
    }

    function visibleTodos() {
        if (root.selectedTab === '')
            return root.todos;
        return root.todos.filter(t => t.categoryId === root.selectedTab);
    }

    function parseTags(json) {
        try {
            var v = JSON.parse(json || '[]');
            return Array.isArray(v) ? v : [];
        } catch (e) {
            return [];
        }
    }

    function refresh() {
        listModel.clear();
        var shown = root.visibleTodos();
        for (var i = 0; i < shown.length; i++) {
            var t = shown[i];
            var tags = Array.isArray(t.tags) ? t.tags.slice() : (t.label ? [t.label] : []);
            listModel.append({
                realIndex: root.todos.indexOf(t),
                title: t.title || '',
                notes: t.notes || '',
                categoryId: t.categoryId || '',
                tagsJson: JSON.stringify(tags),
                done: !!t.done
            });
        }
    }

    function commit() {
        root.refresh();
        root.persist();
    }

    function utf8Bytes(s) {
        var bytes = [];
        for (var i = 0; i < s.length; i++) {
            var c = s.charCodeAt(i);
            if (c < 0x80) {
                bytes.push(c);
            } else if (c < 0x800) {
                bytes.push(0xc0 | (c >> 6), 0x80 | (c & 0x3f));
            } else if (c >= 0xd800 && c <= 0xdbff && i + 1 < s.length) {
                var lo = s.charCodeAt(i + 1);
                if (lo >= 0xdc00 && lo <= 0xdfff) {
                    var cp = 0x10000 + ((c - 0xd800) << 10) + (lo - 0xdc00);
                    bytes.push(0xf0 | (cp >> 18), 0x80 | ((cp >> 12) & 0x3f), 0x80 | ((cp >> 6) & 0x3f), 0x80 | (cp & 0x3f));
                    i++;
                } else {
                    bytes.push(0xe0 | (c >> 12), 0x80 | ((c >> 6) & 0x3f), 0x80 | (c & 0x3f));
                }
            } else {
                bytes.push(0xe0 | (c >> 12), 0x80 | ((c >> 6) & 0x3f), 0x80 | (c & 0x3f));
            }
        }
        return bytes;
    }

    function persist() {
        // Coalesce rapid commits: if a save is already running, just
        // record the newest state – onExited flushes it. Otherwise the
        // running=true retrigger is a no-op and the write is lost.
        root.pendingSave = JSON.stringify({ categories: root.categories, labels: root.labels, todos: root.todos });
        if (!saveProcess.running)
            root.runSave();
    }

    function runSave() {
        root.lastSaved = root.pendingSave;
        var b64 = Qt.btoa(root.utf8Bytes(root.lastSaved));
        saveProcess.command = ['sh', '-c', `mkdir -p '${root.storeDir}' && printf '%s' '${b64}' | base64 -d > '${root.storePath}'`];
        saveProcess.running = true;
    }

    function normalizeTodo(t) {
        return {
            id: t.id,
            title: t.title || '',
            notes: t.notes || '',
            categoryId: t.categoryId || '',
            tags: Array.isArray(t.tags) ? t.tags.filter(x => typeof x === 'string') : (t.label ? [t.label] : []),
            items: Array.isArray(t.items) ? t.items : [],
            done: !!t.done,
            created: t.created
        };
    }

    function migrateOld(parsed) {
        var cats = [{ id: 'general', name: 'General' }];
        var labs = {
            general: [
                { name: 'work', color: '#7aa2f7' },
                { name: 'personal', color: '#9ece6a' },
                { name: 'urgent', color: '#ff5555' },
                { name: 'idea', color: '#e0af68' }
            ]
        };
        var items = parsed.map(t => {
            var n = root.normalizeTodo(t);
            n.categoryId = 'general';
            return n;
        });
        return { categories: cats, labels: labs, todos: items };
    }

    // ---- detail draft ----

    function defaultCatForNew() {
        if (root.selectedTab !== '')
            return root.selectedTab;
        if (root.categories.length > 0)
            return root.categories[0].id;
        return '';
    }

    function openDetail(realIndex) {
        root.editingIndex = realIndex;
        if (realIndex >= 0 && realIndex < root.todos.length) {
            var t = root.todos[realIndex];
            titleField.text = t.title || '';
            notesArea.text = t.notes || '';
            root.detailCat = t.categoryId || '';
            root.detailLabels = Array.isArray(t.tags) ? t.tags.slice() : (t.label ? [t.label] : []);
            root.draftItems = (t.items || []).map(i => ({ text: i.text || '', done: !!i.done }));
        } else {
            titleField.text = '';
            notesArea.text = '';
            root.detailCat = root.defaultCatForNew();
            root.detailLabels = [];
            root.draftItems = [];
        }
        root.editingLabel = null;
        root.managingLabels = false;
        root.showingDetail = true;
    }

    function saveDetail() {
        var entry = {
            id: root.editingIndex >= 0 && root.editingIndex < root.todos.length ? root.todos[root.editingIndex].id : Date.now(),
            title: titleField.text,
            notes: notesArea.text,
            categoryId: root.detailCat,
            tags: root.detailLabels.slice(),
            items: root.draftItems.slice(),
            done: root.editingIndex >= 0 && root.editingIndex < root.todos.length ? !!root.todos[root.editingIndex].done : false,
            created: root.editingIndex >= 0 && root.editingIndex < root.todos.length ? root.todos[root.editingIndex].created : Date.now()
        };
        if (root.editingIndex >= 0 && root.editingIndex < root.todos.length) {
            var copy = root.todos.slice();
            copy[root.editingIndex] = entry;
            root.todos = copy;
        } else {
            root.todos = [entry].concat(root.todos);
        }
        root.showingDetail = false;
        root.commit();
    }

    function toggleDone(realIndex) {
        if (realIndex < 0 || realIndex >= root.todos.length)
            return;
        var copy = root.todos.slice();
        var t = copy[realIndex];
        copy[realIndex] = { id: t.id, title: t.title, notes: t.notes, categoryId: t.categoryId, tags: Array.isArray(t.tags) ? t.tags.slice() : [], items: t.items || [], done: !t.done, created: t.created };
        root.todos = copy;
        root.commit();
    }

    function toggleTag(name) {
        var cur = root.detailLabels.slice();
        var i = cur.indexOf(name);
        if (i >= 0)
            cur.splice(i, 1);
        else
            cur.push(name);
        root.detailLabels = cur;
    }

    function removeTodo(realIndex) {
        if (realIndex < 0 || realIndex >= root.todos.length)
            return;
        var copy = root.todos.slice();
        copy.splice(realIndex, 1);
        root.todos = copy;
        root.commit();
    }

    function submitSubItem() {
        var clean = subField.text.trim();
        if (clean === '')
            return;
        root.draftItems = root.draftItems.concat([{ text: clean, done: false }]);
        subField.text = '';
    }

    function toggleSubItem(i) {
        if (i < 0 || i >= root.draftItems.length)
            return;
        var copy = root.draftItems.slice();
        copy[i] = { text: copy[i].text, done: !copy[i].done };
        root.draftItems = copy;
    }

    function removeSubItem(i) {
        if (i < 0 || i >= root.draftItems.length)
            return;
        var copy = root.draftItems.slice();
        copy.splice(i, 1);
        root.draftItems = copy;
    }

    function subProgress() {
        if (root.draftItems.length === 0)
            return '';
        var d = root.draftItems.filter(x => x.done).length;
        return ` ${d}/${root.draftItems.length}`;
    }

    // ---- categories ----

    function addCategory(name) {
        var clean = name.trim();
        if (clean === '')
            return;
        var entry = { id: String(Date.now()), name: clean };
        root.categories = root.categories.concat([entry]);
        var labs = Object.assign({}, root.labels);
        labs[entry.id] = [];
        root.labels = labs;
        root.selectedTab = entry.id;
        root.commit();
    }

    function renameCategory(id, name) {
        var clean = name.trim();
        if (clean === '')
            return;
        root.categories = root.categories.map(c => c.id === id ? { id: c.id, name: clean } : c);
        root.commit();
    }

    function deleteCategory(id) {
        var remaining = root.categories.filter(c => c.id !== id);
        var fallback = remaining.length > 0 ? remaining[0].id : '';
        var moved = root.todos.map(t => {
            if (t.categoryId !== id)
                return t;
            return { id: t.id, title: t.title, notes: t.notes, categoryId: fallback, tags: [], items: t.items || [], done: !!t.done, created: t.created };
        });
        var labs = Object.assign({}, root.labels);
        delete labs[id];
        root.categories = remaining;
        root.labels = labs;
        root.todos = moved;
        if (root.selectedTab === id)
            root.selectedTab = '';
        root.commit();
    }

    function startAddCategory() {
        root.editingCat = 'new';
        root.catDraft = '';
    }

    function startRenameCategory(id) {
        root.editingCat = id;
        root.catDraft = root.catName(id);
    }

    function commitCatEdit() {
        if (root.editingCat === 'new')
            root.addCategory(root.catDraft);
        else if (root.editingCat !== null)
            root.renameCategory(root.editingCat, root.catDraft);
        root.editingCat = null;
    }

    function commitLabelEdit() {
        if (root.editingLabel === null || root.detailCat === '')
            return;
        if (root.editingLabel.name === '__new__')
            root.addLabel(root.detailCat, root.labelDraft, root.labelDraftColor);
        else
            root.renameLabel(root.detailCat, root.editingLabel.name, root.labelDraft, root.labelDraftColor);
        root.editingLabel = null;
    }

    // ---- labels (per category) ----

    function addLabel(catId, name, color) {
        var clean = name.trim();
        if (clean === '' || catId === '')
            return;
        var list = root.labelsFor(catId).slice();
        for (var i = 0; i < list.length; i++) {
            if (list[i].name === clean)
                return;
        }
        list.push({ name: clean, color: color });
        var labs = Object.assign({}, root.labels);
        labs[catId] = list;
        root.labels = labs;
        root.commit();
    }

    function renameLabel(catId, oldName, name, color) {
        var clean = name.trim();
        if (clean === '' || catId === '')
            return;
        var list = root.labelsFor(catId).map(l => l.name === oldName ? { name: clean, color: color } : l);
        var labs = Object.assign({}, root.labels);
        labs[catId] = list;
        root.labels = labs;
        var moved = root.todos.map(t => {
            if (t.categoryId === catId && Array.isArray(t.tags) && t.tags.indexOf(oldName) >= 0)
                return { id: t.id, title: t.title, notes: t.notes, categoryId: t.categoryId, tags: t.tags.map(x => x === oldName ? clean : x), items: t.items || [], done: !!t.done, created: t.created };
            return t;
        });
        root.todos = moved;
        if (root.detailCat === catId) {
            var dl = root.detailLabels.slice();
            var ri = dl.indexOf(oldName);
            if (ri >= 0)
                dl[ri] = clean;
            root.detailLabels = dl;
        }
        root.commit();
    }

    function deleteLabel(catId, name) {
        if (catId === '')
            return;
        var labs = Object.assign({}, root.labels);
        labs[catId] = root.labelsFor(catId).filter(l => l.name !== name);
        root.labels = labs;
        var moved = root.todos.map(t => {
            if (t.categoryId === catId && Array.isArray(t.tags) && t.tags.indexOf(name) >= 0)
                return { id: t.id, title: t.title, notes: t.notes, categoryId: t.categoryId, tags: t.tags.filter(x => x !== name), items: t.items || [], done: !!t.done, created: t.created };
            return t;
        });
        root.todos = moved;
        if (root.detailCat === catId)
            root.detailLabels = root.detailLabels.filter(x => x !== name);
        root.commit();
    }

    Process {
        id: loadProcess
        running: true
        command: ['sh', '-c', `mkdir -p '${root.storeDir}' && cat '${root.storePath}' 2>/dev/null || echo '{"categories":[],"labels":{},"todos":[]}'`]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(text);
                    if (Array.isArray(parsed)) {
                        var m = root.migrateOld(parsed);
                        root.categories = m.categories;
                        root.labels = m.labels;
                        root.todos = m.todos;
                    } else {
                        root.categories = Array.isArray(parsed.categories) ? parsed.categories : [];
                        root.labels = (parsed.labels && typeof parsed.labels === 'object') ? parsed.labels : {};
                        root.todos = Array.isArray(parsed.todos) ? parsed.todos.map(t => root.normalizeTodo(t)) : [];
                    }
                } catch (e) {
                    root.categories = [];
                    root.labels = {};
                    root.todos = [];
                }
                root.refresh();
            }
        }
    }

    property string pendingSave: ''
    property string lastSaved: ''

    Process {
        id: saveProcess
        running: false

        onExited: {
            if (root.pendingSave !== root.lastSaved)
                root.runSave();
        }
    }

    ColumnLayout {
        id: listPage
        anchors.fill: parent
        anchors.margins: Config.constants.spacing
        spacing: Config.constants.spacing / 2
        visible: opacity > 0.01
        opacity: !root.showingDetail ? 1 : 0
        scale: !root.showingDetail ? 1 : 0.96
        transformOrigin: Item.Top

        Behavior on opacity {
            Anim {}
        }
        Behavior on scale {
            Anim {}
        }

        RowLayout {
            Layout.fillWidth: true

            BackButton {
                text: 'Todos'
                Layout.fillWidth: true
            }

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                onClicked: root.openDetail(-1)

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    Text {
                        anchors.centerIn: parent
                        text: '+'
                        font.pixelSize: 16
                        font.bold: true
                        color: Config.colors.foreground
                    }
                }
            }
        }

        Flickable {
            id: tabsFlick
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            contentWidth: tabsRow.implicitWidth
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            visible: root.editingCat === null

            Row {
                id: tabsRow
                width: Math.max(tabsFlick.width, implicitWidth)
                height: 28
                spacing: 8

                ShrinkButton {
                    width: allTabText.implicitWidth + 20
                    height: 28

                    onClicked: {
                        root.selectedTab = '';
                        root.refresh();
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: root.selectedTab === '' ? Config.colors.secondaryDark : 'transparent'
                        border.color: Config.colors.secondaryDark
                        border.width: root.selectedTab === '' ? 0 : 1

                        Text {
                            id: allTabText
                            anchors.centerIn: parent
                            text: 'All'
                            font.pixelSize: 12
                            font.bold: root.selectedTab === ''
                            color: root.selectedTab === '' ? Config.colors.foreground : Config.colors.secondaryLight
                        }
                    }
                }

                Repeater {
                    model: root.categories

                    delegate: ShrinkButton {
                        required property var modelData

                        // Guarded: during model swaps, dying delegates can
                        // re-evaluate here with modelData already detached.
                        readonly property bool isSel: modelData ? root.selectedTab === modelData.id : false

                        width: tabText.implicitWidth + 20
                        height: 28

                        onClicked: {
                            if (modelData.id === root.selectedTab) {
                                root.startRenameCategory(modelData.id);
                            } else {
                                root.selectedTab = modelData.id;
                                root.refresh();
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: isSel ? Config.colors.secondaryDark : 'transparent'
                            border.color: Config.colors.secondaryDark
                            border.width: isSel ? 0 : 1

                            Text {
                                id: tabText
                                anchors.centerIn: parent
                                text: modelData ? modelData.name : ''
                                font.pixelSize: 12
                                font.bold: isSel
                                color: isSel ? Config.colors.foreground : Config.colors.secondaryLight
                            }
                        }
                    }
                }

                ShrinkButton {
                    width: 28
                    height: 28

                    onClicked: root.startAddCategory()

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: 'transparent'
                        border.color: Config.colors.secondaryDark
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: '+'
                            font.pixelSize: 14
                            font.bold: true
                            color: Config.colors.secondaryLight
                        }
                    }
                }
            }
        }

        RowLayout {
            id: catEditRow
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: Config.constants.spacing / 2
            visible: root.editingCat !== null

            onVisibleChanged: {
                if (visible)
                    catField.forceActiveFocus();
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Config.colors.base
                border.color: Config.colors.secondaryDark
                border.width: 1
                radius: 6

                TextField {
                    id: catField
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: TextInput.AlignVCenter
                    placeholderText: 'Category name'
                    placeholderTextColor: Config.colors.secondaryLight
                    font.family: 'Geist'
                    font.pixelSize: 13
                    color: Config.colors.foreground
                    text: root.catDraft
                    onTextChanged: root.catDraft = text
                    onAccepted: root.commitCatEdit()

                    background: Rectangle {
                        color: 'transparent'
                    }
                }
            }

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                onClicked: root.commitCatEdit()

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    Text {
                        anchors.centerIn: parent
                        text: '✓'
                        font.pixelSize: 13
                        font.bold: true
                        color: Config.colors.foreground
                    }
                }
            }

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                visible: root.editingCat !== null && root.editingCat !== 'new'

                onClicked: {
                    root.deleteCategory(root.editingCat);
                    root.editingCat = null;
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    CustomIcon {
                        iconName: 'trash'
                        anchors.centerIn: parent
                    }
                }
            }

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                visible: root.editingCat === 'new'

                onClicked: root.editingCat = null

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    CustomIcon {
                        iconName: 'x'
                        anchors.centerIn: parent
                    }
                }
            }
        }

        ListView {
            id: todosList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.constants.spacing / 2
            clip: true

            model: listModel

            delegate: Rectangle {
                id: listItem
                required property var model
                clip: true

                width: todosList.width
                height: 60
                radius: 8
                color: Config.colors.base
                border.color: Config.colors.secondaryDark
                border.width: 1

                Behavior on color {
                    ColorAnim {}
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openDetail(listItem.model.realIndex)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Config.constants.spacing / 2
                    spacing: Config.constants.spacing / 2

                    ShrinkButton {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.maximumWidth: 20
                        Layout.maximumHeight: 20

                        onClicked: root.toggleDone(listItem.model.realIndex)

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: listItem.model.done ? Config.colors.foreground : 'transparent'
                            border.color: Config.colors.secondaryDark
                            border.width: 1
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: listItem.model.title || '(No title)'
                            font.family: 'Geist'
                            font.pixelSize: 14
                            font.strikeout: listItem.model.done
                            elide: Text.ElideRight
                            color: listItem.model.done ? Config.colors.secondaryLight : Config.colors.foreground
                        }

                        Row {
                            visible: (listItem.model.tagsJson || '[]') !== '[]'
                            width: parent.width
                            height: 18
                            spacing: 4
                            clip: true

                            Repeater {
                                model: root.parseTags(listItem.model.tagsJson)

                                delegate: Rectangle {
                                    required property var modelData

                                    width: tagText.implicitWidth + 12
                                    height: 18
                                    radius: 4
                                    color: root.labelColor(listItem.model.categoryId, modelData)

                                    Text {
                                        id: tagText
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: Config.colors.base
                                    }
                                }
                            }
                        }
                    }

                    ShrinkButton {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.maximumWidth: 20
                        Layout.maximumHeight: 20

                        onClicked: root.removeTodo(listItem.model.realIndex)

                        CustomIcon {
                            iconName: 'x'
                            anchors.centerIn: parent
                        }
                    }
                }

                HoverHandler {
                    id: itemHover
                    onHoveredChanged: () => {
                        if (hovered) {
                            listItem.color = Config.colors.secondaryDark;
                        } else {
                            listItem.color = Config.colors.base;
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !root.showingDetail && todosList.count === 0
        text: root.selectedTab === '' ? 'No todos yet' : 'Nothing here yet'
        font.pixelSize: 13
        color: Config.colors.secondaryLight
    }

    ColumnLayout {
        id: detailPage
        anchors.fill: parent
        anchors.margins: Config.constants.spacing
        spacing: Config.constants.spacing / 2
        visible: opacity > 0.01
        opacity: root.showingDetail ? 1 : 0
        scale: root.showingDetail ? 1 : 0.96
        transformOrigin: Item.Top

        Behavior on opacity {
            Anim {}
        }
        Behavior on scale {
            Anim {}
        }

        RowLayout {
            Layout.fillWidth: true

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 80
                Layout.preferredHeight: Config.constants.spacing

                onClicked: root.showingDetail = false

                CustomIcon {
                    iconName: 'left'
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                BaseText {
                    text: 'Back'
                    anchors.left: parent.left
                    anchors.leftMargin: Config.constants.iconSize + 5
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                Layout.fillWidth: true
            }

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 70
                Layout.preferredHeight: 28

                onClicked: root.saveDetail()

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    Text {
                        anchors.centerIn: parent
                        text: 'Save'
                        font.pixelSize: 12
                        color: Config.colors.foreground
                    }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: detailCol.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            ColumnLayout {
                id: detailCol
                width: parent.width
                spacing: Config.constants.spacing / 2

        Text {
            text: 'Category'
            font.pixelSize: 13
            color: Config.colors.secondaryLight
            visible: root.categories.length > 0
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8
            visible: root.categories.length > 0

            Repeater {
                model: root.categories

                delegate: ShrinkButton {
                    required property var modelData

                    // Guarded: delegates can briefly evaluate with
                    // modelData detached while the model swaps.
                    readonly property bool isSel: modelData ? root.detailCat === modelData.id : false

                    width: catChoiceText.implicitWidth + 16
                    height: 24

                    onClicked: {
                        root.detailCat = modelData.id;
                        root.detailLabels = [];
                        root.managingLabels = false;
                        root.editingLabel = null;
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: isSel ? Config.colors.secondaryDark : 'transparent'
                        border.color: Config.colors.secondaryDark
                        border.width: 1

                        Text {
                            id: catChoiceText
                            anchors.centerIn: parent
                            text: modelData ? modelData.name : ''
                            font.pixelSize: 12
                            color: isSel ? Config.colors.foreground : Config.colors.secondaryLight
                        }
                    }
                }
            }
        }

        Text {
            text: 'Title'
            font.pixelSize: 13
            color: Config.colors.secondaryLight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Config.colors.base
            border.color: Config.colors.secondaryDark
            border.width: 1
            radius: 8

            TextField {
                id: titleField
                anchors.fill: parent
                anchors.leftMargin: Config.constants.spacing / 2
                anchors.rightMargin: Config.constants.spacing / 2
                verticalAlignment: TextInput.AlignVCenter
                placeholderText: 'Title'
                placeholderTextColor: Config.colors.secondaryLight
                font.family: 'Geist'
                font.pixelSize: 14
                color: Config.colors.foreground

                background: Rectangle {
                    color: 'transparent'
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.constants.spacing / 2
            visible: root.detailCat !== ''

            Text {
                text: 'Labels'
                font.pixelSize: 13
                color: Config.colors.secondaryLight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                Layout.maximumWidth: 22
                Layout.maximumHeight: 22

                onClicked: {
                    root.managingLabels = !root.managingLabels;
                    root.editingLabel = null;
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: root.managingLabels ? Config.colors.secondaryDark : 'transparent'
                    border.color: Config.colors.secondaryDark
                    border.width: 1

                    CustomIcon {
                        iconName: 'tools'
                        anchors.centerIn: parent
                    }
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8
            visible: root.detailCat !== '' && root.editingLabel === null

            Repeater {
                model: root.labelsFor(root.detailCat)

                delegate: ShrinkButton {
                    required property var modelData

                    // Guarded: delegates can briefly evaluate with
                    // modelData detached while the model swaps.
                    readonly property bool isSel: modelData ? root.detailLabels.indexOf(modelData.name) >= 0 : false
                    readonly property string chipColor: modelData ? modelData.color : 'transparent'
                    readonly property string chipName: modelData ? modelData.name : ''

                    width: labelChoiceText.implicitWidth + 16
                    height: 24

                    onClicked: {
                        if (root.managingLabels) {
                            root.editingLabel = { name: chipName };
                            root.labelDraft = chipName;
                            root.labelDraftColor = chipColor;
                        } else {
                            root.toggleTag(chipName);
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: isSel ? chipColor : 'transparent'
                        border.color: chipColor
                        border.width: 1

                        Text {
                            id: labelChoiceText
                            anchors.centerIn: parent
                            text: chipName
                            font.pixelSize: 12
                            color: isSel ? Config.colors.base : chipColor
                        }
                    }
                }
            }

            ShrinkButton {
                width: 52
                height: 24

                onClicked: {
                    root.editingLabel = { name: '__new__' };
                    root.labelDraft = '';
                    root.labelDraftColor = root.colorDots[0];
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: 'transparent'
                    border.color: Config.colors.secondaryDark
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: '+ Add'
                        font.pixelSize: 12
                        color: Config.colors.secondaryLight
                    }
                }
            }
        }

        ColumnLayout {
            id: labelEditBox
            Layout.fillWidth: true
            spacing: Config.constants.spacing / 2
            visible: root.detailCat !== '' && root.editingLabel !== null

            onVisibleChanged: {
                if (visible)
                    labelField.forceActiveFocus();
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Config.constants.spacing / 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: Config.colors.base
                    border.color: Config.colors.secondaryDark
                    border.width: 1
                    radius: 6

                    TextField {
                        id: labelField
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        placeholderText: 'Label name'
                        placeholderTextColor: Config.colors.secondaryLight
                        font.family: 'Geist'
                        font.pixelSize: 13
                        color: Config.colors.foreground
                        text: root.labelDraft
                        onTextChanged: root.labelDraft = text
                        onAccepted: root.commitLabelEdit()

                        background: Rectangle {
                            color: 'transparent'
                        }
                    }
                }

                ShrinkButton {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28

                    onClicked: root.commitLabelEdit()

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Config.colors.secondaryDark

                        Text {
                            anchors.centerIn: parent
                            text: '✓'
                            font.pixelSize: 13
                            font.bold: true
                            color: Config.colors.foreground
                        }
                    }
                }

                ShrinkButton {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    visible: root.editingLabel !== null && root.editingLabel.name !== '__new__'

                    onClicked: {
                        root.deleteLabel(root.detailCat, root.editingLabel.name);
                        root.editingLabel = null;
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Config.colors.secondaryDark

                        CustomIcon {
                            iconName: 'trash'
                            anchors.centerIn: parent
                        }
                    }
                }

                ShrinkButton {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    visible: root.editingLabel !== null && root.editingLabel.name === '__new__'

                    onClicked: root.editingLabel = null

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Config.colors.secondaryDark

                        CustomIcon {
                            iconName: 'x'
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            Row {
                spacing: 8

                Repeater {
                    model: root.colorDots

                    delegate: ShrinkButton {
                        required property var modelData

                        width: 20
                        height: 20

                        onClicked: root.labelDraftColor = modelData

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: modelData
                            border.color: root.labelDraftColor === modelData ? Config.colors.foreground : 'transparent'
                            border.width: 2
                        }
                    }
                }
            }
        }

        Text {
            text: 'Checklist' + root.subProgress()
            font.pixelSize: 13
            color: Config.colors.secondaryLight
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.constants.spacing / 2

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: Config.colors.base
                border.color: Config.colors.secondaryDark
                border.width: 1
                radius: 6

                TextField {
                    id: subField
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: TextInput.AlignVCenter
                    placeholderText: 'Add item...'
                    placeholderTextColor: Config.colors.secondaryLight
                    font.family: 'Geist'
                    font.pixelSize: 13
                    color: Config.colors.foreground
                    onAccepted: root.submitSubItem()

                    background: Rectangle {
                        color: 'transparent'
                    }
                }
            }

            ShrinkButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                onClicked: root.submitSubItem()

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    Text {
                        anchors.centerIn: parent
                        text: '+'
                        font.pixelSize: 14
                        font.bold: true
                        color: Config.colors.foreground
                    }
                }
            }
        }

        ListView {
            id: subList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(subList.contentHeight, 160)
            spacing: 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            model: root.draftItems

            delegate: Rectangle {
                required property var modelData
                required property int index

                width: subList.width
                height: Math.max(34, subText.implicitHeight + 16)
                radius: 6
                color: Config.colors.base
                border.color: Config.colors.secondaryDark
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    ShrinkButton {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        Layout.maximumWidth: 18
                        Layout.maximumHeight: 18

                        onClicked: root.toggleSubItem(index)

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: (modelData && modelData.done) ? Config.colors.foreground : 'transparent'
                            border.color: Config.colors.secondaryDark
                            border.width: 1
                        }
                    }

                    Text {
                        id: subText
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: modelData ? modelData.text : ''
                        font.family: 'Geist'
                        font.pixelSize: 13
                        font.strikeout: modelData && modelData.done
                        wrapMode: Text.WordWrap
                        color: (modelData && modelData.done) ? Config.colors.secondaryLight : Config.colors.foreground
                    }

                    ShrinkButton {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        Layout.maximumWidth: 18
                        Layout.maximumHeight: 18

                        onClicked: root.removeSubItem(index)

                        CustomIcon {
                            iconName: 'x'
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }

        Text {
            visible: root.draftItems.length === 0
            text: 'No items yet'
            font.pixelSize: 12
            font.italic: true
            color: Config.colors.secondaryLight
        }

        Text {
            text: 'Notes'
            font.pixelSize: 13
            color: Config.colors.secondaryLight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: Config.colors.base
            border.color: Config.colors.secondaryDark
            border.width: 1
            radius: 8
            clip: true

            TextArea {
                id: notesArea
                anchors.fill: parent
                anchors.margins: Config.constants.spacing / 2
                wrapMode: TextArea.Wrap
                placeholderText: 'Notes...'
                placeholderTextColor: Config.colors.secondaryLight
                font.family: 'Geist'
                font.pixelSize: 13
                color: Config.colors.foreground

                background: Rectangle {
                    color: 'transparent'
                }
            }
        }
            }
        }
    }
}
